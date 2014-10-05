<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="Wizard_Five.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Wizard_Five" %>

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
    </style>

    <script src="../js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">

        var tabIndex = parent.tabIndex;         //父页面tab 状态
        var surveyId = $.getQueryString({ ID: 'SurveyId' }) || '';

        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            //frameContent.location.href = "Tab_SurveyQueston.aspx?SurveyId=" + surveyId;

            //            // 初始化tooltip
            //            Ext.apply(Ext.QuickTips.getQuickTip(), { dismissDelay: 0 });
            //            tabs = ["基本信息", "问卷内容"]; //, "人员清单"
            //            tabArray = [];
            //            for (var a = 0; a < tabs.length; a++) {
            //                var tab = {
            //                    title: tabs[a],
            //                    tooltip: a,
            //                    listeners: { activate: handleActivate },
            //                    autoScroll: true,
            //                    border: false,
            //                    layout: 'border',
            //                    html: "<div style='display:none;'>asfdasdf</div>"
            //                };
            //                tabArray.push(tab);
            //            }
            //            tabpanel = new Ext.TabPanel({
            //                enableTabScroll: true,
            //                border: true,
            //                region: 'north',
            //                activeTab: tabIndex,
            //                items: [tabArray]
            //            });



            var viewport = new Ext.ux.AimViewport({
                items: [{
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'}]
                });
                if (document.getElementById("frameContent")) {
                    //if (tabIndex == 1)
                    frameContent.location.href = "Tab_SurveyQueston.aspx?SurveyId=" + surveyId;
                    //  else if (tabIndex == 2)
                    //  frameContent.location.href = "Tab_SurveyUserList.aspx?SurveyId=" + surveyId;
                    //   else
                    //   frameContent.location.href = "Tab_SurveyBasicInfo.aspx?SurveyId=" + surveyId;
                }
            }

            //            function handleActivate(tab) {
            //                parent.tabIndex = tab.tooltip;    //改变父页面tab 状态
            //                if (document.getElementById("frameContent")) {
            //                    switch (tab.title) {
            //                        case "基本信息":
            //                            frameContent.location.href = "Tab_SurveyBasicInfo.aspx?SurveyId=" + surveyId;
            //                            break;
            //                        //                        case "人员清单":                           
            //                        //                            frameContent.location.href = "Tab_SurveyUserList.aspx?SurveyId=" + surveyId;                           
            //                        //                            break;                           
            //                        case "问卷内容":
            //                            frameContent.location.href = "Tab_SurveyQueston.aspx?SurveyId=" + surveyId;
            //                            break;

            //                    }
            //                }
            //            }


            //----------------提交事件处理-------------
            function doSubmit(successFun, failureFun) {
                if (typeof successFun == "function") successFun();
            }
            function SuccessSubmit() {

            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
