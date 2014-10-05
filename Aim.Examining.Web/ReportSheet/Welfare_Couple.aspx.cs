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

namespace Aim.Examining.Web.ReportSheet
{
    public partial class Welfare_Couple : BaseListPage
    {
        public Welfare_Couple()
        {
            SearchCriterion.PageSize = 120;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "Query":
                    //DoQuery();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }


        private void DoQuery()
        {
            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "Year":
                            where += " and CreateTime>='" + item.Value + "' ";
                            break;
                        case "CompanyName":
                            where += " and CreateTime<='" + (item.Value.ToString()).Replace(" 0:00:00", " 23:59:59") + "' ";
                            break;
                        default:
                            where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            string Year = this.RequestData.Get("Year") + "";
            string Company = this.RequestData.Get("CompanyName") + "";
            string SQL = @"select A.Year,
                              B.Id,B.UserId,B.UserName,WorkNo,B.CompanyId,CompanyName,Sex,IndutyData,IdentityCard,
                              Case when B.Sex='男' then '女' else '男' End  As  OtherSex,
                             OtherUserName,OtherIdentityCard
                           from
                            (
	                            select year(ApplyTime) As Year ,CompanyID from FL_Culture..UsrDoubleWelfare
	                            group  by year(ApplyTime),CompanyId
                            ) As A
                           left join 
	                            FL_Culture..UsrDoubleWelfare As B 
                            on A.Year=year(B.ApplyTime) and B.CompanyID=A.CompanyID
                           where 1=1 and ##Query## ";

            // string where = " A.Year='" + Year + "' " + Company;
            SQL = SQL.Replace("##Query##", where);
            // this.PageState.Add("DataList");

        }

        //
        private void DoSelect()
        {

            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                switch (item.PropertyName)
                {
                    case "Year":
                        string tempVal = string.IsNullOrEmpty(item.Value.ToString()) ? DateTime.Now.Year.ToString() : item.Value.ToString();
                        where += "  and Year='" + tempVal + "'";
                        break;
                    case "CompanyName":
                        if (!string.IsNullOrEmpty(item.Value.ToString()))
                            where += " and CompanyName like '%" + item.Value + "%' ";
                        break;
                    default:
                        // where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                        break;
                }

            }

            //string Year = this.RequestData.Get("Year") + "";
            //string Company = this.RequestData.Get("CompanyName") + "";
            //Year = string.IsNullOrEmpty(Year) ? DateTime.Now.Year.ToString() : Year;
            //Company = string.IsNullOrEmpty(Company) ? "" : " and B.CompanyName like '%" + Company + "%'";

            string SQL = @"select A.Year,
                              B.Id,B.UserId,B.UserName,WorkNo,B.CompanyId,DeptId,DeptName,CompanyName,Sex,IndutyData,IdentityCard,
                              Case when B.Sex='男' then '女' else '男' End  As  OtherSex,
                             OtherUserName,OtherIdentityCard
                           from
                            (
	                            select year(ApplyTime) As Year ,CompanyID from FL_Culture..UsrDoubleWelfare
	                            group  by year(ApplyTime),CompanyId
                            ) As A
                           left join 
	                            FL_Culture..UsrDoubleWelfare As B 
                            on A.Year=year(B.ApplyTime) and B.CompanyID=A.CompanyID
                           where 1=1  ##Query##  ";

            SQL = SQL.Replace("##Query##", where);
            //var Ent = DataHelper.QueryDictList(SQL);
            this.PageState.Add("DataList", GetPageData(SQL, SearchCriterion));

        }

        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "CompanyId";
            string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? " asc" : " desc";

            string pageSql = @"WITH OrderedOrders AS
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
