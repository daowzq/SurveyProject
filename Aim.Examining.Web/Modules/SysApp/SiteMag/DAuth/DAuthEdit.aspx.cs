using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class DynamicAuthEdit : BasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            DynamicAuth ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Query:
                case RequestActionEnum.Read:
                case RequestActionEnum.Default:
                    if (op == "c")
                    {
                        DynamicAuthCatalog dacent = DynamicAuthCatalog.Find(id);
                        ent = new DynamicAuth();
                        ent.CatalogCode = dacent.Code;
                    }
                    else
                    {
                        ent = DynamicAuth.Find(id);
                    }
                    break;
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<DynamicAuth>();
                    if (!this.FormData.ContainsKey("Editable"))
                    {
                        ent.Editable = false;
                    }
                    if (!this.FormData.ContainsKey("Grantable"))
                    {
                        ent.Grantable = false;
                    }
                    ent.DoUpdate();
                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<DynamicAuth>();
                    ent.CreaterID = UserInfo.UserID;
                    ent.CreaterName = UserInfo.Name;

                    if (this.RequestAction == RequestActionEnum.Create)
                    {
                        ent.CreateAsTop(id);
                    }
                    else
                    {
                        ent.CreateAsSub(id);
                    }

                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<DynamicAuth>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    return;
            }

            this.SetFormData(ent);
        }

        #endregion
    }
}

