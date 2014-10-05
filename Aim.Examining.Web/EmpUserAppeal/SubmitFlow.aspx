<%@ Page Title="流程提交" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="SubmitFlow.aspx.cs" Inherits="Aim.Examining.Web.EmpUserAppeal.SubmitFlow" %>

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
        var AppealId = $.getQueryString({ ID: "AppealId" }) || "";
        function onPgLoad() {
            stateInit();
            setPgUI();
        }

        function setPgUI() {

            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);
            $("#btnCancel").click(function() {
                window.close();
            });
        }

        function stateInit() {

            //var task = new Ext.util.DelayedTask();
            $(".submitHide").hide();
            $("#AppealId").val(AppealId);

            AimState["Treaty"] && $("#Treaty").append(AimState["Treaty"]);

            $("#agree").click(function() {//同意
                $(".submitHide").show();
                $(this).parent().parent().hide();

            })
            $("#disAgree").click(function() {//不同意
                window.close();
            });

        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            var UserId = $("#UserId1").val();
            var UserName = $("#UserName1").val();
            if (!UserId) {
                AimDlg.show("请选择受理人员!");
                return;
            }

            if (confirm("确认提交申诉？")) {
                Ext.getBody().mask("提交中,请稍后...");
                AimFrm.submit("Submit", { AppealId: AppealId, UserId: UserId, UserName: UserName }, null, AutoExecuteFlow);
            }
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
       
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <table class="aim-ui-table-edit" style="border: none">
        <tr style="display: none">
            <td>
                <input id="Id" name="Id" />
                <input id="AppealId" name="AppealId" />
            </td>
        </tr>
        <tr>
            <td class="aim-ui-td-data" colspan="2">
                <div id="Treaty" name="Treaty" style="width: 100%; height: 80%; border: 1px solid gray;
                    background-color: white">
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center;">
                <a id="agree" class="aim-ui-button">同意</a> <a id="disAgree" class="aim-ui-button">不同意</a>
            </td>
        </tr>
        <tr class="submitHide">
            <td class="aim-ui-td-caption" style="width: 30%">
                申诉受理人
            </td>
            <td class="aim-ui-td-data">
                <input id="UserId1" name="UserId1" type="hidden" />
                <input id="UserName1" name="UserName1" aimctrl='user' seltype="single" relateid="UserId1" />
            </td>
        </tr>
        <tr class="submitHide">
            <td class="aim-ui-button-panel" colspan="4">
                <a id="btnSubmit" class="aim-ui-button">提交</a> <a id="btnCancel" class="aim-ui-button cancel">
                    取消</a>
            </td>
        </tr>
    </table>
</asp:Content>
