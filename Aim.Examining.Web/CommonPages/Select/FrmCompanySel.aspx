<%@ Page Title="选择公司" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmCompanySel.aspx.cs" Inherits="Aim.Examining.Web.FrmCompanySel" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

    <script type="text/javascript">
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
                idProperty: 'GroupID',
                data: myData,
                fields: [
			    { name: 'GroupID' },
                { name: 'Code' },
                { name: 'Name' },
                { name: 'CorpCode' }
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
                collapsed: false,
                columns: 3,
                items: [
                { fieldLabel: '公司编号', id: 'Code', schopts: { qryopts: "{ mode: 'Like', field: 'Code' }" } },
                { fieldLabel: '公司名称', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'Name' }" } },
                {
                    fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '1 30 0 0', text: '查 询', handler: function () {
                        Ext.ux.AimDoSearch(Ext.getCmp("Name"));
                    }
                }]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: ['<font color=red style="font-size:12px;">请点击复选框选择/取消选择记录</font>']
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
                autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', header: '标识', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    AimSelCheckModel,
                    { id: 'GroupId', dataIndex: 'GroupId', header: 'PK', width: 100, sortable: true, hidden: true },
                    { id: 'Code', dataIndex: 'Code', header: '公司编号', width: 100, sortable: true },
                    { id: 'Name', dataIndex: 'Name', header: '公司名称', width: 200, sortable: true }
                ],
                bbar: pgBar,
                tbar: titPanel,
                listeners: {
                    "rowdblclick": function () {
                        AimGridSelect();
                    }
                }
            });
            grid = AimSelGrid;

            var buttonPanel = new Ext.form.FormPanel({
                region: 'south',
                frame: true,
                buttonAlign: 'center',
                buttons: [{
                    text: '确定', handler: function () {
                        AimGridSelect();
                    }
                }, {
                    text: '取消', handler: function () {
                        window.close();
                    }
                }]
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [grid, buttonPanel]
            });
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>标题</h1>
    </div>
</asp:Content>
