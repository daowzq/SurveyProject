using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;

namespace Aim.Portal.Web.WebPart
{
    public partial class WebPartEdit : BasePage
    {
        #region 变量

        protected string JsonData = "";

        #endregion

        #region 构造函数

        public WebPartEdit()
        {
            // IsAsyncPage = true;
        }

        #endregion;

        #region ASP.NET 事件


        protected void Page_Load(object sender, EventArgs e)
        {
            Aim.Portal.Model.WebPart usr = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    usr = this.GetMergedData<Aim.Portal.Model.WebPart>();
                    usr.SaveAndFlush();
                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                case RequestActionEnum.Copy:
                    usr = this.GetPostedData<Aim.Portal.Model.WebPart>();
                    usr.IsHidden = "0";
                    usr.CreateAndFlush();
                    if (RequestAction == RequestActionEnum.Copy)
                    {
                        this.SetMessage("复制成功！");
                    }
                    else
                    {
                        this.SetMessage("新建成功！");
                    }
                    break;
                case RequestActionEnum.Delete:
                    usr = this.GetTargetData<Aim.Portal.Model.WebPart>();
                    usr.DeleteAndFlush();
                    this.SetMessage("删除成功！");
                    return;
                case RequestActionEnum.Default:
                    break;
            }

            if (this.Request["Id"] != null)
            {
                Aim.Portal.Model.WebPart user = Aim.Portal.Model.WebPart.Find(this.Request["Id"]);
                this.SetFormData(user);
            }
        }

        #endregion
    }
}
