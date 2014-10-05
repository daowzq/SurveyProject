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
using Aim.Portal.FileSystem;
using Aim.Portal.Data;
namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class SysDataExportTemplateEdit : BasePage
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

            SysDataExportTemplate ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetTargetData<SysDataExportTemplate>();
                    SysDataExportTemplate pent = this.GetPostedData<SysDataExportTemplate>();

                    bool isTemplateFileChanged = false;
                    if (ent.TemplateFileID != pent.TemplateFileID)
                    {
                        isTemplateFileChanged = true;
                    }

                    DataHelper.MergeData(ent, pent);    // 手工合并源数据与提交数据

                    if (isTemplateFileChanged)
                    {
                        DataExportService.DoExportTemplateFileChanged(ent); // 触发模版文件变化操作
                    }

                    ent.DoUpdate();

                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SysDataExportTemplate>();

                    ent.CreaterID = UserInfo.UserID;
                    ent.CreaterName = UserInfo.Name;

                    DataExportService.DoExportTemplateFileChanged(ent); // 触发模版文件变化操作

                    ent.DoCreate();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysDataExportTemplate>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    return;
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = SysDataExportTemplate.Find(id);
                }
                
                this.SetFormData(ent);
            }
            else
            {
                PageState.Add("CreaterName", UserInfo.Name);
                PageState.Add("CreatedDate", DateTime.Now);
            }
        }

        #endregion
    }
}

