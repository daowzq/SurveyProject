<%@ Page Title="信息查看" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="TaskExecuteView.aspx.cs" Inherits="Aim.Examining.Web.WorkFlow.TaskExecuteView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/ext/ux/TabScrollerMenu.js" type="text/javascript"></script>

    <script src="taskview.js" type="text/javascript"></script>

    <style type="text/css">
        body
        {
            color: #003399;
            background-color: #ddd;
        }
        .flow
        {
            background-image: url(/images/shared/arrow_cross.gif) !important;
        }
        .task
        {
            background-image: url(/images/shared/arrow_turnround1.gif) !important;
        }
        .iconop
        {
            background-image: url(/images/shared/message_edit.png) !important;
        }
        .app-header
        {
        }
        .app-header
        {
            font-family: verdana,arial,sans-serif;
            font-size: 20px;
            color: #15428B;
        } 
        .ToolBar
        {
            background-color: red;
        }
    </style>

    <script type="text/javascript">
        var taskId = $.getQueryString({ ID: "TaskId", DefaultValue: "" });
        var EnumType = { '1': '已定', '0': '待定' };
        var routeData=[<%=NextStep %>];
        var flowInstanceId="<%=FlowInstanceId %>";
        var formUrl="<%=FormUrl %>";
        var flowDefineId="<%=FlowDefineId %>";
        
        
        function SubmitTask() {
        }
        function SaveTask(tag)
        {
        }
        //表单控制下一环节路由
        //第一个参数为下一步路由,第二个参数为是否禁止重新选择路由
        function SetRoute(routeName,disabled)
        {
            var comb = Ext.getCmp("id_SubmitState");
            comb.setValue(routeName);
            if(disabled)comb.disabled=disabled;
        }
        function ShowMessage(msg)
        {
            HideMask();
            Ext.MessageBox.alert("操作",msg);
        }
        function ShowMessageAndClose(msg)
        {
            HideMask();
            Ext.MessageBox.alert("操作",msg,RefreshWindow);
        }
        function RefreshWindow()
        {
            if(window.opener&&window.opener.reloadPage)
            {
                window.opener.reloadPage();
            }
            else if(window.opener)
            {
                window.opener.location.reload();
            }
            window.close();
            try
            {
            document.all.WebBrowser.ExecWB(45, 1);
            }catch(e){}
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
                $('#header').css('display', '');
                $('#header').before('<iframe id="frameTrack" src="' + trackurl + '" height="100%" width="100%" frameborder="1" border="1"></iframe>');
            } else {
                $('#header').css('display', 'none');
            }
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="divNorth" class="x-hide-display">
    </div>
    <div id="west" class="x-hide-display">
    </div>
    <object id="WebBrowser" width="0" height="0" classid='CLSID:8856F961-340A-11D0-A96B-00C04FD705A2'>
    </object>
</asp:Content>
