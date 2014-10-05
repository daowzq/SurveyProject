<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="TravelConfigTab.aspx.cs" Inherits="Aim.Examining.Web.EmpWelfare.TravelConfigTab" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
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

            tabs = ["旅游地点", "旅游金"] || [];
            tabArray = [];
            for (var a = 0; a < tabs.length; a++) {
                var tab = {
                    title: tabs[a],
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
                region: 'north',
                activeTab: 0,
                margins: '0 0 0 0',
                heigth: 50,
                items: [tabArray]
            });

            var viewport = new Ext.ux.AimViewport({
                border: false,
                items: [tabpanel, {
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
                }]
            });
            if (document.getElementById("frameContent")) {
                frameContent.location.href = "Welfareconfig.aspx?Index=0";
            }
        }

        function handleActivate(tab) {
            if (document.getElementById("frameContent")) {
                if (tab.title == "旅游地点") {
                    frameContent.location.href = "Welfareconfig.aspx";
                } else if (tab.title == "旅游金") {
                    frameContent.location.href = "TravelMoneyConfigList.aspx";
                }
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
