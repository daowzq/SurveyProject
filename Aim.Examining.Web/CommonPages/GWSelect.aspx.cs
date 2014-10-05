using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Text;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data;
namespace Aim.Examining.Web.CommonPages.Select
{
    public partial class GWSelect : BaseListPage
    {
        public GWSelect()
        {
            SearchCriterion.PageSize = 40;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                default:
                    Doselect();
                    break;
            }
        }

        private void Doselect()
        {
            string CorpId = RequestData.Get("CorpId") + "";

            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        default:
                            where += " and  jobname like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            string SQL = @"select  newid() as Id,jobname As XL from (
	                         select distinct jobname from HR_OA_MiddleDB..fld_gw where isabort='N' and {0}
                           ) AS T where 1=1 ";
            if (!string.IsNullOrEmpty(CorpId))
            {
                SQL = string.Format(SQL, "  pk_corp='" + CorpId + "' ");
            }
            else
            {
                SQL = string.Format(SQL, " 1=1 ");
            }

            SQL = SQL + where;
            SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            SearchCriterion.SetOrder("XL");
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
