<%@ Page Title="角色选择" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="RoleSelect.aspx.cs" Inherits="Aim.Portal.Web.EPC.RoleSelect" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "PRJ_SupplierEdit.aspx";

        var QualificationEnum, OpPropertyEnum, QualificationGradeEnum;

        var store, viewport;

        function onSelPgLoad() {
            //  QualificationEnum = AimState["DataEnum"]["EPC.Supplier.Qualification"];
            // OpPropertyEnum = AimState["DataEnum"]["EPC.Supplier.OpProperty"];
            // QualificationGradeEnum = AimState["DataEnum"]["EPC.Supplier.QualificationGrade"];

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
                idProperty: 'RoleId',
                data: myData,
                fields: [
			{ name: 'RoleId' },
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
                columns: [
                    { id: 'RoleId', header: '标识', dataIndex: 'RoleId', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    AimSelCheckModel,
					{ id: 'Name', header: '角色名称', width: 100, sortable: true, dataIndex: 'Name' },
					{ id: 'Description', header: '角色简介', width: 200, sortable: true, dataIndex: 'Description' }
                    ],
                bbar: pgBar,
                tbar: titPanel,
                autoExpandColumn: 'Name'
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
    <div id="header">
        <h1>
            角色选择</h1>
    </div>
</asp:Content>
