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

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyView_No : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            GetSurveyList();
        }
        private void GetSurveyList()
        {
            string where = string.Empty;
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "StartTime":
                            where += " and  CreateTime>='" + item.Value + "' ";
                            break;
                        case "EndTime":
                            where += " and  CreateTime<='" + (item.Value.ToString()).Replace(" 0:00:00", " 23:59:59") + "' ";
                            break;
                        default:
                            where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            string sql = @"Select distinct A.Id, A.SurveyTitile,A.Description, A.StartTime,A.EndTime,A.IsNoName,A.State,A.CreateTime,
	                              case when getdate()> A.EndTime then 'Y' else 'N'  end As IsPasted ,CA.DeptName
                            From FL_Culture..SurveyQuestion             As A
                            inner join FL_Culture..SurveyFinallyUsr	  As B
	                            on A.Id=B.SurveyId 
                            left join  FL_PortalHR..SysUser  AS C
                                on C.UserId=B.UserId or C.WorkNo=B.WorkNo 
                            cross apply
                            (
	                            select distinct top 1 DeptName from	FL_PortalHR..View_SysUserGroup  AS T
	                            where  T.UserID='{0}'
                            ) As Ca 
                            where C.UserId='{0}' and C.UserId is not null
	                              and  getdate() between StartTime and EndTime and State='1' 
	                              and  ActualSurveyed='1'                 --- 实际执行标志
	                               -- and  getdate() >= B.ExecTime
	                              and not exists( select * from FL_Culture..SurveyCommitHistory  AS D where SurveyedUserId='{0}'  and A.Id=D.SurveyId ) ";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql = string.Format(sql, UserInfo.UserID);
            sql += where;
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
