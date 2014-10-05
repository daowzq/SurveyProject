using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Common;
using Aim.Portal.Model;

using Aim.Portal.Web.UI;

namespace Aim.Portal.Web.Modules.SysApp
{
    public partial class AppEdit : BasePage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op"); // 用户编辑操作
            id = RequestData.Get<string>("id");

            SysApplication ent = null;

            if (IsAsyncRequest)
            {
                switch (RequestAction)
                {
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Read:
                    case RequestActionEnum.Default:
                        break;
                    case RequestActionEnum.Create:
                        ent = this.GetPostedData<SysApplication>();
                        ent.DoCreate();
                        break;
                    case RequestActionEnum.Update:
                        ent = this.GetMergedData<SysApplication>();
                        ent.DoUpdate();
                        break;
                    case RequestActionEnum.Delete:
                        ent = this.GetTargetData<SysApplication>();
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
                        ent = SysApplication.Find(id);
                    }
                }
            }

            this.SetFormData(ent);
        }
    }
}
