<%@ Page Title="办理任务列表" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="TaskTab.aspx.cs" Inherits="Aim.Portal.Web.WorkFlow.TaskTab" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/ext/ux/TabScrollerMenu.js" type="text/javascript"></script>

    <style type="text/css">
        body
        {
            margin: 2px;
            filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=0,startColorStr=#FAFBFF,endColorStr=#C7D7FF);
            color: #003399;
            font-family: Verdana, Arial, Helvetica, sans-serif;
        }
        #main
        {
        }
        .table_banner
        {
            filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=0,startColorStr=#E0F0F6,endColorStr=#A4C7E3);
        }
        .tab_item
        {
            font-size: 15;
            border: 0px;
            border-right: 1px dotted;
            padding-left: 10px;
            padding-right: 10px; /*background-color:Gray;*/
        }
    </style>

    <script type="text/javascript">

        var mdls;
        var tabIndex = parseInt($.getQueryString({ ID: "tab", DefaultValue: "0" }));

        function onPgLoad() {
            mdls = [{ Name: "待办任务", Url: "TaskList.aspx?Status=0", Status: 0 }, { Name: "已办任务", Url: "TaskList.aspx?Status=1", Status: 1 }, { Name: "办结任务", Url: "TaskList.aspx?Status=4", Status: 4}];

            setPgUI();
        }

        function setPgUI() {
            var tabArr = new Array();
            var i = 0;
            var FrameHtml = "";
            // 构建tab标签
            $.each(mdls, function() {
                var tab = {
                    title: this["Name"],
                    href: this["Url"],
                    Status: this["Status"],
                    listeners: { activate: handleActivate },
                    margins: '0 0 0 0',
                    border: false,
                    layout: 'border',
                    html: "<div style='display:none;'></div>"
                }
                tabArr.push(tab);
            });

            // 用于tab过多时滚动
            var scrollerMenu = new Ext.ux.TabScrollerMenu({
                menuPrefixText: '项目',
                maxText: 15,
                pageSize: 5
            });

            var tabPanel = new Ext.ux.AimTabPanel({
                enableTabScroll: true,
                border: true,
                defaults: { autoScroll: true },
                plugins: [scrollerMenu],
                region: 'north',
                margins: '-1 0 0 0',
                activeTab: tabIndex,
                width: document.body.offsetWidth - 5,
                height: 10,
                items: tabArr,
                listeners: { 'click': function() { handleActivate(); } }
            });

            var viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [tabPanel, {
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
}]
                });

                function handleActivate(tab) {
                    tab = tab || tabPanel.getActiveTab();
                    var url = tab.href;

                    if (document.getElementById("frameContent"))
                        frameContent.reloadPage.call(this, { cid: tab.Status });
                    else {
                        window.setTimeout("LoadFirstTab('" + url + "');", 100);
                    }
                    return;
                }
            }
            function LoadFirstTab(url) {
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = url;
                }
                else
                    window.setTimeout("LoadFirstTab('" + url + "');", 100);
            }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
