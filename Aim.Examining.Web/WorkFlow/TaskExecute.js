var actionPanel;
var viewport;
var panel;
var mask;
var usersText;

function onPgLoad() {
    setPgUI();
    if (AimState["InstanceId"]) {
        //renderProcTrack({ flowId: AimState["InstanceId"], track: 1 });
    }
}

function setPgUI() {
    mask = new Ext.LoadMask(Ext.getBody(), { msg: "处理中..." });
    mask.show();
    InitTraceBar();
    // 工具栏
    panel = new Ext.Panel({
        id: 'opinionPanel',
        collapsed: false,
        height: 100,
        border: false,
        html: '<font size=2 color=black>填写审批意见:</font><textarea id=textOpinion style=width:99%;height:80px>' + AimState["Task"].Description + '</textarea>'
    });
    var tlBar = new Ext.Panel({
        region: 'south',
        height: 28,
        items: panel,
        border: true,
        tbar: {
            buttonAlign: 'center',
            xtype: 'toolbar',
            items: [{
                xtype: 'combo',
                name: 'submitState',
                id: 'id_SubmitState',
                hiddenName: 'id_SubmitStateH',
                triggerAction: 'all',
                forceSelection: true,
                lazyInit: false,
                editable: false,
                allowBlank: false,
                hidden: true,
                width: 150,
                store: new Ext.data.SimpleStore({
                    fields: ["returnValue", "displayText"],
                    data: routeData
                }),
                mode: 'local',
                value: routeData[0][0],
                valueField: "returnValue",
                displayField: "displayText",
                listeners: {
                    select: function() {
                        try {
                            $.ajaxExec('getUsers', { TemplateId: AimState["TemplateId"], FlowInstanceId: AimState["InstanceId"], Name: $("#id_SubmitState").val(), CurrentName: AimState["Task"].ApprovalNodeName },
                        function(args) {
                            //AimDlg.show(args.data.NextUserNames);
                            AimState["NextUserIds"] = args.data.NextUserIds;
                            AimState["NextUserNames"] = args.data.NextUserNames;
                            AimState["UserType"] = args.data.NextUserType;
                            AimState["NextNodeName"] = args.data.NextNodeName;
                            usersText.setText("人员:" + AimState["NextUserNames"] + " ");
                        });
                        } catch (ex) {

                        }
                    }
                }, anchor: '99%'
            }, {
                text: '<span style=font-size:12px;color:red;>提交流程</span>',
                iconCls: 'aim-icon-execute', cls: 'x-btn-click', hidden: true,
                handler: SubmitTask
            }, {
                text: '<span style=font-size:12px>审批意见</span>',
                id: 'auditOpinion', hidden: true,
                iconCls: 'iconop',
                handler: function() {
                    ToolBarToggle();
                }
            }, {
                text: '<span style=font-size:12px>暂存</span>',
                iconCls: 'aim-icon-save',
                height: 28,
                handler: SaveTask
            }, '-'],
            height: 35
        }
    });
    var rejectscomment = ",不同意,打回,拒绝,重议,返回,";
    for (var i = 0; i < routeData.length; i++) {
        tlBar.getTopToolbar().addButton(
             {
                 text: routeData[i][1],
                 id: routeData[i][1],
                 height: 28,
                 iconCls: rejectscomment.indexOf(',' + routeData[i][1] + ',') >= 0 ? 'aim-icon-cancel' : 'aim-icon-submit',
                 scope: this, handler: function() {
                     var route = arguments[0].text;
                     $("#id_SubmitStateH").val(route == "结束" ? "" : route);
                     $("#id_SubmitState").val(route);
                     $.ajaxExec('getUsers', { TemplateId: AimState["TemplateId"], FlowInstanceId: AimState["InstanceId"], Name: route, CurrentName: AimState["Task"].ApprovalNodeName },
                        function(args) {
                            //AimDlg.show(args.data.NextUserNames);
                            AimState["NextUserIds"] = args.data.NextUserIds;
                            AimState["NextUserNames"] = args.data.NextUserNames;
                            AimState["UserType"] = args.data.NextUserType;
                            AimState["NextNodeName"] = args.data.NextNodeName;
                            //usersText.setText("人员:" + AimState["NextUserNames"] + " ");
                            SubmitTask();
                        });
                 }
             });


        // if (i > 0 && i < routeData.length) {   //comment by WGM 8/6
        tlBar.getTopToolbar().add("-");
        // }
    }
    /*tlBar.getTopToolbar().add("->");
    tlBar.getTopToolbar().addButton({
    text: '<span style=font-size:12px>暂存</span>',
    iconCls: 'aim-icon-save',
    handler: SaveTask
    });*/
    var hideButton = false;
    var isAllowAdd = false;
    var isParallel = false;
    var isAllowSend = false;
    if (AimState["ExtData"] != "") {
        var extobj = $.getJsonObj(AimState["ExtData"]);
        if (extobj) {
            hideButton = extobj.IsReadNode; //已阅节点
            isAllowAdd = extobj.IsAllowAdd;
            isParallel = extobj.IsParallelNext;
            isAllowSend = extobj.IsAllowSend;
        }
    }
    //分发处理
    if (isAllowSend) {
        tlBar.getTopToolbar().addButton(
             {
                 text: '分发',
                 id: 'btnaddsend',
                 /*cls: 'x-btn-click',*/
                 iconCls: 'aim-icon-group',
                 scope: this, handler: function() {
                     AddSendNode(arguments[0]);
                 }
             });
    }

    var titlelabel = "<table width=100%><tr width=100%><td style='font-size:12px;font-weight:bold;'>" + AimState["Task"].WorkFlowName + "->" + AimState["Task"].ApprovalNodeName + "</td><td  style='font-size:12px;font-weight:bold;text-align:right;cursor:hand;' onclick='ChangeTrackHeight();' id='tdTrackText' valign='middle'><img src='/images/shared/trans.gif'  align='absmiddle' />查看流程跟踪图</td></tr></table>";
    var tlBarTitle = new Ext.Panel({
        region: 'north',
        contentEl: 'divNorth',
        autoHeight: true,
        id: 'northPanel',
        title: titlelabel//, //AimState["Task"].WorkFlowName + "->" + AimState["Task"].ApprovalNodeName
        //html: '<iframe id="frameTrack" src="/WorkFlow/FlowTrack2.aspx?flowId=' + AimState["InstanceId"] + '" height="80" width="100%" frameborder="1" border="1"></iframe>'
    });

    formUrl = formUrl.indexOf("?") > 0 ? formUrl + "&InFlow=T&TaskId=" + taskId : formUrl + "?InFlow=T&TaskId=" + taskId;
    viewport = new Ext.Viewport({
        layout: 'border',
        items: [tlBarTitle, actionPanel,
                    {
                        region: 'center',
                        margins: '0 0 0 0',
                        layout: 'border',
                        bodyStyle: 'background:#f1f1f1',
                        border: false,
                        items: [tlBar, {
                            region: 'center',
                            border: false,
                            html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src = "' + formUrl + '"></iframe>'
}]
}]
    });
    ToolBarToggle();
    //window.setTimeout("ToolBarToggle();actionPanel.toggleCollapse(false);", 4000);
    new Ext.ToolTip({
        target: 'auditOpinion',
        html: '点击填写审批意见'
    });
    mask.hide();
    if (AimState["Task"].Status != "0") {
        tlBar.hide();
    }
}
function ToolBarToggle() {
    panel.toggleCollapse(false);
    panel.collapsed ? panel.el.dom.parentNode.style.display = 'none' : panel.el.dom.parentNode.style.display = '';
    setTimeout("viewport.doLayout()", 100);
}

