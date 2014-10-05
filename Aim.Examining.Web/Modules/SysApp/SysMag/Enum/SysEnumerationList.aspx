
<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="SysEnumerationList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SysMag.SysEnumerationList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    
    var EditWinStyle = CenterWin("width=650,height=300,scrollbars=yes");
    var EditPageUrl = "SysEnumerationEdit.aspx";
    
    var store, myData;
    var viewport, pgBar, schBar, tlBar, titPanel, grid;

    var cid;    // 分类id

    function onPgLoad() {
        cid = $.getQueryString({ID: "cid", DefaultValue: ""});
    
        setPgUI();
    }

    function setPgUI() {

        // 表格数据
        myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["SysEnumerationList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'SysEnumerationList',
            idProperty: 'EnumerationID',
            data: myData,
            fields: [
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
			{ name: 'CreatedDate' }
			], listeners: { "aimbeforeload": function(proxy, options) {
			    options.data = options.data || {};
			    options.data.cid = cid;
			}
			}
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
                { fieldLabel: '编码', id: 'Code', schopts: { qryopts: "{ mode: 'Like', field: 'Code' }"} },
                { fieldLabel: '创建人', id: 'CreaterName', hideLabel: true, hidden: true, schopts: { qryopts: "{ mode: 'Like', field: 'CreaterName' }"}}]
        });

            // 工具栏
        tlBar = new Ext.ux.AimToolbar({
            items: [{
                text: '添加',
                iconCls: 'aim-icon-add',
                handler: function() {
                    var url = $.combineQueryUrl(EditPageUrl, { cid: cid });

                    ExtOpenGridEditWin(grid, url, "c", EditWinStyle);
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
                    autoExpandColumn: 'Description',
                    columns: [
                    { id: 'ParameterID', header: '标识', dataIndex: 'ParameterID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Code', header: '编码', width: 200,  sortable: true, dataIndex: 'Code' },
					{ id: 'Name', header: '名称', width: 150,  linkparams: { url: EditPageUrl, style: EditWinStyle },  sortable: true, dataIndex: 'Name' },
					{ id: 'Value', header: '值', width: 100,  sortable: true, dataIndex: 'Value' },
					{ id: 'Description', header: '描述', width: 100,  sortable: true, dataIndex: 'Description' },
					{ id: 'CreaterName', header: 'CreaterName', width: 100, hidden: true, sortable: true, dataIndex: 'CreaterName' },
					{ id: 'LastModifiedDate', header: 'LastModifiedDate', width: 100, hidden: true, sortable: true, dataIndex: 'LastModifiedDate' },
					{ id: 'CreatedDate', header: 'CreatedDate', width: 100, hidden: true, sortable: true, dataIndex: 'CreatedDate' }
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

            function reloadPage(args) {
                // 重新加载页面
                cid = args.cid || cid;
                store.reload();
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


