<%@ Page Title="申诉协议" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="UsrAppealTreatyEdit.aspx.cs" Inherits="Aim.Examining.Web.UsrAppealTreatyEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript" src="/js/fckeditor/fckeditor.js"></script>

    <script type="text/javascript">
        var op = $.getQueryString({ ID: 'op' });
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });

            if (op != 'c') {
                $("#TreatyKey").attr("disabled", true);
            }
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);
        }

        function SubFinish(args) {
            RefreshClose();
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            申诉协议</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        编码
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="TreatyKey" name="TreatyKey" style="width: 30%" class="validate[required]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        协议标题
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="TreatyTitle" name="TreatyTitle" style="width: 80%" class="validate[required]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        协议内容
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="TreatyContent" name="TreatyContent" aimctrl="editor" style="width: 99%;
                            height: 400px"></textarea>
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
