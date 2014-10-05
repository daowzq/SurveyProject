<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="AuthList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.MdlMag.AuthList" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />
    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var viewport, grid;
        var btnAdd, btnEdt, btnDel
        var store, DataRecord;

        function onPgLoad() {
            setPgUI();
        }

        // 应用或模块数据适配
        function adjustData(jdata) {
            if ($.isArray(jdata)) {
                $.each(jdata, function() {
                    this.ID = this.AuthID || this.AuthTypeID;
                    if (this.AuthTypeID) {
                        this.Type = "AType";
                        this.ParentID = null;
                        this.IsLeaf = !this.HasAuth;
                    } else if (this.AuthID) {
                        this.ParentID = ($.isSetted(this.ParentID) ? this.ParentID : this.Type);  // 1为应用模块
                    }
                });

                return jdata;
            } else {
                return [];
            }
        }

        function setPgUI() {
            var data = adjustData(AimState["DtList"]);

            DataRecord = Ext.data.Record.create([
                { name: 'ID', type: 'string' },
                { name: 'ParentID', type: 'string' },
                { name: 'IsLeaf', type: 'bool' },
                { name: 'Name' },
                { name: 'Code' },
                { name: 'Type' },
                { name: 'Path' },
                { name: 'PathLevel' },
                { name: 'Description' },
                { name: 'CreateDate' }
        ]);

                store = new Ext.ux.maximgb.tg.AdjacencyListStore({
                    autoLoad: true,
                    parent_id_field_name: 'ParentID',
                    leaf_field_name: 'IsLeaf',
                    data: data,
                    reader: new Ext.ux.data.AimJsonReader({ id: 'ID', dsname: 'DtList', aimread: function(rd, resp, dt) {
                        if (dt) {
                            dt = adjustData(dt);
                        }
                    }
                    }, DataRecord),
                    proxy: new Ext.ux.data.AimRemotingProxy({
                        aimbeforeload: function(proxy, options) {
                            var rec = store.getById(options.anode);
                            options.reqaction = "querychildren";
                            options.data = rec ? (rec.json || {}) : {};
                        }
                    })
                });

            // 搜索栏
            var schBar = new Ext.Panel({
                collapsed: true,
                unstyled: true,
                padding: 5,
                layout: 'column',
                items: []
            });

            btnAdd = new Ext.Button({ text: '新建权限', iconCls: 'aim-icon-add',
                handler: function() {
                    var sels = grid.getSelectionModel().getSelections();
                    var sel = null;
                    if (sels.length > 0) {
                        sel = sels[0];
                    } else {
                        AimDlg.show('请先选择当前权限所属权限类型。', '提示', 'alert');
                    }

                    if (sel) {
                        if (sel.data.Type == "AType") {
                            openMdlWin("AuthEdit.aspx", "c");
                        } else {
                            openMdlWin("AuthEdit.aspx", "cs");
                        }
                    }
                }
            });
            btnEdt = new Ext.Button({ text: '修改', iconCls: 'aim-icon-edit', handler: function() { openMdlWin(null, "u"); } });
            btnDel = new Ext.Button({ text: '删除', iconCls: 'aim-icon-delete', handler: function() { openMdlWin(null, "d"); } });

            // 工具栏
            var tlBar = new Ext.Toolbar({
                items: [btnAdd, btnEdt, btnDel, '-',
                { text: '刷新系统权限', iconCls: 'aim-icon-cog', handler: function() { $.ajaxExec("refreshsys"); }
}]
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
                    columns: [
				    { id: 'Name', header: "权限类型 / 权限", renderer: linkRender, width: 160, sortable: true, dataIndex: 'Name' },
				    { header: "编号", width: 100, sortable: true, dataIndex: 'Code' },
                    { id: "Description", header: "描述", width: 75, sortable: true, dataIndex: 'Description' },
                    { header: "创建日期", width: 75, sortable: true, dataIndex: 'CreateDate' }
                  ],
                    autoExpandColumn: 'Description',
                    tbar: titPanel
                });

                grid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                    var type = ($.isSetted(r.data.Type) ? r.data.Type.toString() : "").toLowerCase();
                    if (type == "atype") {
                        btnEdt.disable();
                        btnDel.disable();

                        if (r.data.ID == 1) {
                            btnAdd.disable();
                        } else {
                            btnAdd.enable();
                        }
                    } else if (type == "1") {
                        btnEdt.disable();
                        btnDel.disable();
                        btnAdd.disable();
                    } else {
                        btnAdd.enable();
                        btnEdt.enable();
                        btnDel.enable();
                    }
                });

                // 页面视图
                viewport = new Ext.Viewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });

                store.expandAll();
            }

            // 链接渲染
            function linkRender(val, p, rec) {
                var rtn = val;
                switch (this.dataIndex) {
                    case "Name":
                        if (rec.data.Type != "AType") {
                            rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"AuthEdit.aspx?id=" + rec.data.ID + "\")'>" + val + "</a>";
                        }
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
            function openMdlWin(url, op, pa, style) {
                url = url || "AuthEdit.aspx";
                op = op || "r";
                style = style || "dialogWidth:500px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";

                var sels = grid.getSelectionModel().getSelections();
                var sel = null;
                if (sels.length > 0) sel = sels[0];

                var params = [];
                params[params.length] = "op=" + op;

                if (op === "c" || op === "cs") {
                    if (!sel) {
                        AimDlg.show('请选择对应权限类型或父权限。', '提示', 'alert');
                        return;
                    } else {
                        if (url.indexOf("type=") < 0) {
                            if (sel.data.Type == 'AType') {
                                params[params.length] = "type=" + sel.data.ID;
                            } else {
                                params[params.length] = "type=" + sel.data.Type;
                            }
                        }
                    }
                } else if (!sel) {
                    AimDlg.show('请选择需要操作的行。', '提示', 'alert');
                    return;
                }

                if (op == 'd' && (!store.isLoadedNode(sel) && !sel.data.IsLeaf || store.hasChildNodes(sel))) {
                    AimDlg.show('此模块可能拥有子模块，必须删除所有子模块方可删除。', '提示', 'alert');
                    return;
                }

                if (op !== "c" && url.indexOf("id=") < 0) {
                    params[params.length] = "id=" + sel.data.ID.toString();
                }

                url = $.combineQueryUrl(url, params)
                rtn = window.showModalDialog(url, window, style);

                if (rtn && rtn.result) {
                    if (rtn.result === 'success') {
                        if (op === 'd') {
                            var pnode = store.getById(sel.data.ParentID);
                            if (pnode) { store.removeFromNode(pnode, sel); }
                            else { store.remove(sel) }
                            if (pnode && !store.hasChildNodes(pnode)) {
                                if (pnode.data) { pnode.data.IsLeaf = true; }
                                if (pnode.json) { pnode.json.IsLeaf = true; }
                            }
                        } else if (op === 'u') {
                            for (var key in rtn.data) {
                                sel.beginEdit();
                                sel.set(key, rtn.data[key]);
                                sel.commit();
                            }
                        } else {
                            if (op === 'c' || op === 'cs') {
                                rtn.data.IsLeaf = true;
                                rtn.data.ID = rtn.data.AuthID;
                                var rec = new DataRecord(rtn.data, rtn.data.ID);
                                var pnode = store.getById(rtn.data.ParentID || rtn.data.Type);
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
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>权限列表</h1></div>
</asp:Content>
