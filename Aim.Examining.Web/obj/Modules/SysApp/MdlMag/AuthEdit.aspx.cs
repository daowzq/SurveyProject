using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Common;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.MdlMag
{
    public partial class AuthEdit : BasePage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op"); // 用户编辑操作
            id = RequestData.Get<string>("id");

            SysAuth ent = null;

            if (IsAsyncRequest)
            {
                switch (RequestAction)
                {
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Default:
                        break;
                    case RequestActionEnum.Create:
                        ent = this.GetPostedData<SysAuth>();
                        ent.CreateAndFlush();
                        break;
                    case RequestActionEnum.Delete:
                        ent = this.GetTargetData<SysAuth>();
                        ent.DeleteAndFlush();
                        break;
                    default:
                        if (RequestActionString == "createsub")
                        {
                            ent = this.GetPostedData<SysAuth>();
                            ent.CreateAsSub(id);
                        }
                        break;
                }
            }
            else
            {
                if (op != "c" && op != "cs")
                {
                    if (!String.IsNullOrEmpty(id))
                    {
                        ent = SysAuth.Find(id);
                    }
                }
            }

            DataEnum de = SysAuthTypeRule.GetAuthTypeEnum();
            this.PageState.Add("AuthTypeEnum", de);

            this.SetFormData(ent);
        }
    }
}
