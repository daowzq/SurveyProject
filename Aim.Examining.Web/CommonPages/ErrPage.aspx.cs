using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aim.Portal.Web.CommonPages
{
    public partial class ErrPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();

            if (ex != null)
            {
                lblErrMessage.Text = ex.Message;
            }

            Server.ClearError();
        }
    }
}
