<%@ Page Title="员工旅游管理规定" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <script type="text/javascript" src="/js/fckeditor/fckeditor.js"></script>
    <script type="text/javascript">

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            //绑定按钮验证
            //  FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function () {
                window.close();
            });

            $("#agree").click(function () {
                window.returnValue = true;
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div style="color: black; font-size: 12px; font-weight: bold; height: 30px">
        <span><u>请仔细阅读该页面的内容,若同意请点击底部的<font color="red">'我同意'</font> 按钮.</u></span>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr>
                    <td>
                        <div id="TreatyContent" style="text-align: center">
                            <img src="img/003.jpg" width="750" />
                            <img src="img/004.jpg" width="750" />
                            <img src="img/005.jpg" width="750" />
                            <img src="img/006.jpg" width="750" />
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="agree" class="aim-ui-button">我同意</a> <a id="btnCancel" class="aim-ui-button cancel">
                            不同意</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
