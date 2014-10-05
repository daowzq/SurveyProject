<%@ Page Language="C#" AutoEventWireup="True" MasterPageFile="~/Masters/Ext/SiteHasDTD.Master"
    Title="工作量负荷报表" CodeBehind="OutDutyReport.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.OutDutyReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        /*body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }*/</style>

    <script src="/FusionChart32/FusionCharts.js" type="text/javascript"></script>

    <script src="WeekOfMonth.js" type="text/javascript"></script>

    <script src="TimeSelector.js" type="text/javascript"></script>

    <style type="text/css">
        #div1-grid .x-grid3-hd-inner
        {
            white-space: normal;
        }
        .ext-ie .x-btn BUTTON
        {
            padding-top: 0px;
        }
        #right
        {
            top: 50%;
            width: 31px;
            right: 0px;
            position: fixed;
            _position: absolute;
            _right: 0;
            _top: 40%;
        }
        .report-error
        {
            padding: 100px;
            text-align: center;
            color: rgb(170, 170, 170);
            font-size: 14px;
        }
        .help-tool
        {
            width: 31px;
            height: 31px;
            margin-top: 1px;
            display: block;
            cursor: pointer;
            background-image: url("help-tool.png");
        }
        .help-tool2
        {
            width: 31px;
            height: 31px;
            margin-top: 1px;
            display: block;
            cursor: pointer;
            background-image: url("help-tool2.png");
        }
        #allscreen
        {
            background-position: 0px 0px;
        }
        #allscreen:hover
        {
            background-position: 0px -82px;
        }
        #toTop
        {
            background-position: 0px -324px;
        }
        #toTop:hover
        {
            background-position: 0px -243px;
        }
        .x-grid3-row-selected
        {
            background-color: transparent !important;
        }
    </style>

    <script src="jquery.scrollto.js" type="text/javascript"></script>

    <script type="text/javascript">
        var year_cb, quarter_cb, month_cb, week_cb;

        var store, myData, config;
        var pgBar, schBar, tlBar, titPanel, sm, grid, viewport;

        var structStore;
        var structGrid;

        var dclickCount = 0;
        var uclickCount = 0;

        var according = '2';

        var curDate = new Date();
        var year = curDate.getFullYear();
        var pre1Year = year - 1;
        var next1Year = year + 1;
        var pre2Year = year - 2;
        var next2Year = year + 2;
        var pre3Year = year - 3;
        var next3Year = year + 3;
        var yearArrStr = "{" + pre1Year + ":pre1Year, " + pre2Year + ":pre2Year, " + pre3Year + ":pre3Year, " + year + ":year, " + next1Year + ":next1Year, " + next2Year + ":next2Year, " + next3Year + ":next3Year}";
        var yearArr = eval('(' + yearArrStr + ')');


        var firstDay;
        var lastDay;

        var titleTime = new Date().getFullYear() + "年";

        var opentype = $.getQueryString({ ID: "type" });


        function onPgLoad() {
            if (opentype == "allscreen") {
                $("#allscreen").css({ backgroundPosition: "0px -164px" }).hover(function() {
                    $(this).css({ backgroundPosition: "0px -248px" });
                }, function() {
                    $(this).css({ backgroundPosition: "0px -164px" });
                });
            }
            $("#allscreen").click(function() {
                if (opentype == "allscreen") {
                    window.close();
                    return;
                }
                opencenterwin("OutDutyReport.aspx?type=allscreen", "allscreen", window.screen.availWidth, window.screen.availHeight);
            })
            $('#toTop').click(function() {
                $('html,body').animate({ 'scrollTop': '0' });
                return false;
            });

            $("#div-toolbar-title span:first").text("离职员工月人数统计表【" + titleTime + "】");

            setPgUI();
            structGrid.setTitle("离职员工服务年限结构分析表【" + titleTime + "】");
            titPanel.doLayout();
            //grid.getSelectionModel().selectFirstRow();
            //sm.selectFirstRow();
            CreateChart(store.getRange());
            CreateStructPieChart(structStore.getRange());
            CreateStructColumnChart(structStore.getRange());
        }
        function setPgUI() {
            initTimeSelector();
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["YearView"] || []
            };
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'YearView',
                idProperty: 'Year',
                data: myData,
                fields: [
                    { name: 'Year' },
                    { name: 'January' },
                    { name: 'February' },
                    { name: 'March' },
                    { name: 'April' },
                    { name: 'May' },
			        { name: 'June' },
                    { name: 'July' },
                    { name: 'August' },
			        { name: 'September' },
                    { name: 'October' },
                    { name: 'November' },
			        { name: 'December' },
                    { name: 'YearTotal' }
                ]
            });



            tlBar = new Ext.Toolbar({
                items: ['<b style="font-size:12px;">工作量负荷情况</b>'
                ]
            });

            titPanel = new Ext.Toolbar({
                //                region: 'north',
                //title: '工作量负荷情况',
                applyTo: 'div1-toolbar',

                //frame: true,
                buttonAlign: 'left',
                //tbar: tlBar,
                height: 24,
                items: [{ xtype: 'tbtext', style: { marginLeft: '100px' }, text: '<p style="font-size:12px;color:red;">&nbsp;&nbsp;选择时间模式: </p>' }, {
                    xtype: 'button',
                    text: '年份',
                    enableToggle: true,
                    pressed: true,
                    id: 'btn_Year',
                    style: { marginLeft: '8px' },
                    //iconCls: 'aim-icon-report',
                    handler: function(btn) {
                        Ext.getCmp("btn_Quarter").toggle(false);
                        Ext.getCmp("btn_Month").toggle(false);
                        Ext.getCmp("btn_Week").toggle(false);

                        Ext.getCmp("quarter_label").hide();
                        Ext.getCmp("quarter_combo").hide();

                        Ext.getCmp("month_label").hide();
                        Ext.getCmp("month_combo").hide();

                        Ext.getCmp("week_label").hide();
                        Ext.getCmp("week_combo").hide();

                    }
                }, {
                    xtype: 'button',
                    text: '季度',
                    hidden: true,
                    enableToggle: true,
                    pressed: false,
                    id: 'btn_Quarter',
                    style: { marginLeft: '8px' },
                    //iconCls: 'aim-icon-report',
                    handler: function(btn) {
                        Ext.getCmp("btn_Year").toggle(false);
                        Ext.getCmp("btn_Month").toggle(false);
                        Ext.getCmp("btn_Week").toggle(false);

                        Ext.getCmp("quarter_label").show();
                        Ext.getCmp("quarter_combo").show();

                        Ext.getCmp("month_label").hide();
                        Ext.getCmp("month_combo").hide();

                        Ext.getCmp("week_label").hide();
                        Ext.getCmp("week_combo").hide();
                    }
                }, {
                    xtype: 'button',
                    text: '月份',
                    hidden: true,
                    enableToggle: true,
                    pressed: false,
                    id: 'btn_Month',
                    style: { marginLeft: '8px' },
                    //iconCls: 'aim-icon-report',
                    handler: function(btn) {
                        Ext.getCmp("btn_Year").toggle(false);
                        Ext.getCmp("btn_Quarter").toggle(false);
                        Ext.getCmp("btn_Week").toggle(false);

                        Ext.getCmp("month_label").show();
                        Ext.getCmp("month_combo").show();

                        Ext.getCmp("quarter_label").hide();
                        Ext.getCmp("quarter_combo").hide();

                        Ext.getCmp("week_label").hide();
                        Ext.getCmp("week_combo").hide();
                    }
                }, {
                    xtype: 'button',
                    text: '周',
                    hidden: true,
                    style: { marginLeft: '8px' },
                    enableToggle: true,
                    pressed: false,
                    id: 'btn_Week',
                    //iconCls: 'aim-icon-report',
                    handler: function(btn) {
                        //---hide and show
                        Ext.getCmp("btn_Year").toggle(false);
                        Ext.getCmp("btn_Quarter").toggle(false);
                        Ext.getCmp("btn_Month").toggle(false);

                        Ext.getCmp("month_label").show();
                        Ext.getCmp("month_combo").show();

                        Ext.getCmp("week_label").show();
                        Ext.getCmp("week_combo").show();

                        Ext.getCmp("quarter_label").hide();
                        Ext.getCmp("quarter_combo").hide();
                        //------

                        //---event
                        var selyear = Ext.getCmp("year_combo").getValue();
                        var selmonth = Ext.getCmp("month_combo").getValue();

                        var week = showWeekDate(selyear, selmonth);
                        var weekArr = new Object;
                        weekArr.a1 = "第一周(" + week.week1.start + "-" + week.week1.end + ")";
                        weekArr.a2 = "第二周(" + week.week2.start + "-" + week.week2.end + ")";
                        weekArr.a3 = "第三周(" + week.week3.start + "-" + week.week3.end + ")";

                        if (week.hasOwnProperty("week4")) {
                            weekArr.a4 = "第四周(" + week.week4.start + "-" + week.week4.end + ")";
                        }
                        if (week.hasOwnProperty("week5")) {
                            weekArr.a5 = "第五周(" + week.week5.start + "-" + week.week5.end + ")";
                        }

                        var newStore = new Ext.data.SimpleStore({ fields: ['text', 'value'] });
                        newStore.loadData(adjustData(weekArr));
                        var weekField = Ext.getCmp("week_combo");
                        weekField.store = newStore;


                        if (weekField.view)
                            weekField.view.setStore(newStore);
                        Ext.getCmp("week_combo").setValue("a2");
                        //
                    }
                }, { xtype: 'tbtext', style: { marginLeft: '20px' }, text: '<p style="font-size:12px;color:red;">选择时间: </p>' }, { id: 'year_label', style: { marginLeft: '8px' }, xtype: 'tbtext', text: '<p style="font-size:12px;">年份:</p>' }, year_cb, { id: 'quarter_label', style: { marginLeft: '8px' }, hidden: true, xtype: 'tbtext', text: '<p style="font-size:12px;">季度:</p>' }, quarter_cb, { id: 'month_label', hidden: true, xtype: 'tbtext', style: { marginLeft: '8px' }, text: '<p style="font-size:12px;">月份:</p>' }, month_cb, { id: 'week_label', hidden: true, xtype: 'tbtext', style: { marginLeft: '8px' }, text: '<p style="font-size:12px;">周:</p>' }, week_cb, {
                    xtype: 'button',
                    text: '查询',
                    id: 'btn_search',
                    style: { marginLeft: '8px' },
                    handler: function() {
                        var year = Ext.getCmp("year_combo").getValue();
                        var quarter = Ext.getCmp("quarter_combo").getValue();
                        var month = Ext.getCmp("month_combo").getValue();
                        var weekStr = Ext.getCmp("week_combo").getValue();


                        if (Ext.getCmp("btn_Year").pressed == true) {
                            firstDay = new Date(year, 0, 1);
                            lastDay = new Date(year, 12, 0); //最后一天

                            titleTime = year + "年";
                        } else if (Ext.getCmp("btn_Quarter").pressed == true) {
                            firstDay = new Date(year, 0 + (quarter - 1) * 3, 1);
                            lastDay = new Date(year, (2 + (quarter - 1) * 3) + 1, 0); //最后一天
                            //var quter = { 1: '第一季度', 2: '第二季度', 3: '第三季度', 4: '第四季度' };

                            titleTime = year + "年-" + quarter_cb.getRawValue();
                        } else if (Ext.getCmp("btn_Month").pressed == true) {
                            firstDay = new Date(year, month - 1, 1);
                            lastDay = new Date(year, month, 0); //最后一天

                            titleTime = year + "年-" + month + "月";
                        } else if (Ext.getCmp("btn_Week").pressed == true) {
                            var week = showWeekDate(year, month);
                            if (weekStr == "a1") {
                                firstDay = new Date(week.week1.start);
                                lastDay = new Date(week.week1.end);
                            } else if (weekStr == "a2") {
                                firstDay = new Date(week.week2.start);
                                lastDay = new Date(week.week2.end);
                            } else if (weekStr == "a3") {
                                firstDay = new Date(week.week3.start);
                                lastDay = new Date(week.week3.end);
                            } else if (weekStr == "a4") {
                                firstDay = new Date(week.week4.start);
                                lastDay = new Date(week.week4.end);
                            } else if (weekStr == "a5") {
                                firstDay = new Date(week.week5.start);
                                lastDay = new Date(week.week5.end);
                            }

                            titleTime = year + "年-" + month + "月-" + week_cb.getRawValue();
                        }
                        else {

                        }

                        $.ajaxExec("schbydate", { start: firstDay, end: lastDay }, function(rtn) {
                            if (rtn.data.YearView) {
                                store.loadData({ records: rtn.data.YearView || [] });
                                CreateChart(store.getRange());

                                $("#div-toolbar-title span:first").text("离职员工月人数统计表【" + titleTime + "】");
                            }
                            if (rtn.data.StructView) {
                                structStore.loadData({ records: adjustStructData(rtn.data.StructView || []) });
                                structGrid.setTitle("离职员工服务年限结构分析表【" + titleTime + "】");
                                CreateStructPieChart(structStore.getRange());
                                CreateStructColumnChart(structStore.getRange());
                            }
                        });
                    }
}]
                });

                grid = new Ext.ux.grid.AimGridPanel({
                    //title: '各部门负荷情况列表',
                    store: store,
                    renderTo: 'div1-grid',
                    viewConfig: { forceFit: true },
                    deferRowRender: false,
                    height: 52,
                    margins: '0 10 10 0',
                    //sm: sm,
                    columns: [
                {
                    id: 'Year', dataIndex: 'Year', header: '月份', width: 80,
                    renderer: function(v, c, r) {
                        c.style += 'background-color:rgb(214,214,214);';
                        return v;
                    }
                },
                    //new Ext.ux.grid.AimRowNumberer(),
                {id: 'January', dataIndex: 'January', header: '一月', width: 80 },
                { id: 'February', dataIndex: 'February', header: '二月', width: 80 },
                { id: 'March', dataIndex: 'March', header: '三月', width: 80 },
                { id: 'April', dataIndex: 'April', header: '四月', width: 80 },
                { id: 'May', dataIndex: 'May', header: '五月', width: 80 },
                { id: 'June', dataIndex: 'June', header: '六月', width: 80 },
                { id: 'July', dataIndex: 'July', header: '七月', width: 80 },
                { id: 'August', dataIndex: 'August', header: '八月', width: 80 },
                { id: 'September', dataIndex: 'September', header: '九月', width: 80 },
                { id: 'October', dataIndex: 'October', header: '十月', width: 80 },
                { id: 'November', dataIndex: 'November', header: '十一月', width: 80 },
                { id: 'December', dataIndex: 'December', header: '十二月', width: 80 },
                { id: 'YearTotal', dataIndex: 'YearTotal', header: '总计', width: 80 }
                ]
                });


                structStore = new Ext.ux.data.AimJsonStore({
                    dsname: 'StructView',
                    idProperty: 'Tit',
                    data: { records: adjustStructData(AimState["StructView"] || []) },
                    fields: [
                    { name: 'Tit' },
                    { name: 'Less3M' },
                    { name: 'F3Mto1Y' },
                    { name: 'F1Yto2Y' },
                    { name: 'F2Yto3Y' },
                    { name: 'F3Yto5Y' },
                    { name: 'F5Yto7Y' },
                    { name: 'Greater7Y' },
                    { name: "Total" }
                ],
                    listeners: {
                        "aimbeforeload": function(proxy, options) {
                            options.data = options.data || {};
                        }
                    }
                });


                structGrid = new Ext.ux.grid.AimGridPanel({
                    title: '离职员工服务年限结构分析表',
                    store: structStore,
                    renderTo: 'div2-grid',
                    colspan: 2,
                    viewConfig: { forceFit: true },
                    autoHeight: true,
                    columns: [
                    {
                        id: 'Tit', dataIndex: 'Tit', header: '服务年限', width: 80,
                        renderer: function(v, c, r) {
                            c.style += 'background-color:rgb(214,214,214);';
                            return v;
                        }
                    },
                { id: 'Less3M', dataIndex: 'Less3M', header: '3个月＜', width: 80 },
                { id: 'F3Mto1Y', dataIndex: 'F3Mto1Y', header: '3个月~1年', width: 80 },
                { id: 'F1Yto2Y', dataIndex: 'F1Yto2Y', header: '1年~2年', width: 80 },
                { id: 'F2Yto3Y', dataIndex: 'F2Yto3Y', header: '2年~3年', width: 80 },
                { id: 'F3Yto5Y', dataIndex: 'F3Yto5Y', header: '<label style="color:red;">3年~5年</label>', width: 80 },
                { id: 'F5Yto7Y', dataIndex: 'F5Yto7Y', header: '<label style="color:red;">5年~7年</label>', width: 80 },
                { id: 'Greater7Y', dataIndex: 'Greater7Y', header: '<label style="color:red;">>7年</label>', width: 80 },
                { id: 'Total', dataIndex: 'Total', header: '总计', width: 80 }
                ]
                });

            }
            function opencenterwin(url, name, iWidth, iHeight) {
                var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
                var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;ExamineResultView
                window.open(url, name, 'height=' + iHeight + ',,innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
            }
            function ShowDetail(val) {
                var task = new Ext.util.DelayedTask();
                task.delay(100, function() {
                    opencenterwin("LoadReportDetail.aspx?Param=" + escape(val) + "&According=" + according, "", 1200, 650);
                });
            }
            function CreateChart(records) {
                var seriesarray = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];
                var fieldarray = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                var colorarray = ['AFD8F8', 'F6BD0F', '8BBA00', 'FF8E46', '008E8E', 'D64646', '8E468E', '588526', 'B3AA00', '008ED6', '9D080D', 'A186BE'];
                var jsonarray = [];
                for (var i = 0; i < seriesarray.length; i++) {
                    jsonarray.push({ label: seriesarray[i], value: records[0].get(fieldarray[i]), color: colorarray[i] });
                }

                var jsondata = {
                    chart: {
                        xAxisName: '月份', yAxisName: '人数', showFCMenuItem: '0',
                        decimalPrecision: '0', rotateValues: '1', caption: '离职员工月人数统计表',
                        formatNumberScale: '0', placeValuesInside: '0', chartTopMargin: '0', chartBottomMargin: '5', showValues: '0', unescapeLinks: '0', chartLeftMargin: 20, chartRightMargin: 20
                    },
                    data: jsonarray
                };
                var mychart = new FusionCharts("/FusionChart32/Line.swf", "myChartId", $("#div1-chart")[0].offsetWidth, '300');
                mychart.setJSONData(jsondata);
                mychart.render('div1-chart');
            }
            function CreateStructPieChart(records) {
                var seriesarray = ['3个月＜', '3个月~1年', '1年~2年', '2年~3年', '3年~5年', '5年~7年', '>7年'];
                var fieldarray = ['Less3M', 'F3Mto1Y', 'F1Yto2Y', 'F2Yto3Y', 'F3Yto5Y', 'F5Yto7Y', 'Greater7Y'];
                var mychart = new FusionCharts("/FusionChart32/Pie3D.swf", "myChartId", $("#div2-chart-part1")[0].offsetWidth, 300);
                var jsonarray = [];
                for (var i = 0; i < seriesarray.length; i++) {
                    jsonarray.push({ label: seriesarray[i], value: records[0].get(fieldarray[i]) });
                }
                var chartconfig = { showPercentValues: '1', showFCMenuItem: '0', chartLeftMargin: 20, chartRightMargin: 20, caption: '结构比例', showBorder: '1', borderColor: '#99bbe8' };

                mychart.setJSONData({ chart: chartconfig, data: jsonarray });
                mychart.render('div2-chart-part1');
            }


            function CreateStructColumnChart(records) {
                var seriesarray = ['3个月<', '3个月~1年', '1年~2年', '2年~3年', '3年~5年', '5年~7年', '>7年'];
                var fieldarray = ['Less3M', 'F3Mto1Y', 'F1Yto2Y', 'F2Yto3Y', 'F3Yto5Y', 'F5Yto7Y', 'Greater7Y'];
                var mychart = new FusionCharts("/FusionChart32/Column3D.swf", "myChartId", $("#div2-chart-part2")[0].offsetWidth, 300);
                var jsonarray = [];
                for (var i = 0; i < seriesarray.length; i++) {
                    jsonarray.push({ label: seriesarray[i], value: records[0].get(fieldarray[i]) });
                }
                var chartconfig = { showPercentValues: '1', showFCMenuItem: '0', chartLeftMargin: 20, chartRightMargin: 20, caption: '人数', showBorder: '1', borderColor: '#99bbe8' };

                mychart.setJSONData({ chart: chartconfig, data: jsonarray });
                mychart.render('div2-chart-part2');
            }

            function adjustStructData(jdata) {
                var arrdate = [];
                $.each(jdata, function(e) {
                    if (this.Tit == "结构比例") {
                        this.Less3M += '%';
                        this.F3Mto1Y += '%';
                        this.F1Yto2Y += "%";
                        this.F2Yto3Y += "%";
                        this.F3Yto5Y += "%";
                        this.F5Yto7Y += "%";
                        this.Greater7Y += "%";
                        this.Total += "%";
                    }
                });
                return jdata;
            }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <table style="table-layout: fixed; width: 100%;">
        <tr>
            <td colspan="2">
                <div id="div-toolbar-title" class="x-panel-header x-unselectable">
                    <span class="x-panel-header-text">离职员工月人数统计表</span>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="border: solid 1px #99bbe8;">
                <div id="div1-toolbar">
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <div id="div1-grid">
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <div id="div1-chart">
                </div>
            </td>
        </tr>
        <tr id="div2">
            <td colspan="2">
                <div id="div2-grid">
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <div id="div2-chart-part1">
                </div>
            </td>
            <td>
                <div id="div2-chart-part2">
                </div>
            </td>
        </tr>
        <tr id="div3">
            <td colspan="2">
                <div id="div3-toolbar" class="x-panel-header x-unselectable" style="display: none;">
                    <span id='user-title' class="x-panel-header-text">工作量情况</span>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="vertical-align: top;">
                <div id="div3-grid">
                </div>
            </td>
            <%--            <td>
                <div id="div3-chart">
                </div>
            </td>--%>
        </tr>
        <tr id="div4">
            <td colspan="2">
                <div id="div4-toolbar" class="x-panel-header x-unselectable" style="display: none;">
                    <span id='xj-title' class="x-panel-header-text">请假情况</span>
                </div>
            </td>
        </tr>
        <tr>
            <td style="vertical-align: top;">
                <div id="div4-grid">
                </div>
            </td>
            <td>
                <div id="div4-chart">
                </div>
            </td>
        </tr>
    </table>
    <div id="right">
        <a id="allscreen" class="help-tool2" title="全屏" log="screen"></a><a id="toTop" log="top"
            class="help-tool" title="回到顶部"></a>
    </div>
</asp:Content>
