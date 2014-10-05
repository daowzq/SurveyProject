<%@ Page Title="涉及组织" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="Tab_SurveyOrg.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Tab_SurveyOrg" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #F2F2F2;
        }
        fieldset
        {
            margin: 15px;
            width: 100%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .x-panel-body x-form
        {
            height: 0px;
        }
    </style>

    <script type="text/javascript">

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

        }

        
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
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
                        调查对象
                    </td>
                    <td class="aim-ui-td-data">
                        <textarea name="SurveyOrgNames" id="SurveyOrgNames" rows="6" style="width: 85%"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        查看对象
                    </td>
                    <td class="aim-ui-td-data">
                        <textarea name="ViewOrgNames" id="SurveyOrgNames" rows="6" style="width: 85%"></textarea>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
