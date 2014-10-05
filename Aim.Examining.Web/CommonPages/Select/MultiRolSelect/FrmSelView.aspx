<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmSelView.aspx.cs" Inherits="Aim.Examining.Web.MySelf.FrmSelView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">

        var tabArr = [{ title: "角色", href: "FrmRoleSelView.aspx" },
        { title: "人员", href: "FrmUsrSelView.aspx"}];

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
                margins: '0 0 0 0',
                deferredRender: false,
                activeTab: 0,
                width: document.body.offsetWidth - 5,
                height: 29,
                frame: false,
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
                        //html: '<iframe width="100%" height="100%" frameborder="0" src="FrmRoleSelView.aspx"></iframe>'
                        html: '<div id="divtab1" style="width:100%; height:100%; "><iframe width="100%" height="100%" Id="frame0" frameborder="0" src="FrmRoleSelView.aspx"></iframe></div>' +
                        '<div id="divtab2" style="width:100%; height:100%; display:none; "><iframe width="100%" height="100%" Id="frame1" frameborder="0" src="FrmUsrSelView.aspx"></iframe></div>'
}]
            });
        }

        function handleActivate(tab) {
//            if (document.getElementById("frameRole")) {
//                document.getElementById("frameRole").src = tab.href;
//            }

            if (document.getElementById("divtab1") && document.getElementById("divtab2")) {
                try {
                    if (tab.id.indexOf('3') > 0) {
                        document.getElementById("divtab1").style.display = "block";
                        document.getElementById("divtab2").style.display = "none";
                    }
                    else {
                        document.getElementById("divtab2").style.display = "block";
                        document.getElementById("divtab1").style.display = "none";
                    }
                } catch (ex) {
                    //alert(ex.message);
                } 
            }
        }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;" ></div>
</asp:Content>
