<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FrmView.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmView" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>在线预览</title>
</head>
<body>
    <form id="form1" runat="server">
    <div id="divcontent" runat="server">
        <asp:Literal runat="server" ID="litinfo" />
    </div>
    </form>
</body>
</html>
