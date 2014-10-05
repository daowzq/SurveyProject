using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Common;
using Aim.Security;
using Aim.Portal.Model;

using Aim.Portal.Web.UI;

namespace Aim.Portal.Web.Modules.SysApp.OrgMag
{
    public partial class UsrChgPwd : BasePage
    {
        public UsrChgPwd()
        {
            IsCheckLogon = false;
        }

        string op = String.Empty;
        string id = String.Empty;   // 对象id

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op"); // 用户编辑操作
            id = RequestData.Get<string>("id");

            SysUser ent = null;

            if (IsAsyncRequest)
            {
                switch (RequestAction)
                {
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Read:
                    case RequestActionEnum.Default:
                        break;
                    case RequestActionEnum.Create:
                        ent = this.GetPostedData<SysUser>();
                        ent.DoCreate();
                        break;
                    case RequestActionEnum.Update:
                        ent = this.GetMergedData<SysUser>();
                        ent.DoUpdate();
                        break;
                    case RequestActionEnum.Delete:
                        ent = this.GetTargetData<SysUser>();
                        ent.DoDelete();
                        break;
                    case RequestActionEnum.Custom:
                        if (RequestActionString == "chgpwd")
                        {
                            this.ChgPwd(FormData["LoginName"].ToString(), FormData["OrgPassword"].ToString(), FormData["Password"].ToString());
                        }
                        break;
                }
            }
            else
            {
                if (op != "c")
                {
                    if (!String.IsNullOrEmpty(id))
                    {
                        ent = SysUser.Find(id);
                    }
                }
            }

            this.SetFormData(ent);
        }

        private void ChgPwd(string loginName, string orgPwd, string newPwd)
        {
            MD5Encrypt encrypt = new MD5Encrypt();
            string encryPassword = String.Empty;
            encryPassword = encrypt.GetMD5FromString(orgPwd);

            // 验证用户
            SysUser user = SysUserRule.Authenticate(loginName, encryPassword);

            if (user != null)
            {
                if (String.IsNullOrEmpty(newPwd))
                {
                    user.Password = null;
                }
                else
                {
                    string newEncryPwd = encrypt.GetMD5FromString(newPwd);
                    user.Password = newEncryPwd;
                }

                user.Update();

                SetMessage("修改密码成功！");
            }
            else
            {
                throw new Exception("用户名或密码不正确！");
            }
        }
    }
}
