using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using Aim.Portal.Model;
using Aim.Examining.Model;
using FLWebServices;
using System.Data;
using Aim.Data;
using Aim.Portal;

namespace Aim.Examining.Web
{
    public partial class Login : ExamBasePage
    {
        public Login()
        {
            base.IsCheckLogon = false;
        }
        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            if (RequestActionString == "dologin")
            {
                LoginUser(RequestData.Get<string>("uname"), RequestData.Get<string>("pwd"), true, "0");
            }
            else
            {

            }
        }

        #endregion

        #region 私有方法

        /// <summary>
        /// 由金慧Passcode登录
        /// </summary>
        /// <param name="passcode"></param>
        private void DoLoginByGwPassCodeAndWorkNo(string passcode, string workno)
        {
            bool stateflag = true;
            if (stateflag)
            {
                SysUser usr = SysUser.FindFirstByProperties("WorkNo", workno);
                LoginUser(usr.LoginName, usr.Password, true, "");
            }
        }

        /// <summary>
        /// 用户登录
        /// </summary>
        /// <param name="uname"></param>
        /// <param name="pwd"></param>
        private void LoginUser(string uname, string pwd, bool pwdEncrypted, string loginstate)
        {
            try
            {
                string CorpId = RequestData.Get<string>("CorpId");
                SysUser userent = SysUser.FindAllByProperty(SysUser.Prop_LoginName, uname).FirstOrDefault();
                if (userent == null)
                {
                    PageState.Add("error", "用户名错误！");
                    return;
                }
                if (string.IsNullOrEmpty(userent.Password))
                {
                    PageState.Add("error", "nullpwd");
                    return;
                }

                //判断登陆人有没有在这个公司
                string sql = @"select count(1) from SysUserGroup where UserId='{0}' and GroupId not in (select RoleId from sysRole) and isnull(outdutydate,'')='' and pk_gw is not null and pk_corp='{1}'";
                int corpcount = DataHelper.QueryValue<int>(string.Format(sql, userent.UserID, CorpId));
                if (corpcount > 0 || uname == "admin")
                {
                    string sid = PortalService.AuthUser(uname, pwd, false);
                    if (!String.IsNullOrEmpty(sid))
                    {
                        string url = FormsAuthentication.GetRedirectUrl(uname, true);
                        string returnUrl = RequestData.Get<string>("ReturnUrl");
                        Session["CompanyId"] = CorpId;
                        if (!string.IsNullOrEmpty(returnUrl))
                        {
                            url = returnUrl;
                            Session["CompanyId"] = CorpId;
                            //公司
                            SysGroup group = SysGroup.TryFind(CorpId);
                            if (group != null)
                            {
                                Session["CompanyName"] = group.Name;
                            }
                            else
                            {
                                Session["CompanyName"] = "";
                            }
                        }
                        PageState.Add("url", url);

                    }
                    else
                    {
                        PageState.Add("error", "登陆失败，用户名或密码不正确！");
                    }
                    return;
                }
                else
                {
                    //查询该人员有没有
                    DataTable dtrole = DataHelper.QueryDataTable("select CompanyIds from sysrole where roleid in ( select RoleID from SysUserRole where UserId='" + userent.UserID + "')");
                    bool hasQX = false;
                    foreach (DataRow row in dtrole.Rows)
                    {
                        if ((row["CompanyIds"] + "").Contains(CorpId))
                        {
                            hasQX = true;
                            break;
                        }
                    }
                    if (hasQX)
                    {
                        string sid = PortalService.AuthUser(uname, pwd, false);
                        if (!String.IsNullOrEmpty(sid))
                        {
                            string url = FormsAuthentication.GetRedirectUrl(uname, true);
                            PageState.Add("url", url);

                            Session["CompanyId"] = CorpId;
                        }
                        else
                        {
                            PageState.Add("error", "登陆失败，用户名或密码不正确！");
                        }
                    }
                    else
                    {
                        PageState.Add("error", "您没有该公司的权限，请重新选择公司！");
                    }
                    return;
                }
            }
            catch (Exception ex)
            {
                PageState.Add("error", ex.Message);
            }
        }

        #endregion
    }
}
