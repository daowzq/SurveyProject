<%@ Page Title="系统枚举" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="EnumManage.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SysMag.EnumManage" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script src="/js/pgfunc-ext-adv.js" type="text/javascript"></script>

    <script type="text/javascript">
        var EditWinStyle = "dialogWidth:600px; dialogHeight:330px; scroll:yes; center:yes; status:no; resizable:yes;";
        var EditPageUrl = "SysEnumerationEdit.aspx";

        var viewport, store, grid;
        var DataRecord;
        var topid, topnode; //  右键行

        function onPgLoad() {
            clipBoard = { records: [] }; // 剪切板;
            
            topnode = AimState["TopNode"];

            if (topnode) {
                topid = topnode.EnumerationID;
            }
            
            setPgUI();
        }

        function setPgUI() {
            var data = adjustData(AimState["DtList"]) || [];

            DataRecord = Ext.data.Record.create([
			{ name: 'EnumerationID' },
			{ name: 'Code' },
			{ name: 'Name' },
			{ name: 'Value' },
			{ name: 'ParentID' },
			{ name: 'Path' },
			{ name: 'PathLevel' },
			{ name: 'IsLeaf' },
			{ name: 'SortIndex' },
			{ name: 'EditStatus' },
			{ name: 'Tag' },
			{ name: 'Description' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate'}]);

			store = new Ext.ux.data.AimAdjacencyListStore({
			    data: data,
			    aimbeforeload: function(proxy, options) {
			        var rec = store.getById(options.anode);
			        options.reqaction = "querychildren";
			        
			        if (rec) {
			            options.data.pids = [rec.id];
			        }
			    },
			    reader: new Ext.ux.data.AimJsonReader({ id: 'EnumerationID', dsname: 'DtList' }, DataRecord)
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

                // 表格面板
                grid = new Ext.ux.grid.AimEditorTreeGridPanelEx({
                    store: store,
                    master_column_id: 'Name',
                    region: 'center',
                    columns: [
				{ id: 'Name', dataIndex: 'Name', header: "名称", width: 250, sortable: true },
				{ id: 'Code', dataIndex: 'Code', header: "编码", width: 200, sortable: true },
				{ id: 'Value', dataIndex: 'Value', header: "枚举值", width: 120, sortable: true },
				{ id: 'Description', dataIndex: 'Description', header: "描述", width: 120, sortable: true }
      ],
                    autoExpandColumn: 'Description',
                    tbar: titPanel
                });

                grid.on('paste', function(grid, type, rec, cb) {
                    var pdstype = cb.type;
                    var recs = this.clipBoard.records;
                    var idList = this.getIdStringList(recs);
                    var pids = [];  // 需要刷新的节点

                    $.ajaxExec('paste', { "IdList": idList, type: type, pdstype: pdstype, tid: rec.id }, function() {
                        var selrecs = grid.getSelections();
                        $.merge(recs, selrecs);

                        if (pdstype == 'cut') {
                            // 删除所有复制节点
                            $.each(recs, function() {
                                if (store.getById(this.id)) {
                                    // 若存在则删除节点
                                    store.remove(this);
                                }
                            });

                            if (type == 'sub') {
                                pids = $.map(recs, function(n, i) {
                                    return n.data["ParentID"];
                                });

                                $.merge(pids, [rec.id]);
                            } else {
                                pids = $.map(recs, function(n, i) {
                                    return n.data["ParentID"];
                                });

                                $.merge(pids, [rec.data["ParentID"] || null, rec.id]);
                            }
                        } else {
                            store.remove(rec);
                            pids = [rec.data["ParentID"]];
                        }

                        if (pids && pids.length > 0) {
                            grid.reload({ pids: pids });
                            store.singleSort('SortIndex', 'ASC');
                        }
                    });
                });

                grid.on('rowcontextmenu', function(grid, rowIdx, e) {
                    e.preventDefault(); // 抑制IE右键菜单

                    var grid = this;
                    var store = this.store;
                    var xy = e.getXY();

                    grid.contextRow = store.getAt(rowIdx);

                    var sels = grid.getSelections();

                    if (!sels || sels.length < 0 || $.inArray(this.contextRow, sels) < 0) {
                        grid.selectRow(rowIdx);
                    }

                    if (!grid.rowContextMenu) {
                        grid.rowContextMenu = new Ext.menu.Menu({ id: 'contextMenu', items: [{
                            id: 'menuItemDelete',
                            text: '删除',
                            iconCls: 'aim-icon-delete2',
                            handler: function() {
                                batchOperate('batchdelete');
                            }
                        }, '-', {
                            id: 'menuItemAddSid',
                            text: '新增兄弟节点',
                            handler: function() {
                                showEditWin('c', grid.contextRow);
                            }
                        }, {
                            id: 'menuItemAddSub',
                            text: '新增子节点',
                            handler: function() {
                                showEditWin('cs', grid.contextRow);
                            }
                        }, {
                            id: 'menuItemUpdate',
                            text: '修改',
                            handler: function() {
                                showEditWin('u', grid.contextRow);
                            }
                        }, '-', {
                            id: 'menuItemCut',
                            iconCls: 'aim-icon-cut',
                            text: '剪切',
                            handler: function() {
                                grid.cut();
                            }
                        }, {
                            id: 'menuItemPaste',
                            iconCls: 'aim-icon-plaster',
                            text: '粘贴',
                            menu: [{ id: 'menuItemPasteAsSib', text: '粘贴为同级节点', handler: function() {
                                grid.paste('sib');
                            }
                            }, { id: 'menuItemPasteAsSub', text: '粘贴为子节点', handler: function() {
                                grid.paste('sub');
                            }
                            }, {
                                id: 'menuItemCancelPanel', text: '取消', handler: function() {
                                    grid.clearClipBoard();
                                }
                            }
]
                        }
]
                        });
                    }

                    if (grid.contextRow) {
                        var roots = store.getRootNodes();
                        var isroot = (roots.indexOf(grid.contextRow) >= 0);
                        var isleaf = store.isLeafNode(grid.contextRow);

                        if (!isleaf || isroot) {
                            Ext.getCmp('menuItemDelete').setDisabled(true);
                        } else {
                            Ext.getCmp('menuItemDelete').setDisabled(false);
                        }

                        if (isroot) {
                            Ext.getCmp('menuItemUpdate').setDisabled(true);
                            Ext.getCmp('menuItemAddSid').setDisabled(true);
                            Ext.getCmp('menuItemPasteAsSib').setDisabled(true);
                        } else {
                            Ext.getCmp('menuItemUpdate').setDisabled(false);
                            Ext.getCmp('menuItemAddSid').setDisabled(false);
                            Ext.getCmp('menuItemPasteAsSib').setDisabled(false);
                        }

                        if (grid.clipBoard.records && grid.clipBoard.records.length > 0) {
                            Ext.getCmp('menuItemPaste').setDisabled(false);
                        } else {
                            Ext.getCmp('menuItemPaste').setDisabled(true);
                        }
                    }

                    this.rowContextMenu.showAt(xy);
                })

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid
                    ]
                });

                    // 展开所有加载的节点
                    store.expandAll();
                }

                function adjustData(jdata) {
                    if ($.isArray(jdata)) {
                        $.each(jdata, function() {
                            if (topid && topid == this.ParentID) {
                                this.ParentID = null;
                            }
                        });

                        return jdata;
                    } else {
                        return [];
                    }
                }

                function batchOperate(action, recs, params, url) {
                    recs = recs || grid.getSelections();
                
                    if (!recs || recs.length <= 0) {
                        AimDlg.show("请先选择要操作的记录！");
                        return;
                    }

                    if (action == 'batchdelete') {
                        for (var i = 0; i < recs.length; i++) {
                            if (!store.isLeafNode(recs[i])) {
                                AimDlg.show("存在非叶节点，请删除叶节点子节点再作删除操作！");
                                return;
                            }
                        }

                        if (!confirm("确定执行删除操作？")) {
                            return;
                        }
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

                            store.singleSort('SortIndex', 'ASC');
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

                        store.singleSort('SortIndex', 'ASC');
                    });
                }

                // 提交数据成功后
                function onExecuted() {
                    // store.reload();
                }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>系统枚举</h1></div>
</asp:Content>
