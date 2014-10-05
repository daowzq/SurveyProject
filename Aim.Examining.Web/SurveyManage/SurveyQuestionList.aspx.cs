using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using System.Text;
using System.Data;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyQuestionList : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {

                case "getGuid":
                    CreateGuid();
                    break;
                case "CkFl":
                    CheckMustWorkFlow();
                    break;
                case "Start":   //启动问卷
                    StartSurvery(null);
                    break;
                case "pause":   //暂停问卷
                    PauseSurvey();
                    break;
                case "stop":
                    StopSurvery();
                    break;
                case "batchdelete":
                    DoBatchDelete();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }

        #region 启动问卷
        /// <summary>
        /// 启动问卷
        /// </summary>
        public void StartSurvery(string id)
        {
            string Id = string.IsNullOrEmpty(id) ? RequestData.Get("Id") + "" : id;

            if (!String.IsNullOrEmpty(Id))
            {
                SurveyQuestion Ent = SurveyQuestion.Find(Id);
                StartSurveyQuestion Start = new StartSurveyQuestion();
                bool bol = Start.SurveyQuestionStart(Ent);  //启动
                Ent.State = "1";          // 1表示启动
                Ent.EndTime = Ent.EndTime.GetValueOrDefault().AddHours(23).AddMinutes(59).AddSeconds(59);
                Ent.DoUpdate();

                BackupSurvey(Id);        //backup
                this.PageState.Add("obj", "1");
            }

        }

        /// <summary>
        /// 备份问卷信息
        /// </summary>
        /// <param name="SurveyId"></param>
        private void BackupSurvey(string SurveyId)
        {
            string sql = "select count(*) from FL_Culture..SurveyQuestion_bak where Id='{0}'";
            sql = string.Format(sql, SurveyId);
            int k = DataHelper.QueryValue<int>(sql);
            if (k <= 0)
            {
                try
                {
                    sql = @"insert into  FL_Culture..SurveyQuestion_bak
                            select *  from FL_Culture..SurveyQuestion where Id='{0}';

                            insert into  FL_Culture..QuestionItem_bak
                            select * from FL_Culture..QuestionItem where SurveyId='{0}';

                            insert into  FL_Culture..QuestionAnswerItem_bak 
                            select * from FL_Culture..QuestionAnswerItem where SurveyId='{0}';

                            insert into FL_Culture..SurveyFinallyUsr_bak 
                            select * from FL_Culture..SurveyFinallyUsr where SurveyId='{0}' ";
                    sql = string.Format(sql, SurveyId);
                    DataHelper.ExecSql(sql);

                }
                catch
                { }
            }
        }

        #endregion

        private void PauseSurvey()
        {
            /*将状态设置为停止状态*/
            string Id = this.RequestData.Get<string>("Id");
            if (!string.IsNullOrEmpty(Id))
            {
                SurveyQuestion Ent = SurveyQuestion.Find(Id);
                Ent.State = "3";   //设置为暂停状态
                Ent.DoUpdate();
            }
        }

        private void StopSurvery()
        {
            /*将状态设置为停止状态*/
            string Id = this.RequestData.Get<string>("Id");
            if (!string.IsNullOrEmpty(Id))
            {
                SurveyQuestion Ent = SurveyQuestion.Find(Id);
                Ent.State = "2";
                Ent.DoUpdate();
            }
        }

        /// <summary>
        /// 检查是否审批
        /// </summary>
        private void CheckMustWorkFlow()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            if (!string.IsNullOrEmpty(SurveyId))
            {
                string SQL = @"select  B.MustCheckFlow,C.Id from  FL_Culture..SurveyQuestion As A
                                left join FL_Culture..SurveyType As B 
                                   on B.Id=A.SurveyTypeId 
                                left join FL_Culture..SysWFUserSet As C 
                                   on C.SurveyId=A.Id
                                where  A.Id='{0}'  ";
                SQL = string.Format(SQL, SurveyId);
                DataTable dt = DataHelper.QueryDataTable(SQL);
                if (dt.Rows[0]["MustCheckFlow"].ToString().Contains("1") && string.IsNullOrEmpty(dt.Rows[0]["Id"].ToString()))
                {
                    this.PageState.Add("ChState", "1");
                }
            }
        }
        private void DoSelect()
        {

            //SurveyQuestion[] Ent = SurveyQuestion.FindAll(SearchCriterion);
            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "StartTime":
                            where += " and StartTime>='" + item.Value + "' ";
                            break;
                        case "EndTime":
                            where += " and StartTime<='" + (item.Value.ToString()).Replace(" 0:00:00", " 23:59:59") + "' ";
                            break;
                        default:
                            where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            //创建人或在角色组中的才可查看
            string SQL = @"select  T1.MustCheckFlow As IsCheck,T.* from  FL_Culture..SurveyQuestion As T
                            left join  FL_Culture..SurveyType AS T1
	                            on T.SurveyTypeId=T1.Id
                            where  IsFixed='0' and ( SurveyTitile is not null or  SurveyTitile<>'' ) ";

            CommPowerSplit ps = new CommPowerSplit();//角色组 or HR
            if (!ps.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName) || !ps.IsHR(UserInfo.UserID, UserInfo.LoginName))
            {
                SQL += " and ( T.CreateId='{0}' or T.CompanyId in ({1}) ) ";

                //UserContextInfo UC = new UserContextInfo();
                //加到公司权限的才能看到对应公司发布的问卷，否则只能看自己的
                string Corps = ps.GetCorps(UserInfo.UserID) + "";
                Corps = string.IsNullOrEmpty(Corps.TrimEnd(',')) ? "NULL" :
                   string.Join(",", Corps.TrimEnd(',').Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries).Select(ten => "'" + ten + "'").ToArray());

                SQL = string.Format(SQL, UserInfo.UserID, Corps);
            }

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL += where;

            this.PageState.Add("DataList", GetPageData(SQL, SearchCriterion));

        }

        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "CreateTime";
            string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? " desc" : " asc";
            string pageSql = @"
		    WITH OrderedOrders AS
		    (SELECT *,
		    ROW_NUMBER() OVER (order by {0} {1})as RowNumber
		    FROM ({2}) temp ) 
		    SELECT * 
		    FROM OrderedOrders 
		    WHERE RowNumber between {3} and {4}";
            pageSql = string.Format(pageSql, order, asc, sql, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }

        private void CreateGuid()
        {
            SurveyQuestion ent = new SurveyQuestion();
            var Et = SysUser.Find(UserInfo.UserID);

            ent.IsFixed = "0";                          //0 一般调查问卷
            UserContextInfo UC = new UserContextInfo();
            ent.CompanyId = UC.GetUserCurrentCorpId(UserInfo.UserID); //判断公司登陆

            //部门
            string DeptSQL = @"select A.UserID,A.WorkNo,A.Name,B.GroupID as CropId,B.Name as CropName,
                                    C.GroupID as DeptId,C.Name as DeptName
                             from FL_PortalHR..SysUser As A
	                            left join FL_PortalHR..SysGroup As B
                              on  A.Pk_corp=B.GroupID
	                            left join  FL_PortalHR..SysGroup As C
                              on A.Pk_deptdoc=C.GroupID
                            where UserID='{0}' and  A.pk_corp='{1}' ";

            DeptSQL = DeptSQL.Replace("FL_PortalHR", Global.AimPortalDB);
            DeptSQL = string.Format(DeptSQL, UserInfo.UserID, Et.Pk_corp);

            DataTable dt = DataHelper.QueryDataTable(DeptSQL);
            if (dt.Rows.Count > 0)
            {
                ent.CompanyId = dt.Rows[0]["CropId"].ToString();
                ent.CompanyName = dt.Rows[0]["CropName"].ToString();

                ent.DeptId = dt.Rows[0]["DeptId"].ToString();
                ent.DeptName = dt.Rows[0]["DeptName"].ToString();
            }
            else
            {
                ent.CompanyName = DataHelper.QueryValue("select * from sysgroup where GroupId='" + ent.CompanyId + "'") + "";
            }

            ent.DoCreate();
            this.PageState.Add("Guid", ent.Id);
        }

        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                // SurveyQuestion.DoBatchDelete(idList.ToArray());
                for (var v = 0; v < idList.Count; v++)
                {
                    // 人员 问卷 
                    QuestionItem[] Qent = QuestionItem.FindAllByProperties(QuestionItem.Prop_SurveyId, idList[v].ToString());
                    QuestionAnswerItem[] Aent = QuestionAnswerItem.FindAllByProperties(QuestionAnswerItem.Prop_SurveyId, idList[v].ToString());

                    SurveyFinallyUsr[] FuEnt = SurveyFinallyUsr.FindAllByProperties(SurveyFinallyUsr.Prop_SurveyId, idList[v].ToString());
                    SurveyCanReaderUsr[] Ruent = SurveyCanReaderUsr.FindAllByProperties(SurveyCanReaderUsr.Prop_SurveyId, idList[v].ToString());

                    SurveyedObj[] SoEnt = SurveyedObj.FindAllByProperties(SurveyedObj.Prop_SurveyId, idList[v].ToString());
                    SurveyReaderObj[] RoEnt = SurveyReaderObj.FindAllByProperties(SurveyReaderObj.Prop_SurveyId, idList[v].ToString());

                    foreach (var ent in Qent)
                    {
                        ent.DoDelete();
                    }
                    foreach (var ent in Aent)
                    {
                        ent.DoDelete();
                    }
                    foreach (var ent in FuEnt)
                    {
                        ent.DoDelete();
                    }
                    foreach (var ent in Ruent)
                    {
                        ent.DoDelete();
                    }
                    foreach (var ent in SoEnt)
                    {
                        ent.DoDelete();
                    }
                    foreach (var ent in RoEnt)
                    {
                        ent.DoDelete();
                    }

                }
                SurveyQuestion.DoBatchDelete(idList.ToArray());

            }
        }
    }
}
