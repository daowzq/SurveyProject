<%@ Page Title="组织策划" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="OrgStructure.aspx.cs" Inherits="Aim.Examining.Web.OrgStructure" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script src="/js/ext/ux/FieldLabeler.js" type="text/javascript"></script>

    <script src="/js/pgfunc-ext-adv.js" type="text/javascript"></script>

    <script type="text/javascript">
        var EditWinStyle = "dialogWidth:550px; dialogHeight:250px; scroll:yes; center:yes; status:no; resizable:yes;";
        var EditPageUrl = "OrgStructureEdit.aspx";

        var DataRecord, store;
        var viewport, grid, contextMenu;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            var data = AimState["DtList"];

            DataRecord = Ext.data.Record.create([
        { name: 'GroupID', type: 'string' },
        { name: 'ParentID', type: 'string' },
        { name: 'IsLeaf', type: 'bool' },
        { name: 'Name' },
        { name: 'Code' },
        { name: 'Type' },
        { name: 'Status' },
        { name: 'SortIndex' },
        { name: 'Description' },
        { name: 'CreateDate' }
        ]);

            store = new Ext.ux.data.AimAdjacencyListStore({
                data: data,
                aimbeforeload: function(proxy, options) {
                    var rec = store.getById(options.anode);
                    options.reqaction = "querychildren";

                    if (rec) {
                        options.data.id = rec.id;
                    }
                },
                reader: new Ext.ux.data.AimJsonReader({ id: 'GroupID', dsname: 'DtList' }, DataRecord)
            });

            // 搜索栏
            var schBar = new Ext.ux.AimSchPanel({
                items: []
            });

            // 工具栏
            var tlBar = new Ext.ux.AimToolbar({
                items: [{ text: '展开', handler: function() { store.expandAll(); }
                }, '-', { html: '<span color="yellow">(右键编辑节点)</span>', xtype: 'tbtext'}]
            });


            // 工具标题栏
            var titPanel = new Ext.Panel({
                tbar: tlBar,
                items: [schBar]
            });

            var sm = new Ext.grid.RowSelectionModel({ singleSelect: false,
                listeners: {
                    rowselect: function(g, ridx, e) {
                        var rec = store.getAt(ridx);
                        if (!frameContent.reloadPage) {
                            frameContent.location.href = "UsrView.aspx?type=group&id=" + rec.id + "&op=" + pgOperation;
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
                width: 480,
                minSize: 250,
                maxSize: 500,
                columns: [
				{ id: 'Name', header: "组织结构", renderer: colRender, width: 110, sortable: true, dataIndex: 'Name' },
				{ header: "编号", width: 70, sortable: true, dataIndex: 'Code' },
				{ header: "状态", width: 40, sortable: true, dataIndex: 'Status', renderer: statRender }
                //{ header: "GroupID", width: 70, sortable: true, dataIndex: 'GroupID' },
      ],
                sm: sm,
                autoExpandColumn: 'Name',
                tbar: titPanel
            });

            function colRender(val, p, rec) {
                var rtn = val;
                var type = rec.get('Type');

                switch (type) {
                    case 3:
                        rtn = '<span valign="bottom"><img src="/images/shared/user_red.png">' + val + '</span>';
                        break;
                    case 2:
                        rtn = '<span valign="bottom"><img src="/images/shared/preview2.png">' + val + '</span>';
                        break;
                }

                return rtn;
            }
            function statRender(val, p, rec) {
                switch (val) {
                    case 0:
                        rtn = '失效';
                        break;
                    case 1:
                        rtn = '有效';
                        break;
                    default:
                        rtn = '有效';
                        brreak;
                }

                return rtn;
            }

            grid.on("rowcontextmenu", function(grid, rowIdx, e) {
                e.preventDefault(); //这行是必须的
                showContextMenu(rowIdx, e.getXY());
            });

            //添加右键
            function showContextMenu(rowIdx, xy) {
                if (pgOperation == 'r') {
                    return false;
                }

                var rec = store.getAt(rowIdx);

                if (!contextMenu) {
                    contextMenu = new Ext.menu.Menu({ id: 'contextMenu' });

                    menuItemAddCls = new Ext.menu.Item({
                        id: 'menuItemAddSid',
                        text: '新增同级部门'
                    });

                    menuItemAdd = new Ext.menu.Item({
                        id: 'menuItemAddSub',
                        text: '新增下级部门'
                    });

                    menuItemAddSub = new Ext.menu.Item({
                        id: 'menuItemAddSubRole',
                        text: '新增组织角色'
                    });


                    menuItemUpdate = new Ext.menu.Item({
                        id: 'menuItemUpdate',
                        text: '修改'
                    });

                    menuItemDelete = new Ext.menu.Item({
                        id: 'menuItemDelete',
                        text: '删除'
                    });

                    // contextMenu.addItem(menuItemAddCls);
                    contextMenu.addItem(menuItemAdd);
                    contextMenu.addItem(menuItemAddSub);

                    contextMenu.addItem(menuItemUpdate);
                    contextMenu.addItem(menuItemDelete);
                }

                if (!rec.get('ParentID')) {
                    menuItemAddCls.setVisible(false);
                    menuItemDelete.setVisible(false);
                    menuItemUpdate.setVisible(false);
                } else if (rec.get('Type') == '21') {
                    menuItemAddCls.setVisible(false)    // 创建节点
                    menuItemAdd.setVisible(false)    // 创建节点
                    menuItemAddSub.setVisible(false)    // 创建节点
                    menuItemDelete.setVisible(true);
                    menuItemUpdate.setVisible(true);
                }
                else {
                    menuItemAddCls.setVisible(true)    // 创建节点
                    menuItemAdd.setVisible(true)    // 创建节点
                    menuItemAddSub.setVisible(true)    // 创建节点
                    menuItemDelete.setVisible(true);
                    menuItemUpdate.setVisible(true);
                }

                // menuItemAddCls.setHandler(function() { showEditWin('c', rec); })    // 创建节点
                menuItemAdd.setHandler(function() { showEditWin('cs', rec); })      // 创建子节点

                menuItemAddSub.setHandler(function() { showEditSubWin('cs', rec); })      // 创建子节点角色

                menuItemUpdate.setHandler(function() { showEditWin('u', rec); })    // 更新节点
                menuItemDelete.setHandler(function() { batchOperate('batchdelete', [rec]); })    // 删除节点

                contextMenu.showAt(xy);
            }

            function batchOperate(action, recs, params, url) {
                if (!recs || recs.length <= 0) {
                    AimDlg.show("请先选择要操作的结点！");
                    return;
                } else if (!confirm("确定要删除该结点吗？")) {
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
                    }
                });
            }


            function showEditSubWin(op, rec) {
                OpenModelWin("/CommonPages/Select/RolSelect/PRJ_RoleSelect.aspx?seltype=multi", { op: op, id: rec.id },
                        "dialogWidth:650px; dialogHeight:550px; scroll:yes; center:yes; status:no; resizable:yes;seltype:multi",
                        function() {
                            var expnode = null; // 重新加载后需要展开的节点
                            var params = {};
                            var uids = [];
                            uids.push(rec.id);

                            $.each(rtn.data, function() {
                                if (this.RoleID) {
                                    uids.push(this.RoleID);
                                }
                            });

                            params = { "id": rec.id, "IdList": uids };
                            jQuery.ajaxExec("c", params, function(args) {
                                switch (op) {
                                    case 'cs':
                                        store.reload({ id: rec.id });
                                        expnode = rec;
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
                            });


                            // store.singleSort('CreatedDate', 'ASC');
                        });
            }


            function showEditWin(op, rec) {
                rec = rec || {};
                OpenModelWin(EditPageUrl, { op: op, id: rec.id }, EditWinStyle, function() {
                    var expnode = null; // 重新加载后需要展开的节点

                    switch (op) {
                        case 'c':
                            if (rec && rec.json.ParentID) {

                                var pnode = store.getById(rec.json.ParentID);
                                // store.remove(pnode);
                                expnode = pnode;

                                store.reload({ op: "add", id: pnode.id });
                            }
                            break;
                        case 'cs':
                        case 'u':
                            // store.remove(rec);
                            store.reload({ id: rec.id });

                            if (op == 'cs') {
                                expnode = rec;
                            }
                            break;
                    }
                    window.location.reload();
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

                    //store.singleSort('CreatedDate', 'ASC');
                });
            }

            // 提交数据成功后
            function onExecuted() {
                // store.reload();
            }


            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid, {
                    region: 'center',
                    border: false,
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src=""></iframe>'}]
                });

                // 展开所有加载的节点
                var roots = store.getRootNodes();
                if (roots) {
                    try {
                        $.each(roots, function() {
                            store.expandNode(this);
                        });
                    }
                    catch (ex)
                    { }
                }

                // grid.expandAllNext(1);
            }

            // 应用或模块数据适配
            function adjustData(jdata) {
                if ($.isArray(jdata)) {
                    $.each(jdata, function() {
                        if (this.GroupID) {
                            this.ID = this.GroupID;
                            this.ParentID = $.isSetted(this.ParentID) ? this.ParentID : this.Type;
                        } else if (this.GroupTypeID) {
                            this.ID = this.GroupTypeID;
                            this.Type = "GType";
                            this.ParentID = null;
                            //this.IsLeaf = $.isSetted(this.HasGroup) ? !this.HasGroup : false;
                        }
                    });

                    return jdata;
                } else {
                    return [];
                }
            }
                
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            组织策划</h1>
    </div>
</asp:Content>
