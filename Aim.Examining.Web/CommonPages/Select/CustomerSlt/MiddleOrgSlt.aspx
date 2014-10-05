<%@ Page Title="组织机构" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="MiddleOrgSlt.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.Select.CustomerSlt.MiddleOrgSlt" %>

<%--<%@ OutputCache Duration="120" VaryByParam="None" %>--%>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <script src="/js/ext/ux/TreePanel.js" type="text/javascript"></script>
    <script type="text/javascript">
       var  IsSurveyAdmin=<%=IsSurveyAdmin%>
        var ckId = $.getQueryString({ ID: 'ckId' }) || "";         //选中的ID
        var nodeId = $.getQueryString({ ID: 'allowNodeId' }) || ""; // 默认ID

        if (nodeId.indexOf("1001") > -1) nodeId = "";               //飞力集团
        var tree, url = "MiddleOrgSlt.aspx?nodeId=1001&allowNodeId=" + nodeId;
        var nodeArr = [];   // 数据节点
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            //--------------------------tree---------------------------
            var Tree = Ext.tree;
            treeLoader = new Tree.TreeLoader({ dataUrl: url });
            treeLoader.on("load", function(tree, node, response) {
                nodeArr = node.childNodes;
            })

            tree = new Tree.TreePanel({
                title: '<font color=red size=1.5em >说明:双击可添加</font>',
                region: "center",
                root: new Tree.AsyncTreeNode({
                    text: '飞力集团',
                    draggable: false,
                    expanded: true,
                    id: '1001'
                }),
                useArrows: true,
                autoScroll: true,
                animate: true,
                enableDD: true,
                containerScroll: true,
                loader: treeLoader
            });

            tree.on('checkchange', function(node, checked) {
                node.expand();
                // node.attributes.checked = checked;
                node.eachChild(function(child) {
                    child.ui.toggleCheck(checked);
                    child.attributes.checked = checked;
                    child.fireEvent('checkchange', child, checked);  //递归选中子项
                });

            }, tree);

            //tree.on('beforeload', function(node) {
            //    tree.loader.dataUrl = 'OrgSelectJson.aspx?nodeId=' + node.id;
            //}, tree);

            tree.on("dblclick", function(node, e) {
                if(node.text=="飞力集团"){
                   if(IsSurveyAdmin=="1")
                        parent.treeDbClick.call(this, node);
                   else  return;
                }
                parent.treeDbClick.call(this, node);
            });
            tree.on("click", function(node, e) {
                if(node.text=="飞力集团"){
                   if(IsSurveyAdmin=="1")
                        parent.treeDbClick.call(this, node);
                   else  return;
                }
                parent.treeClick.call(this, node);
            });
            //root.expand();
            //tree.expandAll(); //展开所有节点

            viewport = new Ext.Viewport({
                layout: 'border',
                items: [tree]
            });
            //--------------------------------------------
        }

        function openWin(val) {
	var task = new Ext.util.DelayedTask();
	task.delay(50, function () {
		opencenterwin(EditPageUrl + "?op=r&id=" + val, "", 900, 620);
	});
}
function opencenterwin(url, name, iWidth, iHeight) {
	var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
	var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
	window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
}
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
