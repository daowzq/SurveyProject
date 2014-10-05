<%@ Page Title="流程审批" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="TaskExecute.aspx.cs" Inherits="Aim.Portal.Web.WorkFlow.TaskExecute" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/ext/ux/TabScrollerMenu.js" type="text/javascript"></script>

    <script src="TaskExecute.js" type="text/javascript"></script>

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
            ShowMask();
            if ($("#id_SubmitState").val() == "") {
                Ext.MessageBox.alert('提示框', '请选择路由!');
                return;
            }
            if(!frameContent.onSave)
            {
                alert("请等待页面加载完毕后再提交!");return;
            }
            SaveTask();
            if($("#id_SubmitState").val()=="结束"||AimState["NextNodeName"]=="结束")//流程结束
            {
                if(frameContent.onFinish)
                {
                    frameContent.onFinish(AimState["Task"]);
                }
                $.ajaxExec('submitTask', { FlowDefineId:flowDefineId,TaskId: taskId, Route: $("#id_SubmitState").val(),RouteName: $("#id_SubmitState").val(),UserIds:userIds,UserNames:userNames,NextNodeName:AimState["NextNodeName"] }, function() {ShowMessageAndClose("流程已结束!");});
                return;
            }
            else
            {
                if(frameContent.onSubmit)
                {
                    if(frameContent.onSubmit(AimState["Task"])===false)   
                    {     
                        HideMask();            
                        return;      
                    }                
                }
            }
            //增加跳过环节的功能
            var jumps = "";
            if(frameContent.onGetJumps&&frameContent.onGetJumps($("#id_SubmitState").val())!="")
            {
                jumps = frameContent.onGetJumps($("#id_SubmitState").val());
            }
            if(frameContent.onGiveUsers)//先取表单上的人员
            {
                var users = frameContent.onGiveUsers($("#id_SubmitState").val());
                userIds = users.UserIds;
                if(userIds!="")
                {
                    userNames = users.UserNames;
                    var text = $("#id_SubmitState").val();
                    $.ajaxExec('submitTask', { Jumps:jumps,FlowDefineId:flowDefineId,TaskId: taskId, Route: $("#id_SubmitStateH").val(),RouteName: text,UserIds:userIds,UserNames:userNames,NextNodeName:AimState["NextNodeName"] }, function() {ShowMessageAndClose("提交成功!");});
                }
            }
            if(userIds=="")
            {
                if(AimState["NextUserIds"]!=null&&AimState["NextUserIds"]!="")//流程配置里的人员和打回情况的人员,有打回(执行过的环节)优先取执行过的人提交
                {
                    var text = $("#id_SubmitState").val();
                    //if(frameContent.StartUserId=="")return;
                    if(frameContent.StartUserId&&frameContent.StartUserId!="")
                    {
                        $.ajaxExec('submitTask', { Jumps:jumps,FlowDefineId:flowDefineId,TaskId: taskId, Route: $("#id_SubmitStateH").val(),RouteName: text,UserIds:AimState["NextUserIds"],UserNames:AimState["NextUserNames"] ,UserType:AimState["UserType"]||AimState["NextUserType"],NextNodeName:AimState["NextNodeName"],StartUserId:frameContent.StartUserId,StartUserName:frameContent.StartUserName}, function() {ShowMessageAndClose("提交成功!");});
                    }
                    else
                    {
                        $.ajaxExec('submitTask', { Jumps:jumps,FlowDefineId:flowDefineId,TaskId: taskId, Route: $("#id_SubmitStateH").val(),RouteName: text,UserIds:AimState["NextUserIds"],UserNames:AimState["NextUserNames"] ,UserType:AimState["UserType"]||AimState["NextUserType"],NextNodeName:AimState["NextNodeName"]}, function() {ShowMessageAndClose("提交成功!");});
                    }
                }
                else//手动选人
                {
                    SelectUsers("/CommonPages/Select/UsrSelect/MUsrSelect.aspx?rtntype=array&seltype=multi",null,null,jumps);
                }
            }
        }
        var userIds="";var userNames="";
        function SelectUsers(url, op, style,jumps) {
            userIds="";userNames = "";
            op = op || "r";
            style = style || "dialogWidth:750px; dialogHeight:550px; scroll:yes; center:yes; status:no; resizable:yes;";

            var params = [];
            params[params.length] = "op=" + op;

            url = $.combineQueryUrl(url, params)
            rtn = window.showModalDialog(url, window, style);

            if (rtn && rtn.result) {
                if (rtn.result == 'success') {
                    var uids = [];
                    var usrs = rtn.data;
                    $.each(usrs, function() {
                        if (this.UserID) {
                            userIds = userIds+this.UserID+",";
                            userNames = userNames+this.Name+",";
                        }
                    });
                    if(userIds==""){HideMask();return;}
                    var text = $("#id_SubmitState").val().replace("("+$("#id_SubmitStateH").val()+")","")
                    $.ajaxExec('submitTask', { Jumps:jumps,FlowDefineId:flowDefineId,TaskId: taskId, Route: $("#id_SubmitStateH").val(),RouteName: text,UserIds:userIds,UserNames:userNames ,NextNodeName:AimState["NextNodeName"]}, function() {ShowMessageAndClose("提交成功!");});
                }
            }
            else
                HideMask();
        }
        function SaveTask(tag)
        {
            ShowMask();
            if(frameContent.onSave)
            {
                //传入当前环节数据
                frameContent.onSave(AimState["Task"]);
            }
            $.ajaxExec('saveTask', { TaskId: taskId,Opinion:$("#textOpinion").val()}, function() { if(tag)ShowMessage("保存成功!");});
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
            alert(msg);
            //Ext.MessageBox.alert("操作",msg);
        }
        function ShowMessageAndClose(msg)
        {
            HideMask();
            alert(msg);
            RefreshWindow();
            //Ext.MessageBox.alert("操作",msg,RefreshWindow);
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
            //document.all.WebBrowser.ExecWB(45, 1);
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
    <!--object id="WebBrowser" width="0" height="0" classid='CLSID:8856F961-340A-11D0-A96B-00C04FD705A2'>
    </object-->
</asp:Content>
