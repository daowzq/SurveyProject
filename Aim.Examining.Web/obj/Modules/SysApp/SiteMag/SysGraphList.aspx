
<%@ Page Title="系统图表" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="SysGraphList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.SysGraphList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var EditWinStyle = CenterWin("width=650,height=300,scrollbars=yes");
    var EditPageUrl = "SysGraphEdit.aspx";
    
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
            records: AimState["SysGraphList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'SysGraphList',
            idProperty: 'GraphID',
            data: myData,
            fields: [
			{ name: 'GraphID' },
			{ name: 'Code' },
			{ name: 'Title' },
			{ name: 'FileID' },
			{ name: 'Description' },
			{ name: 'SortIndex' },
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
            items: [
                { fieldLabel: '编号', name: 'Code', schopts: { qryopts: "{ mode: 'Like', field: 'Code' }"} },
                { fieldLabel: '标题', name: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"}}]
        });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openEditWin("SysGraphEdit.aspx", "c");
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openEditWin("SysGraphEdit.aspx", "u");
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
                            batchOperate('batchdelete', recs);
                        }
                    }
                }, '-', { text: '导出Excel', iconCls: 'aim-icon-xls', handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '系统图表' });
                    } 
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
                    columns: [
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Code', header: '编号', width: 100,  sortable: true, dataIndex: 'Code' },
					{ id: 'Title', header: '标题', linkparams: { url: EditPageUrl, style: EditWinStyle }, width: 150, sortable: true, dataIndex: 'Title' },
					{ id: 'FileID', header: '文件', renderer: ExtGridFileRender, width: 200, sortable: true, dataIndex: 'FileID' },
					{ id: 'Description', header: '描述', width: 100, sortable: true, dataIndex: 'Description' },
					{ id: 'CreaterName', header: '创建人', width: 100, sortable: true, dataIndex: 'CreaterName' },
					{ id: 'CreatedDate', header: '创建时间', width: 100, sortable: true, dataIndex: 'CreatedDate' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel,
                    autoExpandColumn: 'Description'
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }
            
            // 打开模态窗口
            function openEditWin(url, op, style) {
                style = style || EditWinStyle;
                
                ExtOpenGridEditWin(grid, url, op, style);
            }

            function batchOperate(action, recs, params, url) {
                ExtBatchOperate(action, recs, params, url, onExecuted);
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>系统图表</h1></div>
</asp:Content>


