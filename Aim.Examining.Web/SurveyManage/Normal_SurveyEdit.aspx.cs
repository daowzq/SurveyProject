using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Normal_SurveyEdit : BaseListPage
    {
        string SurveyId = string.Empty;
        SurveyQuestion ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get<string>("id") + "";

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    DoSave();
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SurveyQuestion>();
                    ent.DoDelete();
                    return;
                default:
                    if (RequestActionString == "GetId")
                    {
                        QuestionItem qItem = new QuestionItem();
                        qItem.SubItemId = Guid.NewGuid().ToString();
                        qItem.DoCreate();
                        this.PageState.Add("SubItemId", qItem.Id + "|" + qItem.SubItemId);
                    }
                    else if (RequestActionString == "Close")
                    {
                        DoClose();
                    }
                    else if (RequestActionString == "ExpandTempLate")
                    {
                        ExpandTempLate();
                    }
                    else if (RequestActionString == "GetTypeInfo")
                    {
                        GetAddFiles();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }
        }
        private void DoSelect()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                ent = SurveyQuestion.Find(SurveyId);
                this.SetFormData(ent);

                string QsItem = @"select * from  FL_Culture..QuestionItem where SurveyId='{0}' order by SortIndex ";
                QsItem = string.Format(QsItem, SurveyId);

                if (string.IsNullOrEmpty(ent.TypeCode))
                {
                    string code = "HR_W" + DateTime.Now.ToString("yyyMMddHHmm");
                    this.SetFormData(new { TypeCode = code });
                }
                this.PageState.Add("DataList", DataHelper.QueryDictList(QsItem));
            }
            else
            {
                string code = "GDWJ" + DateTime.Now.Year + DateTime.Now.Month + DateTime.Now.Day + DateTime.Now.Minute;
                this.SetFormData(new { TypeCode = code });
            }

            GetTemplate();
            GetTypeEnum();
        }

        /// <summary>
        /// 获取问卷类型
        /// </summary>
        private void GetTypeEnum()
        {
            string SQL = string.Empty;
            CommPowerSplit ps = new CommPowerSplit();
            if (ps.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName))  //admin or surveyRole 
            {
                SQL = @"select '' As Id, '请选择...' As TypeName
                            union all 
                            select Id,TypeName from FL_Culture..SurveyType";
                this.PageState.Add("TypeEnum", DataHelper.QueryDict(SQL));
            }
            else
            {
                //                SQL = @" select '' As Id, '请选择...' As TypeName
                //                            union all 
                //                            select Id,TypeName from FL_Culture..SurveyType
                //	                        where ( EnabledState='1' or (EnabledState='1' and (AccessPower is null or len(AccessPower)=0))) 
                //                            and Id in (select distinct TypeId from FL_Culture..View_SuryTypeUsr where UserID='{0}') ";
                SQL = @" select '' As Id, '请选择...' As TypeName
                            union all 
                            select Id,TypeName from FL_Culture..SurveyType
	                        where ( EnabledState='1') 
                            and Id in (select distinct TypeId from FL_Culture..View_SuryTypeUsr where UserID='{0}') ";
                SQL = string.Format(SQL, UserInfo.UserID);
                this.PageState.Add("TypeEnum", DataHelper.QueryDict(SQL));
            }
        }

        /// <summary>
        /// 获取问卷模板
        /// </summary>
        private void GetTemplate()
        {
            string SQL = string.Empty;
            CommPowerSplit ps = new CommPowerSplit();
            if (ps.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName))  //admin or surveyRole 
            {
                SQL = @"select Id,SurveyTitile As Name from FL_Culture..SurveyQuestion
                             where IsFixed='1' and State='1'";
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                PageState.Add("tplEnum", DataHelper.QueryDict(SQL));
            }
            else
            {
                var Ent = SysUser.Find(UserInfo.UserID);
                SQL = @" select Id,SurveyTitile As Name from FL_Culture..SurveyQuestion
                             where IsFixed='1' and State='1' and CompanyId='{0}' Or charindex('{0}',GrantCorpId ) >0 ";
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                SQL = string.Format(SQL, Ent.Pk_corp);
                PageState.Add("tplEnum", DataHelper.QueryDict(SQL));
            }
        }

        /// <summary>
        /// 导入模板
        /// </summary>
        private void ExpandTempLate()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string TemplateId = RequestData.Get("TemplateId") + "";

            SurveyQuestion Ent = SurveyQuestion.Find(SurveyId);
            Ent.TemplateId = TemplateId;
            Ent.DoUpdate();

            int SortIndex = 1;
            string sql = "select count(1) T from FL_Culture..QuestionItem  where SurveyId='{0}' ";
            sql = string.Format(sql, SurveyId);
            object obj = DataHelper.QueryValue(sql);
            if (obj != null)
            {
                SortIndex += int.Parse(obj.ToString());
            }

            //合并模板
            var ItemEnts = QuestionItem.FindAllByProperties(0, QuestionItem.Prop_SortIndex, QuestionItem.Prop_SurveyId, TemplateId);
            var SubItemEnts = QuestionAnswerItem.FindAllByProperties(QuestionAnswerItem.Prop_SurveyId, TemplateId);

            foreach (var ent in ItemEnts)
            {
                QuestionItem Item = new QuestionItem();
                Item = ent;
                Item.SurveyId = SurveyId;
                Item.SortIndex = SortIndex;
                Item.Ext2 = "imp"; //导入标志 imp
                Item.DoCreate();
                SortIndex++;
            }
            foreach (var subEnt in SubItemEnts)
            {
                QuestionAnswerItem subItem = new QuestionAnswerItem();
                subItem = subEnt;
                subItem.SurveyId = SurveyId;
                subItem.Ext1 = "imp";
                subItem.DoCreate();
            }
            IList<QuestionItem> items = QuestionItem.FindAll(Expression.Sql(" SurveyId='" + SurveyId + "' order by SortIndex  "));
            this.PageState.Add("QItem", items);
        }

        /// <summary>
        /// 
        /// </summary>
        private void DoSave()
        {
            string SurveyTypeId = RequestData.Get("SurveyTypeId") + "";
            string SurveyTypeName = RequestData.Get("SurveyTypeName") + "";
            ent = this.GetMergedData<SurveyQuestion>();
            ent.SurveyTypeId = SurveyTypeId;
            ent.SurveyTypeName = SurveyTypeName;
            ent.State = "1";     //1 启用
            ent.IsFixed = "2";   //2 固定问卷
            ent.DoUpdate();

            if (!string.IsNullOrEmpty(SurveyId))
            {
                IList<string> DataList = RequestData.GetList<string>("data");
                if (DataList.Count > 0)
                {
                    IList<QuestionItem> qiEnts = DataList.Select(tent => JsonHelper.GetObject<QuestionItem>(tent) as QuestionItem).ToArray();
                    foreach (QuestionItem itms in qiEnts)
                    {
                        itms.Content = HttpUtility.UrlDecode(itms.Content);
                        itms.DoSave();
                    }
                }
            }
        }

        /// <summary>
        /// 删除操作
        /// </summary>
        private void DoClose()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                SurveyQuestion Ent = SurveyQuestion.Find(SurveyId);
                if (string.IsNullOrEmpty(Ent.SurveyTitile))
                {
                    string SQL = @"delete from  FL_Culture..QuestionAnswerItem  where Id in
                                    (
                                      select id from  FL_Culture..QuestionAnswerItem As A  where not exists (
	                                    select * from FL_Culture..QuestionItem  As B where B.SubItemId=A.QuestionItemId
                                      )    
                                    ) and SurveyId='{0}' ";
                    SQL += " delete from FL_Culture..QuestionItem where SurveyId='{0}' ";
                    SQL = string.Format(SQL, SurveyId);
                    DataHelper.ExecSql(SQL);
                    Ent.DoDelete();
                }

            }
        }

        /// <summary>
        /// 获取附件等相关信息
        /// </summary>
        private void GetAddFiles()
        {
            string typeId = RequestData.Get("typeId") + "";
            string SQL = @"select AddFilesId,AddFilesName,WorkFlowId,WorkFlowName from  FL_Culture..SurveyType where Id='{0}'";
            SQL = string.Format(SQL, typeId);
            this.PageState.Add("TypeInfo", DataHelper.QueryDictList(SQL));
        }
    }
}
