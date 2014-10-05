<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="GrpSelect.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.GrpSelect" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var StatusEnum = { '1': '有效', '0': '无效' };

    var viewport;
    var store;
    var grid;
    var accordion;

    function onPgLoad() {
        setPgUI();
    }

    function setPgUI() {
        
    }
    
 </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">

    <div id="header" style="display:none;"><h1>组选择</h1></div>

</asp:Content>
