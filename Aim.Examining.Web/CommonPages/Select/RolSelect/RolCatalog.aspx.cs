using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;


namespace Aim.Portal.Web.CommonPages
{
    public partial class RolCatalog : BaseListPage
    {
        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            SysRoleType[] roleTypes = SysRoleTypeRule.FindAll();
            this.PageState.Add("DtList", roleTypes);
        }

        #endregion
    }
}
