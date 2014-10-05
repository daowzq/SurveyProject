<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="TaskList.aspx.cs" Inherits="Aim.Portal.Web.WorkFlow.TaskList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=1200,height=600,scrollbars=yes");
        var EditPageUrl = "TaskEdit.aspx";
        var status = $.getQueryString({ ID: "Status", DefaultValue: "" });
        var EnumType = { '4': '已审批', '0': '待审批' };
        var EnumType1 = { 'Idle': '签核中', 'Completed': '已结束' };
        var comboxData = [[3, '三天内'], [7, '一周内'], [14, '二周内'], [30, '一个月内'], [31, '一个月以上'], [100, '全部']];
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["SysWorkFlowTaskList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'SysWorkFlowTaskList',
                idProperty: 'ID',
                data: myData,
                fields: [
			{ name: 'ID' },
			{ name: 'Title' },
			{ name: 'Description' },
			{ name: 'OwnerId' },
			{ name: 'OwnerName' },
			{ name: 'Action' },
			{ name: 'WorkFlowInstanceId' },
			{ name: 'WorkFlowName' },
			{ name: 'EFormName' },
			{ name: 'ApprovalNodeName' },
			{ name: 'GroupId' },
			{ name: 'ApprovalNodeMathConditionType' },
			{ name: 'BookmarkName' },
			{ name: 'CreatedTime' },
			{ name: 'FinishTime' },
			{ name: 'Status' },
			{ name: 'Context' },
			{ name: 'Result' },
			{ name: 'FlowStatus' },
			{ name: 'RelateName' },
			{ name: 'System' },
			{ name: 'Type' },
			{ name: 'ExecUrl' },
			{ name: 'RelateType' },
			{ name: 'OwnerUserId' }
			],
                listeners: { "aimbeforeload": function(proxy, options) {
                    options.data = options.data || {};
                    options.data.Status = status;
                    options.data.Date = $("#id_SubmitStateH").val();
                }
                },
                sortInfo: {
                    field: 'CreatedTime',
                    direction: 'Desc'
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
                items: [
                { fieldLabel: '标题', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                { fieldLabel: '流程名', id: 'WorkFlowName', schopts: { qryopts: "{ mode: 'Like', field: 'WorkFlowName' }"} },
                { fieldLabel: '环节名', id: 'ApprovalNodeName', schopts: { qryopts: "{ mode: 'Like', field: 'ApprovalNodeName' }"}}]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [new Ext.Toolbar.TextItem('查看：'), {
                    xtype: 'combo',
                    name: 'submitState',
                    id: 'id_SubmitState',
                    hiddenName: 'id_SubmitStateH',
                    triggerAction: 'all',
                    forceSelection: true,
                    lazyInit: false,
                    editable: false,
                    allowBlank: false,
                    width: 90,
                    store: new Ext.data.SimpleStore({
                        fields: ["retrunValue", "displayText"],
                        data: comboxData
                    }),
                    mode: 'local',
                    value: '3',
                    valueField: "retrunValue",
                    displayField: "displayText",
                    listeners: {
                        select: function() {
                            reloadPage(null);
                            try {
                            } catch (ex) {

                            }
                        }
                    }, anchor: '99%'
                }, {
                    text: '启动测试流程', hidden: true,
                    iconCls: 'aim-icon-execute',
                    handler: SubmitFlow
                }, '->',
                {
                    text: '复杂查询',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        schBar.toggleCollapse(false);

                        setTimeout("viewport.doLayout()", 50);
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
                    { id: 'ID', header: '标识', dataIndex: 'ID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'execute', header: '执行', renderer: RenderImg, width: 70, sortable: true, fixed: true, menuDisabled: true },
					{ id: 'Title', dataIndex: 'Title', header: '标题', width: 150, sortable: true },
					{ id: 'WorkFlowName', dataIndex: 'WorkFlowName', header: '流程名称', width: 200, sortable: true },
					{ id: 'ApprovalNodeName', dataIndex: 'ApprovalNodeName', header: '环节名称', width: 150, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreatedTime', header: '分发时间', width: 100, sortable: true },
					{ id: 'FinishTime', dataIndex: 'FinishTime', header: '完成时间', width: 100, sortable: true },
					{ id: 'Status', dataIndex: 'Status', header: '状态', width: 50, sortable: true, enumdata: EnumType, hidden: true },
					{ id: 'FlowStatus', dataIndex: 'FlowStatus', header: '单据状态', width: 60, sortable: true, enumdata: EnumType1, hidden: true }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }
            function RenderImg(val, p, rec) {
                switch (this.id) {
                    case "execute":
                        return "<img src='/images/shared/arrow_turnback.gif' style='cursor:hand' onclick=\"ExecuteTask('" + rec.id + "')\"/>";
                        break;
                }
            }
            var WinStyle = CenterWin("width=1200,height=650,scrollbars=yes");
            function ExecuteTask(taskId) {
                var rec = store.getById(taskId);
                if (rec.get("Type")!="") {
                    ExecuteTaskS(rec.get("Type"), rec.get("ID"), rec.get("WorkFlowInstanceId"), rec.get("System"), rec.get("ExecUrl"))
                }
                else
                {
                    if (status == "1") {
                        OpenWin("/WorkFlow/TaskExecute.aspx?op=r&TaskId=" + taskId, "_blank", WinStyle);
                    }
                    OpenWin("/WorkFlow/TaskExecute.aspx?TaskId=" + taskId, "_blank", WinStyle);
                }
            }
            function ExecuteTaskS(taskType, wid, flowId, sys, execUrl) {
                var _link = "<%=Aim.Common.ConfigurationHosting.SystemConfiguration.AppSettings["GoodwayPortalUrl"].Replace("/portal/Portal.aspx","") %>";
                switch (taskType) {
                    case "AuditFlow":
                        if (sys == "Project")
                            _link += "/Project/WorkSpace/PrjNormalTaskBus.aspx?FlowId=" + flowId + "&ItemId=" + wid + "&PassCode=<%=Session["PassCode"] %>";
                        else
                            _link += "/workflow/businessframe/TaskBus.aspx?WorkItemId=" + wid + "&PassCode=<%=Session["PassCode"] %>";
                        OpenWin(_link, "_Blank", CenterWin("width=870,height=650,resizable=yes,scrollbars=yes"));
                        break;
                    case "AuditTask":
                        OpenWin(_link+"/project/workspace/PrjMyAudit.aspx?FlowId=" + flowId + "&amp;TaskKey=" + wid + "&PassCode=<%=Session["PassCode"] %>", "_Blank", CenterWin("width=820,height=600,status=yes"));
                        break;
                    case "FileFlow":
                        _link += "/workflow/fileflowframe/FileBus.aspx?WorkItemId=" + wid + "&PassCode=<%=Session["PassCode"] %>";
                        OpenWin(_link, "_blank", CenterWin("width=820,height=650,scrollbars=yes,resizable=yes"));
                        break;
                    case "newflow":
                        _link += "/workflow/fileflow/FileBus.aspx?WorkItemId=" + wid + "&PassCode=<%=Session["PassCode"] %>";
                        OpenWin(_link, "_blank", CenterWin("width=820,height=650,scrollbars=yes,resizable=yes"));
                        break;
                    case "CustomFormFlow":
                        _link += "/workflow/customformflowframe/CustomFormBus.aspx?WorkItemId=" + wid + "&PassCode=<%=Session["PassCode"] %>";
                        OpenWin(_link, "_blank", CenterWin("width=820,height=650,scrollbars=yes,resizable=yes"));
                        break;
                    default:
                        //LinkTo
                        //("/workflow/businessframe/TaskBus.aspx?WorkItemId=" + wid, "_blank", CenterWin("width=820,height=600,scrollbars=yes"));
                        ExecuteFreeFlow(execUrl, wid, flowId, sys);
                        break;
                }
            }
            function ExecuteFreeFlow(url, wid, flowId, relateType) {
                _link = "<%=Aim.Common.ConfigurationHosting.SystemConfiguration.AppSettings["GoodwayPortalUrl"].Replace("/portal/Portal.aspx","") %>"+url + "&WorkItemId=" + wid + "&FlowId=" + flowId;
                OpenWin(_link, "_Blank", CenterWin("width=1000,height=650,scrollbars=yes"));
            }
            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }

            function reloadPage(args) {
                // 重新加载页面
                status = args ? args.cid : status;
                if (status == 0) {
                    grid.getColumnModel().setHidden(3, false);
                    grid.getColumnModel().setColumnHeader(3, "执行");
                }
                else {
                    grid.getColumnModel().setColumnHeader(3, "查看");
                }
                store.reload();
            }

            function SubmitFlow() {
                var key = window.prompt("请输入流程Key", "");
                if (key && key != "") {
                    Ext.getBody().mask("流程启动中,请稍后...");
                    $.ajaxExec('startflow', { flowkey: key, id: "1", tid: "2" },
                        function(args) {
                            Ext.getBody().unmask();
                            reloadPage();
                        });
                }
            }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
