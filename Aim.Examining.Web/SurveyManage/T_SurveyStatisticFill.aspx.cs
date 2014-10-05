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
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class T_SurveyStatisticFill : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.SearchCriterion.PageSize = 60;
            Doselect();
        }

        private void Doselect()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";

            {
                string QuestionSQL = @"select Content val,content As Name from FL_Culture..QuestionItem 
                                    where SurveyId='{0}' and QuestionType like '填写项%'
                                  order by sortindex ";
                QuestionSQL = string.Format(QuestionSQL, SurveyId);
                this.PageState.Add("QuestionItem", DataHelper.QueryDict(QuestionSQL));
            }


            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "QuestionItem":
                            where += " and Content like '" + item.Value.ToString() + "%' ";
                            break;
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
            var SEnt = SurveyQuestion.TryFind(SurveyId);
            if (SEnt != null && SEnt.IsFixed == "2")
            {
                CommPowerSplit PS = new CommPowerSplit();
                if (PS.IsHR(UserInfo.UserID, UserInfo.LoginName) || PS.IsAdmin(UserInfo.LoginName) || PS.IsInAdminsRole(UserInfo.UserID))
                {
                }
                else
                {
                    UserContextInfo UC = new UserContextInfo();
                    where += " and D.pk_corp='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ";
                }
            }

            string SQL = @"SELECT newid() As Id, A.SurveyTitile, A.IsNoName , B.Content, C.QuestionContent ,C.UserId, C.UserName,C.CreateTime
                        from  FL_Culture..SurveyQuestion  As A
                         left join  FL_Culture..QuestionItem As B
	                        on A.Id=B.SurveyId  
                         left join  FL_Culture..SurveyedResult As C
	                        on  C.QuestionId=B.Id
                         left join FL_PortalHR..SysUser As D
                            on C.UserId=D.UserId
                        where  B.QuestionType='填写项' and  A.Id='{0}'";
            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = string.Format(SQL, SurveyId);
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
    }
}
