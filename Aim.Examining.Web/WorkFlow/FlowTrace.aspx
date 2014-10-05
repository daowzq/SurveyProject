<%@ Page Language="C#" Title="流程跟踪" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FlowTrace.aspx.cs" Inherits="Aim.Portal.Web.WorkFlow.FlowTrace" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "TaskEdit.aspx";
        var status = $.getQueryString({ ID: "FormId", DefaultValue: "" });
        var EnumType = { '4': '已审批', '0': '待审批', '2': '系统已审批' };
        var comboxData = [[3, '三天内'], [7, '一周内'], [14, '二周内'], [30, '一个月内'], [31, '一个月前']];
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
            if (AimState["SysWorkFlowTaskList"]) {
                renderProcTrack({ flowId: AimState["SysWorkFlowTaskList"][0].WorkflowInstanceID, track: 1 });
            }
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["SysWorkFlowTaskList"] || []
            };
            if (AimState["SysWorkFlowTaskList"] && AimState["SysWorkFlowTaskList"].length == 0) {
                alert('无跟踪记录!'); window.close(); return;
            }
            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'SysWorkFlowTaskList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'Title' },
			{ name: 'Description' },
			{ name: 'OwnerId' },
			{ name: 'Owner' },
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
			{ name: 'Result' }
			],
                listeners: { "aimbeforeload": function(proxy, options) {
                    options.data = options.data || {};
                    options.data.FormId = status;
                }
                },
                sortInfo: {
                    field: 'FinishTime',
                    direction: 'Asc'
                }
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });
            // 表格面板
            grid = new Ext.ux.grid.AimGridPanel({
                store: store,
                region: 'center',
                //autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', header: '标识', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
					{ id: 'Title', dataIndex: 'Title', header: '标题', width: 100, sortable: true },
					{ id: 'WorkFlowName', dataIndex: 'WorkFlowName', header: '流程名称', width: 100, sortable: true },
					{ id: 'ApprovalNodeName', dataIndex: 'ApprovalNodeName', header: '环节名称', width: 150, sortable: true },
					{ id: 'Description', dataIndex: 'Description', header: '审批意见', width: 150, sortable: true, renderer: ToolTipForColumn },
					{ id: 'Owner', dataIndex: 'Owner', header: '审批人', width: 60, sortable: true, renderer: ToolTipForColumn },
					{ id: 'CreatedTime', dataIndex: 'CreatedTime', header: '分发时间', width: 100, sortable: true },
					{ id: 'FinishTime', dataIndex: 'FinishTime', header: '完成时间', width: 100, sortable: true },
					{ id: 'Status', dataIndex: 'Status', header: '状态', width: 100, sortable: true, enumdata: EnumType }
                    ],
                bbar: pgBar
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 70 }, grid, {
                    region: 'south',
                    border: false,
                    height: 450,
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src = "' + AimState["SysWorkFlowTaskList"][0].EFormName + '&op=r&FlowTrace=T"></iframe>'
}]
                });
            }
            function ToolTipForColumn(data, metadata, record, rowIndex, columnIndex, store) {
                metadata.attr = 'ext:qtitle ="' + record.data.OwnerName + ':"' + ' ext:qtip ="' + record.data.Description + '"';
                return data;
            }
            function RenderImg(val, p, rec) {
                switch (this.id) {
                    case "execute":
                        return "<img src='/images/shared/arrow_turnback.gif' style='cursor:hand' onclick=\"ExecuteTask('" + rec.id + "')\"/>";
                        break;
                }
            }
            var WinStyle = CenterWin("width=800,height=600,scrollbars=yes");
            function ExecuteTask(taskId) {
                if (status == "4") {
                    alert("环节已审批!"); return;
                }
                OpenWin("/WorkFlow/TaskExecute.aspx?TaskId=" + taskId, "_blank", WinStyle);
            }
            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }

            function reloadPage(args) {
                // 重新加载页面
                status = args ? args.cid : status;
                store.reload();
            }

            function SubmitFlow() {
                $.ajaxExec('startflow', { id: "1", tid: "2" },
                function(args) {
                    alert(args.data.message);
                });
            }


            var TRACK_PAGEURL = '/WorkFlow/FlowTrack2.aspx';

            function renderProcTrack(args) {
                var args = args || {};

                var trackurl = $.combineQueryUrl(TRACK_PAGEURL, args);

                var track = args.track;
                if (track == null || typeof (track) == 'undefined') {
                    track = $.getQueryString({ 'ID': 'track', 'DeafultValue': '' });
                }

                var hidetrack = $.getQueryString({ 'ID': 'hidetrack' });

                if ((track == 1 || 'true'.equals(track)) && !hidetrack) {
                    $('#header').find('h1').css('display', '');
                    $('#header').find('h1').before('<iframe src="' + trackurl + '" height="80" width="100%" frameborder="1" border="1"></iframe>');
                } else {
                    $('#header').css('display', 'none');
                }
            }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="height: 50px">
        <h1>
            流程跟踪</h1>
    </div>
</asp:Content>
