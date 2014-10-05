using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;
using NHibernate.Criterion;

using Aim.Data;
using Aim.Common;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class DPermissionGrantRev : BasePage
    {
        #region 变量

        private DynamicAuth[] ents = null;

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型
        string code = String.Empty; // 编码

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");
            code = RequestData.Get<string>("code");

            switch (RequestAction)
            {
                case RequestActionEnum.Default:
                case RequestActionEnum.Read:
                case RequestActionEnum.Query:
                    DoSelect();
                    break;
                case RequestActionEnum.Custom:
                    if (RequestActionString == "getpermission")
                    {
                        DynamicPermission[] dps = null;
                        if (type == "user")
                        {
                            dps = DynamicPermission.GetOrgPermissions(id, DynamicPermissionCatalog.SysCatalogEnum.SYS_USER);
                        }
                        else if (type == "role")
                        {
                            dps = DynamicPermission.GetOrgPermissions(id, DynamicPermissionCatalog.SysCatalogEnum.SYS_ROLE);
                        }
                        else if (type == "group")
                        {
                            dps = DynamicPermission.GetOrgPermissions(id, DynamicPermissionCatalog.SysCatalogEnum.SYS_GROUP);
                        }
                        else
                        {
                            dps = DynamicPermission.GetPermissionsByCatalogCode(id, type);
                        }

                        PageState.Add("DPList", dps);
                    }
                    break;
                case RequestActionEnum.Update:
                    IList<string> pids = RequestData.GetList<string>("pidList");    // 权限标识
                    IList<string> aids = RequestData.GetList<string>("aidList");    // 授权标识
                    IList<string> ops = RequestData.GetList<string>("opList");      // 操作标识

                    string pcatalog = RequestData.Get<string>("pcatalog");
                    string tag = RequestData.Get<string>("tag");

                    for (int i = 0; i < pids.Count; i++)
                    {
                        var tpid = (pids[i] == null ? pids[i] : pids[i].Trim());
                        var taid = (aids[i] == null ? aids[i] : aids[i].Trim());
                        var top = (ops[i] == null ? ops[i] : ops[i].Trim());

                        if (!String.IsNullOrEmpty(tpid))
                        {
                            DynamicPermission dp = DynamicPermission.Find(tpid);
                            if (!String.IsNullOrEmpty(top))
                            {
                                dp.Operation = top;
                                dp.DoUpdate();
                            }
                            else
                            {
                                dp.DoDelete();
                            }
                        }
                        else
                        {
                            if (!String.IsNullOrEmpty(taid) && !String.IsNullOrEmpty(top))
                            {
                                DynamicAuth tauth = DynamicAuth.Find(taid);
                                IList<string> tOpList = top.Split(DynamicOperations.DivChar);

                                if (type == "user")
                                {
                                    DynamicPermission.GrantDAuthToUser(tauth, id, tOpList, null, UserInfo.UserID, UserInfo.Name);
                                }
                                else if (type == "role")
                                {
                                    DynamicPermission.GrantDAuthToRole(tauth, id, tOpList, null, UserInfo.UserID, UserInfo.Name);
                                }
                                else if (type == "group")
                                {
                                    DynamicPermission.GrantDAuthToGroup(tauth, id, tOpList, null, UserInfo.UserID, UserInfo.Name);
                                }
                                else
                                {
                                    DynamicPermission.GrantDAuths(new DynamicAuth[] { tauth }, new string[] { id }, tOpList, pcatalog, tag, UserInfo.UserID, UserInfo.Name);
                                }
                            }
                        }
                    }

                    break;
            }
        }

        #endregion

        #region 私有方法 

        /// <summary>
        /// 选择操作
        /// </summary>
        private void DoSelect()
        {
            DynamicAuthCatalog dac = null; // 动态权限类型

            SearchCriterion sc = new HqlSearchCriterion();
            SearchCriterion.SetOrder("SortIndex");
            SearchCriterion.SetOrder("CreatedDate");
            SearchCriterion.AddSearch("EditStatus", "G", SearchModeEnum.Like);  // 只显示允许授权的节点

            if (type == "catalog")
            {
                if (String.IsNullOrEmpty(code) && !String.IsNullOrEmpty(id))
                {
                    dac = DynamicAuthCatalog.Find(id);
                    code = dac.Code;
                }

                if (!String.IsNullOrEmpty(code))
                {
                    SearchCriterion.AddSearch("CatalogCode", code);
                    SearchCriterion.AddSearch("ParentID", SingleSearchModeEnum.IsNull);

                    ents = DynamicAuthRule.FindAll(SearchCriterion);

                    if (dac == null)
                    {
                        dac = DynamicAuthCatalog.FindFirst(Expression.Eq("Code", code));
                    }
                }
            }
            else if (!String.IsNullOrEmpty(id))
            {
                SearchCriterion.AddSearch("ParentID", id);

                ents = DynamicAuthRule.FindAll(SearchCriterion);

                DynamicAuth da = DynamicAuth.Find(id);
                dac = DynamicAuthCatalog.FindFirst(Expression.Eq("Code", da.CatalogCode));
            }

            this.PageState.Add("EntList", ents);

            if (!IsAsyncRequest)
            {
                if (dac != null)
                {
                    IList<DynamicPermissionCatalog> dpcs = dac.AllowGrantPermissionCatalog;
                    this.PageState.Add("PCatalogList", dpcs);

                    this.PageState.Add("AllowOperation", dac.GetAllowOperations()); // 允许的操作
                }

                this.PageState.Add("OpDivChar", DynamicOperations.DivChar); // 操作分割符
            }
        }

        #endregion
    }
}
