using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using System.Web.UI.WebControls;
using Aim.Security;
namespace Aim.Examining.Web
{
    public partial class SurveySumit : BasePage
    {
        public SurveySumit()
        {
            IsCheckLogon = false;
            IsCheckAuth = false;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string Id = Request["Id"] + "";
            string uid = Request["uid"] + "";
            string workNo = WebSecurity.EncryptorEencrypt.Des3DecryptStr(uid);
            string sql = "select top 1 UserID from  FL_PortalHR..sysuser where WorkNo='" + workNo + "' ";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);

            uid = DataHelper.QueryValue(sql) + "";
            string url = "SurveyManage/InternetSurvey.aspx?Id=" + Id + "&uid=" + uid + "&op=r";
            Response.Redirect(url, true);
            //Response.Write(WebSecurity.EncryptorEencrypt.Des3EncrypStr("46c5f4df-f6d1-4b36-96ac-d39d3dd65a5d"));
        }
    }
}
