using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Castle.ActiveRecord;
using NHibernate;
using NHibernate.Criterion;
using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Examining.Model;
using System.Configuration;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class NoSubmit : ExamListPage
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestActionString)
            {
                case "MsgRemind":
                    Remind("Msg");
                    break;
                case "EmailRemind":
                    Remind("Email");
                    break;
                default:
                    DoSelect();
                    break;
            }
        }


        /// <summary>
        /// 催办
        /// </summary>
        /// <param name="Type"></param>
        private void Remind(string Type)
        {
            string SurveyId = this.RequestData.Get("SurveyId") + "";
            var Ent = SurveyQuestion.TryFind(SurveyId);
            if (Ent == null)
            {
                this.PageState.Add("State", "0");
                return;
            }

            string NoticeType = string.Empty;
            if (Type == "Email") NoticeType = "Email";
            if (Type == "Msg") NoticeType = "Message";

            var List = RequestData.GetList<string>("Dt");
            IList<RemindCla> ents = List.Select(tent => JsonHelper.GetObject<RemindCla>(tent) as RemindCla).ToList();

            foreach (var v in ents)
            {
                SysUser User = SysUser.Find(v.UserId);
                //发送通知
                StartSurveyQuestion SQ = new StartSurveyQuestion();
                SQ.SendNotice_Nosubmit(User, NoticeType, Ent.SurveyTitile, Ent.Id, Ent.StartTime.GetValueOrDefault().ToString("yyyy-MM-dd HH:mm:ss"), Ent.EndTime.GetValueOrDefault().ToString("yyyy-MM-dd HH:mm:ss"), Ent.Description.ToString());
            }
        }


        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            string SurveyId = this.RequestData.Get("surveyId") + "";
            string where = "";

            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "StartTime":
                            where += " and CreateTime>='" + item.Value + "' ";
                            break;
                        case "EndTime":
                            where += " and CreateTime<='" + (item.Value.ToString()).Replace(" 0:00:00", " 23:59:59") + "' ";
                            break;
                        default:
                            where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            string sql = @"	select distinct A.UserId,A.UserName,B.WorkNo As WorkNo1, C.GroupID As CropId ,C.Name As CropName,
                            D.GroupID As DeptId,D.Name As DeptName,A.CreateTime
                            from (
		                        select * from  FL_Culture..SurveyFinallyUsr where SurveyId='{0}' and 
		                        UserId not in ( select SurveyedUserId  from FL_Culture..SurveyCommitHistory where SurveyId='{0}')
	                         ) As A
                              left join  FL_PortalHR..SysUser As B 
                                on  A.UserId=B.UserID  
                                --or A.WorkNo=B.WorkNo
                              left join  FL_PortalHR..SysGroup As C
                                on C.GroupID=B.Pk_corp
                              left join FL_PortalHR..SysGroup As D
                                 on D.GroupID =B.Pk_deptdoc
                              where 1=1  ";

            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql += where;
            sql = string.Format(sql, SurveyId);

            //SearchCriterion.SetSearch("SurveyId", SurveyId);
            //ents = SurveyCommitHistory.FindAll(SearchCriterion);
            //this.PageState.Add("SurveyCommitHistoryList", ents);
            var Ent = SurveyQuestion.TryFind(SurveyId);
            if (Ent != null)
            {
                if (DateTime.Now >= Ent.EndTime.GetValueOrDefault())
                {
                    this.PageState.Add("IsPased", "1");  //是否过期
                }
            }
            this.PageState.Add("DataList", GetPageData(sql, SearchCriterion));
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
    }

    public sealed class RemindCla
    {
        public string Id { get; set; }
        public string SurveyId { get; set; }
        public string SurveyName { get; set; }
        public string DeptId { get; set; }
        public string DeptName { get; set; }
        public string CropId { get; set; }
        public string CropName { get; set; }
        public string WorkNo1 { get; set; }
        public string UserId { get; set; }
        public string UserName { get; set; }
        public string CreateTime { get; set; }
    }
}
