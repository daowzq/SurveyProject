using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Xml.Linq;

using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
namespace Aim.Examining.Web
{
    public partial class Home : BasePage
    {
        public string Html = "";
        public string LayoutXML = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            string userId = this.UserInfo.UserID;
            Html = WebPartRule.GetBlocks(userId, this.UserInfo.LoginName, ref LayoutXML, this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"]);
        }
    }
}
