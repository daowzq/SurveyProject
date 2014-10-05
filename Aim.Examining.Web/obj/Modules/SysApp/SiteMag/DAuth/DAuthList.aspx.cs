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
    public partial class DAuthList : BasePage
    {
        #region 变量

        private DynamicAuth[] ents = null;

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string code = String.Empty; // 对象类型

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            code = RequestData.Get<string>("code");

            if (IsAsyncRequest)
            {
                DynamicAuth ent = null;

                switch (this.RequestAction)
                {
                    case RequestActionEnum.Read:
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Default:
                        if (SearchCriterion.Orders.Count <= 0)
                        {
                            SearchCriterion.SetOrder("SortIndex");
                            SearchCriterion.SetOrder("CreatedDate");
                        }

                        SearchCriterion.AddSearch("CatalogCode", code);
                        SearchCriterion.AddSearch("EditStatus", SingleSearchModeEnum.IsNotNull);
                        SearchCriterion.AddSearch("EditStatus", "", SearchModeEnum.NotEqual);

                        if (String.IsNullOrEmpty(id))
                        {
                            SearchCriterion.AddSearch("ParentID", SingleSearchModeEnum.IsNull);
                        }
                        else
                        {
                            SearchCriterion.AddSearch("ParentID", id);
                        }

                        ents = DynamicAuthRule.FindAll(SearchCriterion);
                        break;
                    case RequestActionEnum.Delete:
                        ent = DynamicAuth.Find(id);
                        ent.DoDelete();
                        this.SetMessage("删除成功！");
                        break;
                }

                this.PageState.Add("EntList", ents);
            }
            else
            {
                SearchCriterion sc = new HqlSearchCriterion();
                sc.SetOrder("SortIndex");
                sc.SetOrder("CreatedDate");
                DynamicAuthCatalog[] entCatalogs = DynamicAuthCatalogRule.FindAll(sc);

                this.PageState.Add("EntCatalogList", entCatalogs);
            }
        }

        #endregion
    }
}
