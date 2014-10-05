<%@ Page Title="问卷统计" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="T_SurveyStatisticTab.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.T_SurveyStatisticTab" %>

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

        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            // 初始化tooltip
            Ext.apply(Ext.QuickTips.getQuickTip(), { dismissDelay: 0 });
            tabs = ["选项统计", "填写项统计", "选项说明统计"];
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
                border: true,
                region: 'north',
                activeTab: 0,
                items: [tabArray]
            });

            var viewport = new Ext.ux.AimViewport({

                items: [tabpanel, {
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
}]
                });
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = "SurveyStatisticResult.aspx?Id=" + SurveyId + "&op=v";

                }
            }

            function handleActivate(tab) {
                if (document.getElementById("frameContent")) {
                    switch (tab.title) {
                        case "选项统计":
                            frameContent.location.href = "SurveyStatisticResult.aspx?Id=" + SurveyId + "&op=v";
                            break;
                        case "填写项统计":
                            frameContent.location.href = "T_SurveyStatisticFill.aspx?SurveyId=" + SurveyId + "&op=r";
                            break;
                        case "选项说明统计":
                            frameContent.location.href = "T_SuveyQuestionItemFill.aspx?SurveyId=" + SurveyId + "&op=r";
                            break;
                    }
                }
            }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
