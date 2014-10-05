<%@ Page Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Home3.aspx.cs" Inherits="Aim.Portal.Web.EPC.Home3" Title="项目首页" %>

<%@ Import Namespace="Aim" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <link href="/App_Themes/Ext/ux/css/Portal.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/Portal.js" type="text/javascript"></script>

    <script src="/js/ext/ux/PortalColumn.js" type="text/javascript"></script>

    <script src="/js/ext/ux/Portlet.js" type="text/javascript"></script>

    <style type="text/css">
        body
        {
            margin: 2px;
            filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=0,startColorStr=#FAFBFF,endColorStr=#C7D7FF);
            color: #003399;
            font-family: Verdana, Arial, Helvetica, sans-serif;
        }
        #header
        {
            background-color: #BAD1EF;
            filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=0,startColorStr=#BAD1EF,endColorStr=#8DB2E3);
        }
        .tab_item
        {
            font-size: 15;
            border: 0px;
            border-right: 1px dotted;
            padding-left: 10px;
            padding-right: 10px; /*background-color:Gray;*/
        }
        .info_panel
        {
            padding: 10px;
            font-size: 12px;
        }
        .info_panel hr
        {
            color: gray;
            height: 1px;
        }
        .panelSearch
        {
        	filter:progid:DXImageTransform.Microsoft.Gradient(startColorStr=#ffffff, endColorStr=#000000, gradientType=0)
        }
    </style>

    <script type="text/javascript">

        var InfoPopupStyle;
        var InfoTmpl;

        function onPgLoad() {
            InfoPopupStyle = CenterWin("width=650,height=500,scrollbars=yes");
            InfoTmpl = buildInfoTemplate();

            setPgUI();
        }

        function setPgUI() {
            var infoPanels = [];

            var panelSearch = new Ext.ux.AimPanel({
                border: true,
                title: "快速搜索",
                paddings: '5 0 0 0 ',
                html: "<table width=100%><tr width=100%><td align=center><select style=width:120px id=selSearch></select></td></tr><tr width=100%><td align=center><input id=txtSearch style=width:120px;/></td></tr><tr width=100%><td align=center><input type=button id=btnSearch value=执行 class='aim-ui-button' style='cursor:hand;'/></td></tr></table>"
            });
            infoPanels.push(panelSearch);
            panelSearch = new Ext.ux.AimPanel({
            border: true,
            title: "快速新建",
                paddings: '5 0 0 0 ',
                html: "<table width=100%><tr width=100%><td align=center><select style=width:120px id=selAddNew><option value=>新建...</option></select></td></tr><tr width=100%><td align=center><input id=btnAddNew type=button value=执行 class='aim-ui-button' style='cursor:hand;'/></td></tr></table>"
            });
            infoPanels.push(panelSearch);
            
            /*var pal = buildInfoView({ title: '公司资讯', url: '/Modules/PubNews/NewsList.aspx?TypeId={id}', mappings: { 'id': 'Id' }, records: ($.getJsonObj(AimState["News"]) || []) });
            infoPanels.push(pal);*/

            pal = buildInfoView({ title: '办公信息', url: '', records: [{ title: '内部消息', count: AimState["MsgCount"] || "0", url: '/Modules/Office/SysMessageTab.aspx'}] });
            infoPanels.push(pal);

            //作业相关
            var recordsArr = [];
            recordsArr.push({ title: '我的策划', count: null, url: '/EPC/WBS/PrjWbs.aspx', style: CenterWin("width=800,height=600,scrollbars=yes") });
            pal = buildInfoView({ title: '作业', url: '', records: recordsArr });
            infoPanels.push(pal);

            //项目相关
            recordsArr = [];
            recordsArr.push({ title: '里程碑', count: null, url: '/EPC/Schedule/PRJ_MilestoneList.aspx' });
            recordsArr.push({ title: '文件', count: null, url: '/EPC/Document/DocManager.aspx', style: CenterWin("width=800,height=600,scrollbars=yes") });
            recordsArr.push({ title: '项目费用报告', count: null, url: '/EPC/Common/Report/PRJ_Report.aspx?rpt=cost', style: CenterWin("width=800,height=600,scrollbars=yes") });
            //recordsArr.push({ title: '记事', count: AimState["MsgCount"] || 0, url: '/Modules/Office/SysMessageList.aspx?TypeId=Receive' });
            //recordsArr.push({ title: '任务', count: AimState["MsgCount"] || 0, url: '/Modules/Office/SysMessageList.aspx?TypeId=Receive' });
            //recordsArr.push({ title: '讨论', count: AimState["MsgCount"] || 0, url: '/Modules/Office/SysMessageList.aspx?TypeId=Receive' });
            pal = buildInfoView({ title: '项目', url: '', records: recordsArr });
            infoPanels.push(pal);
            portalPanel = new Ext.ux.AimPanel({
                layout: 'border',
                border: false,
                region: 'center',
                /*tbar: { xtype: 'aimtoolbar', items: [{ iconCls: 'aim-icon-user-edit' }, { html: '<b>我的个人首页</b>', xtype: 'tbtext' }, '->', { iconCls: 'aim-icon-help', tooltip: '帮助'}] },*/
                items: [
                { region: 'center', autoScroll: true, margins: '2 0 0 0', html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src="/home.aspx"></iframe>' },
                { id: 'infoView', autoScroll: true, iconCls: 'aim-icon-info', region: 'west', width: 200, margins: '2 0 0 0',
                    items: infoPanels
                }
                ]
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [portalPanel]
            });
            BindFucSelect();
        }
        //绑定下拉框
        var tempInternalAdd = 0;
        var tempInternalSearch = 0;
        function BindFucSelect() {
            var addNews = AimState["ModulesCreate"];
            for (var i = 0, len = addNews.length; i < len; i++) {
                var option = new Option(addNews[i].Name, addNews[i].Url);
                if ($.browser.msie) {
                    document.getElementById("selAddNew").options.add(option);
                }
                else {
                    document.getElementById("selAddNew").options.add(option);
                }
            }
            $("#btnAddNew").click(function() {
                tempInternalAdd = 0;
                if ($("#selAddNew").val() != "") {
                    document.getElementById("frameContent").src = $("#selAddNew").val();
                    var delayedTask = new Ext.util.DelayedTask();
                    delayedTask.delay(400, AddNewFire, this, [this, $("#txtSearch").val(), $("#selAddNew").val()]);
                }
            });
            var addNews = AimState["ModulesSearch"];
            for (var i = 0, len = addNews.length; i < len; i++) {
                var option = new Option(addNews[i].Name, addNews[i].Url);
                if ($.browser.msie) {
                    document.getElementById("selSearch").options.add(option);
                }
                else {
                    document.getElementById("selSearch").options.add(option);
                }
            }
            $("#btnSearch").click(function() {
                tempInternalSearch = 0;
                document.getElementById("frameContent").src = "/SearchBus.aspx";
                var delayedTask = new Ext.util.DelayedTask();
                delayedTask.delay(400, SearchResult, this, [this, $("#txtSearch").val(), $("#selSearch").val()]);
            });
        }
        function AddNewFire() {
            tempInternalAdd++;
            if (tempInternalAdd == 5) return;
            if (document.getElementById("frameContent").contentWindow && document.getElementById("frameContent").contentWindow.location.href.indexOf(arguments[2]) >= 0 && document.getElementById("frameContent").contentWindow.document.body.readyState == "complete") {
                var inputsall = document.getElementById("frameContent").contentWindow.$("button");
                if (inputsall)
                    $.each(inputsall, function() {
                        if (this.innerText == "添加") {
                            this.click();
                        }
                    });
            }
            else {
                var delayedTask = new Ext.util.DelayedTask();
                delayedTask.delay(400, AddNewFire, arguments[0], [arguments[0], arguments[1], arguments[2]]);
            }
        }
        function SearchResult() {
            tempInternalSearch++;
            if (tempInternalSearch == 5) return;
            if (document.getElementById("frameContent").contentWindow && document.getElementById("frameContent").contentWindow.location.href.indexOf(arguments[2])>=0 && document.getElementById("frameContent").contentWindow.document.body.readyState == "complete") {
                if (document.getElementById("frameContent").contentWindow.Ext.getCmp("defaultFullSearch")) {
                    document.getElementById("frameContent").contentWindow.Ext.getCmp("defaultFullSearch").el.dom.value = $("#txtSearch").val();
                    document.getElementById("frameContent").contentWindow.Ext.getCmp("defaultFullSearch").onTrigger2Click(); return;
                }  
                /*
                var inputsall = document.getElementById("frameContent").contentWindow.$("input");
                if(inputsall)
                    $.each(inputsall, function() {
                        if (this.qryopts == "{ type: 'fulltext' }") {
                            this.value = $("#txtSearch").val();
                            document.getElementById("frameContent").contentWindow.Ext.getCmp("defaultFullSearch").onTrigger2Click();
                        }
                    });*/
            }
            else {
                var delayedTask = new Ext.util.DelayedTask();
                delayedTask.delay(400, SearchResult, arguments[0], [arguments[0], arguments[1],arguments[2]]);
            }
        }

        function buildInfoView(opts) {
            var fields = ['title', 'count', 'id', 'url', 'style'];
            var mappings = opts["mappings"] || {};

            var opts = opts || {};
            var store = opts.store;
            var data = opts.data || [];

            if (!store) {
                if (!opts.data && opts.records) {
                    data = { records: opts.records };
                } else {
                    data = opts.data;
                }

                $.each(data.records, function() {
                    for (var key in mappings) {
                        if (mappings[key] && !this[key]) {
                            this[key] = this[mappings[key]];
                        }
                    }
                });

                store = new Ext.ux.data.AimJsonStore({ fields: fields, data: data });
            }

            var tpl = opts.tmpl || buildInfoTemplate(opts);

            var view = new Ext.ux.AimDataView({
                store: store,

                itemSelector: 'p',
                tpl: tpl,
                border: false,
                margins: '5 5 5 5'
            });

            return view;
        }

        function buildInfoTemplate(opts) {
            var opts = opts || {};
            var title = opts.title || '';
            // var colcount = opts.colcount || 2;
            url = $.combineQueryUrl(opts.url, "op=r");

            var tpl = new Ext.XTemplate(
                    '<div class="info_panel">',
                    '<b style="color:black;">' + title + '</b>',
                    '<hr />',
                    '<tpl for=".">',
                    '<span style="width:50%;"><a href="#" onclick=\'OpenWin("',
                    '<tpl if="url">',
                    '{url}',
                    '</tpl>',
                    '<tpl if="!url">',
                    url,
                    '</tpl>',
                    '", "_blank", "',
                    '<tpl if="style">',
                    '{style}',
                    '</tpl>',
                    '<tpl if="!style">',
                    InfoPopupStyle,
                    '</tpl>',
                     '")\'>&nbsp;',
                     '<tpl if="count">',
                    '({count})&nbsp;',
                    '</tpl>',
                    '{title}</a></span>',
                    '</tpl>',
                    '<div>'
                );

            return tpl;
        }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none">
        <h1>
            我的个人首页</h1>
    </div>
</asp:Content>
