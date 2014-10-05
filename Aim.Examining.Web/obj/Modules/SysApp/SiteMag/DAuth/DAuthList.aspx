<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DAuthList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DAuthList" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />
    
    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var grantFormStyle = "height=550,width=900,status=yes,toolbar=no,menubar=no,location=no";
        
        var formStyle = "dialogWidth:500px; dialogHeight:330px; scroll:yes; center:yes; status:no; resizable:yes;";
        var entCatalogFormStyle = "dialogWidth:450px; dialogHeight:100px; scroll:yes; center:yes; status:no; resizable:yes;";

        var store, entCatalogStore;
        var grid, entCatalogGrid, viewport;
        var entCatalogSchField;
        
        var EntRecord;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            entCatalogStore = new Ext.ux.data.AimJsonStore({
                dsname: 'EntCatalogList',
                idProperty: 'DynamicAuthCatalogID',
                data: { records: AimState["EntCatalogList"] || [] },
                fields: [{ name: 'DynamicAuthCatalogID' }, { name: 'Name' }, { name: 'Code' }, { name: 'SortIndex' }, { name: 'Description'}]
            });

            entCatalogTlBar = new Ext.ux.AimToolbar({
                items: []
            });

            var data = AimState["EntList"] || [];

            EntRecord = Ext.data.Record.create([
			{ name: 'DynamicAuthID' },
			{ name: 'Name' },
			{ name: 'CatalogCode' },
			{ name: 'ParentID' },
			{ name: 'Path' },
			{ name: 'PathLevel' },
			{ name: 'IsLeaf' },
			{ name: 'Data' },
			{ name: 'EditStatus' },
			{ name: 'Creatable' },
			{ name: 'Deletable' },
			{ name: 'Editable' },
			{ name: 'Grantable' },
			{ name: 'Tag' },
			{ name: 'Description' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate' }
]);

			store = new Ext.ux.maximgb.tg.AdjacencyListStore({
			    autoLoad: true,
			    parent_id_field_name: 'ParentID',
			    leaf_field_name: 'IsLeaf',
			    data: data,
			    reader: new Ext.ux.data.AimJsonReader({ id: 'DynamicAuthID', dsname: 'EntList' }, EntRecord),
			    proxy: new Ext.ux.data.AimRemotingProxy({
			        aimbeforeload: function(proxy, options) {
			            options.id = options.anode;
			        }
			    })
			});

            entCatalogGrid = new Ext.ux.grid.AimGridPanel({
                id: 'entCatalogPanel',
                store: entCatalogStore,
                frame:false,
                region: 'west',
                split: true,
                border:false,
                width: 200,
                minSize: 100,
                maxSize: 400,
                columns: [
            { id: 'DynamicCatalogID', header: 'DynamicCatalogID', dataIndex: 'DynamicCatalogID', hidden: true },
            { id: 'Name', header: '权限类型', width: 100, renderer: entCatalogRender, sortable: true, dataIndex: 'Name' },
            { id: 'Code', header: '权限类型代码', width: 100, sortable: true, hidden: true, dataIndex: 'Code' }
            ],
                autoExpandColumn: 'Name',
                tbar: entCatalogTlBar
            });

            entCatalogGrid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                Ext.getCmp('btnAddRoot').setDisabled(!r.json.Creatable);
                store.removeAll();

                store.load({ params: { "code": r.data.Code} });
            });
            
            store.on("load", function() {
                // store.expandAll();
            });

            // 搜索栏
            var schBar = new Ext.ux.AimSchPanel({
                items: [{ layout: 'form', unstyled: true, columnWidth: .33, items: []}]
            });

            // 工具栏
            var tlBar = new Ext.Toolbar({
                items: [{
                    id: 'btnAddRoot',
                    text: '添加根权限',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openMdlWin(null, "c");
                    }
                }, {
                    id: 'btnAdd',
                    text: '添加子权限',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openMdlWin(null, "cs");
                    }
                }, {
                    id: 'btnEdt',
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openMdlWin(null, "u");
                    }
                }, {
                    id: 'btnDel',
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }

                        if (confirm("确定删除所选记录？")) {
                            doDelete(recs[0]);
                        }
                    }
                }, '-', {
                    id: 'btnGrant',
                    text: '授权',
                    iconCls: 'aim-icon-key',
                    handler: function() {
                        var recs = entCatalogGrid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择进行授权操作的权限类型！");
                            return;
                        }
                        
                        OpenWin("DPermissionGrant.aspx?type=catalog&code=" + recs[0].json.Code, "_blank", CenterWin(grantFormStyle));
                    }
                }, {
                    id: 'btnGrantRev',
                    text: '反向授权',
                    iconCls: 'aim-icon-key',
                    handler: function() {
                        var recs = entCatalogGrid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择进行授权操作的权限类型！");
                            return;
                        }

                        OpenWin("DPermissionGrantRev.aspx?type=catalog&gd=o&code=" + recs[0].json.Code, "_blank", CenterWin(grantFormStyle));
                    }
}/*, '-', {
                    text: '其他',
                    iconCls: 'aim-icon-cog',
                    menu: [{ text: '其他', handler: function() {  } }]
}*/]
                });

                // 工具标题栏
                var titPanel = new Ext.Panel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.maximgb.tg.GridPanel({
                    store: store,
                    master_column_id: 'Name',
                    region: 'center',
                    columns: [{ id: 'Name', header: "权限名", renderer: linkRender, width: 250, sortable: true, dataIndex: 'Name' },
                { id: 'CatalogCode', header: '分类', hidden: true, width: 100, sortable: true, dataIndex: 'CatalogCode' },
				{ id: "Data", header: "权限信息", width: 250, sortable: true, dataIndex: 'Data' },
				{ id: "Description", header: "描述", width: 75, sortable: true, dataIndex: 'Description' },
				{ header: "创建日期", width: 75, sortable: true, dataIndex: 'CreateDate'}],
                    autoExpandColumn: 'Description',
                    tbar: titPanel
                });

                grid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                    Ext.getCmp("btnAdd").setDisabled(!r.data.Creatable);
                    Ext.getCmp("btnEdt").setDisabled(!r.data.Editable);
                    Ext.getCmp("btnDel").setDisabled(!r.data.Deletable);
                });

                // 页面视图
                viewport = new Ext.Viewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, entCatalogGrid, grid]
                });

                entCatalogGrid.getSelectionModel().selectFirstRow();
            }

            // 链接渲染
            function entCatalogRender(val, p, rec) {
                var rtn = val;
                switch (this.dataIndex) {
                    case "Name":
                        rtn = "<a class='aim-ui-link'>" + val + "</a>";
                        break;
                }

                return rtn;
            }

            // 链接渲染
            function linkRender(val, p, rec) {
                var rtn = val;
                switch (this.dataIndex) {
                    case "Name":
                        rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"DAuthEdit.aspx?id=" + rec.id + "\")'>" + val + "</a>";
                        break;
                }

                return rtn;
            }

            // 枚举渲染
            function enumRender(val, p, rec) {
                var rtn = val;
                switch (this.dataIndex) {
                    case "Status":
                        rtn = StatusEnum[val];
                        break;
                }

                return rtn;
            }

            // 打开模态窗口
            function openMdlWin(url, op, pa, style, grd) {
                url = url || "DAuthEdit.aspx";
                op = op || "r";
                style = style || formStyle;
                grd = grd || grid;

                var entCatalogSels = entCatalogGrid.getSelectionModel().getSelections();
                var entCatalogSel;
                if (entCatalogSels.length > 0) entCatalogSel = entCatalogSels[0];

                var sels = grid.getSelectionModel().getSelections();
                var sel = null;
                if (sels.length > 0) sel = sels[0];

                var params = [];
                params[params.length] = "op=" + op;

                if (op === "c" || op === "cs") {
                    if (entCatalogSel && url.indexOf("id=") < 0) {
                        if (op === "c") {
                            params[params.length] = "id=" + entCatalogSel.json.DynamicAuthCatalogID;
                        } else if (op === "cs") {
                            if (!sel) {
                                AimDlg.show('请选择要创建的节点的父节点。', '提示', 'alert');
                                return;
                            }
                        }
                    }
                } else if (!sel) {
                    AimDlg.show('请选择需要操作的行。', '提示', 'alert');
                    return;
                }

                if (op !== "c" && url.indexOf("id=") < 0 && sel) {
                    params[params.length] = "id=" + sel.data.DynamicAuthID.toString();
                }

                url = $.combineQueryUrl(url, params)
                rtn = window.showModalDialog(url, window, style);

                if (rtn && rtn.result) {
                    if (rtn.result === 'success') {
                        if (op === 'u') {
                            for (var key in rtn.data) {
                                sel.beginEdit();
                                sel.set(key, rtn.data[key]);
                                sel.commit();
                            }
                        } else {
                            if (op === 'c') {
                                rtn.data.IsLeaf = true;
                                var rec = new EntRecord(rtn.data, rtn.data.DynamicAuthID);
                                store.addSorted(rec);
                            } else if (op === 'cs') {
                                rtn.data.IsLeaf = true;
                                var rec = new EntRecord(rtn.data, rtn.data.DynamicAuthID);
                                var pnode = store.getById(rtn.data.ParentID);
                                if (pnode) {
                                    if (pnode.data) { pnode.data.IsLeaf = false; }
                                    if (pnode.json) { pnode.json.IsLeaf = false; }
                                    store.addToNode(pnode, rec);
                                    store.expandNode(pnode);
                                }
                            }
                        }
                    }
                }
            }

            function doDelete(rec) {
                if ((!store.isLoadedNode(rec) && !rec.data.IsLeaf || store.hasChildNodes(rec))) {
                    AimDlg.show('此权限可能拥有子权限，必须删除所有子权限方可删除。', '提示', 'alert');
                    return;
                }
                
                jQuery.ajaxExec("delete", { id: rec.id }, onExecuted);
            }

            function onExecuted(args) {
                if (args.options.reqaction === 'delete') {
                    var rec = store.getById(args.options.data.id);
                    var pnode = store.getById(rec.data.ParentID);
                    if (pnode) { store.remove(rec); }
                    else { store.remove(rec) }
                    if (pnode && !store.hasChildNodes(pnode)) {
                        if (pnode.data) { pnode.data.IsLeaf = true; }
                        if (pnode.json) { pnode.json.IsLeaf = true; }
                    }
                }
            }

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>动态权限列表</h1></div>
</asp:Content>
