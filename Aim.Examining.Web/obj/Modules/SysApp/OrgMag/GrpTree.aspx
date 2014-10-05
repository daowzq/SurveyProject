<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="GrpTree.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.OrgMag.GrpTree" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>
<script src="/js/ext/ux/TreeCheckNodeUI.js" type="text/javascript"></script>
    
<script type="text/javascript">
    var StatusEnum = { 1: "启用", 0: "停用" };

    var viewport;
    var treeLoader, rootNode;
    var entData, entList;
    var optype;

    function onPgLoad() {
        optype = $.getQueryString({ ID: "type" });
    
        setPgUI();
    }

    function setPgUI() {
        entData = adjustData(AimState["EntData"]);
        entList = AimState["EntList"] || [];

        treeLoader = new Ext.tree.TreeLoader({
            baseAttrs: { uiProvider: Ext.ux.TreeCheckNodeUI }
        });

        // 工具栏
        var tlBar = new Ext.Toolbar({
            items: [{
                text: '保存',
                iconCls: 'aim-icon-save',
                handler: function() {
                    saveChanges();
                }
            }, '-'/*, {
                text: '展开',
                iconCls: 'aim-icon-refresh',
                menu: [{ text: '展开下一层', handler: function() { authStore.expandAll(); } }] }*/]
            });

            // 工具标题栏
            var titPanel = new Ext.Panel({
                tbar: tlBar,
                items: [{ hidden: true}]
            });

            var tree = new Ext.tree.TreePanel({
                id: 'tree',
                region: 'center',
                expanded: true,
                tbar: titPanel,
                width: 230,
                height: 250,
                autoScroll: true,
                animate: true,
                checkModel: 'childCascade',
                containerScroll: true,
                lines: true, //节点之间连接的横竖线
                rootVisible: false, //是否显示根节点
                loader: treeLoader
            });

            tree.on('beforeload', function(node) {
                if (node.attributes["Type"] == "GType") {
                    tree.loader.dataUrl = 'GrpTree.aspx?asyncreq=true&reqaction=querydescendant&type=gtype&id=' + node.attributes.ID;
                }
            });

            tree.on('load', function(node) {
                $.each(node.childNodes, function(i) {
                    var attrs = this.attributes;
                    if (attrs.Type != "GType") {
                        for (var i = 0; i < entList.length; i++) {
                            if (entList[i] == attrs.GroupID) {
                                attrs.checked = true;
                                break;
                            }
                        }
                    }
                });
            });

            rootNode = new Ext.tree.AsyncTreeNode({
                draggable: false,
                id: 'root',
                expanded: true,
                children: entData
            });

            tree.setRootNode(rootNode);

            // 页面视图
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [tree]
            });

            rootNode.expand(true);
        }

            // 应用或模块数据适配
        function adjustData(jdata) {
            if ($.isArray(jdata)) {
                $.each(jdata, function() {
                this.ID = this.GroupID || this.GroupTypeID;
                if (this.GroupTypeID) {
                        this.Type = "GType";
                        this.id = "GT_" + this.ID;
                        this.text = this.Name;
                        this.leaf = !this.HasGroup;
                    } else if (this.GroupID) {
                        this.id = this.ID;
                        this.leaf = this.IsLeaf;
                    }
                });

                return jdata;
            } else {
                return [];
            }
        }

        // 获取树下所有节点
        function getAllNodes(rnode, cnodes) {
            cnodes = cnodes || [];
            var nodes = rnode.childNodes || [];
            $.merge(cnodes, nodes);

            for (var i = 0; i < nodes.length; i++) {
                var node = nodes[i];

                if (node.childNodes.length > 0) {
                    getAllNodes(node, cnodes);
                }
            }

            return cnodes;
        }

        function saveChanges() {
            var allNodes = getAllNodes(rootNode);
            var added = []; // 所有新赋的权限
            var removed = [];  // 所有移除的权限

            $.each(allNodes, function() {
                var node = this;
                var cID = node.attributes.GroupID;

                if (cID && cID != "") {
                    if (node.attributes.checked) {
                        if ($.inArray(cID, entList) < 0) {
                            added.push(cID);
                        }
                    } else {
                        if ($.inArray(cID, entList) >= 0) {
                            removed.push(cID);
                        }
                    }
                }
            });

            GetAjaxData(null, "savechanges", { type: optype, added: added, removed: removed, id: AimState["EntityID"] }, function() { AimDlg.show("保存成功！") });
        }

</script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
