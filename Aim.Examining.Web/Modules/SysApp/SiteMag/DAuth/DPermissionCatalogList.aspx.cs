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
    public partial class DPermissionCatalogList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private DynamicPermissionCatalog[] ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            ents = DynamicPermissionCatalogRule.FindAll(SearchCriterion);

            this.PageState.Add("DynamicPermissionCatalogList", ents);
            
            DynamicPermissionCatalog ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<DynamicPermissionCatalog>();
                    ent.DoCreate();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<DynamicPermissionCatalog>();
                    ent.DoUpdate();
                    this.SetMessage("保存成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<DynamicPermissionCatalog>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    IList<object> idList = RequestData.GetList<object>("IdList");

                    if (idList != null && idList.Count > 0)
                    {
                        if (RequestActionString == "batchdelete")
                        {
                            DynamicPermissionCatalogRule.BatchRemoveByPrimaryKeys(idList);
                        }
                    }
                    break;
            }
            
        }

        #endregion

        #region 私有方法

        #endregion
    }
}

