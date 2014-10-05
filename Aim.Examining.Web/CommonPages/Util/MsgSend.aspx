
<%@ Page Title="发送消息" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true" CodeBehind="MsgSend.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.MsgSend" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">

        var op, recdisable, titledisable;

        function onPgLoad() {
            op = $.getQueryString({ 'ID': 'op' });
            recdisable = $.getQueryString({ 'ID': 'recdisable', 'DefaultValue': false });
            titledisable = $.getQueryString({ 'ID': 'titledisable', 'DefaultValue': false });

            title = $.getQueryString({ 'ID': 'title', 'DefaultValue': '' });
            content = $.getQueryString({ 'ID': 'content', 'DefaultValue': '' });
            attachment = $.getQueryString({ 'ID': 'attachment', 'DefaultValue': '' });
            receiverids = $.getQueryString({ 'ID': 'receiverids', 'DefaultValue': '' });
            receivernames = $.getQueryString({ 'ID': 'receivernames', 'DefaultValue': '' });

            setPgUI();
        }

        function setPgUI() {
            if (op == 'c' || op == 'cs') {
                $('#Title').val(title);
                $('#MessageContent').val(content);
                $('#Attachment').val(attachment);
                $('#ReceiverId').val(receiverids);
                $('#ReceiverName').val(receivernames);
            }

            if (recdisable && (recdisable == '1' || recdisable == 'true')) {
                AimCtrl['ReceiverName'].setDisabled(true);
            }

            if (titledisable && (titledisable == '1' || titledisable == 'true')) {
                $('#Title').attr('disabled', true);
            }


            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);
        }

        function SubFinish(args) {
            window.returnValue = args;
            window.close();
        }
        
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>消息</h1></div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit" border="0">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">标题</td>
                    <td class="aim-ui-td-data">
                        <input id="Title" name="Title" class="validate[required] text-input" style="width: 90%" />
                    </td>
                </tr>
                 <tr>
                    <td class="aim-ui-td-caption">接收人</td>
                    <td class="aim-ui-td-data">
                        <input aimctrl='popup' readonly id="ReceiverName" name="ReceiverName" relateid="ReceiverId"
                            popurl="/CommonPages/Select/UsrSelect/MUsrSelect.aspx?seltype=multi" 
                            popparam="ReceiverId:UserID;ReceiverName:Name" popstyle="width=600,height=450"
                            class="validate[required] text ui-widget-content" style="width: 90%"/>
                        <input type="hidden" id="ReceiverId" name="ReceiverId" class="text ui-widget-content" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">文件</td>
                    <td class="aim-ui-td-data" valign="top">
                        <input id="Attachment" name="Attachment" aimctrl='file' value="" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">内容</td>
                    <td class="aim-ui-td-data">
                        <textarea id="MessageContent" name="MessageContent" style="width: 90%; height:200px"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="2">
                        <a id="btnSubmit" class="aim-ui-button submit">发送</a>
                        <a id="btnCancel" class="aim-ui-button cancel">取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>


