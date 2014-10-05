<%@ Page Title="员工配偶保险" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master"
    AutoEventWireup="true" CodeBehind="Welfare_Couple.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.Welfare_Couple" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">

        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "UsrDoubleWelfareEdit.aspx";
        var YearEnum = "";



        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            //----------设置年份----------------
            var evalStr = "";
            var year = new Date().getFullYear();
            evalStr += "{";
            evalStr += "\"\":'请选择...',";
            for (var i = 0; i < 6; i++) {
                if (i > 0) evalStr += ",";
                evalStr += (year - 5 + i) + ":" + (year - 5 + i);
            }
            evalStr += "}";
            YearEnum = eval("(" + evalStr + ")");
            //-- -- -- -- -- -- -- -- -- -- -- --  
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

			{ name: 'Year' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'WorkNo' },
			{ name: 'Sex' },

			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
			{ name: 'IdentityCard' },
			{ name: 'IndutyData' },

            { name: 'OtherUserName' },
            { name: 'OtherSex' },
            { name: 'OtherIdentityCard' },
            { name: 'Ext1' },
			{ name: 'CreateTime' }
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
                columns: 5,
                collapsed: false,
                items: [{ fieldLabel: '年度', id: 'Year', xtype: 'aimcombo', required: true,
                    enumdata: YearEnum,
                    schopts: { qryopts: "{ mode: 'Like', field: 'Year' }" },
                    listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("Year")); } }
                },
                { fieldLabel: '公司', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CompanyName' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Year"));   //Number 为任意
                }
                }
                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
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
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),

					{ id: 'Year', dataIndex: 'Year', header: '年度', width: 100, sortable: true },
			        { id: 'CompanyName', dataIndex: 'CompanyName', header: '公司名称', width: 200, sortable: true },
				    { id: 'DeptName', dataIndex: 'DeptName', header: '一级部门', width: 130, sortable: true },
				    { id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 80, sortable: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 100, sortable: true },
				    { id: 'Sex', dataIndex: 'Sex', header: '性别', width: 60 },
					{ id: 'IdentityCard', dataIndex: 'IdentityCard', header: '身份证号', width: 120 },

					{ id: 'IndutyData', dataIndex: 'IndutyData', header: '入职日期', width: 100, sortable: true },
				    { id: 'OtherUserName', dataIndex: 'OtherUserName', header: '配偶姓名', width: 100, sortable: true },
					{ id: 'OtherSex', dataIndex: 'OtherSex', header: '性别', width: 50, sortable: true },
					{ id: 'OtherIdentityCard', dataIndex: 'OtherIdentityCard', header: '身份证号码', width: 120 }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid]
                });
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
