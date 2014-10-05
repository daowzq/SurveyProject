<%@ Page Title="组织角色选择" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="FrmRoleSelView.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.FrmRoleSelView" %>
<%@ OutputCache Duration="1" VaryByParam="None" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

<script type="text/javascript">
    var store, viewport;

    function onSelPgLoad() {
        setPgUI();
    }

    function setPgUI() {
        // 表格数据
        var myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["DtList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'DtList',
            idProperty: 'RoleID',
            data: myData,
            fields: [
			{ name: 'RoleID' },
			{ name: 'Name' },
			{ name: 'Description' }
			]
        });

        // 分页栏
        pgBar = new Ext.ux.AimPagingToolbar({
            pageSize: AimSearchCrit["PageSize"],
            store: store
        });

        // 搜索栏
        schBar = new Ext.ux.AimSchPanel({
            items: []
        });

        // 工具栏
        tlBar = new Ext.ux.AimToolbar({
            items: ['->', { text: '查询区' }]
            });

            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                tbar: tlBar,
                items: [schBar]
            });

            // 表格面板
            AimSelGrid = new Ext.ux.grid.AimGridPanel({
                store: store,
                region: 'center',
                columns: [
                    { id: 'RoleID', header: '标识', dataIndex: 'RoleID', hidden:true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Name', header: '角色名称', width: 100, sortable: true, dataIndex: 'Name' },
					{ id: 'Description', header: '角色简介', width: 200, sortable: true, dataIndex: 'Description' }
                    ],
                bbar: pgBar,
                tbar: titPanel,
                autoExpandColumn: 'Name'
            });


            AimSelGrid.on("rowclick", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);

                if (typeof (parent.parent.OnSelViewRowClick) == 'function') {
                    parent.parent.OnSelViewRowClick.call(this, rec, { type: 'user' });
                }
            });

            AimSelGrid.on("rowdblclick", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);

                if (typeof (parent.parent.OnSelViewRowDblClick) == 'function') {
                    parent.parent.OnSelViewRowDblClick.call(this, rec, { type: 'user' });
                }
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, AimSelGrid]
            });
        }

        // 获取被选中的角色
        function GetSelections(type) {
            var recs = AimSelGrid.getSelectionModel().getSelections();
            if (recs == null || recs.length == 0) {
                return null;
            }

            switch (type) {
                default:
                    return recs;
            }
        }
    
 </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>组织角色选择</h1></div>
    
</asp:Content>
