
<%@ Page Title="属性编辑" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true" CodeBehind="OrgStructureEdit.aspx.cs" Inherits=" Aim.Examining.Web.OrgStructureEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">

        var DataTypeEnum = {'1': '启用', '2': '停用'};

        var id = null;

        function onPgLoad() {
            id = $.getQueryString({ ID: 'id' });
        
            setPgUI();
        }

        function setPgUI() {            
            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
            if ($.getQueryString({ ID: "op" }) == 'cs') {
                $("[class*=aim-ui-button submit]").show();
            }
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);
        }

        function SubFinish(args) {
            Aim.PopUp.ReturnValue({ id: id, op: pgOperation });
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>属性编辑</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="GroupID" name="GroupID" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        名称
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Name" name="Name" class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        编码
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Code" name="Code" class="validate[required]" />
                    </td>
                </tr>
                 <tr>
                    <td class="aim-ui-td-caption">
                        状态
                    </td>
                    <td class="aim-ui-td-data"> 
                        <select id="Status" name="Status" aimctrl='select' enum="DataTypeEnum" class="validate[required]" style="width: 150px"></select>
                    </td>
                    <td class="aim-ui-td-caption">
                       排序号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="SortIndex" name="SortIndex" class="validate[custom[onlyInteger]]" value=0 />
                       <input type=hidden id=Type value=2 />
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


