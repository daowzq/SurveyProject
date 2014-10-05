using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Common;
using Aim.Portal.Model;

using Aim.Portal.Web.UI;

namespace Aim.Portal.Web.Office
{
    public partial class SysMessageEdit : BasePage
    {
        #region 变量

        string recid = String.Empty;
        string title = String.Empty;
        string op = String.Empty;

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            recid = RequestData.Get<string>("recid");
            title = RequestData.Get<string>("title", String.Empty);
            op = RequestData.Get<string>("op");

            SysMessage msg = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    msg = this.GetMergedData<SysMessage>();
                    msg.SaveAndFlush();
                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Create:
                    msg = this.GetPostedData<SysMessage>();

                    msg.SenderId = this.UserInfo.UserID;
                    msg.SenderName = this.UserInfo.Name;
                    msg.SendTime = DateTime.Now;

                    msg.CreateAndFlush();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Delete:
                    msg = this.GetTargetData<SysMessage>();
                    msg.DeleteAndFlush();
                    this.SetMessage("删除成功！");
                    return;
            }

            if (this.Request["Id"] != null)
            {
                msg = SysMessage.Find(this.Request["Id"]);
            }
            else if(op == "c")
            {
                if (!String.IsNullOrEmpty(recid))
                {
                    SysUser tusr = SysUser.Find(recid);

                    PageState.Add("ReceiverInfo", tusr);
                    PageState.Add("Title", title);
                }
            }

            this.SetFormData(msg);
        }

        #endregion
    }
}
