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
using Aim.WorkFlow;
namespace Aim.Portal.Web.WorkFlow
{
    public partial class WorkFlowDefineEdit : BasePage
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
            id = RequestData.Get<string>("id") == null ? RequestData.Get<string>("Id") : RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            WorkflowTemplate ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<WorkflowTemplate>();
                    ent.DoUpdate();
                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<WorkflowTemplate>();

                    // 设置项目信息
                    ent.Creator = UserInfo.Name;
                    ent.DoCreate();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<WorkflowTemplate>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    return;
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = WorkflowTemplate.Find(id);
                }
                this.SetFormData(ent);
            }
            else
            {
                PageState.Add("CreateName", UserInfo.Name);
                PageState.Add("CreateTime", DateTime.Now);
            }
        }

        #endregion
    }
}