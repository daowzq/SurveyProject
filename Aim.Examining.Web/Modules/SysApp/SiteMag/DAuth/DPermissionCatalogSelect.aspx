<%@ Page Title="授权类型选择" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DPermissionCatalogSelect.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DPermissionCatalogSelect" %>
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
            idProperty: 'Id',
            data: myData,
            fields: [
			{ name: 'DynamicPermissionCatalogID' },
			{ name: 'Code' },
			{ name: 'Name' },
			{ name: 'PositiveGrantUrl' },
			{ name: 'OppositeGrantUrl' },
			{ name: 'DefaultGrantType' },
			{ name: 'SortIndex' },
			{ name: 'Description' },
			{ name: 'Editable' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate' }
			]
        });

        // 搜索栏
        schBar = new Ext.ux.AimSchPanel({
            collapsed: true,
            unstyled: true,
            padding: 5,
            layout: 'column',
            items: []
        });

        // 工具栏
        tlBar = new Ext.ux.AimToolbar({
            items: ['->', { text: '查询:' },
            new Ext.app.AimSearchField({ store: store, schbutton: true, qryopts: "{ type: 'fulltext' }" }), '-',
            { text: '选择', iconCls: 'aim-icon-accept', handler: function() {
                AimGridSelect();
            }
}]
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
                monitorResize: true,
                columns: [
                    { id: 'Id', header: '标识', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    AimSelCheckModel,
					{ id: 'Name', header: '名称', width: 100, sortable: true, dataIndex: 'Name' },
					{ id: 'Code', header: '编码', width: 100, sortable: true, dataIndex: 'Code' },
					{ id: 'Editable', header: '编辑状态', width: 100, sortable: true, dataIndex: 'Editable' }
                    ],
                tbar: titPanel,
                frame: true,
                forceLayout: true,
                stripeRows: true,
                autoExpandColumn: 'Name',
                stateful: true,
                stateId: 'grid'
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, AimSelGrid]
            });
        }
    
 </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>授权类型选择</h1></div>
    
</asp:Content>
