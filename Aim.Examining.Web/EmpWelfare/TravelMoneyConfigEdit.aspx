<%@ Page Title="旅游金" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="TravelMoneyConfigEdit.aspx.cs" Inherits="Aim.Examining.Web.TravelMoneyConfigEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <script type="text/javascript">
        var id = $.getQueryString({ ID: "id" }) || "";
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c" || pgOperation == "cs") {
                $("#CreateName").val(AimState.UserInfo.Name);
                $("#CreateTime").val(jQuery.dateOnly(AimState.SystemInfo.Date));
            }
            if (id) {
                if (AimState["frmdata"]["HaveUsed"]) {
                    $("input[name='HaveUsed']").each(function () {
                        if ($(this).val() == AimState["frmdata"]["HaveUsed"]) {
                            $(this).attr("checked", true)
                        }
                    })
                }
                if (AimState["frmdata"]) {
                    $("input[name='Money']").val(AimState["frmdata"]["Money"] || 0);
                    var Cmp = Ext.getCmp("UserNameusersel");
                    if (Cmp) {
                        Cmp.disable();
                    }
                }
            }


            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function () {
                window.close();
            });
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);
        }

        function SubFinish(args) {
            RefreshClose();
        }

        function achievevalue(rtn) {
            $.ajaxExec("SelectVal", { "UserId": rtn.data.UserID }, function (rtn) {
                if (rtn.data.RtnVal) {
                    var arr = (rtn.data.RtnVal + "").split("|");
                    $("#WorkNo").val(arr[0] || "");
                    $("#Corp").val(arr[1] || "");
                    $("#CorpName").val(arr[2] || "");
                    $("#Indutydate").val(arr[3] || "");

                    if (!id) {
                        $("#Money").val(arr[4] || "");
                        $("#BaseMoney").val(arr[5] || "");
                    }
                }

            })
        }
    </script>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Indutydate" name="Indutydate" />
                        <input id="Id" name="Id" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        姓名
                    </td>
                    <td class="aim-ui-td-data">
                        <input aimctrl='user' id="UserName" name="UserName" popafter='achievevalue' relateid='UserId'
                            class="validate[required]" />
                        <input type="hidden" id="UserId" name="UserId" />
                    </td>
                    <td class="aim-ui-td-caption">
                        工号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="WorkNo" name="WorkNo" class="validate[required]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        服务年限奖励金
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Money" name="Money" class="validate[required custom[onlyNumber]]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        是否使用
                    </td>
                    <td class="aim-ui-td-data">
                        <input type="radio" name="HaveUsed" id="HaveUsed_Y" value="Y" />是
                        <input type="radio" name="HaveUsed" id="HaveUsed_N" value="N" checked="checked" />否
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        旅游基本津贴
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="BaseMoney" name="BaseMoney" disabled="disabled" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        公司
                    </td>
                    <td colspan="3">
                        <input id="CorpName" name="CorpName" disabled="disabled" style="width: 100%" />
                        <input id="Corp" name="Corp" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        <font color="red">说明</font>
                    </td>
                    <td colspan="3">
                        <span>"系统年限奖励金": 累积后的服务年限奖励金</span>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSubmit" class="aim-ui-button submit">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                            取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
