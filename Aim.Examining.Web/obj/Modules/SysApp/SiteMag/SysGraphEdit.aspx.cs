using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Xml.Linq;
using System.Collections.Generic;

using Aim.Common;
using Aim.Portal.Model;

using Aim.Portal.Web.UI;

namespace Aim.Portal.Web.Modules.SiteMag
{
    public partial class SysGraphEdit : BasePage
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

            SysGraph ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SysGraph>();
                    ent.DoUpdate();
                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SysGraph>();

                    ent.CreaterID = UserInfo.UserID;
                    ent.CreaterName = UserInfo.Name;

                    ent.DoCreate();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysGraph>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    return;
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = SysGraph.Find(id);
                    this.SetFormData(ent);
                }
                else
                {
                    if (op == "r")
                    {
                        ent = SysGraph.FindFirst();
                        this.SetFormData(ent);
                    }
                }
            }
            else
            {
                this.PageState.Add("CreaterName", UserInfo.Name);
                this.PageState.Add("CreatedDate", DateTime.Now);
            }
        }

        #endregion
    }
}
