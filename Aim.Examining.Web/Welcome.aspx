<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Welcome.aspx.cs" Inherits="Welcome" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>无标题文档</title>
    <link href="theme/default/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="theme/default/css/style.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="resource/js/jquery-1.9.1.min.js"></script>

    <script type="text/javascript" src="resource/js/jay-mainShow.js"></script>

    <script type="text/javascript" src="resource/js/jquery.nicescroll.js"></script>

    <script type="text/javascript">
        $(function() {
            $(".tablestyle_1 tr:odd").addClass("tdodd")
        });
        //class="htmlBG-in2"
    </script>

    <style type="text/css">
        html, body
        {
            overflow-x: hidden;
        }
        body
        {
            background: url(/theme/default/images/public/paperbg.jpg) #e4f1fe repeat-x left -43px;
        }
    </style>
</head>
<body style="padding-right: 10px;">
    <form id="form1" runat="server">
    <div class="bloclArea">
        <div class="tabboxArea">
            <div class="tabbox" id="mainGetHei">
                <!-- datahere -->
                Welcome
            </div>
            <div class="tabboxBot">
                <em></em>
            </div>
        </div>
    </div>
    </form>
</body>
</html>
