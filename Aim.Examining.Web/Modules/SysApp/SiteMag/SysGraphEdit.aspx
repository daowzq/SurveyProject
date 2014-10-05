<%@ Page Title="系统图表" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true" CodeBehind="SysGraphEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SiteMag.SysGraphEdit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EnumType = { 1: "启用", 0: "停用" };
        
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c") {
                $("#CreaterName").val(AimState.CreaterName);
                $("#CreatedDate").val(AimState.CreatedDate);
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
    <div id="header"><h1>系统图表维护</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="GraphID" name="GraphID" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        编码
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Code" style=" width:200"  name="Code" class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        标题
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Title" style=" width:200"  name="Title" class="validate[required]" />
                    </td>
                </tr>
               <tr>
                    <td class="aim-ui-td-caption">
                        文件
                    </td>
                    <td colspan=3 class="aim-ui-td-data">
                        <input id="FileID" name="FileID" aimctrl='file' mode="single" value="" class="validate[required]" />
                    </td>
                    </tr>
                <tr>
                      <td class="aim-ui-td-caption">
                        详细说明
                    </td>
                    <td  colspan=3 class="aim-ui-td-data">
                        <textarea id="Description" rows="5"  style=" width:98%"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                       创建人
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="CreaterName" disabled name="CreaterName" class="text ui-widget-content" />
                    </td>
                     <td class="aim-ui-td-caption">
                       创建日期
                    </td>
                     <td class="aim-ui-td-data">
                        <input id="CreatedDate" disabled name="CreatedDate" class="text ui-widget-content" />
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
