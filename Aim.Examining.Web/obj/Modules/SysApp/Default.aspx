<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

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
            accordion = new Ext.Panel({
                collapsible: true,
                title: "系统维护",
                region: 'west',
                margins: '0 10 10 0',
                split: false,
                width: 200,
                layout: 'accordion',
                layoutConfig: {
                    animate: true
                },
                items: []
            });

            initAccordion(accordion);

            viewport = new Ext.Viewport({
                layout: 'border',
                items: [
                    accordion, {
                        region: 'center',
                        margins: '0 10 10 0',

                        cls: 'empty',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src="/home.aspx"></iframe>'
}]
            });

        }

        // 初始化右面板
        function initAccordion(accordion) {
            var mdls = AimState["Mdls"];

            $.each(mdls, function(i) {
                if (this["IsTop"]) {
                    var item = new Ext.Panel({
                        title: "<b>" + this["Name"] + "<b>",
                        html: getChildList(mdls, this["ModuleID"]),
                        cls: 'accordion-nav'
                    });

                    accordion.add(item);
                }
            });
        }

        var itemTemplage = "<li><a href='{Url}' target='frameContent'>{Title}</a></li>";
        function getChildList(mdls, pid) {
            var html = "";
            $.each(mdls, function(i) {
                if (this["ParentID"] === pid && this["IsLeaf"] == true) {
                    html += itemTemplage.replace("{Url}", this["Url"]).replace("{Title}", this["Name"]);
                }
            });

            return html;
        }

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            人员选择</h1>
    </div>
</asp:Content>
