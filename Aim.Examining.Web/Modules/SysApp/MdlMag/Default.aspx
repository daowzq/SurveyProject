<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site2.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.MdlMag.Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script type="text/javascript">

        if ((typeof Range !== "undefined") && !Range.prototype.createContextualFragment) {
            Range.prototype.createContextualFragment = function(html) {
                var frag = document.createDocumentFragment(),
                div = document.createElement("div");
                frag.appendChild(div);
                div.outerHTML = html;
                return frag;
            };
        }

        var AppMdlStatusEnum = { 1: "启用", 0: "停用" };
        var MdlTypeEnum;

        var viewport;
        var store;
        var grid;
        var AppMdlRecord;

        function onPgLoad() {
            MdlTypeEnum = AimState["MdlTypeEnum"] || {};

            setPgUI();
        }

        // 应用或模块数据适配
        function adjustData(jdata) {
            if ($.isArray(jdata)) {
                $.each(jdata, function() {
                    if (this.ModuleID) {
                        this.ID = this.ModuleID;
                        this.ParentID = $.isSetted(this.ParentID) ? this.ParentID : this.ApplicationID;
                    } else if (this.ApplicationID) {
                        this.ID = this.ApplicationID;
                        this.Type = "App";
                        this.ParentID = null;
                        this.IsLeaf = $.isSetted(this.HasModule) ? !this.HasModule : false;
                    }
                });

                return jdata;
            } else {
                return [];
            }
        }

        function setPgUI() {
            var data = adjustData(AimState["Apps"] || AimState["Mdls"]);
            AppMdlRecord = Ext.data.Record.create([
                { name: 'ID', type: 'string' },
                { name: 'ParentID', type: 'string' },
                { name: 'IsLeaf', type: 'bool' },
                { name: 'Name' },
                { name: 'Code' },
                { name: 'Type' },
                { name: 'SortIndex' },
                { name: 'Url' },
                { name: 'Status' },
                { name: 'Description' },
                { name: 'CreateDate' }
            ]);

            store = new Ext.ux.maximgb.tg.AdjacencyListStore({
                autoLoad: true,
                parent_id_field_name: 'ParentID',
                leaf_field_name: 'IsLeaf',
                data: data,
                reader: new Ext.ux.data.AimJsonReader({
                    id: 'ID', dsname: 'Mdls', aimread: function(rd, resp, dt) {
                        if (dt) {
                            dt = adjustData(dt);
                        }
                    }
                }, AppMdlRecord),
                proxy: new Ext.ux.data.AimRemotingProxy({
                    aimbeforeload: function(proxy, options) {
                        var rec = store.getById(options.anode);
                        options.reqaction = "querychildren";
                        options.data = rec ? (rec.json || {}) : {};
                    }
                })
            });

            // 搜索栏
            var schBar = new Ext.ux.AimSchPanel();

            // 工具栏
            var tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加应用',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openMdlWin("../AppEdit.aspx", "c");
                    }
                }, {
                    text: '添加子模块',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openMdlWin("MdlEdit.aspx", "cs");
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openMdlWin(null, "u");
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        openMdlWin(null, "d");
                    }
                }, '-', { text: '刷新系统模块', iconCls: 'aim-icon-refresh', handler: function() { $.ajaxExec("refreshsys"); } }]
            });

            // 工具标题栏
            var titPanel = new Ext.ux.AimPanel({
                tbar: tlBar,
                items: [schBar]
            });

            // 表格面板
            grid = new Ext.ux.maximgb.tg.GridPanel({
                store: store,
                master_column_id: 'Name',
                region: 'center',
                columns: [
                    { id: 'Name', header: "应用 / 模块", width: 160, sortable: true, dataIndex: 'Name' },
                    { header: "编号", width: 100, sortable: true, dataIndex: 'Code' },
                    { header: "类型", width: 75, renderer: enumRender, align: 'center', sortable: true, dataIndex: 'Type' },
                    { header: "URL", width: 200, sortable: true, dataIndex: 'Url' },
                    { header: "排序", width: 75, sortable: true, dataIndex: 'SortIndex' },
                    { header: "状态", width: 75, renderer: enumRender, sortable: true, align: 'center', dataIndex: 'Status' },
                    { id: "Description", header: "描述", width: 75, sortable: true, dataIndex: 'Description' },
                    { header: "创建日期", width: 75, sortable: true, dataIndex: 'CreateDate' }
                ],
                autoExpandColumn: 'Description',
                tbar: titPanel
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });
        }

        // 链接渲染
        function linkRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Name":
                    rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"UsrEdit.aspx?id=" + p.value + "\")'>" + val + "</a>";
                    break;
            }

            return rtn;
        }

        // 枚举渲染
        function enumRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Status":
                    rtn = AppMdlStatusEnum[val];
                    break;
                case "Type":
                    if (val == "App") {
                        rtn = "应用";
                    } else {
                        rtn = MdlTypeEnum[val];
                    }
                    break;
            }

            return rtn;
        }

        // 打开模态窗口
        function openMdlWin(url, op, pa, style) {
            op = op || "r";
            style = style || "dialogWidth:450px; dialogHeight:500px; scroll:yes; center:yes; status:no; resizable:yes;";

            var sels = grid.getSelectionModel().getSelections();
            var sel = null;
            if (sels.length > 0) sel = sels[0];

            if (!url) {
                if (sel) {
                    if (sel.data.Type == "App") {
                        url = "../AppEdit.aspx";
                    } else {
                        url = "MdlEdit.aspx";
                    }
                } else {
                    AimDlg.show('请选择需要操作的行。', '提示', 'alert');
                    return;
                }
            }

            if (op == 'd' && (!store.isLoadedNode(sel) && !sel.data.IsLeaf || store.hasChildNodes(sel))) {
                AimDlg.show('此模块可能拥有子模块，必须删除所有子模块方可删除。', '提示', 'alert');
                return;
            }

            var params = [];
            params[params.length] = "op=" + op;

            if (op !== "c" && sel) {
                if (url.indexOf("id=") < 0) {
                    params[params.length] = "id=" + sel.data.ID;
                }
                if (op == "cs") {
                    params[params.length] = "pt=" + sel.data.Type;
                }
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
                        if (op === 'c') {
                            rtn.data.IsLeaf = true;
                            rtn.data.ID = rtn.data.ApplicationID;
                            rtn.data.Type = "App";
                            var rec = new AppMdlRecord(rtn.data, rtn.data.ID);
                            store.addSorted(rec);
                        } else if (op === 'cs') {
                            rtn.data.IsLeaf = true;
                            rtn.data.ID = rtn.data.ModuleID;
                            var rec = new AppMdlRecord(rtn.data, rtn.data.ID);
                            var pnode = store.getById(rtn.data.ParentID || rtn.data.ApplicationID);
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
    <div id="header">
        <h1>
            系统模块</h1>
    </div>
</asp:Content>
