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
using System.Data;
using System.Text;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web
{
    public partial class SurveyCommitHistoryList : ExamListPage
    {

        private IList<SurveyCommitHistory> ents = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyCommitHistory ent = null;
            switch (this.RequestActionString)
            {
                case "getScoreInfo":
                    // DoGetScoreInfo();
                    break;
                default:
                    DoSelect();
                    break;
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

            //权限过滤
            CommPowerSplit PS = new CommPowerSplit();
            if (PS.IsHR(UserInfo.UserID, UserInfo.LoginName) || PS.IsAdmin(UserInfo.LoginName) || PS.IsInAdminsRole(UserInfo.UserID))
            {
            }
            else
            {
                UserContextInfo UC = new UserContextInfo();
                where += " and C.GroupId='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ";
            }

            string sql = @"select A.Id,A.SurveyId,A.SurveyName,A.WorkNo,A.SurveyedUserId,A.SurveyedUserName,A.CreateTime,
                            A.TotalScore,A.ScoreInfo,
                            B.WorkNo As WorkNo1 , C.GroupID As CropId ,C.Name As CropName,D.GroupID As DeptId,D.Name AS DeptName,
                            E.IsNoName
                           from FL_Culture..SurveyCommitHistory As A
                              left join  FL_PortalHR..SysUser As B 
                                on  A.SurveyedUserId=B.UserID  or A.WorkNo=B.WorkNo
	                          left join  FL_PortalHR..SysGroup As C
		                        on C.GroupID=B.Pk_corp
	                          left join FL_PortalHR..SysGroup As D
		                         on D.GroupID =B.Pk_deptdoc
                              left join FL_Culture..SurveyQuestion As E
                                 on A.SurveyId=E.Id 
                           where A.SurveyId='{0}' ";

            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);

            sql += where;
            sql = string.Format(sql, SurveyId);

            //SearchCriterion.SetSearch("SurveyId", SurveyId);
            //ents = SurveyCommitHistory.FindAll(SearchCriterion);
            //this.PageState.Add("SurveyCommitHistoryList", ents);
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
}

