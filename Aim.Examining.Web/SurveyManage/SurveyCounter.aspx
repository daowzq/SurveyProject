<%@ Page Title="问卷数量" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="SurveyCounter.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyCounter" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            ctrlInit();
            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);
            $("#btnCancel").click(function() {
                window.close();
            });
        }
        function ctrlInit() {
            $("#EffectiveCount").focusout(function(e) {
                if (!$.isInt($(this).val())) {
                    $(this).val("");
                }
            }).keyup(function(e) {
                $(this).val($(this).val().replace(/\D|^0/g, ''));
            }).css("ime-mode", "disabled");

            if ($("#Total").val() && !$("#EffectiveCount").val()) {
                $("#EffectiveCount").val($("#Total").val());
            }
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            var EffectiveCount = $("#EffectiveCount").val();
            if (!$("#Total").val()) {
                if (confirm("该问卷暂未生成调查对象,确认保存有效数量吗？")) {
                    AimFrm.submit("Update", { EffectiveCount: EffectiveCount }, null, SubFinish);
                }
            } else {
                AimFrm.submit("Update", { EffectiveCount: EffectiveCount }, null, SubFinish);
            }
        }

        function SubFinish(args) {
            window.setTimeout(function() {
                window.close();
            }, 200);
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <table class="aim-ui-table-edit">
        <tbody>
            <tr style="display: none">
                <td>
                    <input id="Id" name="Id" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption" style="width: 30%">
                    预计问卷数量
                </td>
                <td class="aim-ui-td-data">
                    <input id="Total" name="Total" disabled="disabled" />&nbsp;&nbsp;份
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    有效问卷数量
                </td>
                <td class="aim-ui-td-data">
                    <input id="EffectiveCount" name="EffectiveCount" class="validate[required]" />&nbsp;&nbsp;份
                </td>
            </tr>
        </tbody>
    </table>
    <table class="aim-ui-table-edit">
        <tbody>
            <tr>
                <td class="aim-ui-button-panel" colspan="4">
                    <a id="btnSubmit" class="aim-ui-button">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                        取消</a>
                </td>
            </tr>
        </tbody>
    </table>
</asp:Content>
