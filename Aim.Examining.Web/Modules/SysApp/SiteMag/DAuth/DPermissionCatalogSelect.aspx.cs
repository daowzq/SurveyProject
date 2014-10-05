using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class DPermissionCatalogSelect : BaseListPage
    {
        #region 变量

        private DynamicPermissionCatalog[] ents = null;

        #endregion

        #region 构造函数

        public DPermissionCatalogSelect()
        {
            SearchCriterion.AllowPaging = false;
            IsCheckLogon = false;
        }

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            if (SearchCriterion.Orders.Count <= 0)
            {
                SearchCriterion.SetOrder("SortIndex");
                SearchCriterion.SetOrder("CreatedDate");
            }

            ents = DynamicPermissionCatalogRule.FindAll(SearchCriterion);

            this.PageState.Add("DtList", ents);
        }

        #endregion
    }
}
