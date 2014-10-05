using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Castle.ActiveRecord;
using System.Data;


namespace Aim.Examining.Web
{
    public partial class RoluserList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private SysRole[] ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            if (this.IsAsyncRequest)
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
                if (!string.IsNullOrEmpty(RequestData.Get<string>("Rolid") + ""))
                {
                    string sql = "select * from SYSUSER where USERID in(select USERID from SYSUSERROLE where  ROLEID ='" + RequestData.Get<string>("Rolid") + "') and 1=1";
                    sql = sql.Replace("and 1=1", where);
                    this.PageState.Add("UserList", GetPageData(sql, SearchCriterion));
                }


            }

            SysRole ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SysRole>();
                    ent.SaveAndFlush();
                    this.SetMessage("保存成功！");
                    break;
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SysRole>();
                    ent.CreateAndFlush();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysRole>();
                    ent.DeleteAndFlush();
                    this.SetMessage("删除成功！");
                    break;
                default:

                    if (RequestActionString == "setusers")//添加人员
                    {
                        bool bol = false;
                        //string get_task = "select * from HD_Task where ENDTIME is null ";
                        //DataTable dt = DataHelper.QueryDataTable(get_task);

                        string roleId = this.RequestData.Get<string>("id");
                        string userIds = this.RequestData.Get<string>("userids");
                        DataHelper.ExecSql("delete from SysUserRole where RoleId='" + roleId + "'");
                        string insertTpl = "insert into SysUserRole values ('{0}','" + roleId + "') ";
                        string[] users = userIds.Split(',');

                        foreach (string user in users)
                        {
                            if (user != "")
                                DataHelper.ExecSql(string.Format(insertTpl, user));
                        }
                        if (roleId == "fe0464db-1b6e-483d-b983-4352f14cc367")
                        {
                            bol = true;

                        }
                    }
                    else if (RequestActionString == "getusers")
                    {
                        string uids = "";
                        string names = "";
                        using (new SessionScope())
                        {
                            ent = SysRole.Find(this.RequestData.Get<string>("id"));
                            if (ent.User.Count > 0)
                            {
                                SysUser[] usrs = ent.User.ToArray();
                                foreach (SysUser usr in usrs)
                                {
                                    uids += usr.UserID + ",";
                                    names += usr.Name + ",";
                                }
                            }
                        }
                        uids = uids.TrimEnd(',');
                        names = names.TrimEnd(',');
                        this.PageState.Add("UserId", uids);
                        this.PageState.Add("UserName", names);
                    }
                    else if (RequestActionString == "deleteusers")
                    {
                        string roleId = this.RequestData.Get<string>("id");
                        string userIds = this.RequestData.Get<string>("userids").TrimEnd(',');
                        string delsql = "delete from SysUserRole where RoleId='" + roleId + "' and UserID in ('" + userIds.Replace(",", "','") + "') ";
                        DataHelper.ExecSql(delsql);
                    }
                    else
                    {
                        DoSelect();
                    }

                    break;
            }
        }

        #endregion

        #region 私有方法
        private void DoSelect()
        {
            string sql = "select * from SYSROLE where TYPE='4'  and Name not in ('员工心声','员工申诉','福利申报通知','积分维护','问卷管理','设置管理','管理员组')";
            if (PageState.ContainsKey("RoleList"))
            {
                PageState.Remove("RoleList");
            }
            this.PageState.Add("RoleList", DataHelper.QueryDataTable(sql));

        }


        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t", DataHelper.GetCurrentDbConnection(typeof(SysUser)));
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "Name";
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
            IList<EasyDictionary> dicts = DataHelper.DataTableToDictList(DataHelper.QueryDataTable(pageSql, DataHelper.GetCurrentDbConnection(typeof(SysUser))));//DataHelper.QueryDictList(pageSql);
            return dicts;
        }



        //判断是否为管理员
        public bool getRole(string id)
        {
            bool bol = false;

            if (!string.IsNullOrEmpty(id + ""))
            {
                //   string sql = " select * from SysRole where  ROLEID in(select ROLEID from SYSUSERROLE where USERID=(select USERID from SYSUSER where USERID='" + id + "')) and( CODE='User' or CODE='UserManager')";
                string sql = " select * from SysRole where  ROLEID in(select ROLEID from SYSUSERROLE where USERID=(select USERID from SYSUSER where USERID='" + id + "') and CODE='Aim')";

                DataTable dt = DataHelper.QueryDataTable(sql);
                if (dt.Rows.Count != 0)
                {
                    bol = true;
                }
            }
            return bol;
        }



        #endregion
    }


}
