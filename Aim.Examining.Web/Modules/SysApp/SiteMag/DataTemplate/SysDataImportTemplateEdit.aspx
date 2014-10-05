
<%@ Page Title="数据导入模版" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true" CodeBehind="SysDataImportTemplateEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.SysDataImportTemplateEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c" || pgOperation == "cs") {
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
    <div id="header"><h1>数据导入模版</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="DataImportTemplateID" name="DataImportTemplateID" />
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
                    <td class="aim-ui-td-caption">模版文件</td>
                    <td class="aim-ui-td-data" valign="top" colspan="3">
                        <input id="TemplateFileID" name="TemplateFileID" class="validate[required]" aimctrl='file' mode="single" Filter="Excel文件 (*.xls;*.xlsx)|*.xls;*.xlsx" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">描述</td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Description" name="Description" style="width: 95%; height:80px"></textarea>
                    </td>
                </tr>
                <tr width="100%">
                    <td class="aim-ui-td-caption" >
                        录入人
                    </td>
                    <td class="aim-ui-td-data">
                        <input disabled id="CreaterName" name="CreaterName" />
                    </td>
                    <td class="aim-ui-td-caption" >
                        录入日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input disabled id="CreatedDate" name="CreatedDate" />
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


