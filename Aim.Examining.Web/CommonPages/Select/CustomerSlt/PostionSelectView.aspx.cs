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

namespace Aim.Examining.Web.CommonPages.Select.CustomerSlt
{
    public partial class PostionSelectView : BaseListPage
    {
        public PostionSelectView()
        {
            SearchCriterion.PageSize = 60;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            DoSelect();
        }

        private void DoSelect()
        {
            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        default:
                            where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            string deptId = this.RequestData.Get("deptId") + "";
            string jobSeq = this.RequestData.Get("jobSeq") + "";

            string jobSeqSql = @"and name in (
		                            select distinct jobname from HR_OA_MiddleDB..fld_gw as A
		                            where  A.def2 like '%{0}%'  
	                            )";

            string SQL = @"select  distinct  Name   from 
                                       (
           	                             select  B.* from  FL_Culture..f_splitstr('{0}',',') As A
           	                                left join  FL_PortalHR..SysGroup  As B 
           		                            on B.Path like '%'+A.F1+'%' where type=3 and Status=1 
                                            ##jobseq##
           	                            -- union All
           	                             --select * from FL_PortalHR..SysGroup where type=3 and Status=1 and Path=''
                                        ) As T where 1=1 ";
            if (string.IsNullOrEmpty(jobSeq))
            {
                SQL = SQL.Replace("##jobseq##", "");
            }
            else
            {
                jobSeqSql = string.Format(jobSeqSql, jobSeq);
                SQL = SQL.Replace("##jobseq##", jobSeqSql);
            }


            //            string SQL = @"select  distinct GroupID As Id,GroupID,Name,Code,ParentID  from 
            //                                       (
            //           	                             select  B.* from  FL_Culture..f_splitstr('{0}',',') As A
            //           	                                left join  FL_PortalHR..SysGroup  As B 
            //           		                            on B.Path like '%'+A.F1+'%' where type=3 and Status=1 
            //           	                            -- union All
            //           	                             --select * from FL_PortalHR..SysGroup where type=3 and Status=1 and Path=''
            //                                        ) As T where 1=1 ";

            //            string SQL = @"select distinct Name from 
            //                           (
            //                             select B.* from  FL_Culture..f_splitstr('{0}',',') As A
            //                                left join SysGroup  As B 
            //	                            on B.Path like '%'+A.F1+'%' where type=3 and Status=1 
            //                            -- union All
            //                             --select * from FL_PortalHR..SysGroup where type=3 and Status=1 and Path=''
            //                            ) As T where 1=1 ";

            //string SQL = "select distinct MName As Name,SortIndex from  FL_Culture..ManagementGroup where 1=1 ";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            SQL = string.Format(SQL, deptId);
            SQL += where;
            this.PageState.Add("DataList", GetPageData(SQL, SearchCriterion));


        }

        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            // string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "SortIndex";
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "Name";
            string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? "asc" : "desc";
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
