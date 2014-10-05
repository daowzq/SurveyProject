using System;
using System.Collections.Generic;
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
    public partial class DPermissionGrant : BasePage
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
                }
            }
        }

        #endregion
    }
}
