<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="WFChoices.aspx.cs" Inherits="Aim.Examining.Web.EmpWelfare.WFChoices" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .aim-ui-td-caption
        {
            text-align: right;
        }
        body
        {
            background-color: #F2F2F2;
        }
        fieldset
        {
            margin: 10px;
            width: 100%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .righttxt
        {
            text-align: right;
        }
        input
        {
            width: 90%;
        }
        .x-superboxselect-display-btns
        {
            width: 90% !important;
        }
        .x-form-field-trigger-wrap
        {
            width: 100% !important;
        }
    </style>

    <script type="text/javascript">
        var formtype = $.getQueryString({ ID: 'type' }) || "";    //onlyView
        var SurveyId = $.getQueryString({ ID: "SurveyId" }) || "";
        var ApproveRole = {};   //受理角色

        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            // formtype == "onlyView" && $("#explain").hide();

            $("#SurveyId").val(SurveyId);
            $("#UserId1").val() && selectAfter();   //流程呈现

            //审批验证
            var arr = AimState["ChState"].split("|");
            //            if (arr[0] == "1") {
            //                $("#MustApprove").val("1");        //必须审批标志
            //                $("#wfTxt").text("* 该问卷必须审批");

            //                if (arr.length > 3) {
            //                    var temp = "";
            //                    for (var i = 0; i < arr[3].split(",").length; i++) {
            //                        if (i == 0)
            //                            temp += arr[3].split(",")[i] + "</p>";
            //                        else
            //                            temp += "<p>" + arr[3].split(",")[i] + "</p>";
            //                    }
            //                    $("#wfTxt").after(temp ? "<font color=red>,审批对象为:&nbsp;&nbsp;</font>" + temp : temp);
            //                }

            //            } else {
            //                $("#wfTxt").text("* 该问卷可不审批,可以直接发起问卷");
            //            }
            //arr[3] 审批对象

            $("#wfTxt").text("* 该问卷必须审批,请选择审批对象!");

            if (arr[3]) {
                ApproveRole.ApproveRoleId = arr[2] || "";
                ApproveRole.ApproveRoleName = arr[3] || "";
                ApproveRole.ApproveUses = arr[4] || "";
                ApproveRole.ApproveNames = arr[5] || "";
            }

            if ($("#UserId1").val()) {

                var userids = ($("#UserId1").val() + "").split(",");

                var Ids = "( ";
                $.each(userids, function(i) {
                    if (i > 0) Ids += ",";
                    Ids += "'" + this + "'";
                });
                Ids += " )";

                userids && $.ajaxExec("getUserInfo", { userids: Ids }, function(rtn) {
                    $("#approveTr").show();
                    var data = rtn.data.AppUserInfo;
                    var htmlTpl = "";
                    var tempArr = data.split("|");
                    for (var i = 0; i < tempArr.length; i++) {
                        htmlTpl += "<p>" + tempArr[i] + "</p>";
                    }
                    $("#userinfo").append(htmlTpl);

                })
            }

            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            if (!$("#MustApprove").val() && !$("#UserId1").val()) {
                AimDlg.show("该问卷必须审批,请指定审批人!");
                return;
            }

            var action = $("#Id").val() ? "Update" : "Create";
            if (confirm("确认提交吗,一旦提交审批人员则不能修改？")) {
                Ext.getBody().mask("提交中,请稍后...");
                AimFrm.submit(action, { SurveyId: SurveyId, formtype: formtype }, null, AutoExecuteFlow);
            }
        }


        function AutoExecuteFlow(rtn) {
            var NextInfo = rtn.data.NextInfo;
            var task = new Ext.util.DelayedTask();
            task.delay(500, function() {
                jQuery.ajaxExec('AutoExecuteFlow', { NextInfo: NextInfo }, function(rtn) {
                    Ext.getBody().unmask();
                    AimDlg.show("提交成功！");
                    SubFinish();
                });
            });
        }

        //选中后
        function selectAfter(rtn) {
            var userids = "";
            if (rtn) {

                var Ids = "( ";
                $.each(rtn.data, function(i) {
                    if (i > 0) Ids += ",";
                    Ids += "'" + this["UserID"] + "'";
                });
                Ids += " )";

                $.ajaxExec("getUserInfo", { userids: Ids }, function(rtn) {

                    var data = rtn.data.AppUserInfo;
                    var htmlTpl = "";
                    var tempArr = data.split("|");
                    for (var i = 0; i < tempArr.length; i++) {
                        htmlTpl += "<p>" + tempArr[i] + "</p>";
                    }
                    $("#userinfo").children().remove();
                    $("#userinfo").append(htmlTpl);
                    $("#approveTr").show();

                })
            }


            var length = 0;
            window.setTimeout(function() {
                length = $("#UserName1").val().split(",").length;
                length = length > 8 ? 8 : length;
                if (length == 0) return;
                var Url = "/WorkFlow/FlowTrack2.aspx?TemplateCode=" + "questionnaire_" + length;
                frameContent.location.href = Url;
            }, 400);

        }

        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }

        function SubFinish(args) {
            RefreshClose();
        }
       
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <fieldset>
        <legend>审批人</legend>
        <table class="aim-ui-table-edit" style="border: none">
            <tr style="display: none">
                <td>
                    <input id="Id" name="Id" />
                    <input id="SurveyId" name="SurveyId" />
                    <input id="MustApprove" name="MustApprove" />
                </td>
            </tr>
            <tr id="explain">
                <td class="aim-ui-td-caption">
                    流程说明
                </td>
                <td class="aim-ui-td-data">
                    <span id="wfTxt" style="color: Red"></span>
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    审批人
                </td>
                <td class="aim-ui-td-data">
                    <input id="UserId1" name="UserId1" type="hidden" />
                    <input id="UserName1" name="UserName1" aimctrl='user' popafter="selectAfter" style="width: 450px"
                        seltype="multi" relateid="UserId1" />
                </td>
            </tr>
        </table>
    </fieldset>
    <fieldset>
        <legend>流程信息</legend>
        <table class="aim-ui-table-edit">
            <tr id="approveTr" style="display: none">
                <td style="height: 70px; background-color: rgb(213,213,213); border: solid 1px gray">
                    <div style="font-family: Arial 微软雅黑 Verdana; font-size: 12px; margin-left: 2px">
                        <span style="font-size: 11px;"><b>审批人信息</b></span>
                        <table style="font-size: 12px;">
                            <tr>
                                <td id="userinfo">
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="1">
                    </iframe>
                </td>
            </tr>
        </table>
    </fieldset>
    <table class="aim-ui-table-edit" style="border: none">
        <tr>
            <td class="aim-ui-button-panel" colspan="4">
                <a id="btnSubmit" class="aim-ui-button">提交</a> <a id="btnCancel" class="aim-ui-button cancel">
                    取消</a>
            </td>
        </tr>
    </table>
</asp:Content>
