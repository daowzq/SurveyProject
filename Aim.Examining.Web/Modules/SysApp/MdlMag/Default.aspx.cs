using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Common;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.MdlMag
{
    public partial class Default : BasePage
    {
        #region 变量

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsAsyncRequest)
            {
                switch (this.RequestAction)
                {
                    case RequestActionEnum.Custom:
                        if (RequestActionString == "querychildren")
                        {
                            SysModule[] mdls = null;
                            if (RequestData.ContainsKey("ModuleID") && RequestData["ModuleID"] != null)
                            {
                                mdls = SysModule.FindAll("FROM SysModule as mdl WHERE mdl.ParentID = ?", RequestData["ModuleID"]);
                            }
                            else if (RequestData.ContainsKey("ApplicationID") && RequestData["ApplicationID"] != null)
                            {
                                mdls = SysModule.FindAll("FROM SysModule as mdl WHERE mdl.ApplicationID = ? AND  mdl.ParentID is null", RequestData["ApplicationID"]);
                            }

                            mdls= mdls.OrderBy(ent => ent.SortIndex).ToArray();

                            this.PageState.Add("Mdls", mdls);
                        }
                        else if (RequestActionString == "refreshsys")
                        {
                            PortalService.RefreshSysModules();
                            SetMessage("操作成功！");
                        }
                        break;
                }
            }
            else
            {
                SysApplication[] sysApps = SysApplicationRule.FindAll();
                sysApps = sysApps.OrderBy(ent => ent.SortIndex).ToArray();
                this.PageState.Add("Apps", sysApps);

                DataEnum de = SysModuleTypeRule.GetModuleTypeEnum();
                this.PageState.Add("MdlTypeEnum", de);
            }
        }

        #endregion
    }
}
