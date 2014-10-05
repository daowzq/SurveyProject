using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aim.Portal.Web
{
    public partial class Unlogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 登出页面
            PortalService.Logout();
        }
    }
}
