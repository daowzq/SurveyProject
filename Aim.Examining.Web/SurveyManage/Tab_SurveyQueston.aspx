<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="Tab_SurveyQueston.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Tab_SurveyQueston" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';
        function onPgLoad() {
            loadFrame();
        }
        function loadFrame() {
            if (document.getElementById("frameContent")) {
                frameContent.location.href = "InternetSurveyView.aspx?SurveyId=" + SurveyId;
            } else {
                window.setTimeout(loadFrame, 100);
            }
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <iframe id="frameContent" name="frameContent" width="100%" height="100%" frameborder="0">
    </iframe>
</asp:Content>
