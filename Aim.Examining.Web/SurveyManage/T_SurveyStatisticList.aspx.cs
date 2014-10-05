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
using System.Data;
using System.Text;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class T_SurveyStatisticList : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Doeselect();
        }

        private void Doeselect()
        {

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

            string SQL = string.Empty;

            //问卷角色或管理员
            CommPowerSplit Role = new CommPowerSplit();
            if (Role.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName))
            {
                SQL = @" select A.*,B.SummitCount
                            from FL_Culture..SurveyQuestion  As A 
                            left join 
                            ( 
	                            select SurveyId ,count(*) As SummitCount from FL_Culture..SurveyCommitHistory group by  SurveyId 
                            ) As B
                            on  A.Id=B.SurveyId
                            where A.IsFixed='0' and ( A.state='1' or A.state='2' ) ";
            }
            else
            {
                string CompanyId = string.Empty;
                UserContextInfo UC = new UserContextInfo();
                CompanyId = UC.GetUserCurrentCorpId(UserInfo.UserID); //判断公司登陆

                //(A.state='1' or A.state='2') 开始 结束
                SQL = @" select A.*,B.SummitCount
                            from FL_Culture..SurveyQuestion  As A 
                            left join 
                            ( 
	                            select SurveyId ,count(*) As SummitCount from FL_Culture..SurveyCommitHistory group by  SurveyId 
                            ) As B
                            on  A.Id=B.SurveyId
                         where A.IsFixed='0' and A.CompanyId='{0}' and (A.state='1' or A.state='2') ";
                SQL = string.Format(SQL, CompanyId);
            }

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

        /// <summary>
        /// 汇总数据
        /// </summary>
        private void SummaryData()
        {

        }

    }
}
