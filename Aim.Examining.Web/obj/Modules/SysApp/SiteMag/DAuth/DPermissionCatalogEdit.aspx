
<%@ Page Title="动态授权类别" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true" CodeBehind="DPermissionCatalogEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DPermissionCatalogEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == 'c' || pgOperation == 'cs') {
                $('#Editable').attr('checked', true);
                $('#Editable').attr('disabled', false);
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
            RefreshClose();
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>动态授权类别</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="DynamicPermissionCatalogID" name="DynamicPermissionCatalogID" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        编码
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Code" name="Code" class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        名称
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Name" name="Name" class="validate[required]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        编辑状态
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <label for="Editable">可编辑</label>&nbsp;
                        <input id="Editable" name="Editable" type="checkbox" disabled="true" value=true onclick=""/>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        正向授权URL
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="PositiveGrantUrl" name="PositiveGrantUrl" style="width:90%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        反向授权URL
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="OppositeGrantUrl" name="OppositeGrantUrl" style="width:90%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        描述
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Description" name="Description" rows="5"  style=" width:90%"></textarea>
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


