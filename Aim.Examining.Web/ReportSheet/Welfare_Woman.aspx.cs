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
    public partial class Welfare_Woman : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "":
                    break;
                default:
                    DoSelect();
                    break;
            }
        }
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
                            where += " and B.Name like '%" + item.Value + "%' ";
                        break;
                    default:
                        // where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                        break;
                }

            }

            string SQL = @"select newid() As Id, A.Year, B.Name As CompanyName,C.Name As DeptName,
	                            A.CompanyId,A.DeptId,A.CouponCount ,(A.CouponCount*A.CouponCost) As CouponCost,
	                            A.NoMarryCheckCount,(A.NoMarryCheckCount*A.NoMarryCheckCost) As NoMarryCheckCost,
	                            A.MarryCheckCount, (A.MarryCheckCount*A.MarryCheckCost) As MarryCheckCost,
                                (A.CouponCount*A.CouponCost)+ (A.NoMarryCheckCount*A.NoMarryCheckCost)+(A.MarryCheckCount*A.MarryCheckCost)  As  SmallTotal
                            from  
                            (
			                    select  * from FL_Culture..V_WomanWelfareStatistics As A
				                cross apply
				                (
					                select top 1  isnull(CouponCost,0) CouponCost , isnull(MarryCheckCost,0) MarryCheckCost,
                                            isnull(NoMarryCheckCost,0)  NoMarryCheckCost
						             from FL_Culture..SysApproveConfig As B 
                                     where 
						                A.CompanyId=B.CompanyId and 
						                (CouponCost is not null or len(CouponCost)>0 and len(MarryCheckCost)>0 and 
							                len(NoMarryCheckCost)>0
						                )
				                ) As T
                            ) As A
                            left join FL_PortalHR..SysGroup  As B 
	                            on A.CompanyId=B.GroupID
                            left join FL_PortalHR..SysGroup As C
	                            on C.GroupID=A.DeptID
                            where  1=1  ##Query##";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

            SQL = SQL.Replace("##Query##", where);
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
