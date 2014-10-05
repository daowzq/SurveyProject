<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="GWSelect.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.Select.GWSelect" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

    <script type="text/javascript">
        var CorpId = $.getQueryString({ ID: 'CorpId' }) || "";
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        function onSelPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };
            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
			     { name: 'Id' },
			     { name: 'XL' },
			],
                listeners: { 'aimbeforeload': function(proxy, options) {
                    options.data = options.data || [];
                    options.data.CorpId = CorpId;
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
                collapsed: false,
                columns: 2,
                items: [{ fieldLabel: '职位', id: 'XL', schopts: { qryopts: "{ mode: 'Like', field: 'XL' }"}}]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: ['<img src="../../images/shared/arrow_right1.png" /><font color=red>说明： 双击行可以直接完成选择</font>', '->',
                {
                    text: '复杂查询',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        schBar.toggleCollapse(false);

                        setTimeout("viewport.doLayout()", 50);
                    }
}]
                });
                var buttonPanel = new Ext.form.FormPanel({
                    region: 'south',
                    frame: true,
                    buttonAlign: 'center',
                    buttons: [
                    {
                        text: '确定',
                        handler: function() { AimGridSelect(); }
                    },
                    {
                        text: '清除', handler: function() { AimGridRemove(); }
                    },
                     { text: '取消', handler: function() {
                         window.close();
                     } }]
                });
                // 工具标题栏"" +
                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                AimSelGrid = new Ext.ux.grid.AimGridPanel({
                    title: "职位",
                    store: store,
                    bbar: pgBar,
                    region: 'center',
                    autoExpandColumn: 'XL',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: 'Id', hidden: true },
                     new Ext.ux.grid.AimRowNumberer(),
                     AimSelCheckModel,
                    { id: 'XL', dataIndex: 'XL', header: '职位', width: 200}],
                    tbar: titPanel
                });
                // 页面视图{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 },
                viewport = new Ext.ux.AimViewport({
                    items: [AimSelGrid, buttonPanel]
                });
            }

            //移除
            function AimGridRemove() {
                Aim.PopUp.ReturnValue();
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
