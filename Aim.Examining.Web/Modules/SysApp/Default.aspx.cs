using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Common;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp
{
    public partial class Default : BasePage
    {
        #region 成员

        //private const string MDL_CODE = "SYS_ORG";
        private const string APP_CODE = "SYS";

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET事件

        protected void Page_Load(object sender, EventArgs e)
        {
            SysApplication app = SysApplicationRule.FindByCode(APP_CODE);
            IList<SysModule> mdls = app.GetModulesByLevel(0, 5);    // 获取深度为0~5的模块

            PageState.Add("Mdls", mdls);
        }

        #endregion
    }

}
