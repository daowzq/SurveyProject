<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Welfare_BXTab.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.Welfare_BXTab" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .x-panel-body x-form
        {
            height: 0px;
        }
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            // 初始化tooltip
            Ext.apply(Ext.QuickTips.getQuickTip(), { dismissDelay: 0 });
            tabs = ["未处理", "已处理"];
            tabArray = [];
            for (var a = 0; a < tabs.length; a++) {
                var tab = {
                    title: tabs[a],
                    tooltip: a,
                    listeners: { activate: handleActivate },
                    autoScroll: true,
                    border: false,
                    layout: 'border',
                    html: "<div style='display:none;'></div>"
                };
                tabArray.push(tab);
            }

            tabpanel = new Ext.TabPanel({
                enableTabScroll: true,
                border: false,
                margins: '0 10 0 0',
                region: 'north',
                activeTab: 0,
                items: [tabArray]
            });

            var viewport = new Ext.ux.AimViewport({

                items: [tabpanel, {
                    region: 'center',
                    border: false,
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
}]
                });
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = "Welfare_Child.aspx?type=n";
                }
            }

            function handleActivate(tab) {
                if (document.getElementById("frameContent")) {
                    switch (tab.title) {
                        case "未处理":
                            frameContent.location.href = "Welfare_Child.aspx?type=n";
                            break;
                        case "已处理":
                            frameContent.location.href = "Welfare_Child.aspx?type=y";
                            break;
                    }
                }
            }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
