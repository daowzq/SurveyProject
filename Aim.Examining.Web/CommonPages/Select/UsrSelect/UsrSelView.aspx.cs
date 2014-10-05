using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NHibernate;
using NHibernate.Criterion;
using Castle.ActiveRecord;
using Castle.ActiveRecord.Queries;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using Aim.Utilities;
using Aim.Examining.Web;

namespace Aim.Portal.Web.CommonPages
{
    public partial class UsrSelView : BaseListPage
    {


        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型
        string ctype = String.Empty; // 分类类型

        string selsex = string.Empty;

        private IList<SysUser> users = new List<SysUser>();



        public UsrSelView()
        {
            IsCheckLogon = false;

            SearchCriterion.CurrentPageIndex = 1;
            SearchCriterion.PageSize = 100; // 一次最多显示100人
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get<string>("id", String.Empty);
            type = RequestData.Get<string>("type", String.Empty).ToLower();
            ctype = RequestData.Get<string>("ctype", "user").ToLower();
            selsex = RequestData.Get<string>("selsex", "all").ToLower();
            string sql = string.Empty;

            if (ctype == "group")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    //ICriterion cirt = null;

                    //if (type == "gtype")
                    //{
                    //    cirt = Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID IN (SELECT GroupID FROM SysGroup WHERE Type = ?))", id, NHibernateUtil.String);
                    //}
                    //else
                    //{
                    //    // 应该同时获取子组用户
                    //    cirt = Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID IN (SELECT GroupID FROM SysGroup WHERE GroupID = ? OR Path LIKE '%" + id + "%'))",
                    //        id, NHibernateUtil.String);
                    //}

                    SearchCriterion.AutoOrder = false;
                    SearchCriterion.SetOrder(SysUser.Prop_WorkNo);
                    //users = SysUserRule.FindAll(SearchCriterion, cirt);
                    //this.PageState.Add("UsrList", users);

                    //for FL_PortalHR 保持同步
                    if (type == "gtype")
                    {
                        sql = @"select * from FL_PortalHR..SysUser where UserID IN 
                                (SELECT UserID FROM FL_PortalHR..SysUserGroup 
                                WHERE GroupID IN (SELECT GroupID FROM FL_PortalHR..SysGroup WHERE Type = {0} )) ";
                        sql = string.Format(sql, id);
                    }
                    else
                    {
                        sql = @"select * from FL_PortalHR..SysUser where  
                                   UserID IN (SELECT UserID FROM FL_PortalHR..SysUserGroup 
                                WHERE GroupID IN (SELECT GroupID FROM FL_PortalHR..SysGroup WHERE GroupID ='{0}' OR Path LIKE '%{0}%')) ";
                        sql = string.Format(sql, id);
                    }
                    sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
                    this.PageState.Add("UsrList", GetPageData(sql, SearchCriterion));

                }
            }
            else
            {
                SearchCriterion.AutoOrder = false;
                string dName = SearchCriterion.GetSearchValue<string>("Name");
                string workNo = SearchCriterion.GetSearchValue<string>("WorkNo");
                SearchCriterion.SetOrder(SysUser.Prop_WorkNo);

                string where = string.Empty;
                string sex = string.Empty;

                if (selsex == "male")
                {
                    sex = " and Sex='男'";
                }
                else if (selsex == "female")
                {
                    sex = " and Sex='女'";
                }

                if (dName != null && dName.Trim() != "")  //拼音查询
                {
                    if (string.IsNullOrEmpty(id))
                    {
                        where = "select * from FL_PortalHR..SysUser where " + GetPinyinWhereString("Name", dName);
                        where += " and WorkNo like '%" + workNo + "%'";
                        where += sex;
                    }
                    else
                    {
                        where = @"select * from FL_PortalHR..SysUser where  
                                   UserID IN (SELECT UserID FROM FL_PortalHR..SysUserGroup 
                                WHERE GroupID IN (SELECT GroupID FROM FL_PortalHR..SysGroup WHERE GroupID ='{0}' OR Path LIKE '%{0}%')) ";
                        where = string.Format(where, id);
                        where += " and " + GetPinyinWhereString("Name", dName) + " and WorkNo like '%" + workNo + "%'";
                        where += sex;
                    }

                    where = where.Replace("FL_PortalHR", Global.AimPortalDB);

                    this.PageState.Add("UsrList", GetPageData(where, SearchCriterion));
                }
                else   //工号查询
                {
                    if (String.IsNullOrEmpty(id))
                    {
                        where = "select * from FL_PortalHR..SysUser where 1=1 ";
                        where += " and WorkNo like '%" + workNo + "%'";
                        where += sex;
                    }
                    else
                    {
                        where = @"select * from FL_PortalHR..SysUser where  
                                   UserID IN (SELECT UserID FROM FL_PortalHR..SysUserGroup 
                                WHERE GroupID IN (SELECT GroupID FROM FL_PortalHR..SysGroup WHERE GroupID ='{0}' OR Path LIKE '%{0}%')) ";
                        where = string.Format(where, id);
                        where += " and WorkNo like '%" + workNo + "%'";
                        where += sex;
                    }
                    where = where.Replace("FL_PortalHR", Global.AimPortalDB);

                    this.PageState.Add("UsrList", GetPageData(where, SearchCriterion));
                }
            }

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

        public string GetPinyinWhereString(string fieldName, string pinyinIndex)
        {
            string[,] hz = Tool.GetHanziScope(pinyinIndex);
            string whereString = "(";
            for (int i = 0; i < hz.GetLength(0); i++)
            {
                whereString += "(SUBSTRING(" + fieldName + ", " + (i + 1) + ", 1) >= '" + hz[i, 0] + "' AND SUBSTRING(" + fieldName + ", " + (i + 1) + ", 1) <= '" + hz[i, 1] + "') AND ";
            }
            if (whereString.Substring(whereString.Length - 4, 4) == "AND ")
                return whereString.Substring(0, whereString.Length - 4) + ")";
            else
                return "(1=1)";
        }

    }
}
