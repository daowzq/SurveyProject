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


namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class DPermissionUser : BaseListPage
    {
        #region 变量

        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型

        private IList<DynamicPermission> dps = null;

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
                case RequestActionEnum.Query:
                case RequestActionEnum.Read:
                case RequestActionEnum.Default:
                    if (!String.IsNullOrEmpty(id))
                    {
                        using (new Castle.ActiveRecord.SessionScope())
                        {
                            SearchCriterion.PageSize = 50;
                            SearchCriterion.AddSearch("AuthID", id);
                            SearchCriterion.AddSearch("CatalogCode", DynamicPermissionCatalog.SysCatalogEnum.SYS_USER.ToString());

                            dps = DynamicPermissionRule.FindAll(SearchCriterion);
                        }
                    }
                    break;
                case RequestActionEnum.Update:
                    IList<string> entStrList = RequestData.GetList<string>("data");

                    using (TransactionScope trans = new TransactionScope())
                    {
                        try
                        {
                            foreach (string entStr in entStrList)
                            {
                                DynamicPermission tent = JsonHelper.GetObject<DynamicPermission>(entStr) as DynamicPermission;

                                tent.DoUpdate();
                            }

                            trans.VoteCommit();
                        }
                        catch (Exception ex)
                        {
                            trans.VoteRollBack();

                            throw ex;
                        }
                    }
                    break;
                case RequestActionEnum.Custom:
                    if (RequestActionString == "adduser" || RequestActionString == "deluser")
                    {
                        IList<string> userIDs = RequestData.GetList<string>("UserIDs");

                        if (!String.IsNullOrEmpty(id))
                        {
                            using (new SessionScope())
                            {
                                if (RequestActionString == "adduser")
                                {
                                    DynamicAuth dauth = DynamicAuth.Find(id);
                                    DynamicPermission.GrantDAuthToUsers(dauth, userIDs, null, null, UserInfo.UserID, UserInfo.Name);
                                }
                                else if (RequestActionString == "deluser")
                                {
                                    DynamicPermission.RevokeDAuthFromUsers(id, userIDs);
                                }
                            }
                        }
                    }
                    break;
            }

            this.PageState.Add("EntList", dps);

            if (!IsAsyncRequest)
            {
                if (!String.IsNullOrEmpty(id))
                {
                    using (new SessionScope())
                    {
                        DynamicAuth da = DynamicAuth.Find(id);

                        DynamicAuthCatalog dac = DynamicAuthCatalog.FindFirst(Expression.Eq("Code", da.CatalogCode));

                        if (dac != null)
                        {
                            this.PageState.Add("AllowOperation", dac.GetAllowOperations());
                        }
                    }
                }

                this.PageState.Add("OpDivChar", DynamicOperations.DivChar);
            }
        }

        #endregion

        #region 私有方法

        #endregion
    }
}
