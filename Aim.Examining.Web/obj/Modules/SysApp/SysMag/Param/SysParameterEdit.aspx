
<%@ Page Title="系统参数" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true" CodeBehind="SysParameterEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.SysParameterEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var DataTypeEnum = { '': '请选择...', 'String': 'String', 'Int32': 'Integer', 'Boolean': 'Boolean', 'Decimal': 'Decimal', 'Double': 'Double', 'DateTime': 'DateTime' };
        var cid;

        function onPgLoad() {
            cid = $.getQueryString({ ID: "cid", DefaultValue: "" });
        
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c" || pgOperation == "cs") {
                $("#CreaterName").val(AimState.CreaterName);
                $("#CreatedDate").val(AimState.CreatedDate);
                $("#CatalogID").val(cid);
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
    <div id="header"><h1>系统参数</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="ParameterID" name="ParameterID" />
                        <input id="CatalogID" name="CatalogID" />
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
                        值
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Value" name="Value" class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        值类型
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="Type" name="Type" aimctrl='select' enum="DataTypeEnum" class="validate[required]" style="width: 150px"></select>
                    </td>
                </tr>
                 <tr>
                    <td class="aim-ui-td-caption">
                        描述
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Description" rows="5"  style=" width:98%"></textarea>
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


