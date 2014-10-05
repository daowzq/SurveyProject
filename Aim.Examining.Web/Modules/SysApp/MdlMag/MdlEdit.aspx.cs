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

namespace Aim.Portal.Web.Modules.SysApp.MdlMag
{
    public partial class MdlEdit : BasePage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string pt = String.Empty; // 父模块类型

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op"); // 用户编辑操作
            id = RequestData.Get<string>("id");
            pt = RequestData.Get<string>("pt");

            SysModule ent = null;

            if (IsAsyncRequest)
            {
                switch (RequestAction)
                {
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Read:
                    case RequestActionEnum.Default:
                        break;
                    case RequestActionEnum.Create:
                        ent = this.GetPostedData<SysModule>();
                        ent.DoCreate();
                        break;
                    case RequestActionEnum.Update:
                        ent = this.GetMergedData<SysModule>();
                        ent.DoUpdate();
                        break;
                    case RequestActionEnum.Delete:
                        ent = this.GetTargetData<SysModule>();
                        ent.DoDelete();
                        break;
                    default:
                        if (RequestActionString == "createsub")
                        {
                            if (!String.IsNullOrEmpty(id))
                            {
                                ent = this.GetPostedData<SysModule>();
                                if (pt == "App")
                                {
                                    // 父节点为应用程序时，添加模块
                                    ent.ApplicationID = id;
                                    ent.CreateAsTop();
                                }
                                else
                                {
                                    // 父节点为模块时，添加子模块
                                    ent.CreateAsSub(id);
                                }
                            }
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
                        ent = SysModule.Find(id);
                    }
                }

                DataEnum de = SysModuleTypeRule.GetModuleTypeEnum();
                this.PageState.Add("MdlTypeEnum", de);
            }

            this.SetFormData(ent);
        }
    }
}
