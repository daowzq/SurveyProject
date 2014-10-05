using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;
using FLWebServices;

namespace Aim.Examining.Web
{
    public partial class FrmTransitionPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string employee_id;
            if (Request.QueryString["employee_id"] + "" != "")
            {
                employee_id = Request.QueryString["employee_id"] + "";
                employee_id = SSoService.Singletion.Decrypt(employee_id);
                if (!string.IsNullOrEmpty(employee_id))
                {
                    if (SysUser.FindAllByProperties("LoginName", employee_id).Length > 0)
                    {
                        LoginUser(employee_id, "mhxzkhl2012", false);
                    }
                    else
                    {
                        ClientScript.RegisterClientScriptBlock(this.GetType(), "adsf", "window.parent.location.href='/Login.aspx'", true);
                        return;
                    }
                }
            }
            else
            {
                ClientScript.RegisterClientScriptBlock(this.GetType(), "adsf", "window.parent.location.href='/Login.aspx'", true);
                return;
            }
        }

        /// <summary>
        /// 用户登录
        /// </summary>
        /// <param name="uname"></param>
        /// <param name="pwd"></param>
        private void LoginUser(string uname, string pwd, bool pwdEncrypted)
        {
            try
            {
                SysUser userent = SysUser.FindAllByProperty(SysUser.Prop_LoginName, uname).FirstOrDefault();
                if (userent == null)
                {
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "adsf", "window.parent.location.href='/Login.aspx'", true);
                    return;
                }

                string CorpId = userent.Pk_corp;
                SysGroup group = SysGroup.TryFind(CorpId);
                Session["CompanyId"] = CorpId;
                if (group != null)
                {
                    Session["CompanyName"] = group.Name;
                }
                else
                {
                    Session["CompanyName"] = "";
                }

                string sid = PortalService.AuthUser(uname, pwd, false);
                if (!String.IsNullOrEmpty(sid))
                {
                    string url = FormsAuthentication.GetRedirectUrl(uname, true);
                    Response.Redirect(url);
                    return;
                }
                else
                {
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "adsf", "window.parent.location.href='/Login.aspx'", true);
                    return;
                }
            }
            catch { }
        }
    }
}
