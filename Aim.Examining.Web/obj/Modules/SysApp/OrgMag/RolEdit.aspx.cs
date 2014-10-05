using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Common;
using Aim.Portal.Model;

using Aim.Portal.Web.UI;

namespace Aim.Portal.Web.Modules.SysApp.OrgMag
{
    public partial class RolEdit : BasePage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string pt = String.Empty; // 父模块类型

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op"); // 用户编辑操作
            id = RequestData.Get<string>("id");
            pt = RequestData.Get<string>("pt");

            SysRole ent = null;

            if (IsAsyncRequest)
            {
                switch (RequestAction)
                {
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Read:
                    case RequestActionEnum.Default:
                        break;
                    case RequestActionEnum.Create:
                        ent = this.GetPostedData<SysRole>();
                        ent.DoCreate();
                        break;
                    case RequestActionEnum.Update:
                        ent = this.GetMergedData<SysRole>();
                        ent.DoUpdate();
                        break;
                    case RequestActionEnum.Delete:
                        ent = this.GetTargetData<SysRole>();
                        ent.DoDelete();
                        break;
                }
            }
            else
            {
                if (op != "c")
                {
                    if (!String.IsNullOrEmpty(id))
                    {
                        ent = SysRole.Find(id);
                    }
                }
            }

            DataEnum de = SysRoleTypeRule.GetRoleTypeEnum();
            this.PageState.Add("RolTypeEnum", de);

            this.SetFormData(ent);
        }
    }
}
