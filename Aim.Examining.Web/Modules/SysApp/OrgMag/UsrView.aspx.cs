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
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.OrgMag
{
    public partial class UsrView : BaseListPage
    {
        #region 变量

        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型

        private IList<SysUser> users = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

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
                    ICriterion cirt = Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID = ?)", id, NHibernateUtil.String);

                    users = SysUserRule.FindAll(SearchCriterion, cirt);
                }
            }
            else
            {
                users = SysUserRule.FindAll(SearchCriterion);
            }

            this.PageState.Add("UsrList", users);
        }

        #endregion

        #region 私有方法

        #endregion
    }
}
