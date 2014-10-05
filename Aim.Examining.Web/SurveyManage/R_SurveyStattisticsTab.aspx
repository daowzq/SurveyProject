<%@ Page Title="选项统计" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="R_SurveyStattisticsTab.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.R_SurveyStattisticsTab" %>

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

            tabs = ["一般问卷", "常用问卷"] || [];
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
                margins: '0 11 0 0',
                region: 'north',
                activeTab: 0,
                heigth: 50,
                items: [tabArray]
            });


            var viewport = new Ext.ux.AimViewport({
                items: [tabpanel, {
                    region: 'center',
                    border: false,
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'}]
                });
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = "T_SurveyStatisticList.aspx?Index=0"
                }
            }

            function handleActivate(tab) {
                if (document.getElementById("frameContent")) {
                    if (tab.title == "常用问卷") {
                        frameContent.location.href = "R_SurveyNormalStatistics.aspx?Index=0";
                    } else if (tab.title == "一般问卷") {
                        frameContent.location.href = "T_SurveyStatisticList.aspx?Index=0" + "&op=" + pgOperation;
                    }
                }
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
