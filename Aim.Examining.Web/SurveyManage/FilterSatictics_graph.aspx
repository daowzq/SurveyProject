<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="FilterSatictics_graph.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.FilterSatictics_graph" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #ffffff;
            font-family: 微软雅黑, Arial, Verdana;
        }
        #mainTbl td, #mainTbl th
        {
            font-size: 1em;
            border: 1px solid #000000;
            padding: 3px 7px 2px 7px;
        }
    </style>
    <script src="/FusionChart32/FusionCharts.js" type="text/javascript"></script>
    <script type="text/javascript">

        var chartInfo = {};

        var chartInfo = (window.location.href + "").indexOf("?") > -1 ? Ext.urlDecode(window.location.href.split("?")[1]) : {};
        // chartInfo["arrContent"]
        //chartInfo["arrCount"]
        // chartInfo["arrValue"]


        function onPgLoad() {
            $.ajaxExec("GetItemContent", { SurveyId: chartInfo["SurveyId"] || "", Title: chartInfo["Title"] }, function (rtn) {
                var list = rtn.data.List;
                chartInfo["arrContent"] = [];
                $.each(list, function () {
                    chartInfo["arrContent"].push(this["Answer"]);
                });
                setPgUI();
            });

        }

        function setPgUI() {
            initTbl(chartInfo);
            setChart(chartInfo);
            $("#but1").toggle(function () {
                $(this).html("柱状图");
                $("#div2-chart-part2").show();
                $("#div2-chart-part1").hide();
            }, function () {
                $(this).html("饼状图");
                $("#div2-chart-part1").show();
                $("#div2-chart-part2").hide();
            });
        }

        //表格初始化
        function initTbl(chartInfo) {
            var tdRate = parseInt((90 - 2) / chartInfo["arrContent"].length);

            var tbl_Content = "", tbl_Count = "", tbl_Value = "";
            var tpl_Content = "<td>{item}</td>";
            var tpl_Count = "<td>{item}</td>";
            var tpl_Value = "<td>{item}</td>";

            for (var i = 0; i < chartInfo["arrContent"].length; i++) {
                tbl_Content += tpl_Content.replace("{item}", chartInfo["arrContent"][i]);
                tbl_Count += tpl_Content.replace("{item}", chartInfo["arrCount"][i]);
                tbl_Value += tpl_Content.replace("{item}", chartInfo["arrValue"][i]);
            }

            $("#title").text(chartInfo.Title);
            $("#tbl_content").after(tbl_Content);
            $("#tbl_Value").after(tbl_Value);
            $("#tbl_count").after(tbl_Count);

        }

        //设置Chart
        function setChart(chartInfo) {

            var chartTpl = "<chart yAxisName='百分比' subCaption='选项比例统计图' xAxisName='选项' numDivLines='5' showYAxisValues='1'  maxLabelWidthPercent='20' yAxisMaxValue='100' numDivLines='0' labelDisplay='ROTATE' canvasLeftMargin='150' numberSuffix='%' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
            var ItemTpl = "<set label='{item}' value='{val}' />";
            var tempItems = "", TotalCount = 0;
            for (var i = 0; i < chartInfo["arrContent"].length; i++) {

                var txt = ((chartInfo["arrContent"][i] + "").length > 21) ? (chartInfo["arrContent"][i].substring(0, 21) + "...") : chartInfo["arrContent"][i] + "";
                var temp = ItemTpl.replace('{item}', txt);   //标题

                temp = temp.replace('{val}', chartInfo["arrValue"][i]);           //条形高度值
                // temp = temp.replace('{count}', chartInfo["arrCount"][i] + " 票");           //条形高度值
                TotalCount = (parseInt(chartInfo["arrCount"][i]) > TotalCount) && parseInt(chartInfo["arrCount"][i]);
                tempItems += temp;
            }

            //------------图形自适应------
            var width = 500, heigth = 300;
            if (chartInfo["arrContent"].length > 6) {
                width += (chartInfo["arrContent"].length - 6) * 28;
            }
            //------------------------------

            var chart = chartTpl.replaceAll('{items}', tempItems);
            var chartdiv2 = new FusionCharts('/FusionChart32/Pie3D.swf', '', width, heigth, '0', '1');
            chartdiv2.setXMLData(chart);
            chartdiv2.render("div2-chart-part2");

            var chartdiv = new FusionCharts('/FusionChart32/Column2D.swf', '', width, heigth, '0', '1');
            chartdiv.setXMLData(chart);
            chartdiv.render("div2-chart-part1");

            var chartdiv2 = new FusionCharts('/FusionChart32/Pie3D.swf', '', width, heigth, '0', '1');
            chartdiv2.setXMLData(chart);
            chartdiv2.render("div2-chart-part2");
            //-----------------------------------------

            //票数
            chartTpl = "<chart yAxisName='票数'  subCaption='选项票数统计图' xAxisName='选项' numDivLines='5' showYAxisValues='1'  maxLabelWidthPercent='20' yAxisMaxValue='{max}' numDivLines='0' labelDisplay='ROTATE' canvasLeftMargin='150' numberSuffix=' 票' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
            chartTpl = chartTpl.replace("{max}", Math.round(TotalCount + 5));

            tempItems = "";
            for (var i = 0; i < chartInfo["arrContent"].length; i++) {
                var txt = ((chartInfo["arrContent"][i] + "").length > 21) ? (chartInfo["arrContent"][i].substring(0, 21) + "...") : chartInfo["arrContent"][i] + "";
                var temp = ItemTpl.replace('{item}', txt);   //标题

                temp = temp.replace('{val}', chartInfo["arrCount"][i]);           //条形高度值
                TotalCount += parseInt(chartInfo["arrCount"][i]);
                tempItems += temp;
            }

            var chart = chartTpl.replaceAll('{items}', tempItems);
            var chartdiv2 = new FusionCharts('/FusionChart32/Column2D.swf', '', width, heigth, '0', '1');
            chartdiv2.setXMLData(chart);
            chartdiv2.render("div2-chart-part3");

        }

 
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="editDiv" align="left">
        <table id="mainTbl" style="margin: 6px 1px; border-collapse: collapse; table-layout: auto">
            <tbody style="width: 99%">
                <tr>
                    <td colspan="100" id="title">
                    </td>
                </tr>
                <tr style="text-align: left; padding-top: 5px; padding-bottom: 4px; background-color: #A7C942;
                    color: #ffffff;">
                    <td style="width: 10%" id="tbl_content">
                        内容
                    </td>
                </tr>
                <tr style="text-align: left; padding-top: 5px; padding-bottom: 4px; background-color: rgb(252,213,180);">
                    <td id="tbl_Value">
                        占比
                    </td>
                </tr>
                <tr>
                    <td id="tbl_count">
                        票数
                    </td>
                </tr>
                <tr>
                    <td colspan='100'>
                        <div id="but1" style="display: inline-block; display: inline; width: 50px; height: 25px;
                            color: Blue; text-decoration: underline; cursor: pointer
                            border: solid 1 red">
                            饼状图
                        </div>
                        <div id="div2-chart-part1">
                        </div>
                        <div id="div2-chart-part2" style="display: none">
                        </div>
                        <div id="div2-chart-part3">
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
