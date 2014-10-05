
<%@ Page Title="数据模版" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="SysDataExportTemplateList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.SysDataExportTemplateList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var EditWinStyle = CenterWin("width=650,height=300,scrollbars=yes");
    var EditPageUrl = "SysDataExportTemplateEdit.aspx";
    
    var viewport;
    var store, myData;
    var pgBar, schBar, tlBar, titPanel, grid;

    function onPgLoad() {
        setPgUI();
    }

    function setPgUI() {

        // 表格数据
        myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["SysDataExportTemplateList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
        dsname: 'SysDataExportTemplateList',
            idProperty: 'DataExportTemplateID',
            data: myData,
            fields: [
			{ name: 'DataExportTemplateID' },
			{ name: 'Name' },
			{ name: 'Code' },
			{ name: 'TemplateFileID' },
			{ name: 'Config' },
			{ name: 'Description' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate' }
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
            aimgrp:"defgrp",
            items: [
                { fieldLabel: '名称', name: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'Name' }"} },
                { fieldLabel: '编码', name: 'Code', schopts: { qryopts: "{ mode: 'Like', field: 'Code' }"} },
                { fieldLabel: '创建人', xtype: 'aimuserselector', id: 'CreaterName', schopts: { qryopts: "{ mode: 'Like', field: 'CreaterName' }"} },
                { fieldLabel: '创建时间', id: 'CreatedDateStart', endDateField: 'CreatedDateEnd', xtype: 'datefield', vtype: 'daterange', schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'CreatedDate' }"} },
                { fieldLabel: '至', id: 'CreatedDateEnd', startDateField: 'CreatedDateStart', xtype: 'datefield', vtype: 'daterange', schopts: { qryopts: "{ mode: 'LessThan', datatype:'Date', field: 'CreatedDate' }"} }
]
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
                text: '其他',
                iconCls: 'aim-icon-cog',
                menu: [{ text: '导出Excel', iconCls: 'aim-icon-xls', handler: function() {
                    ExtGridExportExcel(grid, { store: null, title: '数据导出模版' });
                } }]
                }, '->', { text: '查询:' },
                new Ext.app.AimSearchField({ store: store, schbutton: true, qryopts: "{ type: 'fulltext' }" }),
                '-',
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
                    { id: 'DataExportTemplateID', header: '标识', dataIndex: 'DataExportTemplateID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Name', header: '名称', width: 150, linkparams: { url: EditPageUrl, style: EditWinStyle }, sortable: true, dataIndex: 'Name' },
					{ id: 'Code', header: '编码', width: 100,  sortable: true, dataIndex: 'Code' },
					{ id: 'TemplateFileID', header: '模版文件', renderer: ExtGridFileRender, width: 200, sortable: true, dataIndex: 'TemplateFileID' },
					{ id: 'Description', header: '描述', width: 100, sortable: true, dataIndex: 'Description' },
					{ id: 'CreaterName', header: '创建人', hidden: true, width: 100, sortable: true, dataIndex: 'CreaterName' },
					{ id: 'CreatedDate', header: '创建时间', hidden: true, width: 100, sortable: true, dataIndex: 'CreatedDate' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
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
    <div id="header" style="display:none;"><h1>数据模版</h1></div>
</asp:Content>


