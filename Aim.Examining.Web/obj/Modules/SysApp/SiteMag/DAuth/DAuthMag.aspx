<%@ Page Title="动态权限维护" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DAuthMag.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DAuthMag" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    
<script type="text/javascript">
    var tabArr = [{ title: "动态权限维护", href: "DAuthList.aspx" },
        { title: "动态权限分类", href: "DAuthCatalogList.aspx" },
        { title: "动态授权分类", href: "DPermissionCatalogList.aspx"}];
    
    var viewport = null;
    var tab = null;

    function onPgLoad() {
        setPgUI();
    }

    function setPgUI() {
        $.each(tabArr, function(i) {
            this.listeners = { activate: handleActivate };
            this.html = "<div style='display:none;'></div>";
        });
    
        tab = new Ext.TabPanel({
            region: 'north',
            margins: '30 0 0 0',
            activeTab: 0,
            width: document.body.offsetWidth - 5,
            height: 29,
            items: tabArr
        });

        viewport = new Ext.Viewport({
            layout: 'border',
            items: [
                { xtype: 'box', region: 'north', applyTo: 'header', height: 30 },
                    tab, {
                        region: 'center',
                        margins: '0 0 0 0',
                        cls: 'empty',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src="DAuthList.aspx"></iframe>'
}]
        });
    }

    function handleActivate(tab) {
        if (document.getElementById("frameContent")) {
            document.getElementById("frameContent").src = tab.href;
        }
    }

</script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>动态权限维护</h1></div>
</asp:Content>
