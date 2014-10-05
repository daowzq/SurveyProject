<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="EmpInsuranceList.aspx.cs" Inherits="Aim.Examining.Web.EmpInsuranceList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=680,height=535,scrollbars=yes");
        var EditPageUrl = "EmpInsuranceEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
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
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'Sex' },
			{ name: 'WorkNo' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'IdentityCard' },
			{ name: 'NSSFNo' },
			{ name: 'ChildCount' },
			{ name: 'Addr' },
			{ name: 'Reason' },
            { name: "ApproveUserId" },
            { name: "ApproveName" },
			{ name: "AddFiles" },
			{ name: 'ApplyTime' },
			{ name: 'CreateId' }, { name: 'CreateName' },
			{ name: 'CreateTime' }, { name: 'State' }, { name: 'Result' }
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
                columns: 4,
                items: [
               { fieldLabel: '起始时间', id: 'StartTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', endDateField: 'EndTime', schopts: { qryopts: "{ mode: 'GreaterThanEqual', datatype:'Date', field: 'ApplyTime' }"} },
                { fieldLabel: '截至时间', id: 'EndTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', startDateField: 'StartTime', schopts: { qryopts: "{ mode: 'LessThanEqual', datatype:'Date', field: 'ApplyTime' }"} },
				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
				    Ext.ux.AimDoSearch(Ext.getCmp("StartTime"));   //Number 为任意
				}
				}
                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        //  ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                        window.location.href = "EmpInsuranceEdit.aspx?op=c";
                    }
                }, '-', {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs[0].get("State") != "待提交") {
                            AimDlg.show("审批中或者审批结束的的记录不能修改!");
                            return;
                        }
                        window.location.href = "EmpInsuranceEdit.aspx?op=u&id=" + recs[0].get("Id");
                    }
                }, '-', {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }
                        if (recs[0].get("WorkFlowState") == "Start") {
                            AimDlg.show("审批中的记录不能删除!");
                            return;
                        }
                        if (recs[0].get("WorkFlowState") == "End") {
                            AimDlg.show("审批结束的记录不能删除!");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, '-', {
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
                    margins: '0 0 10 0',
                    region: 'center',
                    viewConfig: { forceFit: true, scrollOffset: 10 },
                    // autoExpandColumn: 'Name',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    { id: 'UserId', dataIndex: 'UserId', header: '标识', hidden: true },
                    { id: 'DeptId', dataIndex: 'DeptId', header: '部门ID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'UserName', dataIndex: 'UserName', header: '申请人', width: 100, sortable: true },
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 80, sortable: true },
					{ id: 'Sex', dataIndex: 'Sex', header: '性别', width: 80, sortable: true },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 200, sortable: true },
	                { id: 'ApproveName', dataIndex: 'ApproveName', header: '审批人', width: 80 },
					{ id: 'State', dataIndex: 'State', header: '申报状态', width: 80, sortable: true },
					{ id: 'Result', dataIndex: 'Result', header: '申报结果', width: 80, sortable: true },
					{ id: 'ApplyTime', dataIndex: 'ApplyTime', header: '申请日期', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }
            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
                    case "WorkFlowState":
                        if (value == "Start") {
                            rtn = "审批中";
                        } else if (value == "End") {
                            rtn = "结束";
                        }
                        break;
                }
                return rtn;
            }
            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
