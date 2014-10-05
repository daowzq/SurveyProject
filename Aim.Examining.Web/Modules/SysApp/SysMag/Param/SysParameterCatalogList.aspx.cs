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
    public partial class SysParameterCatalogList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private SysParameterCatalog[] ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {            
            SysParameterCatalog ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysParameterCatalog>();
                    ent.Delete();
                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    IList<object> idList = RequestData.GetList<object>("IdList");

                    if (idList != null && idList.Count > 0)
                    {
                        if (RequestActionString == "batchdelete")
                        {                            
                            SysParameterCatalog.DoBatchDelete(idList.ToArray());
                        }
                    }
                    break;
                default:
					ents = SysParameterCatalogRule.FindAll(SearchCriterion);
					this.PageState.Add("SysParameterCatalogList", ents);
					break;
            }
            
        }

        #endregion

        #region 私有方法

        #endregion
    }
}

