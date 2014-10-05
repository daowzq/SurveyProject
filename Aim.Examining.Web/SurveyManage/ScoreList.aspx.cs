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
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.SurveyManage
{

    public partial class ScoreList : ExamListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "doBatchClear":
                    DoBatchClear();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }

        //
        private void DoSelect()
        {

            string sort = RequestData.Get("sort") + "";
            string tp = RequestData.Get("tp") + ""; //my个人积分 mgr 管理员

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
            string sql = " select * from FL_Culture..V_SurveyScore where UserName is not null  ";

            if (tp.Contains("mgr"))   //角色验证-->配置
            {
                CommPowerSplit ps = new CommPowerSplit();
                if (ps.IsScoreRole(UserInfo.UserID, UserInfo.LoginName))
                {
                    this.PageState.Add("Power", "1");
                }
                else //分公司判断
                {
                    string corp = string.Empty;
                    UserContextInfo UC = new UserContextInfo();
                    corp = UC.GetUserCurrentCorpId(UserInfo.UserID);

                    this.PageState.Add("Power", "1");
                    where += " and CorpId='" + corp + "' ";
                }
            }
            else if (tp.Contains("my")) //个人
            {
                where += " and UserID='" + UserInfo.UserID + "' ";
                this.PageState.Add("Power", "0");
            }

            sql += where;
            this.PageState.Add("DataList", GetPageData(sql, SearchCriterion));

        }


        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "Score";
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

        private void DoBatchClear()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                string[] arr = idList.Select(ent => { return "'" + ent.ToString() + "'"; }).ToArray();
                string Ids = string.Join(",", arr);
                string sql = "update FL_Culture..SurveyScore set Score=0 where UserID in (" + Ids + ") ";
                DataHelper.ExecSql(sql);
            }
        }

    }
}
