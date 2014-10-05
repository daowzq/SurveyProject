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
using System.Data;
using System.Text;
using NHibernate.Criterion;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyQuestionWizard : BaseListPage
    {

        string op = string.Empty;
        string id = string.Empty;
        public string guid = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get("id") + "";
            switch (RequestActionString)
            {
                case "SurveyOneSave":
                    SurveyOneSave();
                    break;
                case "Close":
                    DoClose();
                    break;
                case "ImpTpl":
                    ImpTpl();
                    break;
                case "EffectiveCount":
                    EffectiveCount();
                    break;
                case "ReSetImgIds":
                    ReSetImgIds();
                    break;
                case "havaQuestion":
                    CheckHavaQuestion();
                    break;
                default:
                    DoSelect();
                    break;
            }

        }

        // 
        private void CheckHavaQuestion()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string sql = @"select count(*) from  FL_Culture..SurveyFinallyUsr where SurveyId='{0}' ";
            sql = string.Format(sql, SurveyId);
            int count = DataHelper.QueryValue<int>(sql);
            if (count > 0)
                this.PageState.Add("State", "1");
            else
                this.PageState.Add("State", "0");
        }


        //设置问卷有效数量
        private void EffectiveCount()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string EffectiveCount = RequestData.Get("EffectiveCount") + "";
            if (!string.IsNullOrEmpty(SurveyId))
            {
                if (!string.IsNullOrEmpty(EffectiveCount))
                {
                    var Ent = SurveyQuestion.Find(SurveyId);
                    Ent.EffectiveCount = int.Parse(EffectiveCount);
                    Ent.DoUpdate();
                }
            }
        }

        //导入模板
        private void ImpTpl()
        {
            if (!string.IsNullOrEmpty(id))
            {
                string TemplateId = RequestData.Get("TemplateId") + "";
                SurveyQuestion TemplateEnt = SurveyQuestion.TryFind(TemplateId); //问卷模板
                SurveyQuestion Ent = SurveyQuestion.Find(id);

                if (string.IsNullOrEmpty(Ent.Description) && TemplateEnt != null) //描述
                {
                    Ent.Description = TemplateEnt.Description;
                }
                Ent.TemplateId = TemplateId;
                Ent.DoUpdate();

                string SurveyId = id;
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

                foreach (var ents in ItemEnts)
                {
                    QuestionItem Item = new QuestionItem();
                    Item = ents;
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
        }

        private void ReSetImgIds()
        {
            string SubItemId = RequestData.Get("SubItemId") + "";
            var Ent = QuestionItem.FindFirstByProperties(QuestionItem.Prop_SubItemId, SubItemId);
            this.PageState.Add("ImgIds", Ent.ImgIds + "[]" + Ent.Ext1);

        }
        //string sql = @" select * from FL_Culture..QuestionAnswerItem where SurveyId='{0}' and QuestionItemId='{1}' order by SortIndex ";
        //      sql = string.Format(sql, SurveyId, QuestionItemId);
        //      this.PageState.Add("DataList", DataHelper.QueryDictList(sql));


        /// <summary>
        /// 问卷保存
        /// </summary>
        private void SurveyOneSave()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string SurveyTypeId = RequestData.Get("SurveyTypeId") + "";
            string SurveyTypeName = RequestData.Get("SurveyTypeName") + "";
            string NoticeWay = RequestData.Get("NoticeWay") + "";
            string TypeCode = RequestData.Get("TypeCode") + "";
            string SurveyTitile = RequestData.Get("SurveyTitile") + "";
            string Description = RequestData.Get("Description") + "";
            string StartTime = RequestData.Get("StartTime") + "";
            string EndTime = RequestData.Get("EndTime") + "";
            string CompanyName = RequestData.Get("CompanyName") + "";
            string CompanyId = RequestData.Get("CompanyId") + "";
            string DeptName = RequestData.Get("DeptName") + "";
            string DeptId = RequestData.Get("DeptId") + "";
            string AddFilesName = RequestData.Get("AddFilesName") + "";
            string Score = RequestData.Get("Score") + "";
            string SetTimeout = RequestData.Get("SetTimeout") + "";
            string ReaderObj = RequestData.Get("ReaderObj") + "";

            string RemindWay = RequestData.Get("RemindWay") + "";   //提醒方式
            string RecyleDay = RequestData.Get("RecyleDay") + "";   //提醒天数
            string TimePoint = RequestData.Get("TimePoint") + "";   //提醒时间点

            SurveyQuestion ent = SurveyQuestion.Find(SurveyId);
            if (string.IsNullOrEmpty(ent.State)) ent.State = "0";  //"0" 表示创建
            ent.SurveyTypeId = SurveyTypeId;
            ent.SurveyTypeName = SurveyTypeName;
            ent.NoticeWay = NoticeWay;
            ent.TypeCode = TypeCode;
            ent.SurveyTitile = SurveyTitile;
            ent.Description = Description;
            if (!string.IsNullOrEmpty(StartTime)) ent.StartTime = DateTime.Parse(StartTime);

            if (!string.IsNullOrEmpty(EndTime))
            {
                ent.EndTime = DateTime.Parse(EndTime);
            }

            if (!string.IsNullOrEmpty(TimePoint)) ent.TimePoint = TimePoint;
            if (!string.IsNullOrEmpty(RecyleDay)) ent.RecyleDay = int.Parse(RecyleDay);

            if (!string.IsNullOrEmpty(CompanyName)) ent.CompanyName = CompanyName;
            if (!string.IsNullOrEmpty(CompanyId)) ent.CompanyId = CompanyId;

            ent.DeptName = DeptName;
            ent.DeptId = DeptId;
            ent.AddFilesName = AddFilesName;
            ent.RemindWay = RemindWay;

            if (!string.IsNullOrEmpty(Score)) ent.Score = int.Parse(Score);
            if (!string.IsNullOrEmpty(SetTimeout)) ent.SetTimeout = DateTime.Parse(SetTimeout);
            ent.ReaderObj = ReaderObj;

            ent.DoUpdate();

            string sql = " delete from  FL_Culture..SurveyReaderObj where SurveyId='{0}' ;";
            sql = string.Format(sql, SurveyId);
            DataHelper.ExecSql(sql);

            string ReadObj = ent.ReaderObj;
            if (ReadObj.Contains("joiner")) ReadObj = "joiner";
            else ReadObj = "sender";

            SurveyReaderObj ReadEnt = new SurveyReaderObj();
            ReadEnt.SurveyId = SurveyId;
            ReadEnt.ReaderWay = ReadObj;
            ReadEnt.DoCreate();
        }

        /// <summary>
        /// 默认查询
        /// </summary>
        private void DoSelect()
        {
            GetEduEnum();
            GetTplEnum();
            SurveyTypeEnum();
            personTypeEnum();

            SurveyQuestion ent = SurveyQuestion.Find(id);
            if (string.IsNullOrEmpty(ent.TypeCode))
            {
                ent.TypeCode = GetCode(); //设置问卷编号
            }
            if (string.IsNullOrEmpty(ent.CompanyId))
            {
                //公司与部门
                string SQL = @"select A.UserID,A.WorkNo,A.Name,B.GroupID as CropId,B.Name as CropName,
                                    C.GroupID as DeptId,C.Name as DeptName
                             from FL_PortalHR..SysUser As A
	                            left join FL_PortalHR..SysGroup As B
                              on  A.Pk_corp=B.GroupID
	                            left join  FL_PortalHR..SysGroup As C
                              on A.Pk_deptdoc=C.GroupID
                            where UserID='{0}' ";

                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                SQL = string.Format(SQL, UserInfo.UserID);
                DataTable dt = DataHelper.QueryDataTable(SQL);
                ent.CompanyId = dt.Rows[0]["CropId"].ToString();
                ent.CompanyName = dt.Rows[0]["CropName"].ToString();

                ent.DeptId = dt.Rows[0]["DeptId"].ToString();
                ent.DeptName = dt.Rows[0]["DeptName"].ToString();
            }

            //问题项列表
            string sql = "select * from FL_Culture..QuestionItem where SurveyId='{0}' order by SortIndex ";
            sql = string.Format(sql, id);
            var Ents = DataHelper.QueryDictList(sql);
            if (Ents.Count > 0)
            {
                this.PageState.Add("DataList_QItem", DataHelper.QueryDictList(sql));
            }

            this.SetFormData(ent);

            //调查对象
            sql = "select * from FL_Culture..SurveyedObj where SurveyId='{0}'  ";
            sql = string.Format(sql, id);
            this.PageState.Add("SurveyedObj", DataHelper.QueryDataTable(sql));

        }

        /// <summary>
        /// 问卷类型枚举
        /// </summary>
        private void SurveyTypeEnum()
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

        // //问卷模板
        private void GetTplEnum()
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
        //调查问卷编号
        private string GetCode()
        {
            return "HR_W" + DateTime.Now.ToString("yyyMMddHHmm");
        }
        //学历枚举
        private void GetEduEnum()
        {
            this.PageState.Add("MajorEnum", SysEnumeration.GetEnumDict("EduMajor"));
        }

        //人员类别
        private void personTypeEnum()
        {
            //string sql = @"select pk_fld_rylb Value,psnclassname Name
            //  from HR_OA_MiddleDB..fld_rylb where patIndex('%'+psnclassname+'%','正式工临时工实习生其他人员' )>0 ";
            string sql = @"select pk_fld_rylb Value,psnclassname Name
                            from HR_OA_MiddleDB..fld_rylb where patIndex('%'+psnclassname+'%','正式工临时工实习生其他人员' )>0 ";
            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            this.PageState.Add("personTypeEnum", DataHelper.QueryDictList(sql));
        }

        /// <summary>
        ///默认选中的公司Id
        /// </summary>
        public string nodeId
        {
            get
            {
                //问卷角色或管理员
                CommPowerSplit Role = new CommPowerSplit();
                bool bl = Role.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName);
                if (bl)
                {
                    string SQL = "select top 1 GroupID from FL_PortalHR..sysgroup where type='2' and Name='飞力集团' ";
                    SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                    object obj = DataHelper.QueryValue(SQL);
                    return obj.ToString();
                }
                else
                {
                    CommPowerSplit ps = new CommPowerSplit();
                    string corps = ps.GetRoleCorps(UserInfo.UserID); //角色所在公司id

                    StringBuilder strb = new StringBuilder();
                    if (Session["CompanyId"] != null)           //判断公司登陆
                    {
                        strb.Append(Session["CompanyId"].ToString());

                    }
                    else
                    {
                        string sql = @"select B.GroupID, B.Name from sysuser As A 
	                               left join Sysgroup As B
                                        on A.Pk_corp=B.GroupID
	                               where A.UserID='{0}' ";
                        sql = string.Format(sql, UserInfo.UserID);
                        DataTable dt = DataHelper.QueryDataTable(sql);

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            if (i > 0) strb.Append(",");
                            strb.Append(dt.Rows[i]["GroupID"].ToString());
                        }
                    }

                    if (strb.Length > 0)
                        strb.Append("," + corps);
                    else
                        strb.Append(corps);

                    return strb.ToString();

                }
            }
        }


        /// <summary>
        /// 删除操作
        /// </summary>
        private void DoClose()
        {
            string Id = RequestData.Get("Id") + "";
            if (!string.IsNullOrEmpty(Id))
            {
                SurveyQuestion Ent = SurveyQuestion.Find(Id);
                if (string.IsNullOrEmpty(Ent.SurveyTitile) && Ent.State == "0")
                {
                    string SQL = @"delete from  FL_Culture..QuestionItem where SurveyId='{0}'
                                delete from  FL_Culture..QuestionAnswerItem where SurveyId='{0}'
                                delete from  FL_Culture..SurveyFinallyUsr   where SurveyId='{0}'
                                delete from  FL_Culture..SurveyedObj  where SurveyId='{0}'
                                delete from  FL_Culture..SurveyReaderObj  where  SurveyId='{0}' ";
                    SQL = string.Format(SQL, Id);
                    DataHelper.ExecSql(SQL);
                    Ent.DoDelete();
                }

            }
        }

    }
}
