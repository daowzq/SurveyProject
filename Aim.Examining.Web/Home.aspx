<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="Aim.Examining.Web.Home" CodePage="936"%>
<%@ OutputCache Location="None" %>
<html>
<head>
    <title>首页</title>
		<meta content="JavaScript" name="vs_defaultClientScript"/>
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema"/>
		<SCRIPT src="/Modules/WebPart/prototype.js" type="text/javascript"></SCRIPT>
		<SCRIPT src="/Modules/WebPart/common.js" type="text/javascript"></SCRIPT>
		<SCRIPT src="/Modules/WebPart/follow.js" type="text/javascript"></SCRIPT>
		<SCRIPT src="/Modules/WebPart/drag.js" type="text/javascript"></SCRIPT>
		<LINK href="/Modules/WebPart/door.css" type="text/css" rel="stylesheet"/>
		<LINK href="/Modules/WebPart/style.css" type="text/css" rel="stylesheet"/>
		<SCRIPT type="text/javascript">
		    var _blockType = "Portal";
		    var _params = "";

		    //增加元素
		    function addBlock(blocktype, blocktitle) {
		        var blockIds = getAllDragDiv();
		        for (var i = 0; i < blockIds.length; i++) {
		            if (blockIds[i] == blocktype) {
		                alert("该模块已经添加,无须重复添加!"); return;
		            }
		        }
		        var layouttype = $('layouttype').value;
		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "asyncreq=true&Param=GetOneNew&BlockId=" + blocktype + "&BlockType=" + _blockType + "&" + _params;

		        new Ajax.Request
	(
		url,
		{
		    method: "post",
		    onSuccess: function(resp) {
		        var colnum = $('layouttype').value;
		        var objCol = document.getElementById("col_" + colnum);
		        var objColChilds = objCol.getElementsByTagName("div");
		        var newdiv = document.createElement("div");
		        newdiv.innerHTML = resp.responseText;
		        objCol.appendChild(newdiv);
		        initDrag();
		        loadDragContent(blocktype, '5');
		    },
		    onFailure: function() {
		        //alert(url);

		    },
		    parameters: queryString
		}
	);

		    }
		    //删除元素
		    function delDragDiv(blockid) {
		        Element.hide('popupImgMenuID');
		        var logicv = window.confirm("确定删除这个元素吗？");
		        if (logicv) {
		            var rid = document.getElementById("drag_" + blockid);
		            rid.parentNode.removeChild(rid);
		            url = "/CommonPages/Data/HomeData.aspx";
		            queryString = "Param=DeleteBlock&BlockId=" + blockid + "&BlockType=" + _blockType + "&" + _params;
		            new Ajax.Request(url, { method: "post", parameters: queryString });

		        }
		    }

		    //新闻订阅
		    function myRssDiv(blockid) {
		        var objDivID = document.getElementById('drag_myrss_img_' + blockid);
		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=MyRss&BlockId=" + blockid + "&BlockType=" + _blockType;
		        new Ajax.Request
	(
		url,
		{
		    method: "post",
		    onSuccess: function(resp) {
		        if (resp.responseText == "T")
		            alert("取消订阅!");
		        else if (resp.responseText == "F")
		            alert("成功订阅!");
		        //objDivID.src = resp.responseText;
		    },
		    onFailure: function() {
		        //alert(url);
		    },
		    parameters: queryString
		}
	);
		    }

		    function reset() {
		        if (confirm("确定要恢复默认吗?")) {
		            url = "/CommonPages/Data/HomeData.aspx";
		            queryString = "Param=Reset&BlockType=" + _blockType + "&" + _params;
		            new Ajax.Request
		(
			url,
			{
			    method: "post",
			    onSuccess: function(resp) {
			        var color = resp.responseText;
			        window.parent.FootBar.document.getElementById("footerTd").style.backgroundImage = "url('/Modules/WebPart/MenuTpl/" + color + "/state_bg.jpg')";
			        window.parent.TitleBar.location.reload();
			        window.location.reload();
			    },
			    onFailure: function() {
			        //alert(url);
			    },
			    parameters: queryString
			}
		);
		        }

		    }

		    //展开隐藏元素
		    function switchDrag(tid, imgid) {
		        var openurl = "/Modules/WebPart/close.gif";
		        var closeurl = "/Modules/WebPart/open.gif";
		        showHiddenInfo(tid, imgid, openurl, closeurl);

		    }

		    //展开隐藏所有元素
		    function switchDragAll(imgid) {
		        var openurl = "/Modules/WebPart/close.gif";
		        var closeurl = "/Modules/WebPart/open.gif";

		        var objSS = document.getElementById('showstatus');
		        var n = objSS.value;

		        var aryBlockId = [];
		        aryBlockId = getAllDragDiv();
		        var blockid = 0;
		        for (var i = 0; i < aryBlockId.length; i++) {
		            blockid = aryBlockId[i];
		            var objDragSwitch = document.getElementById('drag_switch_' + blockid);

		            if (n == 1) {
		                objSS.value = 0;
		                imgid.url = openurl;
		                hiddenInfo(objDragSwitch, imgid, openurl);
		            }
		            else {
		                objSS.value = 1;
		                imgid.url = closeurl;
		                showInfo(objDragSwitch, imgid, closeurl);
		            }
		        }

		    }

		    //取所有拖动元素的blockid
		    function getAllDragDiv() {
		        var odjLT = document.getElementById('layouttype');
		        var m = odjLT.value;
		        var aryBlockId = [];
		        for (var j = 1; j <= m; j++) {
		            var col = document.getElementById("col_" + j);
		            var colChilds = col.getElementsByTagName("div");
		            for (var i = 0; i < colChilds.length; i++) {
		                if (colChilds[i].className == 'drag_div') {
		                    var blockid = colChilds[i].id.replace("drag_", "");
		                    aryBlockId[aryBlockId.length] = blockid;
		                }
		            }
		        }
		        return aryBlockId;
		    }

		    //修改元素样式颜色
		    function switchTpl(id, tpl) {
		        var objDragTitle = document.getElementById("drag_title_" + id);
		        var objDrag = document.getElementById("drag_" + id);
		        var objBlockTpl = document.getElementById("blocktpl_" + id);
		        objBlockTpl.value = tpl;
		        objDragTitle.style.backgroundImage = "url('/Modules/WebPart/tpl/" + tpl + "/title_bg.png')";
		        var bordercolor = getTplBolderColor(tpl)
		        objDrag.style.borderColor = bordercolor;
		        objBlockTpl.colorvalue = bordercolor;
		        url = "do.php";
		        queryString = "f=savetpl&blockid=" + id + "&blocktpl=" + tpl;
		        new Ajax.Request(url, { method: "post", parameters: queryString });
		    }

		    //修改元素标题
		    function changeDragText(id) {
		        var objDragText = document.getElementById("drag_text_" + id);
		        var objBlocktitle = document.getElementById("blocktitle_" + id);
		        objDragText.innerHTML = objBlocktitle.value;
		    }

		    //展开元素编辑器
		    function modifyBlock(id) {
		        Element.show('drag_switch_' + id);
		        Element.hide('popupImgMenuID');
		        var objDivID = document.getElementById('drag_editor_' + id);

		        if (objDivID.style.display == "") {
		            objDivID.style.display = "none";
		            objDivID.innerHTML = '<div id="loadeditorid_' + id + '" style="width:100px"><img src="/Modules/WebPart/loading.gif"><span id="loadeditortext_' + id + '" style="color:#333"></span></div>'
		            return;
		        }

		        var objOtext = document.getElementById('loadeditortext_' + id);

		        objDivID.style.display = "";
		        objOtext.innerHTML = " 加载编辑器...";

		        var saveGimgEditor = {
		            onCreate: function() {
		                Element.show('loadeditorid_' + id);
		            },
		            onComplete: function() {
		                if (Ajax.activeRequestCount == 0) {
		                    Element.hide('loadeditorid_' + id);
		                }
		            }
		        };
		        Ajax.Responders.register(saveGimgEditor);

		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=BlockParam&BlockId=" + id + "&BlockType=" + _blockType + "&" + _params;

		        new Ajax.Request
	(
		url,
		{
		    method: "post",
		    onSuccess: function(resp) {
		        objDivID.innerHTML = resp.responseText;

		    },
		    onFailure: function() {
		        //alert(url);

		    },
		    parameters: queryString
		}
	);
		    }

		    //保存编辑器内容
		    function saveDragEditor(blockid) {

		        Element.hide('popupImgMenuID');

		        var blocktitle = "";
		        var blockrow = "5";
		        var subjectlength = "20";
		        var isshowcreator = 0;
		        var isshowdate = 0;
		        var blockeffect = 0;
		        var commonid = 0;
		        var blocktpl = "gray";
		        var commonstr = "";
		        var colorvalue = "";

		        if (document.getElementById('blocktitle_' + blockid) != null) {
		            var objBlockTitle = document.getElementById('blocktitle_' + blockid);
		            blocktitle = objBlockTitle.value;
		        }
		        if (document.getElementById('blockrow_' + blockid) != null) {
		            var objBlockRow = document.getElementById('blockrow_' + blockid);
		            if ((!isInteger(objBlockRow.value)) || objBlockRow.value == 0) {
		                objBlockRow.select();
		                alert("请输入大于0的数字！");
		                return;

		            }
		            blockrow = objBlockRow.value;
		        }

		        if (document.getElementById('subjectlength_' + blockid) != null) {
		            var objSubjectLength = document.getElementById('subjectlength_' + blockid);
		            if ((!isInteger(objSubjectLength.value)) || objSubjectLength.value == 0) {
		                objSubjectLength.select();
		                alert("请输入大于0的数字！");
		                return;

		            }
		            subjectlength = objSubjectLength.value;
		        }

		        if (document.getElementById('blocktpl_' + blockid) != null) {
		            var objBlockTpl = document.getElementById('blocktpl_' + blockid);
		            blocktpl = objBlockTpl.value;
		            colorvalue = objBlockTpl.colorvalue;
		        }

		        var par = "";
		        par += '&blocktitle=' + blocktitle;
		        par += '&blockrow=' + blockrow;
		        par += '&subjectlength=' + subjectlength;
		        par += '&blocktpl=' + blocktpl;
		        par += '&blockid=' + blockid;
		        par += '&colorvalue=' + escape(colorvalue);
		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=BlockUpdate" + par + "&BlockType=" + _blockType + "&" + _params;
		        new Ajax.Request
	(
		url,
		{
		    method: "post",
		    onSuccess: function(resp) {

		        modifyBlock(blockid);
		        resetDragContent(blockid)
		        loadDragContent(blockid, blockrow);

		    },
		    onFailure: function() {
		        //alert(url);

		    },
		    parameters: queryString
		}
	);
		    }

		    //
		    function resetDragContent(id) {
		        var objDivID = document.getElementById('drag_content_' + id);
		        if (document.getElementById('loadcontentid_' + id) == null) {
		            objDivID.innerHTML = '<div id="loadcontentid_' + id + '" style="width:100px"><img src="/Modules/WebPart/loading.gif"><span id="loadcontenttext_' + id + '" style="color:#333"></span>'

		        }

		    }

		    var i = 0;
		    //加载元素内容
		    function loadDragContent(id, count, newId) {
		        var loadId = id;
		        if (newId) {
		            loadId = newId;
		        }
		        var objDivID = document.getElementById('drag_content_' + id);
		        var objOtext = document.getElementById('loadcontenttext_' + id);

		        var objLoadcontentid = document.getElementById('loadcontentid_' + id);
		        objOtext.innerHTML = "加载内容...";

		        var saveGimgContent = {
		            onCreate: function() {
		                Element.show('loadcontentid_' + id);
		            },
		            onComplete: function() {
		                if (Ajax.activeRequestCount == 0) {
		                    Element.hide('loadcontentid_' + id);
		                }
		            }
		        };
		        Ajax.Responders.register(saveGimgContent);

		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=GetContent&BlockId=" + loadId + "&Count=" + count;
		        new Ajax.Request
	(
		url,
		{
		    method: "post",
		    onSuccess: function(resp) {
		        objDivID.innerHTML = resp.responseText;
		        if (document.getElementById('blocktypevalue_' + id).value == -1) {
		            loadingNewsPic(-1, id);
		        }
		    },
		    onFailure: function() {
		        //alert(url);

		    },
		    parameters: queryString
		}
	);
		    }



		    //展开图标库
		    function showPopup(id) {
		        closeAllItemEditor();
		        var objBlockID = document.getElementById('tmpblockid');
		        objBlockID.value = id;

		        var objDivID = document.getElementById('popupImgItem');
		        var objDivPopup = document.getElementById('popupImgMenuID');
		        var objOtext = document.getElementById('loadtext');

		        var popupX = 0;
		        var popupY = 0;
		        contentBox = document.getElementById("popupImgMenuID");
		        var o = event.srcElement;
		        while (o.tagName != "BODY") {
		            popupX += o.offsetLeft;
		            popupY += o.offsetTop;
		            o = o.offsetParent;
		        }

		        objDivPopup.style.left = popupX + 20;
		        objDivPopup.style.top = popupY;

		        objDivPopup.style.display = "";


		        objOtext.innerHTML = " 加载图标...";

		        var saveGimgIcon = {
		            onCreate: function() {
		                Element.show('loadimgid');
		            },
		            onComplete: function() {
		                if (Ajax.activeRequestCount == 0) {
		                    Element.hide('loadimgid');
		                }
		            }
		        };
		        Ajax.Responders.register(saveGimgIcon);


		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=GetIcons&BlockId=" + id;

		        new Ajax.Request
	(
		url,
		{
		    method: "post",
		    onSuccess: function(resp) {
		        objDivID.innerHTML = resp.responseText;
		    },
		    onFailure: function() {
		        //alert(url);
		    },
		    parameters: queryString
		}
	);
		    }

		    //更换图标
		    function changeDragIcon(src, blockimg) {
		        var objBlockID = document.getElementById('tmpblockid');
		        var blockid = objBlockID.value;

		        var dragImgId = "drag_img_" + blockid;
		        var objImgId = document.getElementById(dragImgId);
		        objImgId.src = src;

		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=SetIcon&BlockId=" + blockid + "&BlockType=" + _blockType + "&BlockImg=" + src + "&" + _params;
		        new Ajax.Request(url, { method: "post", parameters: queryString });


		        Element.hide('popupImgMenuID');

		    }

		    //获取模版边框值
		    function getTplBolderColor(tpl) {
		        var bcol = "#999";
		        switch (tpl) {
		            case "navarat":
		                bcol = "#FFB0B0";
		                break;
		            case "orange":
		                bcol = "#FFC177";
		                break;
		            case "yellow":
		                bcol = "#FFED77";
		                break;
		            case "green":
		                bcol = "#CBE084";
		                break;
		            case "blue":
		                bcol = "#A1D9ED";
		                break;
		            case "gray":
		                bcol = "#BBBBBB";
		                break;
		            case "o_navarat":
		                bcol = "#B78AA9";
		                break;
		            case "o_orange":
		                bcol = "#D68C6F";
		                break;
		            case "o_yellow":
		                bcol = "#A9B98C";
		                break;
		            case "o_green":
		                bcol = "#96C38A";
		                break;
		            case "o_blue":
		                bcol = "#579AE9";
		                break;
		            case "o_gray":
		                bcol = "#8AA2B7";
		                break;
		        }
		        return bcol;

		    }

		    //元素编辑按钮开关
		    function switchOptionImg(blockid, n) {

		        if (n == 1) {
		            if (document.getElementById('drag_myrss_img_' + blockid))
		                Element.show('drag_myrss_img_' + blockid);
		            Element.show('drag_switch_img_' + blockid);
		            Element.show('drag_refresh_img_' + blockid);
		            Element.show('drag_edit_img_' + blockid);
		            Element.show('drag_delete_img_' + blockid);
		        }
		        else {
		            if (document.getElementById('drag_myrss_img_' + blockid))
		                Element.hide('drag_myrss_img_' + blockid);
		            Element.hide('drag_switch_img_' + blockid);
		            Element.hide('drag_refresh_img_' + blockid);
		            Element.hide('drag_edit_img_' + blockid);
		            Element.hide('drag_delete_img_' + blockid);

		        }


		    }

		    //锁定界面
		    function lockWindowPage() {

		        var widthHeight = getScreenWH();
		        var screenDiv = document.createElement("div");
		        screenDiv.id = "locksrceen";
		        screenDiv.style.zIndex = "100";
		        screenDiv.style.width = widthHeight.width;
		        screenDiv.style.height = widthHeight.height;
		        screenDiv.style.background = "#000";
		        screenDiv.style.filter = "alpha(Opacity=20)";
		        screenDiv.style.position = "absolute";
		        screenDiv.style.left = "0px";
		        screenDiv.style.top = "0px";
		        document.body.appendChild(screenDiv);
		    }

		    //解除锁定界面
		    function unlockWindowPage() {
		        var screenDiv = document.getElementById("locksrceen");
		        if (screenDiv)
		            screenDiv.parentNode.removeChild(screenDiv);
		    }

		    //全屏高宽度
		    function getScreenWH() {
		        var objData = new Object();
		        var cwidth = document.body.clientWidth;
		        var swidth = document.body.scrollWidth;
		        var cheight = document.body.clientHeight;
		        var sheight = document.body.scrollHeight;
		        objData.width = cwidth > swidth ? cwidth : swidth;
		        objData.height = cheight > sheight ? cheight : sheight;
		        return objData;
		    }
		    var isSave = false;
		    //设置列数
		    function setLayoutType(n) {
		        var objLayouttype = document.getElementById('layouttype');
		        var m = objLayouttype.value;
		        m = parseInt(m, 10);

		        if (n < m) {
		            var objInitText = document.getElementById('inittext');
		            objInitText.innerHTML = "";
		            lockWindowPage();

		            var logIsSure = window.confirm("修改后的列数比现有的列数少，被删除列里的元素将转到最后一列！确定吗？");
		            if (!logIsSure) {
		                objInitText.innerHTML = "";
		                unlockWindowPage();
		                return;
		            }
		        }
		        for (i = 1; i <= 4; i++) {
		            var objLayoutnum = document.getElementById("layoutnum_" + i);
		            if (i == n) {
		                objLayoutnum.className = "layoutnumselect";
		            }
		            else {
		                objLayoutnum.className = "layoutnum";
		            }
		        }
		        var objLayoutdisplay1 = document.getElementById('layoutdisplay1');
		        var objLayoutdisplay2 = document.getElementById('layoutdisplay2');
		        var objLayoutdisplay3 = document.getElementById('layoutdisplay3');
		        var objLayoutdisplay4 = document.getElementById('layoutdisplay4');

		        objLayouttype.value = n;
		        if (n == 1) {
		            objLayoutdisplay1.style.display = "";
		            objLayoutdisplay2.style.display = "none";
		            objLayoutdisplay3.style.display = "none";
		            objLayoutdisplay4.style.display = "none";
		            switch (m) {
		                case 1:
		                    break;
		                case 2:
		                    var col1 = document.getElementById('col_1');
		                    var col2 = document.getElementById('col_2');
		                    var objLayout1 = document.getElementById("layout1");
		                    objLayout1.value = 100;
		                    col1.style.width = "100%";
		                    for (var i = 0; i < col2.childNodes.length; i++) {
		                        if (!Element.hasClassName(col2.childNodes(i), 'no_drag'))
		                            col1.innerHTML += col2.childNodes(i).outerHTML;
		                    }
		                    col2.parentNode.removeChild(col2);
		                    break;
		                case 3:
		                    var col1 = document.getElementById('col_1');
		                    var col2 = document.getElementById('col_2');
		                    var col3 = document.getElementById('col_3');
		                    var objLayout1 = document.getElementById("layout1");
		                    for (var j = 2; j <= 3; j++) {
		                        var col = eval("col" + j);
		                        for (var i = 0; i < col.childNodes.length; i++) {
		                            if (!Element.hasClassName(col.childNodes(i), 'no_drag'))
		                                col1.innerHTML += col.childNodes(i).outerHTML;
		                        }
		                        col.parentNode.removeChild(col);
		                    }
		                    objLayout1.value = 100;
		                    col1.style.width = "100%";
		                    break;
		                case 4:
		                    var col1 = document.getElementById('col_1');
		                    var col2 = document.getElementById('col_2');
		                    var col3 = document.getElementById('col_3');
		                    var col4 = document.getElementById('col_4');
		                    var objLayout1 = document.getElementById("layout1");
		                    for (var j = 2; j <= 3; j++) {
		                        var col = eval("col" + j);
		                        for (var i = 0; i < col.childNodes.length; i++) {
		                            if (!Element.hasClassName(col.childNodes(i), 'no_drag'))
		                                col1.innerHTML += col.childNodes(i).outerHTML;
		                        }
		                        col.parentNode.removeChild(col);
		                    }
		                    objLayout1.value = 100;
		                    col1.style.width = "100%";
		                    break;
		            }
		        }

		        if (n == 2) {
		            objLayoutdisplay1.style.display = "";
		            objLayoutdisplay2.style.display = "";
		            objLayoutdisplay3.style.display = "none";
		            objLayoutdisplay4.style.display = "none";
		            switch (m) {
		                case 1:
		                    var col1 = document.getElementById('col_1');
		                    var objLayout1 = document.getElementById("layout1");
		                    objLayout1.value = 50;
		                    col1.style.width = "50%";
		                    addCol2();
		                    break;
		                case 2:
		                    break;
		                case 3:
		                    var col1 = document.getElementById('col_1');
		                    var col2 = document.getElementById('col_2');
		                    var col3 = document.getElementById('col_3');
		                    var objLayout1 = document.getElementById("layout1");
		                    var objLayout2 = document.getElementById("layout2");
		                    for (var i = 0; i < col3.childNodes.length; i++) {
		                        if (!Element.hasClassName(col3.childNodes(i), 'no_drag'))
		                            col2.innerHTML += col3.childNodes(i).outerHTML;
		                    }
		                    col3.parentNode.removeChild(col3);

		                    objLayout1.value = 50;
		                    col1.style.width = "50%";

		                    var widthcol2 = 50;
		                    col2.style.width = widthcol2 + "%"; ;
		                    objLayout2.value = widthcol2;
		                    break;
		                case 4:
		                    var col1 = document.getElementById('col_1');
		                    var col2 = document.getElementById('col_2');
		                    var col3 = document.getElementById('col_3');
		                    var col4 = document.getElementById('col_4');
		                    var objLayout1 = document.getElementById("layout1");
		                    var objLayout2 = document.getElementById("layout2");
		                    for (var j = 3; j <= 4; j++) {
		                        var col = eval("col" + j);
		                        for (var i = 0; i < col.childNodes.length; i++) {
		                            if (!Element.hasClassName(col.childNodes(i), 'no_drag'))
		                                col2.innerHTML += col.childNodes(i).outerHTML;
		                        }
		                        col.parentNode.removeChild(col);
		                    }

		                    objLayout1.value = 50;
		                    col1.style.width = "50%";

		                    var widthcol2 = 50;
		                    col2.style.width = widthcol2 + "%"; ;
		                    objLayout2.value = widthcol2;
		                    break;

		            }
		        }

		        if (n == 3) {
		            objLayoutdisplay1.style.display = "";
		            objLayoutdisplay2.style.display = "";
		            objLayoutdisplay3.style.display = "";
		            objLayoutdisplay4.style.display = "none";
		            switch (m) {
		                case 1:
		                    var col1 = document.getElementById('col_1');
		                    var objLayout1 = document.getElementById("layout1");
		                    objLayout1.value = 30;
		                    col1.style.width = "30%";
		                    addCol2();

		                    var col2 = document.getElementById('col_2');
		                    var objLayout2 = document.getElementById("layout2");
		                    objLayout2.value = 40;
		                    col2.style.width = "40%";
		                    addCol3();
		                    break;
		                case 2:
		                    var col1 = document.getElementById('col_1');
		                    var objLayout1 = document.getElementById("layout1");
		                    objLayout1.value = 30;
		                    col1.style.width = "30%";

		                    var col2 = document.getElementById('col_2');
		                    var objLayout2 = document.getElementById("layout2");
		                    objLayout2.value = 40;
		                    col2.style.width = "40%";
		                    addCol3();
		                    DragUtil.getSortIndex();
		                    break;
		                case 3:
		                    break;
		                case 4:
		                    var col1 = document.getElementById('col_1');
		                    var col3 = document.getElementById('col_3');
		                    var objLayout3 = document.getElementById("layout3");
		                    var objLayout4 = document.getElementById("layout4");
		                    objLayout3.value = parseInt(objLayout3.value) + parseInt(objLayout4.value);
		                    col3.style.width = objLayout3.value + "%";
		                    var col4 = document.getElementById('col_4');
		                    for (var i = 0; i < col4.childNodes.length; i++) {
		                        if (!Element.hasClassName(col4.childNodes(i), 'no_drag'))
		                            col3.innerHTML += col4.childNodes(i).outerHTML;
		                    }
		                    col4.parentNode.removeChild(col4);

		                    break;
		            }
		        }
		        if (n == 4) {
		            objLayoutdisplay1.style.display = "";
		            objLayoutdisplay2.style.display = "";
		            objLayoutdisplay3.style.display = "";
		            objLayoutdisplay4.style.display = "";
		            switch (m) {
		                case 1:
		                    var col1 = document.getElementById('col_1');
		                    var objLayout1 = document.getElementById("layout1");
		                    objLayout1.value = 25;
		                    col1.style.width = "25%";

		                    addCol2();
		                    var col2 = document.getElementById('col_2');
		                    var objLayout2 = document.getElementById("layout2");
		                    objLayout2.value = 25;
		                    col2.style.width = "25%";

		                    addCol3();
		                    var col3 = document.getElementById('col_3');
		                    var objLayout3 = document.getElementById("layout3");
		                    objLayout3.value = 25;
		                    col3.style.width = "25%";

		                    addCol4();
		                    break;
		                case 2:
		                    var col1 = document.getElementById('col_1');
		                    var objLayout1 = document.getElementById("layout1");
		                    objLayout1.value = 25;
		                    col1.style.width = "25%";

		                    var col2 = document.getElementById('col_2');
		                    var objLayout2 = document.getElementById("layout2");
		                    objLayout2.value = 25;
		                    col2.style.width = "25%";

		                    addCol3();
		                    var col3 = document.getElementById('col_3');
		                    var objLayout3 = document.getElementById("layout3");
		                    objLayout3.value = 25;
		                    col3.style.width = "25%";

		                    addCol4();

		                    break;
		                case 3:
		                    var col1 = document.getElementById('col_1');
		                    var objLayout1 = document.getElementById("layout1");
		                    objLayout1.value = 25;
		                    col1.style.width = "25%";

		                    var col2 = document.getElementById('col_2');
		                    var objLayout2 = document.getElementById("layout2");
		                    objLayout2.value = 25;
		                    col2.style.width = "25%";

		                    var col3 = document.getElementById('col_3');
		                    var objLayout3 = document.getElementById("layout3");
		                    objLayout3.value = 25;
		                    col3.style.width = "25%";

		                    addCol4();
		                    break;
		                case 4:
		                    break;
		            }
		        }
		        initDrag();
		        var col1width = document.getElementById('layout1').value;
		        var col2width = document.getElementById('layout2').value;
		        var col3width = document.getElementById('layout3').value;
		        var col4width = document.getElementById('layout4').value;
		        var url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=ChangeColumns&" + _params + "&layout1=" + col1width + "&layout2=" + col2width + "&layout3=" + col3width + "&layout4=" + col4width;
		        queryString += "&Columns=" + n;
		        queryString += "&TemplateString=" + DragUtil.getSortIndex();
		        queryString += "&BlockType=" + _blockType;
		        new Ajax.Request(url, { method: "post", parameters: queryString });
		        unlockWindowPage();
		        Element.hide('popupConMenuID');
		    }


		    //增加第二列
		    function addCol2() {
		        var colAry = [];
		        colAry[colAry.length] = ' 	<div id="col_2_hidden_div" class="drag_div no_drag"><div id="col_2_hidden_div_h"></div></div>';

		        var col1 = document.getElementById("col_1");

		        var col1Width = document.getElementById("layout1").value;
		        var col2Width = 100 - col1Width;
		        document.getElementById("layout2").value = col2Width;

		        var newColDiv = document.createElement("div");
		        newColDiv.className = "col_div";
		        newColDiv.id = "col_2";
		        newColDiv.style.width = col2Width + "%";
		        newColDiv.innerHTML = colAry.join("");
		        col1.parentNode.insertBefore(newColDiv, null)
		        initDrag();
		    }

		    //增加第三列
		    function addCol3() {
		        var colAry = [];
		        colAry[colAry.length] = ' 	<div id="col_3_hidden_div" class="drag_div no_drag"> <div id="col_3_hidden_div_h"></div></div>';

		        var col1 = document.getElementById("col_1");

		        var col1Width = document.getElementById("layout1").value;
		        var col2Width = document.getElementById("layout2").value;
		        var col3Width = 100 - col1Width - col2Width;

		        document.getElementById("layout3").value = col3Width;
		        var newColDiv = document.createElement("div");
		        newColDiv.className = "col_div";
		        newColDiv.id = "col_3";
		        newColDiv.style.width = col3Width + "%";
		        newColDiv.innerHTML = colAry.join("");
		        col1.parentNode.insertBefore(newColDiv, null);
		        initDrag();
		    }
		    //增加第四列
		    function addCol4() {
		        var colAry = [];
		        colAry[colAry.length] = ' 	<div id="col_4_hidden_div" class="drag_div no_drag"><div id="col_4_hidden_div_h"></div></div>';

		        var col1 = document.getElementById("col_1");

		        var col1Width = document.getElementById("layout1").value;
		        var col2Width = document.getElementById("layout2").value;
		        var col3Width = document.getElementById("layout3").value;
		        var col4Width = 100 - col1Width - col2Width - col3Width;

		        document.getElementById("layout4").value = col4Width;
		        var newColDiv = document.createElement("div");
		        newColDiv.className = "col_div";
		        newColDiv.id = "col_4";
		        newColDiv.style.width = col4Width + "%";
		        newColDiv.innerHTML = colAry.join("");
		        col1.parentNode.insertBefore(newColDiv, null);
		        initDrag();
		    }

		    //数值太小
		    function isThinNum(n) {
		        var logicv = true;
		        if (n < 10) {
		            logicv = window.confirm("输入的值偏小可能引起元素模块变形！确定吗？");
		        }
		        return logicv;
		    }

		    //改变宽度
		    function changeColWidth() {
		        var col1width = document.getElementById('layout1').value;
		        var col2width = document.getElementById('layout2').value;
		        var col3width = document.getElementById('layout3').value;
		        var col4width = document.getElementById('layout3').value;

		        for (var i = 1; i <= 4; i++) {
		            if (document.getElementById('col_' + i.toString()) != null) {
		                var objCol = document.getElementById('col_' + i.toString());
		                var colwidth = document.getElementById('layout' + i.toString()).value;
		                if (!isInteger(colwidth)) {

		                    document.getElementById('layout' + i.toString()).select();
		                    return;

		                }
		                if (!isThinNum(colwidth)) {
		                    document.getElementById('layout' + i.toString()).select();
		                    return;
		                };
		                objCol.style.width = colwidth + "%";
		            }
		        }
		        var objLayouttype = document.getElementById('layouttype');
		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=ChangeWidth&" + _params + "&layout1=" + col1width + "&layout2=" + col2width + "&layout3=" + col3width + "&layout4=" + col4width + "&Columns=" + objLayouttype.value;
		        queryString += "&BlockType=" + _blockType;
		        new Ajax.Request(url, { method: "post", parameters: queryString });
		        Element.hide('popupConMenuID');

		    }

		    //加载列内容的面板
		    function loadColEdit() {
		        if (document.getElementById('coleditcon') == null) {
		            return;
		        }
		        var objDivID = document.getElementById('paneladdcontent');
		        var objOtext = document.getElementById('coleditcontext');

		        objOtext.innerHTML = "加载内容...";

		        var saveGimgColCon = {
		            onCreate: function() {
		                Element.show('coleditcon');
		            },
		            onComplete: function() {
		                if (Ajax.activeRequestCount == 0) {
		                    Element.hide('coleditcon');
		                }
		            }
		        };
		        Ajax.Responders.register(saveGimgColCon);

		        url = "/CommonPages/Data/HomeData.aspx";
		        queryString = "Param=GetAllBlock&BlockType=" + _blockType + "&" + _params;
		        new Ajax.Request
	(
		url,
		{
		    method: "post",
		    onSuccess: function(resp) {
		        objDivID.innerHTML = resp.responseText;
		        InitColsValue();

		    },
		    onFailure: function() {
		        //alert(url);

		    },
		    parameters: queryString
		}
	);
		    }

		    function InitColsValue() {
		        var cols = document.getElementById("layouttype").value;
		        for (var i = 1; i <= 4; i++) {
		            document.getElementById("layoutnum_" + i).className = "layoutnum";
		        }
		        document.getElementById("layoutnum_" + cols).className = "layoutnumselect";
		        for (var i = 1; i <= parseInt(cols, 10); i++) {
		            document.getElementById("layoutdisplay" + i).style.display = "";
		            document.getElementById("layout" + i).value = document.getElementById("Divlayout").childNodes(i - 1).style.width.replace("%", "");
		        }
		        for (var i = parseInt(cols, 10) + 1; i <= 6; i++) {
		            if (document.getElementById("layoutdisplay" + i))
		                document.getElementById("layoutdisplay" + i).style.display = "none";
		        }
		    }

		    //展开首页编辑器
		    function showPanelCon() {
		        var objPCM = document.getElementById('popupConMenuID');
		        if (objPCM.style.display == "none") {
		            closeAllItemEditor();
		            Element.show('popupConMenuID');
		        }
		        else {
		            Element.hide('popupConMenuID')
		        }
		        loadColEdit();

		    }

		    //关闭所有元素编辑器
		    function closeAllItemEditor() {
		        var aryBlockId = getAllDragDiv();
		        for (var i = 0; i < aryBlockId.length; i++) {
		            var blockid = aryBlockId[i];
		            var objDE = document.getElementById('drag_editor_' + blockid);
		            if (objDE.style.display != "none") {
		                objDE.style.display = "none";
		                objDE.innerHTML = '<div id="loadeditorid_' + blockid + '" style="width:100px"><img src="/Modules/WebPart/loading.gif"><span id="loadeditortext_' + blockid + '" style="color:#333"></span></div>'
		            }

		        }
		    }

		    //初始化功能图标 元素内
		    function initItemImg() {
		        var aryBlockId = getAllDragDiv();
		        for (var i = 0; i < aryBlockId.length; i++) {
		            var blockid = aryBlockId[i];
		            var objDMI = document.getElementById('drag_myrss_img_' + blockid);
		            var objDSI = document.getElementById('drag_switch_img_' + blockid);
		            var objDRI = document.getElementById('drag_refresh_img_' + blockid);
		            var objDEI = document.getElementById('drag_edit_img_' + blockid);
		            var objDDI = document.getElementById('drag_delete_img_' + blockid);
		            if (objDMI) {
		                objDMI.onmouseover = function() { this.style.filter = '' };
		                objDMI.onmouseout = function() { this.style.filter = 'gray()' };
		                objDMI.style.display = "none";
		            }
		            objDSI.onmouseover = function() { this.style.filter = '' };
		            objDSI.onmouseout = function() { this.style.filter = 'gray()' };
		            objDRI.onmouseover = function() { this.style.filter = '' };
		            objDRI.onmouseout = function() { this.style.filter = 'gray()' };
		            objDEI.onmouseover = function() { this.style.filter = '' };
		            objDEI.onmouseout = function() { this.style.filter = 'gray()' };
		            objDDI.onmouseover = function() { this.style.filter = '' };
		            objDDI.onmouseout = function() { this.style.filter = 'gray()' };
		            objDSI.style.display = "none";
		            objDRI.style.display = "none";
		            objDEI.style.display = "none";
		            objDDI.style.display = "none";
		        }
		    }

		    //初始化功能图标 列
		    function initColImg() {
		        var objCPCM = document.getElementById('controlPopupConMenu');
		        objCPCM.onclick = function() {
		            showPanelCon();
		        };
		        var objDSIA = document.getElementById('drag_switch_img_all');
		        objDSIA.onclick = function() {
		            switchDragAll(objDSIA);
		        };
		    }
		</SCRIPT>
	</HEAD>
	<body style="margin-right:1px;overflow-y:auto">
		<DIV style="WIDTH: 200px">
			<DIV style="FLOAT: left; WIDTH: 100px"><IMG class="imglink" id="controlPopupConMenu" title="添加修改首页内容" style="MARGIN-LEFT: 10px"
					src="/Modules/WebPart/add.gif"><IMG class="imglink" id="drag_switch_img_all" title="展开/隐藏所有元素" style="MARGIN-LEFT: 5px"
					src="/Modules/WebPart/open.gif"><IMG class="imglink" id="reset" title="恢复默认" style="MARGIN-LEFT: 5px" src="/Modules/WebPart/refresh.gif"
					onclick="reset();">
			</DIV>
			<DIV id="inittext" style="FLOAT: left; WIDTH: 100px; COLOR: #999; HEIGHT: 20px"></DIV>
		</DIV>
		<DIV id="Divlayout" style="float:left;overflow-x:hidden;width:100%;">
			<%=Html%>
		</DIV>
		<DIV id="popupImgMenuID" style="DISPLAY: none; POSITION: absolute">
			<DIV style="PADDING-RIGHT: 2px; PADDING-LEFT: 2px; PADDING-BOTTOM: 2px; WIDTH: 100%; PADDING-TOP: 2px"><IMG class="imglink" title="关闭" onclick="Element.hide('popupImgMenuID')" src="/Modules/WebPart/closetab.gif"
					align="right"></DIV>
			<DIV class="popupImgMenu" id="popupImgItem"></DIV>
			<DIV id="loadimgid" style="WIDTH: 100px"><IMG src="/Modules/WebPart/loading.gif" align="absMiddle"><SPAN id="loadtext" style="COLOR: #333"></SPAN></DIV>
		</DIV>
		<INPUT type="hidden" name="tmpblockid"><INPUT id="layouttype" type="hidden" value="<%=LayoutXML%>" name="layouttype">
		<INPUT id="showstatus" type="hidden" value="1" name="showstatus">
		<DIV id="popupConMenuID" style="BORDER-RIGHT: #a2c7d9 1px solid; PADDING-RIGHT: 5px; BORDER-TOP: #a2c7d9 1px solid; DISPLAY: none; PADDING-LEFT: 5px; Z-INDEX: 10; LEFT: 15px; PADDING-BOTTOM: 5px; BORDER-LEFT: #a2c7d9 1px solid; WIDTH: 200px; PADDING-TOP: 5px; BORDER-BOTTOM: #a2c7d9 1px solid; POSITION: absolute; TOP: 20px; BACKGROUND-COLOR: #f1f7f9">
			<DIV style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 100%; PADDING-TOP: 5px"><IMG class="imglink" onclick="Element.hide('popupConMenuID')" src="/Modules/WebPart/closetab.gif"
					align="right"></DIV>
			<DIV style="PADDING-RIGHT: 5px; DISPLAY: inline; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 180px; COLOR: #222; PADDING-TOP: 5px"><IMG style="CURSOR: hand" onclick="switchDrag('paneladdcontent',this)" src="/Modules/WebPart/open.gif"
					align="absMiddle"> 添加首页内容</DIV>
			<DIV id="paneladdcontent" style="OVERFLOW: auto; WIDTH: 100%; HEIGHT: 300px" align="left">
				<DIV id="coleditcon" style="WIDTH: 100px"><IMG src="/Modules/WebPart/loading.gif"><SPAN id="coleditcontext" style="COLOR: #333"></SPAN></DIV>
			</DIV>
			<DIV style="PADDING-RIGHT: 5px; DISPLAY: inline; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 180px; COLOR: #222; PADDING-TOP: 5px"><IMG style="CURSOR: hand" onclick="switchDrag('panelmodifycol',this)" src="/Modules/WebPart/open.gif"
					align="absMiddle"> 修改首页排版</DIV>
			<DIV id="panelmodifycol">
				<DIV style="PADDING-RIGHT: 2px; DISPLAY: inline; PADDING-LEFT: 2px; PADDING-BOTTOM: 2px; PADDING-TOP: 2px">
					<DIV class="layoutnum" id="layoutnum_1" onclick="setLayoutType(1)">1列</DIV>
					<DIV class="layoutnumselect" id="layoutnum_2" onclick="setLayoutType(2)">2列</DIV>
					<DIV class="layoutnum" id="layoutnum_3" onclick="setLayoutType(3)">3列</DIV>
					<DIV class="layoutnum" id="layoutnum_4" onclick="setLayoutType(4)">4列</DIV>
				</DIV>
				<DIV id="layoutdisplay1" style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 100%; COLOR: #333333; PADDING-TOP: 5px">第1列宽
					<INPUT class="block_input" id="layout1" style="WIDTH: 30px" maxLength="3" value="0" name="layout1"
						onkeyup="value=value.replace(/[^0-9.]/g,'');" onbeforepaste="value=value.replace(/[^0-9.]/g,'');">%
					<INPUT class="block_button" onclick="changeColWidth();" type="button" value="确定" style="WIDTH:35px"><INPUT class="block_button" onclick="Element.hide('popupConMenuID');" type="button" value="取消"
						style="WIDTH:35px">
				</DIV>
				<DIV id="layoutdisplay2" style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 100%; COLOR: #333333; PADDING-TOP: 5px">第2列宽
					<INPUT class="block_input" id="layout2" style="WIDTH: 30px" maxLength="3" value="0" name="layout2"
						onkeyup="value=value.replace(/[^0-9.]/g,'');" onbeforepaste="value=value.replace(/[^0-9.]/g,'');">%
				</DIV>
				<DIV id="layoutdisplay3" style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 100%; COLOR: #333333; PADDING-TOP: 5px">第3列宽
					<INPUT class="block_input" id="layout3" style="WIDTH: 30px" maxLength="3" value="0" name="layout3"
						onkeyup="value=value.replace(/[^0-9.]/g,'');" onbeforepaste="value=value.replace(/[^0-9.]/g,'');">%
				</DIV>
				<DIV id="layoutdisplay4" style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 100%; COLOR: #333333; PADDING-TOP: 5px">第4列宽
					<INPUT class="block_input" id="layout4" style="WIDTH: 30px" maxLength="3" value="0" name="layout4"
						onkeyup="value=value.replace(/[^0-9.]/g,'');" onbeforepaste="value=value.replace(/[^0-9.]/g,'');">%
				</DIV>
			</DIV>
		</DIV>
		<DIV id="drag_editor" style="BORDER-RIGHT:#a2c7d9 1px solid; PADDING-RIGHT:5px; BORDER-TOP:#a2c7d9 1px solid; DISPLAY:none; PADDING-LEFT:5px; Z-INDEX:10; LEFT:30px; PADDING-BOTTOM:5px; BORDER-LEFT:#a2c7d9 1px solid; WIDTH:200px; PADDING-TOP:5px; BORDER-BOTTOM:#a2c7d9 1px solid; POSITION:absolute; TOP:20px; BACKGROUND-COLOR:#f1f7f9">
			<DIV style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; WIDTH: 100%; PADDING-TOP: 5px"><IMG class="imglink" onclick="Element.hide('drag_editor')" src="/Modules/WebPart/closetab.gif"
					align="right"></DIV>
			<div>整体颜色：</div>
			<div class="block_editor_b">
				<div>
					<div class="colorblock" style="BACKGROUND:#ffb0b0;CURSOR:hand" onclick="ApplayGlobalColor('navarat')"></div>
					<div class="colorblock" style="BACKGROUND:#ffc177;CURSOR:hand" onclick="ApplayGlobalColor('orange')"></div>
					<div class="colorblock" style="BACKGROUND:#ffed77;CURSOR:hand" onclick="ApplayGlobalColor('yellow')"></div>
					<div class="colorblock" style="BACKGROUND:#cbe084;CURSOR:hand" onclick="ApplayGlobalColor('green')"></div>
					<div class="colorblock" style="BACKGROUND:#a1d9ed;CURSOR:hand" onclick="ApplayGlobalColor('blue')"></div>
					<div class="colorblock" style="BACKGROUND:#bbbbbb;CURSOR:hand" onclick="ApplayGlobalColor('gray')"></div>
				</div>
			</div>
			<div class="block_editor_a"></div>
			<div class="block_editor_b">
				<div><FONT face="宋体"></FONT><FONT face="宋体"></FONT>
					<div class="colorblock" style="BACKGROUND:#e55147;CURSOR:hand" onclick="ApplayGlobalColor('o_navarat')"></div>
					<div class="colorblock" style="BACKGROUND:#fed9a5;CURSOR:hand" onclick="ApplayGlobalColor('o_orange')"></div>
					<div class="colorblock" style="BACKGROUND:#72ca97;CURSOR:hand" onclick="ApplayGlobalColor('o_yellow')"></div>
					<div class="colorblock" style="BACKGROUND:#85d35e;CURSOR:hand" onclick="ApplayGlobalColor('o_green')"></div>
					<div class="colorblock" style="BACKGROUND:#5690e4;CURSOR:hand" onclick="ApplayGlobalColor('o_blue')"></div>
					<div class="colorblock" style="BACKGROUND:#a6baec;CURSOR:hand" onclick="ApplayGlobalColor('o_gray')"></div>
				</div>
				<input type="hidden" name="ColorAll" id="ColorAll" value="navarat">
			</div>
			<div style="WIDTH:100%" align="center"><input type="button" value="取消" class="block_button" onclick="Element.hide('drag_editor')"
					ID="Button2" NAME="Button2"></div>
		</DIV>
		<SCRIPT type="text/javascript">
		    function QueryString(qs) {
		        var svalue = location.search.match(new RegExp("[\?\&]" + qs + "=([^\&]*)(\&?)", "i"));
		        return svalue ? svalue[1] : "";
		    }

		    window.onload = function() {
		        initDrag();
		        initItemImg();
		        initColImg();
		        _blockType = QueryString("BlockType") == "" ? "Portal" : QueryString("BlockType");
		        //_params = "TemplateId="+GetQueryString("TemplateId")+"&IsManage="+GetQueryString("IsManage");
		    }


		    function showColorPanel() {
		        var objPCM = document.getElementById('drag_editor');
		        if (objPCM.style.display == "none") {
		            closeAllItemEditor();
		            Element.show('drag_editor');
		        }
		        else {
		            Element.hide('drag_editor')
		        }
		        loadColEdit();

		    }
		    function ApplayGlobalColor(color) {
		        if (confirm("确定要设置全局颜色吗?")) {
		            var bordercolor = getTplBolderColor(color)
		            url = "/CommonPages/Data/HomeData.aspx";
		            queryString = "Param=SetGlobalColor&Color=" + color + "&ColorValue=" + escape(bordercolor) + "&" + _params;
		            queryString += "&BlockType=" + _blockType;
		            new Ajax.Request(url, { method: "post",
		                onSuccess: function(resp) {
		                    //objDivID.innerHTML = resp.responseText;
		                    //InitColsValue();
		                    window.parent.FootBar.document.getElementById("footerTd").style.backgroundImage = "url('Modules/WebPart/MenuTpl/" + color + "/state_bg.jpg')";
		                    window.parent.TitleBar.location.reload();
		                    window.location.reload();
		                },
		                parameters: queryString
		            });
		        }
		        Element.hide('drag_editor');

		    }
		</SCRIPT>
		<script language="javascript">

		    function OpenNews(NewsUrl) {
		        //window.open(NewsUrl, '查看信息',"left=0,top=0,width="+(screen.availWidth-12)+",height="+(screen.availHeight-30));
		        //window.open(NewsUrl,'_blank', openstr);
		        //window.open(NewsUrl, '查看信息',"left=112,top=50,width=800,height=600,resizable=yes");
		        OpenWin(NewsUrl, "_Blank", CenterWin("width=900,height=550,resizable=yes,scrollbars=yes"));
		    }

		    function jumpMenu(targ, selObj, restore) { //v3.0
		        //eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
		        if (selObj.options[selObj.selectedIndex].value != "") window.open(selObj.options[selObj.selectedIndex].value, '查看信息', "");
		    }

		    function ShowHiddenObject(obj) {
		        obj.style.display == "none" ? obj.style.display = "" : obj.style.display = "none";
		    }
		    //弹出生日窗口
		    function OpenBirthday(Url) {
		        Url += "?Name=";
		        var left = window.screenLeft + 680;
		        var top = 180;
		        var width = 745;
		        var height = 540;
		        var openstr = 'left=' + left + ',top=' + top + ',titlebar=no,toolbar=no,resizable=no,directions=no,scrollbars=no,width=' + width + ',height=' + height;
		        window.open(Url, 'message', openstr);
		    }

		    function SelectChange(value) {
		        window.open(value);
		    }

		    function WorkAreaLink(url) {
		        if (window.parent && url != "") {
		            window.parent.document.all("WorkArea").src = url;
		        }
		    }

		    function OpenReadonlyWin(url, target, style) {
		        target = target || '_blank';
		        style = style || 'width=800px,height=600px,scrollbars=yes';
		        if (url.indexOf('op=') < 0) {
		            if (url.indexOf('?') < 0) {
		                url = url + "?" + "op=r"
		            } else {
		                url = url + "&" + "op=r"
		            }
		        }
		        window.open(url, target, style);
		    }

		    function OpenWin(url, target, style) {
		        var desurl = url;
		        var win = null;
		        if (desurl == null || desurl == "") {
		            return false;
		        }
		        if (desurl.indexOf("{") != -1) {
		            var param = returnUrl.substring(desurl.indexOf("{") + 1, desurl.indexOf("}"));
		            var value = AppServer[param];
		            desurl = desurl.replace("{" + param + "}", value);
		        }
		        try { var target = eval(target); } catch (e) { }
		        if (!target || target == "null") {
		            window.location.href = desurl;
		        } else if (typeof (target) == "object")
		            target.location.href = desurl;
		        else if (typeof (target) == "string") {
		            if (!style) style = "compact";
		            else style += ",resizable=yes";
		            if (target == "")
		                target = "_SELF";
		            if (target.toUpperCase() == "_BLANK") {
		                win = window.open(desurl, "", style);
		            }
		            else {
		                win = window.open(desurl, target, style);
		            }
		            if (!win) alert("弹出窗口被阻止！");
		            //}		
		            //win = window.open(desurl,target,style);
		        }
		        if (win) return win;
		    }

		    /**<doc type="function" name="Global.CenterWin">
		    <desc>得到居中样式字符串</desc>
		    <input>
		    <param name="linkStyle"  type="string">连接样式</param>
		    <param name="isDialog"  type="bool">是否为对话框</param>
		    </input>
		    </doc>**/
		    function CenterWin(linkStyle, isDialog) {
		        if (!linkStyle) return "";
		        if (isDialog)
		            var sp = new StringParam(linkStyle.toLowerCase());
		        else
		            var sp = new StringParam(linkStyle.toLowerCase(), ",", "=");
		        if (sp.Get("left") || sp.Get("top")) {
		            return linkStyle;
		        }
		        else {
		            var widthC = sp.Get("width").replace("px", "");
		            if (widthC == null)
		                widthC = window.screen.width / 2;
		            else
		                sp.Remove("width");
		            var heightC = sp.Get("height").replace("px", "");
		            if (heightC == null)
		                heightC = window.screen.height / 2;
		            else
		                sp.Remove("height");
		            var left = (window.screen.width - widthC) / 2;
		            var top = (window.screen.height - heightC) / 2 - 30;
		            return "left=" + left + ",top=" + top + ",width=" + widthC + ",height=" + heightC + "," + sp.ToString();
		            alert("left=" + left + ",top=" + top + ",width=" + widthC + ",height=" + heightC + "," + sp.ToString());
		        }
		    }
		    function StringParam(spstr, divchar, gapchar) {
		        this.Keys = new Array();
		        this.Values = new Array();
		        this.DivChar = ";";
		        this.GapChar = ":";
		        if (divchar && gapchar) {
		            this.DivChar = divchar;
		            this.GapChar = gapchar;
		        }
		        if (spstr) {
		            var ary = spstr.split(this.DivChar);
		            for (var i = 0; i < ary.length; i++) {
		                var subary = ary[i].split(this.GapChar);
		                if (subary[0] != "") {
		                    this.Values.push(subary[1]);
		                    this.Keys.push(subary[0]);
		                }
		            }
		        }
		    }
		    /**<doc type="protofunc" name="StringParam.GetCount">
		    <desc>获得元素个数</desc>
		    <output type="number">元素的个数</output>
		    </doc>**/
		    StringParam.prototype.GetCount = function() {
		        return this.Keys.length;
		    }

		    ArrayFind = function(ary, value) {
		        for (var i = 0; i < ary.length; i++)
		            if (ary[i] == value) return i;
		        return -1;
		    }

		    /**<doc type="protofunc" name="StringParam.Add">
		    <desc>添加元素</desc>
		    <input>
		    <param name="key" type="string">元素key</param>
		    <param name="value" type="string">元素value</param>
		    <param name="notescape" type="bool">是否不对对value进行编码</param>
		    </input>
		    </doc>**/
		    StringParam.prototype.Add = function(key, value, notescape) {
		        var pos = ArrayFind(this.Keys, key);
		        if (pos >= 0) {
		            var ary = this.Values[pos].split(",");
		            if (ArrayFind(ary, escape(value)) < 0 && !notescape) {
		                if (notescape) {
		                    this.Values[pos] = this.Values[pos] + "," + escape(value);
		                } else {
		                    this.Values[pos] = this.Values[pos] + "," + value;
		                }
		            }
		            else
		                throw new Error(0, "(" + key + " , " + value + ") has exist!");
		        } else {
		            if (notescape) {
		                this.Values.push(value);
		            } else {
		                this.Values.push(escape(value));
		            }
		            this.Keys.push(key);
		        }
		    }

		    /**<doc type="protofunc" name="StringParam.Set">
		    <desc>设置元素值</desc>
		    <input>
		    <param name="key" type="string">元素key</param>
		    <param name="value" type="string">元素value</param>
		    <param name="notclear" type="bool">为true时查询原Values中是否包含指定值，不包含则加入</param>
		    </input>
		    </doc>**/
		    StringParam.prototype.Set = function(key, value, notclear) {
		        if (typeof (key) == "string") {
		            var pos = ArrayFind(this.Keys, key);
		            if (pos >= 0) {
		                if (notclear) {
		                    var ary = this.Values[pos].split(",");
		                    if (ArrayFind(ary, escape(value)) < 0)
		                        this.Values[pos] = this.Values[pos] + "," + escape(value);
		                } else
		                    this.Values[pos] = escape(value);
		            } else {
		                this.Values.push(escape(value));
		                this.Keys.push(key);
		            }
		        }
		        else if (typeof (key) == "number") {
		            if ((key < 0 || key >= this.Keys.length))
		                throw new Error(0, key + " not in scope!");
		            if (notclear) {
		                var ary = this.Values[key].split(",");
		                if (ArrayFind(ary, escape(value)) < 0)
		                    this.Values[key] = this.Values[key] + "," + escape(value);
		            } else
		                this.Values[key] = escape(value);
		        }
		    }

		    /**<doc type="protofunc" name="StringParam.Insert">
		    <desc>在StringParam的制定位置插入值</desc>
		    <input>
		    <param name="key" type="string">元素key</param>
		    <param name="value" type="string">元素value</param>
		    <param name="before" type="number/string">制定位置或值得位置,默认为末位</param>
		    </input>
		    </doc>**/
		    StringParam.prototype.Insert = function(key, value, before) {
		        if (ArrayFind(this.Keys, key) >= 0) {
		            throw new Error(0, key + " has exist!");
		            return;
		        }
		        if (typeof (before) == "undefined") {
		            this.Add(key, escape(value));
		            return;
		        }
		        if (typeof (before) == "number") {
		            if ((before < 0 || before >= this.Keys.length))
		                this.Add(key, value);
		            else {
		                this.Keys.splice(before, 0, key);
		                this.Values.splice(before, 0, escape(value));
		            }
		        }
		        if (typeof (before) == "string") {
		            var bpos = ArrayFind(this.Keys, before);
		            if (bpos < 0)
		                this.Add(key, escape(value)); //这里有错误?
		            else {
		                this.Keys.splice(bpos, 0, key);
		                this.Values.splice(bpos, 0, escape(value));
		            }
		        }

		    }

		    /**<doc type="protofunc" name="StringParam.Get">
		    <desc>得到指定位置的值</desc>
		    <input>
		    <param name="key" type="string/number">元素key或位置</param>
		    </input>
		    </doc>**/
		    StringParam.prototype.Get = function(key) {
		        if (typeof (key) == "string") {
		            var pos = ArrayFind(this.Keys, key);
		            if (pos < 0) return null;
		            return unescape(this.Values[pos]);
		        }
		        if (typeof (key) == "number") {
		            if ((key < 0 || key >= this.Keys.length)) return null;
		            return unescape(this.Values[key]);
		        }
		    }

		    /**<doc type="protofunc" name="StringParam.GetArray">
		    <desc>返回指定Key对应的Value并转化为数组</desc>
		    <output type="object">由指定Key对应的Value转化的数组</output>
		    </doc>**/
		    StringParam.prototype.GetArray = function(key) {
		        var value;
		        if (typeof (key) == "string") {
		            var pos = ArrayFind(this.Keys, key);
		            if (pos < 0) return null;
		            value = this.Values[pos];
		        }
		        if (typeof (key) == "number") {
		            if ((key < 0 || key >= this.Keys.length)) return null;
		            value = this.Values[key];
		        }
		        var ary = value.split(",");
		        for (var i = 0; i < ary.length; i++)
		            ary[i] = unescape(ary[i]);
		        return ary;
		    }
		    /**<doc type="protofunc" name="StringParam.Remove">
		    <desc>删除一个元素</desc>
		    <input>
		    <param name="keyindex" type="string/number">键值或索引</param>
		    </input>
		    </doc>**/
		    StringParam.prototype.Remove = function(key) {
		        if (typeof (key) == "number") {
		            if (key < 0 || key >= this.Keys.length)
		                return false;
		            this.Keys.splice(key, 1);
		            this.Values.splice(key, 1);
		            return true;
		        } else if (typeof (key) == "string") {
		            var pos = ArrayFind(this.Keys, key);
		            if (pos < 0)
		                return false;
		            this.Keys.splice(pos, 1);
		            this.Values.splice(pos, 1);
		            return true;
		        }
		    }


		    /**<doc type="protofunc" name="StringParam.Clear">
		    <desc>清除所有元素</desc>
		    </doc>**/
		    StringParam.prototype.Clear = function() {
		        this.Keys.splice(0, this.Keys.length);
		        this.Values.splice(0, this.Values.length);
		    }

		    /**<doc type="protofunc" name="StringParam.Clone">
		    <desc>复制本集合</desc>
		    <output type="object">StringParam对象</output>
		    </doc>**/
		    StringParam.prototype.Clone = function() {
		        var newsp = new StringParam();
		        var count = this.Keys.length;
		        for (var i = 0; i < count; i++) {
		            newsp.Keys[i] = this.Keys[i];
		            newsp.Values[i] = this.Values[i];
		        }
		        return newsp;
		    }

		    /**<doc type="protofunc" name="StringParam.ToString">
		    <desc>返回StringParam的字符串形式格式为 "Key+GapChar+Value"</desc>
		    <input>
		    <param name="noescape" type="bool">是否用unescape编码Value</param>
		    </input>
		    </doc>**/
		    StringParam.prototype.ToString = function(noescape) {
		        var str = "", value;
		        var count = this.Keys.length;
		        for (var i = 0; i < count; i++) {
		            if (noescape)
		                value = unescape(this.Values[i]);
		            else
		                value = this.Values[i];
		            str += this.Keys[i] + this.GapChar + value + this.DivChar;
		        }
		        if (str.length > 0)
		            return str.substr(0, str.length - 1);
		        return "";
		    }
		</script>
	</body>
</HTML>