function InitTraceBar() {
    var tasks = eval(AimState["Tasks"]);
    var items = [];
    var item;
    var i = 1;
    var istep = 1;
    var tempName = "";
    $.each(tasks, function() {
        var finishT = this.FinishTime == null ? "[未完成]" : this.FinishTime;
        var viewT = this.UpdatedTime == null ? "[未签收]" : this.UpdatedTime;
        if (finishT != "[未完成]" && viewT == "[未签收]") {
            viewT = finishT;
        }
        var state = "未签收";
        if (viewT != "[未签收]")
            state = "已签收审批中";
        if (finishT != "[未完成]")
            state = "已完成";
        var result = "";
        if (this.Result)
            result = this.Result.split(" ")[1];
        switch (result) {
            case "同意":
                result = "同意。";
                break;
            case "不同意":
                result = "不同意。";
                break;
            default:
                result = "";
                break;
        }
        var deptName = this.DeptName == null ? "" : "部门:" + this.DeptName;
        var isFinish = this.Status;
        if (tempName == this.ApprovalNodeName) {
            //item.html = item.html.replace("<ul><li>执行人:", "<ul><li>执行人:" + this.Owner + ",");
            item = new Ext.Panel({
                frame: true,
                title: '第' + istep + '步 ' + this.ApprovalNodeName,
                bodyStyle: isFinish == "0" ? "background-color:yellow;" : "",
                collapsible: true,
                titleCollapse: true,
                iconCls: 'task',
                html: '<ul><li>执行人: ' + this.Owner + ' &nbsp;&nbsp;' + deptName + '</li><li>状态: ' + state + '</li><li>发送时间: ' + this.CreatedTime + '</li><li>签收时间: ' + viewT + '</li><li>办结时间: ' + finishT + '</li><li>审批意见: ' + result + " " + this.Description + '</li></ul>'
            });
        }
        else {
            item = new Ext.Panel({
                frame: true,
                title: '第' + istep + '步 ' + this.ApprovalNodeName,
                bodyStyle: isFinish == "0" ? "background-color:yellow;" : "",
                collapsible: true,
                titleCollapse: true,
                iconCls: 'task',
                html: '<ul><li>执行人: ' + this.Owner + ' &nbsp;&nbsp;' + deptName + '</li><li>状态: ' + state + '</li><li>发送时间: ' + this.CreatedTime + '</li><li>签收时间: ' + viewT + '</li><li>办结时间: ' + finishT + '</li><li>审批意见: ' + result + " " + this.Description + '</li></ul>'
            });
            istep++;
        }
        items.push(item);
        tempName = this.ApprovalNodeName;
        i++;
    });
    if (tasks[tasks.length - 1].Status != "0") {
        items.push(new Ext.Panel({
            frame: true,
            title: '流程结束',
            bodyStyle: i == tasks.length && isFinish != "0" ? "background-color:yellow;" : "",
            collapsible: true,
            titleCollapse: true,
            iconCls: 'task',
            html: '<ul><li>结束时间: ' + tasks[tasks.length - 1].FinishTime + '</li></ul>'
        }));
    }
    actionPanel = new Ext.Panel({
        id: 'panelTrace',
        region: 'east',
        iconCls: 'flow',
        title: '流程步骤跟踪',
        contentEl: 'west',
        split: true,
        collapsible: true,
        collapsed: false,
        width: 210,
        autoScroll: true,
        minWidth: 150,
        maxWidth: 300,
        border: true,
        items: items
    });
    return actionPanel;
}
function ShowMask() {
    mask.show();
}
function HideMask() {
    mask.hide();
}

