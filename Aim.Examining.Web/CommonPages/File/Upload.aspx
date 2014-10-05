<%@ Page Language="c#" AutoEventWireup="true" %>

<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Aim.Common" %>

<script runat="server">

    string UploadServiceUrl = String.Empty;

    private void Page_Init(object sender, EventArgs e)
    {    
        if (Request.Url.Host.Contains("221.224.21.25"))
        {
            UploadServiceUrl =ConfigurationHosting.SystemConfiguration.AppSettings["UploadServiceUrl2"];
        }
        else
        {
            if (ConfigurationHosting.SystemConfiguration.AppSettings.ContainsKey("UploadServiceUrl"))
            {
                UploadServiceUrl = ConfigurationHosting.SystemConfiguration.AppSettings["UploadServiceUrl"];
            }
            else
            {
                UploadServiceUrl = String.Format(@"http://{0}:8007/UploadService.svc", Dns.GetHostName());
            }
        }
    }
    
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" style="height: 100%;">
<head id="Head1" runat="server">
    <title>文件上传</title>
    <style type="text/css">
        html, body
        {
            height: 100%;
            overflow: auto;
        }
        body
        {
            padding: 0;
            margin: 0;
        }
        #silverlightControlHost
        {
            height: 100%;
        }
    </style>

    <script type="text/javascript" src="Silverlight.js"></script>

    <script type="text/javascript">
        function getQueryString(name)//name 是URL的参数名字 
        {
            var reg = new RegExp("(^|&|\\?)" + name + "=([^&]*)(&|$)"), r;
            if (r = window.location.href.match(reg)) return unescape(r[2]); return null;
        }

        function onSilverlightError(sender, args) {
            var appSource = "";
            if (sender != null && sender != 0) {
                appSource = sender.getHost().Source;
            }
            var errorType = args.ErrorType;
            var iErrorCode = args.ErrorCode;

            var errMsg = "Silverlight 2 应用程序中未处理的错误 " + appSource + "\n";

            errMsg += "代码: " + iErrorCode + "    \n";
            errMsg += "类别: " + errorType + "       \n";
            errMsg += "消息: " + args.ErrorMessage + "     \n";

            if (errorType == "ParserError") {
                errMsg += "文件: " + args.xamlFile + "     \n";
                errMsg += "行号: " + args.lineNumber + "     \n";
                errMsg += "位置: " + args.charPosition + "     \n";
            }
            else if (errorType == "RuntimeError") {
                if (args.lineNumber != 0) {
                    errMsg += "行号: " + args.lineNumber + "     \n";
                    errMsg += "位置: " + args.charPosition + "     \n";
                }
                errMsg += "方法名称: " + args.methodName + "     \n";
            }

            // throw new Error(errMsg);
            alert(args.ErrorMessage);
        }

        var slCtl = null;
        function pluginLoaded(sender) {
            //IMPORTANT: Make sure this is the same ID as the ID in your <OBJECT tag (<object id="MultiFileUploader" etc)
            slCtl = document.getElementById("MultiFileUploader");

            // slCtl.Content.Control.Single = true;
            /*
            //单选多选设置 slCtl.Content.Control.Single=true;
            
            //文件类型过滤
            slCtl.Content.Control.FileFilter = "All   Image   Formats   (*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.tif)| " +
            "*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.tif|Bitmaps   (*.bmp)|*.bmp|" +
            "GIFs   (*.gif)|*.gif|JPEGs   (*.jpg)|*.jpg;*.jpeg|PNGs   (*.png)|*.png|TIFs   (*.tif)|*.tif|All   Files   (*.*)|*.* ";
            */
            ///CommonPages/File/Upload.aspx?IsSingle=true&Filter=gif|*.gif
            if (getQueryString("IsSingle")) {
                slCtl.Content.Control.Single = getQueryString("IsSingle");
            }
            if (getQueryString("Filter")) {
                slCtl.Content.Control.FileFilter = getQueryString("Filter");
            }
            if (getQueryString("MaxFileSize")) {
                slCtl.Content.Control.MaxFileSize = parseInt(getQueryString("MaxFileSize")) * 1024 * 1024;
            }
        }

        function FinishUpload() {
            var files = "";
            for (i = 0; i < slCtl.Content.Files.FileList.length; i++) {
                files += slCtl.Content.Files.FileList[i].NewFileName + ",";
            }
            window.returnValue = files;
            window.close();
        }
        function CancelClose() {
            window.close();
        }
    </script>

</head>
<body style="height: 100%; margin: 0;">
    <form id="form1" runat="server" style="height: 100%;">
    <div id='errorLocation' style="font-size: small; color: Gray;">
    </div>
    <div id="silverlightControlHost">
        <object id="MultiFileUploader" data="data:application/x-silverlight-2," type="application/x-silverlight-2"
            width="460" height="400">
            <param name="source" value="/ClientBin/Aim.FileUpload.xap" />
            <param name="onerror" value="onSilverlightError" />
            <param name="onload" value="pluginLoaded" />
            <param name="background" value="white" />
            <param name="InitParams" value="CustomParam=FolderKey:Portal,WcfServiceUrl=<%=UploadServiceUrl %>" />
            <param name="minRuntimeVersion" value="2.0.31005.0" />
            <a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;">
                <img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="获取 Microsoft Silverlight"
                    style="border-style: none" />
            </a>
        </object>
        <iframe style='visibility: hidden; height: 0; width: 0; border: 0px'></iframe>
    </div>
    </form>
</body>
</html>
