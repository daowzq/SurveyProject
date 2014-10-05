<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TopBar.aspx.cs" Inherits="TopBar" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link href="../theme/default/css/reset.css" rel="stylesheet" type="text/css" />
<link href="../theme/default/css/style.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resource/js/jquery-1.9.1.min.js"></script>
<style type="text/css">
html,body { height:100%; width:100%; overflow:hidden}
</style>
<script type="text/javascript">
$(function() {
	$("a.aframbar2").click(function () {
		var framecols = parent.document.getElementById('framell').getAttribute('rows');
		if (framecols == "85,12,*") {
			parent.document.getElementById('framell').rows = "0,12,*";
			$(this).addClass("aframbarshow2");
		} else {
			parent.document.getElementById('framell').rows = "85,12,*";
			$(this).removeClass("aframbarshow2")
			//$("#hiddel_show").attr("src", "AdminImg/left.gif");
			//$("#hiddel_show").alt = "点击隐藏左侧导航栏";
		}
	});
});
</script>
</head>
<body style=" background:#6190C8">
    <a href="javascript:void(0)" style="display:block; height:100%; width:100%;" class="aframbar2"></a>
    <form id="form1" runat="server">
    <div>

    </div>
    </form>
</body>
</html>
