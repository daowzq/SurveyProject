<%@ Page Title="组分类" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="GrpCatalog.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.GrpCatalog" %>
<%@ OutputCache Duration="1" VaryByParam="None" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };
        var catalogType = [['type', '角色类型']];

        var viewport, store, grid;
        var DataRecord, selCombo;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DtList',
                idProperty: 'GroupTypeID',
                data: { records: AimState["DtList"] || [] },
                fields: [{ name: 'GroupTypeID' }, { name: 'Name'}]
            });

            selCombo = new Ext.form.ComboBox({
                width:150,
                forceSelection: true,
                triggerAction: 'all',
                emptyText: '选择视图...',
                store: catalogType,
                listeners: {
                    "select": function(combo, rec, idx) {
                        if (parent.SetCatalog) {
                            parent.SetCatalog(combo.getValue());
                        }
                    },
                    "afterrender": function() {
                        if (!this.getValue()) {
                            this.setValue('type');
                        }
                    }
                }
            });

            // 工具栏
            var tlBar = new Ext.ux.AimToolbar({
                items: [{ text: "视图：" }, selCombo ]
            });

            // 表格面板
            grid = new Ext.grid.GridPanel({
                id: 'catalogPanel',
                store: store,
                region: 'center',
                split: true,
                frame: false,
                border:false,
                width: 250,
                minSize: 120,
                maxSize: 400,
                margins: '0 0 5 5',
                cmargins: '0 5 5 5',
                columns: [
            { id: 'GroupTypeID', header: 'GroupTypeID', dataIndex: 'GroupTypeID', hidden: true },
            { id: 'Name', header: '角色类型', width: 100, sortable: true, dataIndex: 'Name' }
            ],
                autoExpandColumn: 'Name',
                tbar: tlBar
            });

            grid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) { 
                if (parent.SetCatalog) {
                    parent.SetCatalog(selCombo.getValue(), { cid: r.id });
                }
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });

            // grid.getSelectionModel().selectFirstRow();
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>组分类</h1></div>
</asp:Content>
