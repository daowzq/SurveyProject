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
    public partial class RolTypeEdit : BasePage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string pt = String.Empty; // 父模块类型

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op"); // 用户编辑操作
            id = RequestData.Get<string>("id");
            pt = RequestData.Get<string>("pt");

            SysRoleType ent = null;

            if (IsAsyncRequest)
            {
                switch (RequestAction)
                {
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Read:
                    case RequestActionEnum.Default:
                        break;
                    case RequestActionEnum.Create:
                        ent = this.GetPostedData<SysRoleType>();
                        ent.DoCreate();
                        break;
                    case RequestActionEnum.Update:
                        ent = this.GetMergedData<SysRoleType>();
                        ent.DoUpdate();
                        break;
                    case RequestActionEnum.Delete:
                        ent = this.GetTargetData<SysRoleType>();
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
                        ent = SysRoleType.Find(Convert.ToInt32(id));
                    }
                }
            }

            this.SetFormData(ent);
        }
    }
}
