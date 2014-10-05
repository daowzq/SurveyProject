
<%@ Page Title="动态权限分类" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true" CodeBehind="DAuthCatalogEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DAuthCatalogEdit" %>

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

            if (pgOperation == 'r') {
                $('#opformat').css("display", "none");
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
    <div id="header"><h1>动态权限分类</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="DynamicAuthCatalogID" name="DynamicAuthCatalogID" />
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
                        操作类型
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <label id="opformat">格式：[{Code:操作编码1,Name:操作名1,IsDefault:true},...]<br /></label>
                        <textarea id="AllowOperation" name="AllowOperation" rows="3" class="validate[required]" style="width:90%"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        允许授权类型
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input aimctrl='popup' readonly id="AllowGrantCatalogName" name="AllowGrantCatalogName" style="width:90%"
                            popurl="DPermissionCatalogSelect.aspx?seltype=multi"
                            popparam="AllowGrantCatalogName:Name;AllowGrantCatalogCode:Code" popstyle="width=450,height=500" />
                        <input type="hidden" id="AllowGrantCatalogCode" name="AllowGrantCatalogCode" style="width:90%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        自定义授权地址
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CustomGrantUrl" name="CustomGrantUrl" style="width:90%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        描述
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Description" name="Description" rows="5" style=" width:90%"></textarea>
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