function printpreview() {
    // 打印页面预览
    try {
        document.getElementById("WebBrowser").ExecWB(7, 1);
    }
    catch (e) {
        window.print();
    }
}
var trackCollapased = true;
function ChangeTrackHeight() {
    OpenWin("/WorkFlow/FlowTrack2.aspx?flowId=" + AimState["InstanceId"], "_blank", CenterWin("width=1000,height=400,scrollbars=yes"));
    return;
    if (trackCollapased) {
        Ext.getCmp("northPanel").setHeight("250");
        document.getElementById("frameTrack").height = "230";
        trackCollapased = false;
        document.getElementById("tdTrackText").innerText = "折叠流程跟踪";
        setTimeout("viewport.doLayout()", 100);
    }
    else {
        Ext.getCmp("northPanel").setHeight("100");
        document.getElementById("frameTrack").height = "70";
        trackCollapased = true;
        document.getElementById("tdTrackText").innerText = "展开流程跟踪";
        setTimeout("viewport.doLayout()", 100);
    }
}


//分发
function AddSendNode(btn) {
    userIds = ""; userNames = "";
    var style = "dialogWidth:750px; dialogHeight:550px; scroll:yes; center:yes; status:no; resizable:yes;";

    var params = [];

    var url = $.combineQueryUrl("/CommonPages/Select/UsrSelect/MUsrSelect.aspx?rtntype=array&seltype=multi", params)
    var rtn = window.showModalDialog(url, window, style);

    if (rtn && rtn.result) {
        if (rtn.result == 'success') {
            var uids = [];
            var usrs = rtn.data;
            $.each(usrs, function() {
                if (this.UserID) {
                    userIds = userIds + this.UserID + ",";
                    userNames = userNames + this.Name + ",";
                }
            });
            if (userIds == "") { HideMask(); return; }
            var text = $("#id_SubmitState").val().replace("(" + $("#id_SubmitStateH").val() + ")", "")
            $.ajaxExec('submitAddTask', { FlowDefineId: flowDefineId, TaskId: taskId, UserIds: userIds, UserNames: userNames }, function() { ShowMessage("已成功分发!"); });
        }
    }
}