<%@ Page Title="组织列表" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="OrgSelectView.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.Select.CustomerSlt.OrgSelectView" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/ext/ux/TreePanel.js" type="text/javascript"></script>

    <script type="text/javascript">
        var tree, url = "OrgSelectJson.aspx?nodeId=1001&ckId=" + ($.getQueryString({ ID: 'ckId' }) || '');
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
                //通过该节点的深度 控制展开层级
                //for (var i = 0; i < nodeArr.length; i++) {
                //   // alert(nodeArr[i].getDepth());
                //}
            })
            tree = new Tree.TreePanel({
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
                node.attributes.checked = checked;
                //                node.eachChild(function(child) {
                //                    child.ui.toggleCheck(checked);
                //                    child.attributes.checked = checked;
                //                    child.fireEvent('checkchange', child, checked);  //递归选中子项
                //                });
            }, tree);

            //tree.on('beforeload', function(node) {
            //    tree.loader.dataUrl = 'OrgSelectJson.aspx?nodeId=' + node.id;
            //}, tree);

            //root.expand();
            //tree.expandAll(); //展开所有节点


            //--------------------------------面板--------------
            cmdPanel = new Ext.Panel({
                region: 'south',
                layout: 'hbox',
                // hidden: (seltype == "single"),
                layoutConfig: {
                    padding: '5',
                    pack: 'center',
                    align: 'middle'
                },
                height: 40,
                items: [{ xtype: 'button', text: '确定',
                    handler: function() {
                        selected();
                    }
                },
            { xtype: 'button', text: '取消', handler: function() {
                window.returnValue = "";
                window.close();
            } }]
            });

            viewport = new Ext.Viewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, tree, cmdPanel]
            });
            //--------------------------------------------
        }


        //选中方法
        function selected() {
            //选中的组织GroupID
            var groupIDArr = tree.getChecked();
            var groupIds = [], groupName = [];
            $.each(groupIDArr, function() {
                groupIds.push(this.id);
                groupName.push(this.text);
            })
            if (groupIds.length > 0) {
                window.returnValue = groupIds.join() + "|" + groupName.join();
                window.close();
            } else {
                window.returnValue = "";
                window.closed();
            }
        }
        
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            组列表</h1>
    </div>
</asp:Content>
