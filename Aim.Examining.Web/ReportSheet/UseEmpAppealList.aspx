<%@ Page Title="员工申诉" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="UseEmpAppealList.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.UseEmpAppealList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=500,scrollbars=yes");

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["UsrAppealListList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'UsrAppealListList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'WorkNo' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'IsNoName' },
			{ name: 'AppealTypeCode' },
			{ name: 'AppealTypeName' },
			{ name: 'AppealReason' },

			{ name: "Title" },
			{ name: 'AddFiles' },
			{ name: 'DealResult' },
			{ name: 'WorkFlowCode' },
			{ name: 'WorkFlowState' },
			{ name: 'AppealSolve' },
			{ name: 'DeptId' },
			{ name: 'State' },
			{ name: 'CompanyName' },
			{ name: 'DeptName' },
			{ name: 'CreateId' },
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
                collapsed: false,
                columns: 5,
                items: [
                  { fieldLabel: '标题', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                  { fieldLabel: '申诉类型', id: 'AppealTypeName', xtype: 'aimcombo', required: true, enumdata: AimState["AppealTypeName"], schopts: { qryopts: "{ mode: 'Like', field: 'AppealTypeName' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("AppealTypeName")); } } },
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
                items: []
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
                //autoExpandColumn: 'AppealReason',
                viewConfig: { forceFit: true, scrollOffset: 10 },
                margins: '0 10 10 0',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 80, sortable: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '申诉人', width: 90, sortable: true, renderer: RowRender },
					{ id: 'AppealTypeName', dataIndex: 'AppealTypeName', header: '申诉类型', width: 90, sortable: true },
					{ id: 'Title', dataIndex: 'Title', header: '标题', width: 150, renderer: RowRender },
                //{ id: 'AppealReason', dataIndex: 'AppealReason', header: '申诉事由', width: 200, renderer: RowRender },
					{id: 'CompanyName', dataIndex: 'CompanyName', header: '所属公司', width: 150, sortable: true },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '所属部门', width: 100, sortable: true },
					 { id: 'IsNoName', dataIndex: 'IsNoName', header: '是否匿名', width: 80, renderer: RowRender },
					{ id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: '状态', width: 80, sortable: true, renderer: RowRender },

					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '申诉时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
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
                case "UserName":
                    if (record.get("IsNoName") == "1") {
                        rtn = "<font color=gray>匿名</font>";
                    } else {
                        rtn = "<span>" + value + "</span>"
                    }
                    break;
                case "IsNoName":
                    if (value == "1") {
                        rtn = "是";
                    } else {
                        rtn = "否";
                    }
                    break;
                case "WorkFlowState":
                    if (value == "Start") {
                        rtn = "受理中";
                    } else if (value == "End") {
                        rtn = "结束";
                    }
                    break;
                case "Title":
                    var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='openWin(\"" + record.get("Id") + "\")'>" + (value || "") + "</span>";
                    rtn = str;
                    break;
                case "AppealReason":
                    value = value || "";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = value;
                    break;

            }
            return rtn;
        }


        //打开流程跟踪
        function openWin(val) {
            var task = new Ext.util.DelayedTask();
            var url = "AppealResultView.aspx";
            var url = "/workflow/TaskExecuteView.aspx";
            task.delay(10, function() {
                //opencenterwin(url + "?op=r&id=" + val, "", 540, 425);
                opencenterwin(url + "?FormId=" + val, "", 1004, 604);
            });
        }

        //        function openWin(val) {
        //            var task = new Ext.util.DelayedTask();
        //            var url = "AppealResultView.aspx";
        //            task.delay(10, function() {
        //                opencenterwin(url + "?op=r&id=" + val, "", 700, 620);
        //            });
        //        }

        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',                      innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }
        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
