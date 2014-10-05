using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Common;
using Aim.Web.UI;
using Aim.Portal.Entity;
using Aim.Portal.Rule;
using Aim.Portal.Model;

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
