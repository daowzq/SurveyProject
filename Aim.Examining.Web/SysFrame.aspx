<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SysFrame.aspx.cs" Inherits="SysFrame"
    Title="飞力达员工互动平台" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>飞力达员工互动平台</title>
</head>
<frameset rows="85,12,*" framespacing="0" frameborder="0" name="framell" id="framell">
	<frame src="Frames/Top.aspx" name="top" noresize="noresize" frameborder="0" scrolling="no" id="frametop"/>
    <frame src="Frames/TopBar.aspx" name="topbar" noresize="noresize" frameborder="0" scrolling="no" id="frametopbar"/>
	<frameset cols="194,12,*" framespacing="0" frameborder="0" name="main" id="framemain">
		<frame src="Frames/Left.aspx" name="left" noresize="noresize" frameborder="0" scrolling="no" id="frameleft"/>
		<frame src="Frames/Bar.aspx" name="hiddel" noresize="noresize" frameborder="0" scrolling="no" id="framehiddel"/>
		<%--<frameset rows="34,*" framespacing="0" frameborder="0" id="framemainShow">
			<frame src="Frames/mainNav.aspx" name="mainNav" noresize="noresize" frameborder="0" scrolling="no" id="frameMainNav"/>--%>
			<frame src="Welcome.aspx" name="mainShow" noresize="noresize"   frameborder="0" scrolling="1" id="framemainArea"/>
		<%--</frameset>--%>
	</frameset> 
</frameset>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
