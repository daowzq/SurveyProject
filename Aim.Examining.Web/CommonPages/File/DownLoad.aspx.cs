using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

using Aim.Common;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;

namespace Aim.Portal.Web.CommonPages
{
    public partial class DownLoad : BasePage
    {
        public DownLoad()
        {
            this.IsCheckLogon = false;
        }
        string fileId = String.Empty;
        string FileName = string.Empty;
        private void Page_Load(object sender, System.EventArgs e)
        {
            this.EnableViewState = false;   // 禁用ViewState

            fileId = Request["id"];
            Stream iStream = null;
            FileName = Request["FileName"];

            try
            {
                if (!String.IsNullOrEmpty(fileId))
                {
                    FileItem file = FileItem.Find(fileId);

                    // 下载大附件的方法
                    iStream = new FileStream(file.FilePath, FileMode.Open, FileAccess.Read, FileShare.Read);
                    WebHelper.ResponseFile(iStream, file.Name);
                }
                else if (!string.IsNullOrEmpty(FileName))
                {
                    string path = MapPath("../../help/" + FileName);
                    // 下载大附件的方法
                    iStream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);
                    WebHelper.ResponseFile(iStream, FileName);
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script language=JScript>");
                Response.Write("alert(\"" + ex.Message + ",下载Id=" + fileId + " 的文件时发生系统级错误\");");
                Response.Write("</script>");
            }
            finally
            {
                if (iStream != null)
                {
                    iStream.Close();
                }

                Response.End();
            }
        }
    }
}
