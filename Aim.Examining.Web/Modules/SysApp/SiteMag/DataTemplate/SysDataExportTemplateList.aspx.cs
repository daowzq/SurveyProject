using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Model;
using Aim.Common;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Data;

namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class SysDataExportTemplateList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private SysDataExportTemplate[] ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {            
            SysDataExportTemplate ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysDataExportTemplate>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "batchrefresh")
                    {
                        DoBatchRefresh();
                    }
                    else
                    {
                        ents = SysDataExportTemplateRule.FindAll(SearchCriterion);
                        this.PageState.Add("SysDataExportTemplateList", ents);
                    }
                    break;
            }
            
        }

        #endregion

        #region 私有方法

        /// <summary>
        /// 批量删除
        /// </summary>
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                SysDataExportTemplate.DoBatchDelete(idList.ToArray());
            }
        }

        /// <summary>
        /// 刷新模板（重新生成config）
        /// </summary>
        private void DoBatchRefresh()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                SysDataExportTemplate[] tmpls = SysDataExportTemplate.FindAllByPrimaryKeys(idList.ToArray());

                tmpls.All((SysDataExportTemplate tmpl) => { DataExportService.DoExportTemplateFileChanged(tmpl); tmpl.DoUpdate(); return true; });
            }
        }

        #endregion
    }
}

