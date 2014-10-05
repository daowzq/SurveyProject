<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MainNav.aspx.cs" Inherits="Frames_MainNav" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>无标题文档</title>
    <link href="../theme/default/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="../theme/default/css/style.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../resource/js/jquery-1.9.1.min.js"></script>

    <script type="text/javascript" src="../resource/js/jay-mainNav.js"></script>

    <style type="text/css">
        html, body
        {
            overflow: hidden;
        }
    </style>
</head>
<body class="htmlBG-in" style="padding-right: 10px;">
    <form id="form1" runat="server">
    <div class="mainNavArea">
        <div class="mainNavArea-r">
            <div class="mainNavArea-l">
                <div class="carollWrap">
                    <div class="carollin" id="navUlWraphide">
                        <ul id="navUlWrap">
                        </ul>
                    </div>
                    <a href="javascript:void(0)" class="carNav prev"></a><a href="javascript:void(0)"
                        class="carNav next"></a>
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
</html>
