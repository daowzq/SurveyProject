using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aim.Portal.Web.Masters.Ext
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Session["CompanyId"] + "" == "")
            //{
            //    Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "ad2sf", "window.location='/Login.aspx?ReturnUrl='+window.location;", true);
            //}
        }
    }
}
