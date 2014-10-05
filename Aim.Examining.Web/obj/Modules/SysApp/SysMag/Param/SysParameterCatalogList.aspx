
<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="SysParameterCatalogList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.SysParameterCatalogList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
    var EditPageUrl = "SysParameterCatalogEdit.aspx";
    
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
            records: AimState["SysParameterCatalogList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'SysParameterCatalogList',
            idProperty: 'ParameterCatalogID',
            data: myData,
            fields: [
			{ name: 'ParameterCatalogID' },
			{ name: 'Code' },
			{ name: 'Name' },
			{ name: 'EditStatus' },
			{ name: 'ParentID' },
			{ name: 'Path' },
			{ name: 'PathLevel' },
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
            items: [
                { fieldLabel: '名称', id: 'Name', schopts: { store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Name' }"} },
                { fieldLabel: '编码', id: 'Code', schopts: { store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Code' }"} },
                { fieldLabel: '创建人', id: 'CreateName', schopts: { store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'CreateName' }"} }]
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
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
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
                    //autoExpandColumn: 'Name',
                    columns: [
                    { id: 'ParameterCatalogID', header: '标识', dataIndex: 'ParameterCatalogID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Code', header: 'Code', width: 100,  sortable: true, dataIndex: 'Code' },
					{ id: 'Name', header: 'Name', width: 100,  linkparams: { url: EditPageUrl, style: EditWinStyle },  sortable: true, dataIndex: 'Name' },
					{ id: 'EditStatus', header: 'EditStatus', width: 100,  sortable: true, dataIndex: 'EditStatus' },
					{ id: 'ParentID', header: 'ParentID', width: 100,  sortable: true, dataIndex: 'ParentID' },
					{ id: 'Path', header: 'Path', width: 100,  sortable: true, dataIndex: 'Path' },
					{ id: 'PathLevel', header: 'PathLevel', width: 100,  sortable: true, dataIndex: 'PathLevel' },
					{ id: 'Description', header: 'Description', width: 100,  sortable: true, dataIndex: 'Description' },
					{ id: 'CreaterID', header: 'CreaterID', width: 100,  sortable: true, dataIndex: 'CreaterID' },
					{ id: 'CreaterName', header: 'CreaterName', width: 100,  sortable: true, dataIndex: 'CreaterName' },
					{ id: 'LastModifiedDate', header: 'LastModifiedDate', width: 100,  sortable: true, dataIndex: 'LastModifiedDate' },
					{ id: 'CreatedDate', header: 'CreatedDate', width: 100,  sortable: true, dataIndex: 'CreatedDate' }
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
    <div id="header" style="display:none;"><h1>标题</h1></div>
</asp:Content>


