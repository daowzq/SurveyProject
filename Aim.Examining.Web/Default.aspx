<%@ Page Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    EnableEventValidation="false" CodeBehind="Default.aspx.cs" Inherits="Aim.Examining.Web.Default"
    Title="企业文化系统" %>

<%@ Import Namespace="Aim" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/ext/ux/TabScrollerMenu.js" type="text/javascript"></script>

    <style type="text/css">
        body
        {
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
            border-right: 1px solid;
            border-color: Gray;
            padding-left: 10px;
            padding-right: 10px;
        }
        .x-tab-strip-text
        {
            color: Black !important;
        }
        .x-tab-strip-active
        {
            height: 28;
            line-height: 28;
            border-bottom-style: solid;
            border-bottom-color: Red;
            border-bottom-width: 2;
            background-image: url(images/NPortal/nav_bg1.png) repeat-x;
        }
        .x-tab-panel-header
        {
            border: 0px;
            background-image: url() !important;
            background: Transparent;
        }
        .x-tab-panel-header .x-tab-strip
        {
            border: 0px;
            background: none;
            height: 32px;
        }
        .toolbar
        {
            border: 0px;
            background-image: url(/images/nportal/tdbg.jpg);
        }
    </style>

    <script type="text/javascript">

        var mdls;

        function onPgLoad() {
            mdls = AimState["Modules"] || [];

            setPgUI();
            RefreshSession();
        }
        function RefreshSession() {
            $.ajax({
                type: "GET",
                url: "Default.aspx",
                data: "tag=Refresh",
                success: function(msg) {
                }
            });
            window.setTimeout("RefreshSession()", 900000);
        }

        function setPgUI() {
            var tabArr = new Array();
            var i = 0;
            var FrameHtml = "";
            // 构建tab标签
            $.each(mdls, function() {
                //FrameHtml = "<iframe width=100% height=100% id=frameContent" + i.toString() + " name=frameContent frameborder='0' src=''></iframe>";
                var tab = {
                    title: this["Name"],
                    href: this["Url"],
                    code: this["Code"],
                    listeners: { activate: handleActivate },
                    margins: '0 0 0 0',
                    border: false,
                    layout: 'border',
                    html: "<div style='display:none;'></div>"
                    /*items: [{ region: 'center', border: false,
                    html: "<div style='display:none;'></div>"
                    }]*/
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
                margins: '50 5 0 5',
                activeTab: 0,
                width: document.body.offsetWidth - 5,
                height: 10,
                items: tabArr,
                listeners: { 'click': function() { handleActivate(); } },
                itemTpl: new Ext.XTemplate(
                '<li id="{id}" style="overflow:hidden">',
                    '<span class="tab_item" style="margin-top:5px;">',
                        '<span class="x-tab-strip-text" align="center">{text}</span>',
                    '</span>',
                '</li>'
                )
            });
            var html = "<div style='font-size: 12px; margin: 0;padding:0px;'><table width=99%><tr><td style='font-size:12px;color:white;'>&nbsp;您好&nbsp;<%=UserInfo.Name %>&nbsp;&nbsp;欢迎您使用系统&nbsp;!&nbsp;&nbsp;<span  style='font-size:12px;' onclick=\"window.open('/Modules/Office/calendar.htm','_blank')\" style='text-decoration: underline; cursor: hand;'>  今天是 <%=String.Format("{0}月{1}日", DateTime.Now.Month, DateTime.Now.Day) %></span></td><td align=right style='font-size:12px;color:white;'>上海融为信息科技有限公司</td></tr></table></div>";
            var bottomBar = new Ext.Toolbar({
                cls: "toolbar",
                region: 'south',
                bodyStyle: 'border:0px',
                width: document.body.offsetWidth - 5,
                html:html
            });
            var viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [tabPanel, {
                    region: 'center',
                    margins: '0 5 0 5',
                    cls: 'empty',
                    bodyStyle: 'border-top-color:#323232;border-top-width: 1px;background:#323232',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
                }, bottomBar]
            });
            function handleActivate(tab) {
                tab = tab || tabPanel.getActiveTab();

                if (!tab) {
                    return;
                }

                var url = tab.href;
                // 首页
                if (tab.code.toUpperCase() != "PORTAL") {
                    url = $.combineQueryUrl("/SubPortal3.aspx", "mcode=" + tab.code);
                }
                if (document.getElementById("frameContent"))
                    frameContent.location.href = url;
                else {
                    window.setTimeout("LoadFirstTab('" + url + "');", 100);
                }
                return;
            }
        }
        function LoadFirstTab(url) {
            if (document.getElementById("frameContent"))
                frameContent.location.href = url;
            else
                window.setTimeout("LoadFirstTab('" + url + "');", 100);
        }

        function DoRelogin() {
            window.setTimeout("location.href = '../Login.aspx'", 200);
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="main" align="center">
        <div align="center" align="center" />
        <table id="__01" width="100%" cellpadding="0" cellspacing="0" style="table-layout: fixed;
            background-color: White;">
            <tr>
                <td width="5" valign="top">
                </td>
                <td>
                    <table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout: fixed;">
                        <tr height="50">
                            <td align="left" width="250">
                                <img src="images/NPortal/1.png" />
                            </td>
                            <td valign="top" align="right" style="background: url(images/NPortal/3.png) repeat-x">
                                <asp:LinkButton Visible="false" ID="lnkGoodway" Font-Size="12px" runat="server" ForeColor="White"
                                    OnClick="lnkGoodway_Click">综合管理平台</asp:LinkButton>
                                <asp:LinkButton ID="lnkRelogin" runat="server" OnClick="lnkRelogin_Click" ForeColor="White"
                                    Font-Size="12px">注销</asp:LinkButton>
                                &nbsp;<font style="color: White">|</font>&nbsp;
                                <asp:LinkButton ID="lnkExit" runat="server" OnClick="lnkExit_Click" ForeColor="White"
                                    Font-Size="12px">退出</asp:LinkButton>
                            </td>
                            <td width="11" style="background: url(images/NPortal/5.png) norepeat; background-color: none;">
                            </td>
                        </tr>
                        <tr height="32">
                            <td align="left" width="250">
                                <img src="images/NPortal/2.png" />
                            </td>
                            <td align="right" style="background: url(images/NPortal/4.png) repeat-x">
                            </td>
                            <td width="11" style="background: url(images/NPortal/6.png) norepeat">
                            </td>
                        </tr>
                    </table>
                </td>
                <td width="5" valign="top">
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
