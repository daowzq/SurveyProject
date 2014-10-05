<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="AuthTree.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.MdlMag.AuthTree" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <script src="/js/ext/ext-base.js"></script>
    <script type='text/javascript'>
        if (Ext.isIE6 && /msie 9/.test(navigator.userAgent.toLowerCase())) {
            Ext.isIE6 = Ext.isIE = false;
            Ext.isChrome = Ext.isIE9 = true;
        }</script>
    <script src="/js/ext/ext-all2.js"></script>

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>
    <script src="/js/ext/ux/TreeCheckNodeUI.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var viewport;
        var treeLoader, rootNode;
        var authData, authList;
        var optype;

        function onPgLoad() {
            optype = $.getQueryString({ ID: "type" });

            setPgUI();
        }

        function setPgUI() {
            authData = adjustData(AimState["DtList"]);
            authList = AimState["AtList"] || [];

            treeLoader = new Ext.tree.TreeLoader({
                baseAttrs: { uiProvider: Ext.ux.TreeCheckNodeUI }
            });

            // 工具栏
            var tlBar = new Ext.Toolbar({
                items: [{
                    text: '保存',
                    iconCls: 'aim-icon-save',
                    handler: function () {
                        saveChanges();
                    }
                }]
            });

            // 工具标题栏
            var titPanel = new Ext.Panel({
                tbar: tlBar,
                items: [{ hidden: true }]
            });

            var tree = new Ext.tree.TreePanel({
                id: 'tree',
                region: 'center',
                expanded: true,
                border: false,
                tbar: titPanel,
                width: 230,
                height: 250,
                autoScroll: true,
                animate: true,
                checkModel: 'cascade',
                containerScroll: true,
                lines: true, //节点之间连接的横竖线
                rootVisible: false, //是否显示根节点
                loader: treeLoader
            });

            tree.on('beforeload', function (node) {
                if (node.attributes["Type"] == "AType") {
                    tree.loader.dataUrl = 'AuthTree.aspx?asyncreq=true&reqaction=querydescendant&type=atype&id=' + node.attributes.ID;
                }
            });

            tree.on('load', function (node) {
                var atList = AimState["AtList"];
                $.each(node.childNodes, function (i) {
                    var attrs = this.attributes;
                    if (attrs.Type != "AType") {
                        for (var i = 0; i < authList.length; i++) {
                            if (authList[i] == attrs.AuthID) {
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
                children: authData
            });

            tree.setRootNode(rootNode);

            // 页面视图
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [tree]
            });

            rootNode.expand();
        }

        // 应用或模块数据适配
        function adjustData(jdata) {
            if ($.isArray(jdata)) {
                $.each(jdata, function () {
                    this.ID = this.AuthID || this.AuthTypeID;
                    if (this.AuthTypeID) {
                        this.Type = "AType";
                        this.id = "AT_" + this.ID;
                        this.text = this.Name;
                        this.leaf = !this.HasAuth;
                    } else if (this.AuthID) {
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
            var authAdded = []; // 所有新赋的权限
            var authRemoved = [];  // 所有移除的权限

            $.each(allNodes, function () {
                var node = this;
                var cAuthID = node.attributes.AuthID;

                if (cAuthID && cAuthID != "") {
                    if (node.attributes.checked) {
                        if ($.inArray(cAuthID, authList) < 0) {
                            authAdded.push(cAuthID);
                        }
                    } else {
                        if ($.inArray(cAuthID, authList) >= 0) {
                            authRemoved.push(cAuthID);
                        }
                    }
                }
            });

            GetAjaxData(null, "savechanges", { type: optype, added: authAdded, removed: authRemoved, id: AimState["EntityID"] }, function () { AimDlg.show("保存成功！") });
        }

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
