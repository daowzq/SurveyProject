<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FrmImgNews.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmImgNews" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script src="/js/lib/jquery-1.4.2.min.js" type="text/javascript"></script>

    <script language="javascript">
        onload = inint;
        var index = 0;
        var imgary = [];
        var lblary = [];

        function inint() {
            imgary = $("#divimg img");
            //设置数字显示
            var temp = "";
            for (var i = 0; i < imgary.length; i++) {
                temp += "<label style='background-color:Green; cursor:pointer; margin:3px;' id='lblindex" + i + "' onclick='disimg(" + i + ")'>" + (i + 1) + "</label>";
            }
            $("#divpageindex").html(temp);
            lblary = $("#divpageindex label");

            test();
        }

        function test() {
            if (index < imgary.length - 1) {
                index++;
            }
            else {
                index = 0;
            }
            disimg(index)
            setTimeout(test, 3000);
        }

        function disimg(j) {
            for (var i = 0; i < imgary.length; i++) {
                imgary[i].style.display = "none";
            }
            imgary[j].style.display = "block";

            //修改索引样式
            for (var i = 0; i < lblary.length; i++) {
                lblary[i].style.backgroundColor = "Green";
            }
            lblary[j].style.backgroundColor = "yellow";
        }


        function Test() {
            var createtime = new Date('2011-11-11');
            alert(createtime);
            var temp = new Date();
            var today = new Date(temp.getFullYear(), temp.getMonth(), temp.getDate() - 5);
            if (Date.parse('2011/11/11') - Date.parse(today) < 0)
            { alert("OK"); }

        }

        function DisMenu(obj) {
            var divmenu = document.getElementById("divmenu");
            divmenu.style.display = "inline";
            divmenu.style.left = obj.offsetLeft + "px";
            divmenu.style.top = obj.offsetTop + document.body.scrollTop + 12 + "px";
        }
        
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div id="divimg" style="width: 300px; height: 200px; background-color: LightGray;
        position: relative;">
        <img style="width: 100%; height: 100%; cursor: pointer;" src="http://www.google.com.hk/intl/zh-CN/images/logo_cn.png"
            alt="Google" />
        <img style="display: none; width: 100%; height: 100%; cursor: pointer;" src="http://www.baidu.com/img/baidu_sylogo1.gif"
            alt="baidu" />
        <img style="display: none; width: 100%; height: 100%; cursor: pointer;" src="http://soso.qstatic.com/30d/img/logo/r_defaultLogo.jpg"
            alt="soso" />
        <div id="divpageindex" style="position: absolute; display: inline; right: 10px; bottom: 8px;
            color: Red;">
        </div>
    </div>
    <label style="font-size: 12px; width: 50px; background-color: LightPink; cursor: pointer;"
        onmouseover="DisMenu(this)">
        附件
    </label>
    &nbsp;&nbsp;&nbsp;
    <label style="font-size: 12px; width: 50px; background-color: LightPink; cursor: pointer;"
        onmouseover="DisMenu(this)">
        附件2
    </label>
    
    <div id="divmenu" style="font-size: 12px; width: 50px;
        display: none; position: absolute;" onmouseleave="this.style.display='none';">
        <a href="#">预览</a><br />
        <a href="#">下载</a>
    </div>
    </form>
</body>
</html>
