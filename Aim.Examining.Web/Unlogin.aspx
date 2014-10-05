<%@ Page Title="注销系统" Language="C#" AutoEventWireup="true" CodeBehind="Unlogin.aspx.cs" Inherits="Aim.Portal.Web.Unlogin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script src="js/lib/jquery-1.4.2.min.js" type="text/javascript"></script>

    <script type="text/javascript" language="javascript">
        function exit() {
            setTimeout('window.location.href = "/Login.aspx"', 200);
        }
    </script>
</head>
<body onload="setTimeout('exit();', 200);">
    <form id="form1" runat="server">
        <table cellspacing="1" cellpadding="1" width="100%" border="0" align="center">
            <tr>
                <td width="18"></td>
                <td align="left" align="center"><span><b>准备登出系统</span></b></td>
            </tr>
            <tr bgcolor="#809FC3" height="2">
                <td colspan="2"></td>
            </tr>
            <tr height="48">
                <td colspan="2" id="Title" align="center" valign="middle" style="color: red">&nbsp;</td>
            </tr>
            <tr height="32">
                <td colspan="2" align="center" valign="middle">
                    <img src="./images/loading.gif"></td>
            </tr>
        </table>
    </form>
</body>
</html>
