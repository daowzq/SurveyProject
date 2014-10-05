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
using Aim.Portal.FileSystem;

namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class SysDataImportTemplateList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private SysDataImportTemplate[] ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {            
            SysDataImportTemplate ent = null;
            
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysDataImportTemplate>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    IList<object> idList = RequestData.GetList<object>("IdList");

                    if (idList != null && idList.Count > 0)
                    {
                        if (RequestActionString == "batchdelete")
                        {                            
                            SysDataImportTemplate.DoBatchDelete(idList.ToArray());
                        }
                    }
                    break;
                default:
					ents = SysDataImportTemplateRule.FindAll(SearchCriterion);
                    this.PageState.Add("SysDataImportTemplateList", ents);
					break;
            }
            
        }

        #endregion

        #region 私有方法

        #endregion
    }
}

