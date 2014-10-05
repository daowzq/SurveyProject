<%@ Page Language="C#" AutoEventWireup="True" CodeBehind="Left.aspx.cs" Inherits="Aim.Examining.Web.Left" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title></title>
    <link href="../theme/default/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="../theme/default/css/style.css" rel="stylesheet" type="text/css" />
    <link href="../theme/default/css/dtree.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../resource/js/jquery-1.9.1.min.js"></script>

    <script type="text/javascript" src="../resource/js/jquery.nicescroll.js"></script>

    <script type="text/javascript" src="../resource/js/dtree.js"></script>

    <script type="text/javascript" src="../resource/js/jay-left.js"></script>

    <script src="/js/lib/jquery.plug-ins.js" type="text/javascript"></script>

    <script src="/js/lib/jquery.form.js" type="text/javascript"></script>
    <style type="text/css">
        body
        {
            background: url(/theme/default/images/public/paperbg.jpg);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="leftFrame">
            <div class=" title-3-r">
                <span class="title-3-l"><em class=" ltiticon"></em><span class="fz-1 fontes tx-sd-1">功能列表</span> </span>
            </div>
            <div class="tabboxArea">
                <div class="tabbox" id="gethei">
                    <div id="treeContainer" runat="server">
                    </div>
                </div>
                <div class="tabboxBot">
                    <em></em>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
