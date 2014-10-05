<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="GrpList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.OrgMag.GrpList" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script src="/js/pgfunc-ext-adv.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var formStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";
        var grpTypeFormStyle = "dialogWidth:450px; dialogHeight:100px; scroll:yes; center:yes; status:no; resizable:yes;";

        var viewport;
        var store, grpTypeStore;
        var grid, grpTypeGrid;
        var grpTypeSchField;
        
        var GrpRecord;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            grpTypeStore = new Ext.ux.data.AimJsonStore({
                dsname: 'GrpTypeList',
                idProperty: 'GroupTypeID',
                data: { records: AimState["GrpTypeList"] || [] },
                fields: [{ name: 'GroupTypeID' }, { name: 'Name'}]
            });

            grpTypeTlBar = new Ext.Toolbar({
                items: []
            });

            var data = AimState["GrpList"] || [];
            
            GrpRecord = Ext.data.Record.create([
        { name: 'GroupID', type: 'string' },
        { name: 'ParentID', type: 'string' },
        { name: 'IsLeaf', type: 'bool' },
        { name: 'Name' },
        { name: 'Code' },
        { name: 'Type' },
        { name: 'Status' },
        { name: 'Description' },
        { name: 'CreateDate' }
]);

        store = new Ext.ux.data.AimAdjacencyListStore({
            autoLoad: true,
            parent_id_field_name: 'ParentID',
            leaf_field_name: 'IsLeaf',
            data: data,
            reader: new Ext.ux.data.AimJsonReader({ id: 'GroupID', dsname: 'GrpList' }, GrpRecord),
            proxy: new Ext.ux.data.AimRemotingProxy({
                aimbeforeload: function(proxy, options) {
                    options.schcrit = options.schcrit || {};
                    var grpTypeID = parseInt(grpTypeSchField.getValue());
                    var schs = options.schcrit["ccrit"] = options.schcrit["ccrit"] || [];
                    var tpflag = false;
                    var pflag = false;

                    var pNode;
                    if (options.anode) {
                        pNode = store.getById(options.anode);
                    }

                    $.each(schs, function(i) {
                        if (this["PropertyName"] == "Type") {
                            this["Value"] = grpTypeID;
                            tpflag = true;
                        }

                        if (this["PropertyName"] == "ParentID") {
                            this["Value"] = this["Value"] || pNode.data.GroupID;
                            pflag = true;
                        }
                    });
                    /*
                    if (!tpflag) {
                        schs[schs.length] = { PropertyName: "Type", "Value": grpTypeID };
                    }

                    if (!pflag && pNode) {
                        schs[schs.length] = { PropertyName: "ParentID", "Value": pNode.data.GroupID };
                    }*/
                }
            })
        });

        //store.on("load", function() {
         //  store.expandAll();
        //});

            grpTypeGrid = new Ext.grid.GridPanel({
                id: 'grpTypePanel',
                store: grpTypeStore,
                region: 'west',
                split: true,
                border:false,
                width: 150,
                minSize: 100,
                maxSize: 400,
                columns: [
            { id: 'GroupTypeID', header: 'GroupTypeID', dataIndex: 'GroupTypeID', hidden: true },
            { id: 'Name', header: '组类型', width: 100, renderer: grpTypeRender, sortable: true, dataIndex: 'Name' }
            ],
                autoExpandColumn: 'Name',
                tbar: grpTypeTlBar
            });

            grpTypeGrid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                grpTypeSchField.setValue(r.data.GroupTypeID);
                store.reload();
            });

            grpTypeSchField = new Ext.app.AimSearchField({ fieldLabel: '', anchor: '90%', name: 'Type', hidden: true, hideLable: true, store: store, aimgrp: "grp", qryopts: "{ mode: 'Equal', field: 'Type' }" });

            // 搜索栏
            var schBar = new Ext.Panel({
                collapsed: true,
                unstyled: true,
                padding: 5,
                layout: 'column',
                items: [{ layout: 'form', unstyled: true, columnWidth: .33, items: [grpTypeSchField]}]
            });

            // 工具栏
            var tlBar = new Ext.Toolbar({
                items: [{
                    text: '添加根组',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openMdlWin(null, "c");
                    }
                }, {
                    text: '添加子组',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openMdlWin(null, "cs");
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
                }, '-', { text: '刷新系统组', iconCls: 'aim-icon-refresh', handler: function() { $.ajaxExec("refreshsys"); } }]
                });

                // 工具标题栏
                var titPanel = new Ext.Panel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.maximgb.tg.GridPanel({
                store: store,
                frame: false,
                    master_column_id: 'Name',
                    region: 'center',
                    columns: [{ id: 'Name', header: "组名", width: 160, sortable: true, dataIndex: 'Name' },
                { id: 'Code', header: '编号', width: 100, sortable: true, dataIndex: 'Code' },
				{ header: "状态", width: 75, renderer: enumRender, sortable: true, align: 'center', dataIndex: 'Status' },
				{ id: "Description", header: "描述", width: 75, sortable: true, dataIndex: 'Description' },
				{ header: "创建日期", width: 75, sortable: true, dataIndex: 'CreateDate'}],
                    autoExpandColumn: 'Description',
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.Viewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grpTypeGrid, grid]
                });

                // store.expandAll(true);

                grpTypeGrid.getSelectionModel().selectFirstRow();
            }

            // 链接渲染
            function grpTypeRender(val, p, rec) {
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
                        rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"GrpEdit.aspx?id=" + p.value + "\")'>" + val + "</a>";
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
                url = url || "GrpEdit.aspx";
                op = op || "r";
                style = style || formStyle;
                grd = grd || grid;
            
                var grpTypeSels = grpTypeGrid.getSelectionModel().getSelections();
                var grpTypeSel;
                if (grpTypeSels.length > 0) grpTypeSel = grpTypeSels[0];

                var sels = grid.getSelectionModel().getSelections();
                var sel = null;
                if (sels.length > 0) sel = sels[0];

                var params = [];
                params[params.length] = "op=" + op;

                if (op === "c" || op === "cs") {
                    if (grpTypeSel && url.indexOf("type=") < 0) {
                        params[params.length] = "type=" + grpTypeSel.data.GroupTypeID;
                    }
                } else if (!sel) {
                    AimDlg.show('请选择需要操作的行。', '提示', 'alert');
                    return;
                }

                if (op == 'd' && (!store.isLoadedNode(sel) && !sel.data.IsLeaf || store.hasChildNodes(sel))) {
                    AimDlg.show('此模块可能拥有子组，必须删除所有子组方可删除。', '提示', 'alert');
                    return;
                }

                if (op !== "c" && url.indexOf("id=") < 0) {
                    if (sel) {
                        params[params.length] = "id=" + sel.data.GroupID.toString();
                    } else {
                        AimDlg.show('请选择需要此组的父组。', '提示', 'alert');
                        return;
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
                                var rec = new GrpRecord(rtn.data, rtn.data.GroupID);
                                store.addSorted(rec);
                            } else if (op === 'cs') {
                                rtn.data.IsLeaf = true;
                                var rec = new GrpRecord(rtn.data, rtn.data.GroupID);
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

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>组列表</h1></div>
</asp:Content>
