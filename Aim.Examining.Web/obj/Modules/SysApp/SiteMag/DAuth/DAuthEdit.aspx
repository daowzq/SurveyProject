
<%@ Page Title="动态权限" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true" CodeBehind="DAuthEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DynamicAuthEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c" || pgOperation == "cs") {
                if (!$("#DynamicAuthID").val()) {
                    $('#Editable').attr('checked', true);   // 默认可编辑
                    $('#Grantable').attr('checked', true);   // 默认可编辑
                }
                
                $("#DynamicAuthID").val("");
                $("#Name").val("");
                $("#AuthData").val("");
                $('#Editable').attr('disabled', false);
                $('#Grantable').attr('disabled', false);
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
            var data, frmdata;
            if (args && args.data) { frmdata = args.data.frmdata }

            ReturnClose(frmdata || {});
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>动态权限</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="DynamicAuthID" name="DynamicAuthID" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        名称
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="Name" name="Name" class="validate[required]" style="width:98%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        类别编码
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CatalogCode" name="CatalogCode" disabled />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        编辑状态
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <label for="Editable">可编辑</label>&nbsp;
                        <input id="Editable" name="Editable" type="checkbox" disabled="true" value=true onclick=""/>
                        &nbsp;&nbsp;&nbsp;&nbsp;
                        <label for="Grantable">可授权</label>&nbsp;
                        <input id="Grantable" name="Grantable" type="checkbox" disabled="true" value=true onclick=""/>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        数据
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Data" name="Data" rows="3" style="width:98%"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        附加数据
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="Tag" name="Tag" style="width:98%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSubmit" class="aim-ui-button submit">提交</a>
                        <a id="btnCancel" class="aim-ui-button cancel">取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>


