<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Bar.aspx.cs" Inherits="Frames_Bar" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>无标题文档</title>
    <link href="../theme/default/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="../theme/default/css/style.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../resource/js/jquery-1.9.1.min.js"></script>

    <style type="text/css">
        html, body
        {
            height: 100%;
            width: 100%;
            overflow: hidden;
        }
        .myClass
        {
            background: url(../theme/default/images/public/bar.gif) no-repeat left center;
        }
    </style>

    <script type="text/javascript">
        $(function() {
            $("a.aframbar").click(function() {
                var framecols = parent.document.getElementById('framemain').getAttribute('cols');
                if (framecols == "194,12,*") {
                    parent.document.getElementById('framemain').cols = "0,12,*";
                    $(this).addClass("aframbarshow");
                } else {
                    parent.document.getElementById('framemain').cols = "194,12,*";
                    $(this).removeClass("aframbarshow")
                    //$("#hiddel_show").attr("src", "AdminImg/left.gif");
                    //$("#hiddel_show").alt = "点击隐藏左侧导航栏"; 
                }
            });
        });
    </script>

</head>
<body class="htmlBG-in">
    <form id="form1" runat="server">
    <a href="javascript:void(0)" style="display: block; height: 100%; width: 100%;" class="aframbar">
    </a>
    </form>
</body>
</html>
