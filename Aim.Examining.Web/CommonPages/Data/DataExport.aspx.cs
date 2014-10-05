using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Common;

using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using Aim.Examining.Web;

namespace Aim.Portal.Web.CommonPages
{
    public partial class DataExport : ExamBasePage
    {
        private ExpFileTypeEnum fileType = ExpFileTypeEnum.Unknown;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string strFileType = Request["FileType"];
                if (!String.IsNullOrEmpty(strFileType))
                {
                    try
                    {
                        fileType = (ExpFileTypeEnum)Enum.Parse(typeof(ExpFileTypeEnum), strFileType, true);
                    }
                    catch { }
                }

                string strFileName = Request["ExportFile"];
                if (!String.IsNullOrEmpty(strFileName))
                {
                    if (fileType == ExpFileTypeEnum.Unknown)
                    {
                        string lowFileName = strFileName.ToLower();

                        if (lowFileName.EndsWith("xls") || lowFileName.EndsWith("xlsx"))
                        {
                            fileType = ExpFileTypeEnum.Excel;
                        }
                    }
                }

                if (!String.IsNullOrEmpty(Request["ExportContent"]))
                {
                    string tmpContent = HttpUtility.HtmlDecode(Request["ExportContent"]);   //获取传递上来的文件内容  

                    string tmpFileName = String.Empty;

                    if (Request["ExportFile"] != "")
                    {
                        tmpFileName = Request["ExportFile"];//获取传递上来的文件名   
                        tmpFileName = System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(tmpFileName));//处理中文文件名的情况                       
                    }

                    this.EnableViewState = false;   // 禁用ViewState

                    switch (fileType)
                    {
                        case ExpFileTypeEnum.Excel:
                            if (String.IsNullOrEmpty(tmpFileName))
                            {
                                tmpFileName = "export.xls";
                            }

                            WebHelper.ExportExtGridToExcel(tmpFileName, tmpContent);
                            break;
                    }
                }
            }
        }
    }
}
