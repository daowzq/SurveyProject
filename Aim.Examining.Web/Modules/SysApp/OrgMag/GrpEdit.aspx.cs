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
    public partial class GrpEdit : BasePage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string pt = String.Empty; // 父模块类型

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op"); // 用户编辑操作
            id = RequestData.Get<string>("id");
            pt = RequestData.Get<string>("pt");

            SysGroup ent = null;

            if (IsAsyncRequest)
            {
                switch (RequestAction)
                {
                    case RequestActionEnum.Query:
                    case RequestActionEnum.Read:
                    case RequestActionEnum.Default:
                        break;
                    case RequestActionEnum.Create:
                        ent = this.GetPostedData<SysGroup>();
                        ent.Create();
                        break;
                    case RequestActionEnum.Update:
                        ent = this.GetMergedData<SysGroup>();
                        ent.DoUpdate();
                        break;
                    case RequestActionEnum.Delete:
                        ent = this.GetTargetData<SysGroup>();
                        ent.DoDelete();
                        break;
                    default:
                        if (RequestActionString == "createsub")
                        {
                            ent = this.GetPostedData<SysGroup>();
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
                        ent = SysGroup.Find(id);
                    }
                }
            }

            DataEnum de = SysGroupTypeRule.GetGroupTypeEnum();
            this.PageState.Add("GrpTypeEnum", de);

            this.SetFormData(ent);
        }
    }
}
