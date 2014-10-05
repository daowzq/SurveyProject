<%@ Page Title="员工申诉" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="UsrAppealListEdit.aspx.cs" Inherits="Aim.Examining.Web.UsrAppealListEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
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
        .aim-ui-td-caption
        {
            width: 15% !important;
        }
        .aim-ui-td-data
        {
            width: 35% !important;
        }
    </style>

    <script src="../js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        var id = $.getQueryString({ ID: 'id' }) || '';
        var op = $.getQueryString({ ID: 'op' }) || "r";
        var InFlow = $.getQueryString({ ID: "InFlow" });
        var LinkView = $.getQueryString({ ID: "LinkView" });

        function onPgLoad() {
            stateInit();
            setPgUI();
            if (window.parent.AimState["Task"]) {
                taskName = window.parent.AimState["Task"].ApprovalNodeName;
            }

            if (InFlow == "T" || LinkView == "T") {
                IniOpinion();
            }
        }

        function setPgUI() {
            //暂存
            FormValidationBind('btnSubmit', function() {
                //当前第一个审批人 HRUsr HR专员
                $.ajaxExecSync("GetAcceptName", { id: $("#Id").val(), taskName: "HRUsr" }, function(rtn) {
                    var UserId = rtn.data.NextUsers["nextUserId"];
                    var UserName = rtn.data.NextUsers["nextUserName"];
                    $("#FristAcceptUserID").val(UserId);
                    $("#FristAcceptUserName").val(UserName);
                });
                AimFrm.submit(pgAction, {}, null, SubFinish);
            });
            //取消
            $("#btnCancel").click(function() {
                window.close();
            });
        }


        function stateInit() {

            if (op != "c") $("#submit").hide();  //隐藏提交

            $("#AppealTypeName option").each(function() {
                $(this).removeAttr("selected");
            }).eq(0).before("<option value='' selected='selected'>请选择..</option>");

            //匿名
            if ($("#Id").val()) {
                if (AimState["frmdata"]["IsNoName"] == "1") {
                    $("#UserName").parent().parent().hide();
                    $("#UserId,#UserName,#WorkNo").val("");
                }
            }
            $("#IsNoName").click(function() {
                if ($(this).attr("checked")) {
                    $("#UserName").parent().parent().hide();
                }
                else {
                    $("#UserName").parent().parent().show();
                }
            });

            //流程审批
            $("#submit").click(function() {

                var Id = $("#Id").val();
                var UserId = "";
                var UserName = "";

                //当前第一个审批人 HRUsr HR专员
                $.ajaxExecSync("GetAcceptName", { id: $("#Id").val(), taskName: "HRUsr" }, function(rtn) {
                    UserId = rtn.data.NextUsers["nextUserId"];
                    UserName = rtn.data.NextUsers["nextUserName"];
                });

                if (!UserId) {
                    AimDlg.show("系统暂未配置申诉审批受理人!");
                    return;
                }

                if (confirm("确认提交申诉吗？")) {
                    Ext.getBody().mask("提交中,请稍后...");

                    AimFrm.submit("Submit", { id: Id, UserId: UserId, UserName: UserName }, null, function(rtn) {
                        AutoExecuteFlow(rtn);
                    });
                }
            });

        }

        function AutoExecuteFlow(rtn) {

            var NextInfo = rtn.data.NextInfo;
            var task = new Ext.util.DelayedTask();
            task.delay(800, function() {
                jQuery.ajaxExec('AutoExecuteFlow', { NextInfo: NextInfo }, function(rtn) {
                    Ext.getBody().unmask();
                    AimDlg.show("提交成功！");
                    SubFinish();
                });
            });
        }

        function SubFinish(args) {
            RefreshClose();
        }


        function achievevalue(rtn) {
            $.ajaxExec("select", { "UserId": rtn.data.UserID }, function(rtn) {
                if (rtn.data.getUserByWo[0])
                    $("#WorkNo").val(rtn.data.getUserByWo[0].WorkNo);
                //$("#Dept").val(rtn.data.getUserByWo[0].WorkNo);
            })
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
                    td.innerHTML = '<textarea rows="2" disabled style="width: 97%; ">' + Description + '</textarea>';
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
        function onGiveUsers(nextName) {        //在此处理选人
            var users = { UserIds: "", UserNames: "" };
            var approve = {
                '申诉人': "AppealUsr",
                "HR专员": "HRUsr",
                "一级组织负责人": "CompanyLeader",
                "HR经理": "HRManager",
                "总部HR专员": "HQHRUser",
                "总部HR经理": "HQHRManager",
                "总部HR总监": 'HQHRMajor'
            }
              
            $.ajaxExecSync("GetNextUsers", { taskName: approve[taskName], id: id, nextName: nextName }, function(rtn) {
                if (rtn.data.NextUsers["nextUserId"]) {
                    users.UserIds = rtn.data.NextUsers["nextUserId"];
                    users.UserNames = rtn.data.NextUsers["nextUserName"];
                }
            });

            return users;
        }

        //流程结束时触发
        function onFinish(task) {
            jQuery.ajaxExec('submitfinish', { id: id, ApproveResult: window.parent.document.getElementById("id_SubmitState").value
            }, function() {
                RefreshClose();
            });
        }
        
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            员工申诉</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                        <input id="FristAcceptUserName" name="FristAcceptUserName" />
                        <input id="FristAcceptUserID" name="FristAcceptUserID" />
                        <input id="DeptName" name="DeptName" />
                        <input type="hidden" id="DeptId" name="DeptId" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        申诉人
                    </td>
                    <td>
                        <!-- <input aimctrl='user' id="UserName" name="UserName" readonly relateid="UserId"
                        popafter="achievevalue" />-->
                        <input id="UserName" name="UserName" readonly="readonly" />
                        <input id="UserId" name="UserId" type="hidden" />
                    </td>
                    <td class="aim-ui-td-caption">
                        工号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="WorkNo" name="WorkNo" style="width: 90%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        申诉类型
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <select id="AppealTypeName" class="validate[required]" name="AppealTypeName" enum='AimState["AppealTypeName"]'
                            aimctrl="select" style="width: 31%">
                        </select>
                    </td>
                    <!--    <td class="aim-ui-td-caption">
                        是否匿名
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="IsNoName" name="IsNoName" type="checkbox" value="1" />
                    </td>-->
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        标题
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="Title" name="Title" style="width: 96%" class="validate[required]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        所在组织
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CompanyName" name="CompanyName" style="width: 96%" readonly="readonly" />
                        <input type="hidden" id="CompanyId" name="CompanyId" />
                    </td>
                </tr>
                <!--
                <tr>
                    <td class="aim-ui-td-caption">
                        所在部门
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="DeptName" name="DeptName" readonly="readonly" aimctrl="popup" popurl="/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=single"
                            popparam="DeptId:GroupID;DeptName:Name" popstyle="width=320,height=400" style="width: 91%" />
                        <input type="hidden" id="DeptId" name="DeptId" />
                    </td>
                </tr>-->
                <%--                <tr style="display: none">
                    <td class="aim-ui-td-caption">
                        所在岗位
                    </td>
                    <td class="aim-ui-td-data" colspan="2">
                        <select id="PostName" name="PostName" aimctrl='select' style="width: 96%">
                        </select>
                    </td>
                </tr>--%>
                <tr>
                    <td class="aim-ui-td-caption">
                        申诉事由
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="AppealReason" name="AppealReason" rows="10" style="width: 96%" cols="20"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        附件
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="AddFiles" name="AddFiles" aimctrl="file" style="width: 100%"></textarea>
                    </td>
                </tr>
                <%--                  <tr>
                    <td class="aim-ui-td-caption">
                        申诉时间
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CreateTime" name="CreateTime" type="text" class="validate[required] Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})" />
                    </td>
                </tr>--%>
                <%--                <tr>
                    <td class="aim-ui-td-caption">
                        <b>说明</b>
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <span style="color=red">当前申诉受理人为HR专员:&nbsp;&nbsp;</span><span id="AcceptName"></span>
                    </td>
                </tr>--%>
                <%--                <tr class="submitHide">
                    <td class="aim-ui-td-caption" style="width: 30%">
                        申诉受理人
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="UserId1" name="UserId1" type="hidden" />
                        <input id="UserName1" name="UserName1" aimctrl='user' seltype="single" relateid="UserId1" />
                    </td>
                </tr>--%>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="submit" class="aim-ui-button">提交</a> <a id="btnSubmit" class="aim-ui-button submit">
                            暂存</a> <a id="btnCancel" class="aim-ui-button cancel">取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <fieldset id="examfield" style="display: none">
        <legend>审批意见区</legend>
        <table width="100%" id="tbOpinion" style="font-size: 12px; border: none;" class="aim-ui-table-edit">
        </table>
    </fieldset>
</asp:Content>
