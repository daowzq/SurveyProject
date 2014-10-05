using System;
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

namespace Aim.Examining.Web.CommonPages.Select
{
    public partial class FrmNeedUserSelect : BaseListPage
    {
        public FrmNeedUserSelect()
        {
            SearchCriterion.PageSize = 60;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string PostName = Server.UrlDecode(RequestData.Get<string>("PostName"));
            //string sql = "select Id,CreateId as UserID,CreateName as Name from " + WFHelper.PurchaseDB + "..Manpower where Ext4='" + PostName + "'";
            string corp = string.Empty;
            if (Session["CompanyId"] != null)
            {
                corp = Session["CompanyId"] + "";
            }

            string sql = "select distinct u.UserID as Id, u.* from sysusergroup ug inner join sysgroup g on ug.groupid=g.groupid inner join sysuser u on u.userid=ug.userid where g.Path like '%" + corp + "%' and u.Status=1";

            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (item.Value + "" != "")
                {
                    where += " and u." + item.PropertyName + " like '%" + item.Value + "%' ";
                }
            }

            PageState.Add("DataList", GetPageData(sql + where, SearchCriterion, "WorkNo", "asc"));
        }



        /// <summary>
        /// 复杂表单查询
        /// </summary>
        /// <param name="sql">sql</param>
        /// <param name="search">SearchCriterion</param>
        /// <returns>数据</returns>
        public static IList<EasyDictionary> GetPageData(String sql, SearchCriterion search, string SortCol, string DefSort)
        {
            search.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : SortCol;
            string asc = search.Orders.Count <= 0 ? DefSort : search.Orders[0].Ascending ? " asc" : " desc";
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


