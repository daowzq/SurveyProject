<%@ Page Title="审批流程" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="WorkFlowTab.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.WorkFlowTab" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #F2F2F2;
        }
        fieldset
        {
            margin: 15px 0px 15px 0px;
            width: 100%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .x-panel-body x-form
        {
            height: 0px;
        }
    </style>

    <script type="text/javascript">

        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';
        var op = $.getQueryString({ ID: 'op' }) || '';
        var type = $.getQueryString({ ID: 'type' }) || '';
        var InFlow = $.getQueryString({ ID: "InFlow" });
        var LinkView = $.getQueryString({ ID: "LinkView" });

        function onPgLoad() {
            setPgUI();
            if (window.parent.AimState["Task"]) {
                taskName = window.parent.AimState["Task"].ApprovalNodeName;
            }
            if (InFlow == "T" || LinkView == "T") {
                IniOpinion();
            }
        }

        function setPgUI() {
            // 初始化tooltip
            Ext.apply(Ext.QuickTips.getQuickTip(), { dismissDelay: 0 });
            tabs = ["问卷内容", "涉及组织", "调查对象"];
            tabArray = [];
            for (var a = 0; a < tabs.length; a++) {
                var tab = {
                    title: tabs[a],
                    tooltip: a,
                    listeners: { activate: handleActivate },
                    autoScroll: true,
                    border: false,
                    layout: 'border',
                    html: "<div style='display:none;'></div>"
                };
                tabArray.push(tab);
            }

            tabpanel = new Ext.TabPanel({
                enableTabScroll: true,
                border: true,
                region: 'north',
                activeTab: 0,
                items: [tabArray]
            });

            var viewport = new Ext.ux.AimViewport({
                // layout: 'anchor',
                items: [tabpanel, {
                    //height: 400,
                    // anchor: '100%',
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="68%" id="frameContent" name="frameContent" frameborder="1"></iframe><fieldset id="examfield" style="height:31%; display: none; overflow:scroll;  "> <legend>审批意见区</legend> <table width="100%"  id="tbOpinion" style="font-size: 12px; border: none;" class="aim-ui-table-edit"> </table></fieldset>'
}]
                });
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = "InternetSurvey.aspx?type=read&Id=" + SurveyId + "&op=v";
                    //$("#frameContent").load("InternetSurvey.aspx?type=read&Id=" + SurveyId + "&op=v");
                }
            }

            function handleActivate(tab) {
                if (document.getElementById("frameContent")) {
                    switch (tab.title) {
                        case "问卷内容":
                            frameContent.location.href = "InternetSurvey.aspx?type=read&Id=" + SurveyId + "&op=v";
                            //$("#frameContent").load("InternetSurvey.aspx?type=read&Id=" + SurveyId + "&op=v");
                            break;
                        case "调查对象":
                            frameContent.location.href = "Wizard_Finish.aspx?SurveyId=" + SurveyId + "&op=r";
                            //$("#frameContent").load("Wizard_Finish.aspx?SurveyId=" + SurveyId + "&op=r");
                            break;
                        case "涉及组织":
                            frameContent.location.href = "Tab_SurveyOrg.aspx?SurveyId=" + SurveyId + "&op=r";
                            //$("#frameContent").load("Tab_SurveyOrg.aspx?SurveyId=" + SurveyId + "&op=r");
                            break;
                    }
                }
            }

            function IniOpinion() {

                var tab = document.getElementById("tbOpinion");
                var myData = AimState["Opinion"] || [];
                if (AimState["Opinion"] && AimState["Opinion"].length > 0) {
                    $("#examfield").show();
                    for (var i = 1; i < myData.length; i++) {//从1开始 是为了不显示自动提交的任务
                        var tr = tab.insertRow(); tr.height = 32;
                        var td = tr.insertCell();
                        td.innerHTML = myData[i].ApprovalNodeName ? myData[i].ApprovalNodeName + "意见" : '';
                        td.rowSpan = 2;
                        td.className = "aim-ui-td-caption";
                        td.style.width = "25%";
                        td.style.textAlign = "right";
                        var td = tr.insertCell();
                        var Description = myData[i].Description ? myData[i].Description : '';
                        td.innerHTML = '<textarea rows="2" disabled style="width: 97%;">' + Description + '</textarea>';
                        td.colSpan = 6;
                        var tr = tab.insertRow();
                        var td = tr.insertCell();
                        td.innerHTML = '审批结果:';
                        td.style.width = "100px";
                        var td = tr.insertCell();
                        //不同意,打回,拒绝,退回  如果包含上述文字。结果就是不同意。否则就是同意 
                        if (myData[i].Result && (myData[i].Result.indexOf("不同意") >= 0 || myData[i].Result.indexOf("打回") >= 0 || myData[i].Result.indexOf("拒绝") >= 0) || myData[i].Result.indexOf("退回") >= 0) {
                            td.innerHTML = "不同意";
                        }
                        else {
                            td.innerHTML = "同意";
                        }
                        td.style.textDecoration = "underline";
                        var td = tr.insertCell(); td.innerHTML = '签名:';
                        var td = tr.insertCell();
                        td.innerHTML = '<img style="width: 70px; height: 25px;" src="/CommonPages/File/DownLoadSign.aspx?UserId=' + myData[i].OwnerId + '" />';
                        var td = tr.insertCell(); td.innerHTML = '审批时间:';
                        var td = tr.insertCell();
                        td.innerHTML = myData[i].FinishTime ? myData[i].FinishTime : '';
                        td.style.textDecoration = "underline";
                    }
                }
                if (LinkView != "T") {
                    $("#examfield").show();
                    var tr = tab.insertRow(); tr.height = 32; var td = tr.insertCell();
                    td.innerHTML = taskName + "意见";
                    td.className = "aim-ui-td-caption";
                    td.style.width = "25%"; td.style.textAlign = "right"; var td = tr.insertCell();
                    td.innerHTML = '<textarea id="TaskNameOpinion" name="TaskNameOpinion" style="width: 97%;background-color:rgb(254, 255, 187)"  rows="2"></textarea>';
                    td.colSpan = 6;
                    if (AimState["UnSubmitOpinion"]) {
                        $("#TaskNameOpinion").val(AimState["UnSubmitOpinion"]);
                    }
                }
            }
 
    </script>

    <script language="javascript" type="text/javascript">
        //保存流程和提交流程时触发
        function onSave(task) {
            //SuccessSubmit
            if (window.parent.document.getElementById("textOpinion")) {
                window.parent.document.getElementById("textOpinion").value = $("#TaskNameOpinion").val() ? $("#TaskNameOpinion").val() : "";
            }
        }
        //提交流程时触发
        function onSubmit(task) {
            if ($("#TaskNameOpinion").css("display") == "inline" && !$("#TaskNameOpinion").val()) {
                AimDlg.show("提交时必须填写审批意见！");
                return false;
            }
        }
        function onGiveUsers(nextName) {
            var users = { UserIds: "", UserNames: "" };
            $.ajaxExecSync("GetNextUsers", { taskName: taskName, SurveyId: SurveyId, nextName: nextName }, function(rtn) {
                if (rtn.data.NextUsers["nextUserId"]) {
                    users.UserIds = rtn.data.NextUsers["nextUserId"];
                    users.UserNames = rtn.data.NextUsers["nextUserName"];
                }
            });

            return users;
        }

        //流程结束时触发
        function onFinish(task) {
            jQuery.ajaxExec('submitfinish', { SurveyId: SurveyId, ApproveResult: window.parent.document.getElementById("id_SubmitState").value
            }, function() {
                RefreshClose();
            });
        }
        
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <fieldset id="examfield" style="display: none">
        <legend>审批意见区</legend>
        <table width="100%" id="tbOpinion" style="font-size: 12px; border: none;" class="aim-ui-table-edit">
        </table>
    </fieldset>
</asp:Content>
