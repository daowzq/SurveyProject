<%@ Page Title="问卷跟踪" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SurveyTraceTab.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyTraceTab" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var tableData, columnData, store, tabs, tlBar, tabpanel;
        var titPanel, grid, viewport;
        var surveyId = $.getQueryString({ ID: 'surveyId' });
        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            // 初始化tooltip
            Ext.apply(Ext.QuickTips.getQuickTip(), { dismissDelay: 0 });

            tabs = ["已提交", "未提交"] || [];
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
                border: true,
                //margins: '0 10 0 0',
                region: 'north',
                activeTab: 0,
                heigth: 50,
                items: [tabArray]
            });


            var viewport = new Ext.ux.AimViewport({
                items: [tabpanel, {
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'}]
                });
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = "SurveyCommitHistoryList.aspx?Index=0&surveyId=" + surveyId;
                }
            }

            function handleActivate(tab) {
                if (document.getElementById("frameContent")) {
                    if (tab.title == "已提交") {
                        frameContent.location.href = "SurveyCommitHistoryList.aspx?op=r&surveyId=" + surveyId;
                    } else if (tab.title == "未提交") {
                        frameContent.location.href = "NoSubmit.aspx?Index=0&surveyId=" + surveyId;
                    }
                }
            }
    </script>

    <script type="text/javascript">
        var tableData, columnData, store, tabs, tlBar, tabpanel;
        var titPanel, grid, viewport;
        var surveyId = $.getQueryString({ ID: 'surveyId' });
        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            // 初始化tooltip
            Ext.apply(Ext.QuickTips.getQuickTip(), { dismissDelay: 0 });

            tabs = ["已提交", "未提交"] || [];
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
                border: true,
                //margins: '0 10 0 0',
                region: 'north',
                activeTab: 0,
                heigth: 50,
                items: [tabArray]
            });


            var viewport = new Ext.ux.AimViewport({
                items: [tabpanel, {
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'}]
                });
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = "SurveyCommitHistoryList.aspx?Index=0&surveyId=" + surveyId;
                }
            }

            function handleActivate(tab) {
                if (document.getElementById("frameContent")) {
                    if (tab.title == "已提交") {
                        frameContent.location.href = "SurveyCommitHistoryList.aspx?op=r&surveyId=" + surveyId;
                    } else if (tab.title == "未提交") {
                        frameContent.location.href = "NoSubmit.aspx?Index=0&surveyId=" + surveyId;
                    }
                }
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
