<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.master" AutoEventWireup="true"
    CodeBehind="OrgPathName.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.OrgPathName" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .x-panel-body x-form
        {
            height: 0px;
        }
    </style>

    <script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

    <script type="text/javascript">

        var store, AimSelGrid;

        function onSelPgLoad() {
            setPgUI();
            $(".x-panel-ml").remove();
        }

        function setPgUI() {



            var myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };

            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'MName' },
			{ name: 'SortIndex' }
			]
            });

            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            //功能按钮
            buttonPanel = new Ext.form.FormPanel({
                region: 'south',
                frame: true,
                //height: 40,
                buttonAlign: 'center',
                buttons: [{ text: '确定', handler: function() { AimGridSelect(); } }, { text: '取消', handler: function() {
                    AimSelGrid.getSelectionModel().clearSelections();
                    AimGridSelect();
                    window.close();
                } }]
                });

                schBar = new Ext.ux.AimSchPanel({
                    store: store,
                    columns: 2,
                    collapsed: true,
                    items: [{ fieldLabel: '职位名称', id: 'MName', schopts: { qryopts: "{ mode: 'Like', field: 'MName' }"}}]
                });

                tlBar = new Ext.ux.AimToolbar({
                    items: ['<font color=red>请点击复选框选择/取消选择记录</font>', '->',
            {
                text: '复杂查询',
                iconCls: 'aim-icon-search',
                handler: function() {
                    schBar.toggleCollapse(false);
                    setTimeout("viewport.doLayout()", 50);
                } }]
                });


                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });


                AimSelGrid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'MName',
                    columns: [
                    { id: 'Id', header: '标识', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    AimSelCheckModel,
					{ id: 'MName', header: '职位名称', width: 100, sortable: true, dataIndex: 'MName' },
					{ id: 'SortIndex', header: '序号', width: 80, sortable: true, dataIndex: 'SortIndex' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, AimSelGrid, buttonPanel]
                });
            }
 
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            职位选择</h1>
    </div>
</asp:Content>
