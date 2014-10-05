<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="MiddleDbPostionSlt.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.Select.CustomerSlt.MiddleDbPostionSlt" %>

<%@ OutputCache Duration="120" VaryByParam="None" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/ext/ux/TreePanel.js" type="text/javascript"></script>

    <script type="text/javascript">
        var param = $.getQueryString({ ID: 'param' }) || "";         //选中的ID
        var nodeId = $.getQueryString({ ID: 'nodeId' }) || "1001"; // 默认ID

        var tree, url = "?nodeId=1001";
        var nodeArr = [];   // 数据节点
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            //--------------------------tree---------------------------
            url += "&param=" + param;
            var Tree = Ext.tree;
            treeLoader = new Tree.TreeLoader({ dataUrl: url });
            treeLoader.on("load", function(tree, node, response) {
                nodeArr = node.childNodes;
                //通过该节点的深度 控制展开层级 nodeArr[3].id  //1009


                //                for (var i = 0; i < nodeArr.length; i++) {
                //                    // alert(nodeArr[i].getDepth());
                //                    if ((ckId + "").indexOf(nodeArr[i]["id"] || "") > -1) {

                //                        // nodeArr[i].attributes.checked = true;
                //                        nodeArr[i].getUI().toggleCheck(true); //设置选中
                //                    }
                //                }
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

            tree.on("dblclick", function(node, e) {
                if (node.text == "飞力集团") return;
                parent.treeDbClick.call(this, node);
            });
            tree.on("click", function(node, e) {
                if (node.text == "飞力集团") return;
                parent.treeClick.call(this, node);
            });
            //tree.on('beforeload', function(node) {
            //    tree.loader.dataUrl = 'OrgSelectJson.aspx?nodeId=' + node.id;
            //}, tree);

            //root.expand();
            //tree.expandAll(); //展开所有节点
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [tree]
            });
        }

 
        
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
