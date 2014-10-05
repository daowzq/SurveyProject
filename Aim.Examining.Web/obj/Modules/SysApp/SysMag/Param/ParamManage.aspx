<%@ Page Title="系统参数" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="ParamManage.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.ParamManage" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>
    <script src="/js/ext/ux/FieldLabeler.js" type="text/javascript"></script>

    <script src="/js/pgfunc-ext-adv.js" type="text/javascript"></script>

    <script type="text/javascript">
        var EditWinStyle = "dialogWidth:600px; dialogHeight:230px; scroll:yes; center:yes; status:no; resizable:yes;";
        var EditPageUrl = "SysParameterCatalogEdit.aspx";

        var viewport, store, grid, contextMenu;
        var DataRecord;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            var data = AimState["DtList"] || {};

            DataRecord = Ext.data.Record.create([
            { name: 'ParameterCatalogID', type: 'string' },
            { name: 'ParentID', type: 'string' },
            { name: 'IsLeaf', type: 'bool' },
            { name: 'Code' },
            { name: 'Name' },
            { name: 'SortIndex' },
            { name: 'Description' },
            { name: 'CreatedDate'}]);

            store = new Ext.ux.data.AimAdjacencyListStore({
                data: data,
                aimbeforeload: function(proxy, options) {
                    var rec = store.getById(options.anode);
                    options.reqaction = "querychildren";
                },
                reader: new Ext.ux.data.AimJsonReader({ id: 'ParameterCatalogID', dsname: 'DtList' }, DataRecord)
            });

            // 搜索栏
            var schBar = new Ext.ux.AimSchPanel({
                items: []
            });

            // 工具栏
            var tlBar = new Ext.ux.AimToolbar({
                items: [{ text: '展开下一层', handler: function() { store.expandAll(); }
                }, '-', { html: '<span color="yellow">(右键编辑节点)</span>', xtype: 'tbtext'}]
            });

                // 工具标题栏
                var titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });

                var sm = new Ext.grid.RowSelectionModel({ singleSelect: false,
                    listeners: {
                        rowselect: function(g, ridx, e) {
                            var rec = store.getAt(ridx);

                            if (!frameContent.reloadPage) {
                                frameContent.location.href = "SysParameterList.aspx?cid=" + rec.id;
                            }

                            if (frameContent.reloadPage) {
                                // 异步加载
                                frameContent.reloadPage.call(this, { cid: rec.id });
                            }
                        }
                    }
                });

                // 表格面板
                grid = new Ext.ux.grid.AimEditorTreeGridPanel({
                    store: store,
                    master_column_id: 'Name',
                    region: 'west',
                    split: true,
                    width: 300,
                    minSize: 250,
                    maxSize: 500,
                    columns: [
				{ id: 'Name', header: "参数名称", width: 160, sortable: true, dataIndex: 'Name' }
      ],
                    sm: sm,
                    autoExpandColumn: 'Name',
                    tbar: titPanel
                });

                grid.on("rowcontextmenu", function(grid, rowIdx, e) {
                    e.preventDefault(); //这行是必须的
                    showContextMenu(rowIdx, e.getXY());
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid, {
                    region: 'center',
                        border:false,
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src=""></iframe>'}]
                    });

                    // 展开所有加载的节点
                    store.expandAll();
                }

                function showContextMenu(rowIdx, xy) {
                    var rec = store.getAt(rowIdx);

                    if (!contextMenu) {
                        contextMenu = new Ext.menu.Menu({ id: 'contextMenu' });

                        menuItemAddCls = new Ext.menu.Item({
                            id: 'menuItemAddSid',
                            text: '新增兄弟节点'
                        });

                        menuItemAdd = new Ext.menu.Item({
                            id: 'menuItemAddSub',
                            text: '新增子节点'
                        });

                        menuItemUpdate = new Ext.menu.Item({
                            id: 'menuItemUpdate',
                            text: '修改'
                        });

                        menuItemDelete = new Ext.menu.Item({
                            id: 'menuItemDelete',
                            text: '删除'
                        });

                        contextMenu.addItem(menuItemAddCls);
                        contextMenu.addItem(menuItemAdd);

                        contextMenu.addItem(menuItemUpdate);
                        contextMenu.addItem(menuItemDelete);
                    }

                    menuItemAddCls.setHandler(function() { showEditWin('c', rec); })    // 创建节点
                    menuItemAdd.setHandler(function() { showEditWin('cs', rec); })      // 创建子节点
                    menuItemUpdate.setHandler(function() { showEditWin('u', rec); })    // 更新节点
                    menuItemDelete.setHandler(function() { batchOperate('batchdelete', [rec]); })    // 删除节点

                    contextMenu.showAt(xy);
                }

                function batchOperate(action, recs, params, url) {
                    if (!recs || recs.length <= 0) {
                        AimDlg.show("请先选择要操作的记录！");
                        return;
                    } else if (!confirm("确定执行删除操作？")) {
                        return;
                    }

                    ExtBatchOperate(action, recs, params, url, function(args) {
                        if (args.status == "success") {
                            // 从store中删除已删除的记录
                            var pids = $.map(recs, function(n, i) {
                                var tpid = n.data["ParentID"];
                                store.remove(n);
                                return tpid;
                            });

                            // 刷新已删除的记录的父节点
                            store.reload({ params: { data: { ids: pids, pids: pids}} });

                            store.singleSort('CreatedDate', 'ASC');
                        }
                    });
                }

                function showEditWin(op, rec) { 
                    OpenModelWin(EditPageUrl, { op: op, id: rec.id }, EditWinStyle, function() {
                        var expnode = null; // 重新加载后需要展开的节点
                        switch (op) {
                            case 'c':
                                if (rec && rec.json.ParentID) {
                                    var pnode = store.getById(rec.json.ParentID);
                                    store.remove(pnode);
                                    expnode = pnode;

                                    store.reload({ params: { data: { ids: [pnode.id], pids: [pnode.id]}} });
                                }
                                break;
                            case 'cs':
                            case 'u':
                                store.remove(rec);
                                store.reload({ params: { data: { ids: [rec.id]}} });

                                if (op == 'cs') {
                                    expnode = rec;
                                }
                                break;
                        }

                        if (expnode && expnode.id) {
                            // 展开节点
                            $.ensureExec(function() {
                                var npnode = store.getById(expnode.id);
                                if (npnode) {
                                    store.expandNode(npnode);
                                    return true;
                                }

                                return false;
                            });
                        }

                        store.singleSort('CreatedDate', 'ASC');
                    });
                }

                // 提交数据成功后
                function onExecuted() {
                    // store.reload();
                }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>系统参数</h1></div>
</asp:Content>
