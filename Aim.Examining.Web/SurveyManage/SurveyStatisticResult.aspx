<%@ Page Title="统计信息_选项统计" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="SurveyStatisticResult.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyStatisticResult" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: White;
        }
        td, select, input
        {
            font-size: 12px;
            color: #646464;
            line-height: 18px;
        }
        .guid
        {
            filter: dropshadow(color=#FFFFFF,direction=0,offx=1,offy=1);
            width: 100%;
            font-size: 14px;
            font-weight: bold;
            color: #FF6600;
        }
        .header
        {
            background-color: #e0e0e0;
        }
        .discuss
        {
            float: left;
            width: 30px;
            border: solid 1 gray;
            margin: 12px 3px 0px 0px;
        }
        fieldset
        {
            border: solid 2px #ff7800;
            width: 100%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .style1
        {
            width: 374px;
        }
        .headTbl
        {
            border-collapse: collapse;
            font-size: 1em;
            border: 1px solid #98bf21;
            padding: 3px 7px 2px 7px;
        }
    </style>
    <script src="/FusionChart32/FusionCharts.js" type="text/javascript"></script>
    <script type="text/javascript">
        var id = $.getQueryString({ ID: 'Id' });
        var records, baseInfo, fillQuestion;
        var counter = 0;            //题目序号
        function onPgLoad() {
            setPageUI();
        }

        function setPageUI() {

            records = AimState["DataList"] || [];
            baseInfo = AimState["SurveyQuestion"];
            fillQuestion = AimState["FillQuestion"] || [];  //必填项

            if (records.length > 0) {
                var resetedDataArr = chartAdapter(records);
                setChart(resetedDataArr);
            }

            // if (baseInfo) {
            //     setBaseInfo(baseInfo);            // 基本信息       
            // }    
            // if (fillQuestion.length > 0) {
            //     setFillQuestion(fillQuestion);   //填写项
            // }

        }
        //设置填写项
        function setFillQuestion(obj) {
            var divContaint = "";
            for (var i = 0; i < obj.length; i++) {
                divContaint += "<div style=\"font-size: 15px; font-weight: bold; margin: 10px\"><a href='#'  onclick='showWin(\"" + obj[i]["Id"] + "\")'><span>" + (counter + i + 1) + '.' + obj[i]["Content"] + "【填写项】</span></a></div>";
            }
            $("#result_content").append(divContaint);
        }

        //设置基本信息
        function setBaseInfo(obj) {

            $("#title").text(AimState["SurveyQuestion"]["Title"]);   //title
            $("#DeptName").text(AimState["SurveyQuestion"]["DeptName"]); //发布部门

            $("#IsName").text((obj.IsNoName == "yes" ? "可匿名" : "不匿名"));
            $("#State").text(obj.State != "2" ? "已启动" : "已结束");
            $("#startDate").text(obj.StartTime);
            $("#endDate").text(obj.EndTime);
        }


        //设置Chart
        function setChart(objArr) {

            var resetedDataArr = objArr;
            var div = "chartdiv_"; //要动态呈现的div
            var counter = 0;       //题目序号

            var chartTpl = " <chart maxLabelWidthPercent='20' yAxisMaxValue='100' numDivLines='0' labelDisplay='WRAP' canvasLeftMargin='150' numberSuffix='%' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' caption='{caption}' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
            var ItemTpl = "<set label='{item}'  value='{val}' {other} />";


            for (var i = 0; i < resetedDataArr.length; i++) {
                counter = i + 1;                                 //题目序号
                var title, tempItems;                            //标题 子项
                title = counter + "." + resetedDataArr[i]["Content"] + "【" + resetedDataArr[i]["QuestionType"] + "】";  //标题+类型
                for (var k = 0; k < resetedDataArr[i]["Item"].length; k++) {
                    var tempArr = (resetedDataArr[i]["Item"][k] + "").split("|");
                    if (tempArr.length > 0) {

                        var temp = ItemTpl.replace('{item}', tempArr[0].substring(0, 500));   //标题
                        temp = temp.replace('{val}', tempArr[1]);           //条形高度值

                        if (tempArr[2] == "是") {  //该问题项是否说明
                            var link = "j-showWin-" + tempArr[3];  //tempArr[3] 传递的参数
                            temp = temp.replaceAll('{other}', "link='" + link + "' dashed='1'");
                        } else {
                            temp = temp.replaceAll('{other}', "");
                        }
                    }
                    tempItems += temp;            //子项
                }

                //
                var itmLength = resetedDataArr[i]["Item"].length;
                var areaHeight = itmLength * 24 + 90;
                //

                //------ChartSet 的数据填写与呈现
                $("#result_content").append("<div style='margin-left:0px;height:" + areaHeight + "px;' id=" + (div + i) + "></div>");

                var chart = chartTpl.replaceAll('{caption}', title);
                chart = chart.replaceAll('{items}', tempItems);
                var chartdiv = new FusionCharts('/FusionChart32/Bar2D.swf', title, '780', areaHeight, '0', '1');
                chartdiv.setXMLData(chart);
                chartdiv.render(div + i);
                tempItems = "";
                //-----------------------------------------
            }
        }

        //chart adapter
        function chartAdapter(obj) {
            //问题 >>答案 >>item
            var questionsArr = [];
            //  var questionObj = {};

            for (var i = 0; i < obj.length; i++) {
                //if (obj[i]["HasImg"] == "Y") continue;  //图片类型跳出  填写项跳出
                if (obj[i]["QuestionType"] == "填写项") continue;   //填写项 跳出
                if (obj[i]["ItemSet"] == null) continue;  //没有具体的问题项 

                var itemArr = obj[i]["ItemSet"].split('$');
                var tempArr = [];
                for (var v = 0; v < itemArr.length; v++) {
                    tempArr.push(itemArr[v]);
                }
                var QuestionType = obj[i]["QuestionType"];
                var Content = obj[i]["Content"];
                var IsMustAnswer = obj[i]["IsMustAnswer"];
                var IsComment = obj[i]["IsComment"];
                var QuestionId = obj[i]["QuestionId"]

                var objArr = {
                    QuestionType: QuestionType,
                    Content: Content,
                    IsMustAnswer: IsMustAnswer,
                    IsComment: IsComment,
                    QuestionId: QuestionId,
                    Item: itemArr
                };
                questionsArr.push(objArr);

            }
            return questionsArr;
        }

        function showWin(val1) {

            var isNoName = baseInfo.IsNoName || '';
            var url = "GetPersonalAdvices.aspx?ItemId=" + val1 + "&ran=" + Math.random() + "&isNoName=" + isNoName;
            opencenterwin(url, "", 735, 360);
        }
        /*  创建fusionchart  end by Phg 20120616*/
        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=auto,resizable=yes');
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <table width="750" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td align="center">
                <b class="guid"><font color="#000000"><span id="title"></span></font></b>
            </td>
            <td>
            </td>
        </tr>
    </table>
    <table width="750" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table width="750" border="0" align="center" cellpadding="0" cellspacing="0">
                    <%--                    <tr>
                        <td width="750" style="margin-top: 20px; margin-bottom: 12px; height: 12px;">
                            <fieldset>
                                <legend>问卷基本信息</legend>
                                <table class="aim-ui-table-edit" width="100%">
                                    <tr>
                                        <td class="aim-ui-td-caption" style="width: 25%">
                                            是否匿名
                                        </td>
                                        <td class="aim-ui-td-data" style="width: 25%">
                                            <span id="IsName">允许</span>
                                        </td>
                                        <td class="aim-ui-td-caption" style="width: 25%">
                                            状态
                                        </td>
                                        <td class="aim-ui-td-data" style="width: 25%">
                                            <span id="State">未完成</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="aim-ui-td-caption" style="width: 25%">
                                            开始时间
                                        </td>
                                        <td class="aim-ui-td-data" style="width: 25%">
                                            <span id="startDate">2012-12-12</span>
                                        </td>
                                        <td class="aim-ui-td-caption" style="width: 25%">
                                            结束时间
                                        </td>
                                        <td class="aim-ui-td-data" style="width: 25%">
                                            <span id="endDate">2012-11-12</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="aim-ui-td-caption" style="width: 25%">
                                            发起部门
                                        </td>
                                        <td class="aim-ui-td-data" style="width: 90%" colspan="4">
                                            <span id="DeptName"></span>
                                        </td>
                                    </tr>
                                </table>    //change by WGM 7/7
                            </fieldset>
                        </td>
                    </tr>--%>
                    <tr>
                        <td>
                            <table width="750" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>
                                        <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="E0E0E0">
                                        </table>
                                    </td>
                                </tr>
                                <tr bgcolor="#FFFFFF">
                                    <td width="100%">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="3">
                                            <tr valign="top">
                                                <td width="100%" id="SurveyList">
                                                    <%---------------------------------------%>
                                                    <div class="result_content" id="result_content" style="height: 600px; text-align: center">
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                        <table>
                                            <tr>
                                                <td height="12">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
