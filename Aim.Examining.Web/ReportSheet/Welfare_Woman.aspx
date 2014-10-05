<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Welfare_Woman.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.Welfare_Woman" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        collect
        {
            background-color: Red;
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">

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
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },

			{ name: 'CouponCount' },
			{ name: 'CouponCost' },
			{ name: 'NoMarryCheckCount' },
			{ name: 'NoMarryCheckCost' },
			{ name: 'MarryCheckCount' },
			{ name: 'MarryCheckCost' },

			{ name: 'SmallTotal' },
			{ name: 'CompanyTotal' },
            { name: 'Remark' }

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


                var total = 0;
                $.each(store.getRange(), function() {
                    total += parseFloat(this.get("SmallTotal"));
                });
                total = total || 0.00;

                //底部工具栏
                bottom = new Ext.ux.AimPanel({
                    items: [
                     new Ext.Panel({
                         id: 'mony',
                         title: '合计汇总',
                         //cls: 'statics',
                         height: 50,
                         html: "<span style='font-size:12px;font-weight:bold; margin-right: 100px; float:right'>合计:<span id='money'>" + total + "</span>&nbsp;￥</span>"
                     }), pgBar]
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

					{ id: 'Year', dataIndex: 'Year', header: '年度', width: 50, sortable: true },
			        { id: 'CompanyName', dataIndex: 'CompanyName', header: '公司名称', width: 200, sortable: true },
				    { id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 130, sortable: true },

				    { id: 'CouponCount', dataIndex: 'CouponCount', header: '购物券人数', width: 80, sortable: true },
					{ id: 'CouponCost', dataIndex: 'CouponCost', header: '合计金额', width: 70, sortable: true },
				    { id: 'NoMarryCheckCount', dataIndex: 'NoMarryCheckCount', header: '体检人数(未婚)', width: 90 },
				    { id: 'NoMarryCheckCost', dataIndex: 'NoMarryCheckCost', header: '合计金额', width: 80 },

					{ id: 'MarryCheckCount', dataIndex: 'MarryCheckCount', header: '体检人数(已婚)', width: 100 },
				    { id: 'MarryCheckCost', dataIndex: 'MarryCheckCost', header: '合计金额', width: 70 },
				    { id: 'SmallTotal', dataIndex: 'SmallTotal', header: '小计', width: 80 },
                    //{ id: 'CompanyTotal', dataIndex: 'CompanyTotal', header: '合计', width: 90 },

				    {id: 'Remark', dataIndex: 'Remark', header: ' 备注', width: 120 }
                    ],
                    //                    view: new Ext.grid.GroupingView({
                    //                        forceFit: true,
                    //                        groupTextTpl: '{text} ({[values.rs.length]} 项)'
                    //                    }),
                    bbar: bottom,
                    tbar: titPanel
                });

                grid.on("render", function(cmp) {


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
