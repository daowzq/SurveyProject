<%@ Page Title="门户管理" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmPortalList.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmPortalList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var EditWinStyle = CenterWin("width=800,height=600,scrollbars=yes");
    var EditPageUrl = "FrmPortalEdit.aspx";

    var store, myData;
    var pgBar, schBar, tlBar, titPanel, grid, viewport;

    function onPgLoad() {
        setPgUI();
    }

    function setPgUI() {

        // 表格数据
        myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["PortalList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
        dsname: 'PortalList',
            idProperty: 'Id',
            data: myData,
            fields: [
			{ name: 'Id' },
			{ name: 'Name' },
			{ name: 'Type' },
			{ name: 'Description' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' }
			]
        });

        // 分页栏
        pgBar = new Ext.ux.AimPagingToolbar({
            pageSize: AimSearchCrit["PageSize"],
            store: store
        });

        // 搜索栏
        schBar = new Ext.ux.AimSchPanel({
            store: store,
            items: [
                { fieldLabel: '名称', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'Name' }"} },
                { fieldLabel: '创建时间', id: 'CreateTime', schopts: { qryopts: "{ mode: 'Like', field: 'CreateTime' }"}}]
        });

        // 工具栏
        tlBar = new Ext.ux.AimToolbar({
            items: [{
                text: '添加',
                iconCls: 'aim-icon-add',
                handler: function() {
                    ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                }
            }, {
                text: '修改',
                iconCls: 'aim-icon-edit',
                handler: function() {
                    ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                }
            }, {
                text: '删除',
                iconCls: 'aim-icon-delete',
                handler: function() {
                    var recs = grid.getSelectionModel().getSelections();
                    if (!recs || recs.length <= 0) {
                        AimDlg.show("请先选择要删除的记录！");
                        return;
                    }

                    if (confirm("确定删除所选记录？")) {
                        ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                    }
                }
            }, '-', {
                text: '导出Excel',
                iconCls: 'aim-icon-xls',
                handler: function() {
                    ExtGridExportExcel(grid, { store: null, title: '标题' });
                }
            }, '->',
                {
                    text: '复杂查询',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        schBar.toggleCollapse(false);

                        setTimeout("viewport.doLayout()", 50);
                    }
}]
        });

        // 工具标题栏
        titPanel = new Ext.ux.AimPanel({
            tbar: tlBar,
            items: [schBar]
        });

        // 表格面板
        grid = new Ext.ux.grid.AimGridPanel({
            store: store,
            region: 'center',
            autoExpandColumn: 'Description',
            columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Name', dataIndex: 'Name', header: '名称' },
					{ id: 'Type', dataIndex: 'Type', header: '类别' },
					{ id: 'Description', dataIndex: 'Description', header: '描述' },
					{ id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 100, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建日期', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
            listeners: { "rowdblclick": function(grid, rowIndex, e) {
                ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
            }
            },
            bbar: pgBar,
            tbar: titPanel
        });

        // 页面视图
        viewport = new Ext.ux.AimViewport({
            items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
        });
    }

    // 提交数据成功后
    function onExecuted() {
        store.reload();
    }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>标题</h1></div>
</asp:Content>