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

namespace Aim.Examining.Web
{
    public partial class UsrView : BaseListPage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型

        private IList<SysUser> users = null;


        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get<string>("id", String.Empty);
            type = RequestData.Get<string>("type", String.Empty).ToLower();

            switch (RequestAction)
            {
                case RequestActionEnum.Custom:
                    if (RequestActionString == "addgrpuser" || RequestActionString == "delgrpuser")
                    {
                        IList<string> userIDs = RequestData.GetList<string>("UserIDs");

                        if (!String.IsNullOrEmpty(id))
                        {
                            using (new SessionScope())
                            {
                                SysGroup grp = SysGroup.Find(id);

                                if (RequestActionString == "addgrpuser")
                                {
                                    grp.AddUsers(userIDs);
                                    //更新到岗级
                                    //if (grp.Type == 3)
                                    //{
                                    //    PRJ_PostDuty pd = PRJ_PostDuty.FindFirstByProperties(new string[]{"Post",grp.Name});
                                    //   // pd.EmployeeId=userIDs
                                    //    SysUser[] usrsToAdd = SysUser.FindAllByPrimaryKeys(userIDs.ToArray());
                                    //    string names = "";
                                    //    string ids = "";
                                    //    foreach (SysUser sy in usrsToAdd)
                                    //    {
                                    //        ids += sy.UserID+",";
                                    //        names += sy.Name+",";
                                    //    }
                                    //    pd.EmployeeId = pd.EmployeeId+","+ids.Substring(0, ids.Length - 1);
                                    //    pd.EmployeeName = pd.EmployeeName+","+names.Substring(0, names.Length - 1);
                                    //    pd.Update();
                                    //}
                                }
                                else if (RequestActionString == "delgrpuser")
                                {
                                    grp.RemoveUsers(userIDs);
                                }
                            }
                        }
                    }
                    break;
            }

            if (type == "group" && !String.IsNullOrEmpty(id))
            {
                using (new Castle.ActiveRecord.SessionScope())
                {
                    ICriterion cirt = Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID in (select GroupID from SysGroup where Path like '%?%' ))", id, NHibernateUtil.String);

                    //string SQL = @"SELECT UserID FROM SysUserGroup WHERE GroupID in (select GroupID from SysGroup where Path like '%{0}%'";
                    //SQL = string.Format(SQL, id); 
                    //users =  .FindAll(SearchCriterion, cirt);

                    this.PageState.Add("UsrList", SysUser.FindAll(SearchCriterion, Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID in (select GroupID from SysGroup where Path like '%" + id + "%' or GroupID like '%" + id + "%'  ))")));
                }
            }
            else
            {
                users = SysUserRule.FindAll(SearchCriterion);
                this.PageState.Add("UsrList", users);
            }


        }

    }
}
