<%@ Page Title="动态权限授权" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DPermissionGrant.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DPermissionGrant" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>
    <script src="/js/ext/ux/TabScrollerMenu.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var EntRecord, store;
        var viewport, grid, pcTab;
        var gd = "p";   // 授权方向（正向授权p, 反向授权o）

        function onPgLoad() {
            gd = $.getQueryString({ "ID": "gd", "DEFAULT": "p" });
            setPgUI();
        }

        function setPgUI() {
            var data = AimState["EntList"] || [];
            var pCatalogData = AimState["PCatalogList"] || [];
            
            var pgTabItems = [];

            $.each(pCatalogData, function(i) {
                var grantUrl = ((gd == "o") ? this.OppositeGrantUrl : this.PositiveGrantUrl);

                if (grantUrl) {
                    var titem = { title: this.Name, id: this.DynamicPermissionCatalog, code: this.Code, granturl: grantUrl };
                    titem.listeners = { activate: handleActivate };
                    titem.html = "<div style='display:none;'></div>";

                    pgTabItems.push(titem);
                }
            });

            EntRecord = Ext.data.Record.create([
			{ name: 'DynamicAuthID' },
			{ name: 'Name' },
			{ name: 'CatalogCode' },
			{ name: 'ParentID' },
			{ name: 'Path' },
			{ name: 'PathLevel' },
			{ name: 'IsLeaf' },
			{ name: 'Data' },
			{ name: 'EditStatus' },
			{ name: 'Creatable' },
			{ name: 'Deletable' },
			{ name: 'Editable' },
			{ name: 'Grantable' },
			{ name: 'Tag' },
			{ name: 'Description' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate'}]);

            store = new Ext.ux.maximgb.tg.AdjacencyListStore({
                autoLoad: true,
                parent_id_field_name: 'ParentID',
                leaf_field_name: 'IsLeaf',
                data: data,
                reader: new Ext.ux.data.AimJsonReader({ id: 'DynamicAuthID', dsname: 'EntList' }, EntRecord),
                proxy: new Ext.ux.data.AimRemotingProxy({
                    aimbeforeload: function(proxy, options) {
                        options.id = options.anode;
                    }
                })
            });

            // 搜索栏
            var schBar = new Ext.ux.AimSchPanel({});

            // 工具栏
            var tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '展开',
                    iconCls: 'aim-icon-refresh',
                    menu: [{ text: '展开下一层', handler: function() { store.expandAll(); } }]
}]
                });

                // 工具标题栏
                var titPanel = new Ext.Panel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.maximgb.tg.GridPanel({
                    store: store,
                    master_column_id: 'Name',
                    region: 'west',
                    split: true,
                    width: 250,
                    minSize: 250,
                    maxSize: 500,
                    columns: [
				{ id: 'Name', header: "权限名", width: 200, sortable: true, dataIndex: 'Name' },
				{ header: "权限信息", width: 100, sortable: true, hidden:true, dataIndex: 'Data' },
				{ header: "描述", width: 100, sortable: true, hidden: true, dataIndex: 'Description' }
      ],
                    autoExpandColumn: 'Name',
                    tbar: titPanel
                });

                grid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                    handleActivate();
                });

                var scrollerMenu = new Ext.ux.TabScrollerMenu({
                    menuPrefixText: '项目',
                    maxText: 15,
                    pageSize: 5
                });

            pcTab = new Ext.TabPanel({
                enableTabScroll: true,
                defaults: { autoScroll: true },
                plugins: [scrollerMenu],
                region: 'north',
                margins: '0 0 0 0',
                activeTab: 0,
                width: document.body.offsetWidth - 5,
                height: 10,
                border:0,
                items: pgTabItems
            });

                // 页面视图
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid, {
                    layout: 'border',
                    region: 'center',
                    margins: '0 0 0 0',
                    items: [pcTab, {
                        region: 'center',
                        margins: '0 0 0 0',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src=""></iframe>'}]
}]
                    });

                    // store.expandAll();

                    grid.getSelectionModel().selectFirstRow();
                }

                function handleActivate() {
                    var actTab = pcTab.getActiveTab();
                    var actRecs = grid.getSelectionModel().getSelections();

                    if (actTab && actRecs && actRecs.length > 0)
                        if (document.getElementById("frameContent")) {
                            var url = $.combineQueryUrl(actTab.granturl, { type: "auth", "id": actRecs[0].id });
                            //alert(url)
                            document.getElementById("frameContent").src = url;
                    }
                }

                // 链接渲染
                function linkRender(val, p, rec) {
                    var rtn = val;
                    switch (this.dataIndex) {
                        case "Name":
                            rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"GrpEdit.aspx?id=" + rec.id + "\")'>" + val + "</a>";
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
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>动态权限授权</h1></div>
</asp:Content>
