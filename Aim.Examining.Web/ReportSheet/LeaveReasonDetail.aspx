<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/SiteHasDTD.Master"
    AutoEventWireup="true" CodeBehind="LeaveReasonDetail.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.LeaveReasonDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            font-family: 微软雅黑 宋体 Verdana Arial;
            font-size: 12px;
            color: white;
        }
        .main
        {
            border-collapse: collapse;
            font-size: 1.2em;
            font-weight: bold;
        }
        .tbl_head
        {
            background-color: #339966;
            text-align: center;
        }
        .cont_left
        {
            background-color: #339966;
        }
        .cont_left table
        {
            background-color: #339966;
            border-collapse: collapse;
            border: solid 1px white;
        }
        .cont_left table td
        {
            border: 1px white solid;
        }
        .tbl_head_title
        {
            text-align: center;
        }
        .main_right
        {
            color: Black;
            font-size: 12px;
            font-weight: normal;
        }
        .main_right1
        {
            color: Black;
            font-size: 12px;
            font-weight: normal;
        }
        .main_right table td
        {
            border: 1px white solid;
            border-left: none;
            border-right: none;
        }
        ul li
        {
            width: 22px;
            text-align: center;
            margin-right: 1px;
            writing-mode: lr-tb;
            padding-top: 1px;
            float: left;
            display: inline;
            margin-top: 1px;
            border-right: solid 1px white;
            background-color: rgb(255,205,153);
        }
        .listItem
        {
            height: 223px;
            overflow: hidden;
        }
        .listItem li
        {
            display: inline;
            text-align: center;
            height: 205px;
        }
        .btLi
        {
            background-color: rgb(204,255,204);
        }
        .x-combo-list-item
        {
            color: Black;
        }
        .reasonTbl
        {
            margin-left: 2.7%;
            margin-top: 5px;
            font-size: 1em;
            color: Black;
            border-collapse: collapse;
        }
        .reasonTbl td
        {
            height: 50px;
            border: 1px solid rgb(51,153,102);
            font-size: 1.1em;
            font-weight: bold;
            padding: 5px 10px 5px 10px;
        }
    </style>

    <script type="text/javascript">
        var year = "", month = "";
        year = $.getQueryString({ ID: 'year' }) || new Date().getFullYear();
        month = $.getQueryString({ ID: 'month' }) || new Date().getMonth() + 1;

        function onPgLoad() {
            //var ct_width = $(".main").innerWidth();
            // $("#mainTbl").innerWidth();  //实际内容宽度

            $("body").width(1350);
            setPgUI();
        }
        function setPgUI() {
            var MonthTotal = '<%=MonthTotal %>'
            var YearTotal = '<%=YearTotal %>'
            
            $("#sHear").text(year + "年" + month + "月份" + "离职原因分析表");

            //分值比率计算
            var leng = $(".main_right").length;
            //---年份----
            for (var i = 0; i < leng; i++) {
                var tep = $("#cur_YearTotal_" + i).text();
                $("#yearTotal_" + i).text(tep);
                if (parseInt(tep) == 0) {
                    tep = 0;
                } else {
                    var rate = parseFloat((parseInt(tep) * 100 / YearTotal));
                    var num = new Number(rate);
                    tep = num.toFixed(1);
                }
                $("#yearRate_" + i).text(tep + "%");
            }

            //----月份计算----
            for (var i = 0; i < leng; i++) {
                var tep = 0;
                $("#cur_MonthTotal_" + i + " li").each(function() {
                    tep += parseInt($(this).text());
                });

                $("#monthTotal_" + i).text(tep);
                if (parseInt(tep) == 0) {
                    tep = 0;
                } else {
                    var rate = parseFloat((parseInt(tep) * 100 / MonthTotal));
                    var num = new Number(rate);
                    tep = num.toFixed(1);
                }
                $("#monthRate_" + i).text(tep + "%");
            }


            //最后汇总

            $("#F_YearTotal,#F_YearTotal_t").text(YearTotal);
            $("#F_monthTotal").text(MonthTotal);


            //概要表格汇总
            for (var i = 0; i < leng; i++) {
                //月 year
                var mr = $("#monthRate_" + i).text();
                var yr = $("#yearRate_" + i).text();

                $("#monthR tr:eq(1) td").eq(i + 1).text(mr);
                $("#yearR tr:eq(1) td").eq(i + 1).text(mr);
            }
        }
       
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div class="main">
        <table id="mainTbl">
            <tbody>
                <tr class="tbl_head">
                    <td colspan="100" style="height: 40px" id="sHear">
                    </td>
                </tr>
                <tr>
                    <td class="cont_left">
                        <table>
                            <tr class="tbl_head_title">
                                <td colspan="2" style="height: 24px; text-align: center">
                                    类别
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td rowspan="5" style="padding-left: 1px;">
                                    &nbsp;IDL
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td>
                                    本月离职人数
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td>
                                    %（本月）
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td>
                                    本年度累计离职人数&nbsp;&nbsp;
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td>
                                    %（累计）
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" style="width: 10px; vertical-align: middle; writing-mode: lr-tb;
                                    padding-left: 50%; height: 220px">
                                    離職原因分析
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td rowspan="3">
                                    &nbsp;IDL
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td style="font-size: 14px">
                                    本月
                                </td>
                            </tr>
                            <tr class="tbl_head_title">
                                <td style="font-size: 14px">
                                    年度累計
                                </td>
                            </tr>
                        </table>
                    </td>
                    <!-- --------------------------------内容部分-------------------------------------------->
                    <%for (int i = 0; i < QItm.Count; i++){%>
                    <td class="main_right">
                        <table style="border-collapse: collapse; border: solid 1px #339966; border-left: none;
                            margin-top: 3px; table-layout: inherit">
                            <tr style="background-color: #339966; height: 24px; text-align: center">
                                <td>
                                    <b>
                                        <%=QItm[i].type.ToString().Replace("（请透露影响您离开飞力达的主要原因：请于8-12题选项中选择您离开飞力达最主要的前三项原因，请在选项说明中以1、2、3表示）","") %></b>
                                </td>
                            </tr>
                            <tr style="background-color: rgb(204,255,204); text-align: center; font-size: 14px;">
                                <td id="monthTotal_<%=i %>">
                                </td>
                            </tr>
                            <tr style="background-color: rgb(204,255,204); text-align: center; font-size: 14px;">
                                <td id="monthRate_<%=i %>">
                                </td>
                            </tr>
                            <tr style="background-color: rgb(255,255,153); text-align: center; font-size: 14px;">
                                <td style="margin-top: 2px" id="yearTotal_<%=i %>">
                                </td>
                            </tr>
                            <tr style="background-color: rgb(255,255,153); text-align: center; font-size: 14px;">
                                <td id="yearRate_<%=i %>">
                                </td>
                            </tr>
                            <tr>
                                <td class="listItem" style="vertical-align: top;">
                                    <ul style="margin-top: 2px; margin-left: 2px; margin-right: 2px;">
                                        <%for (int j = 0; j < QItm[i].items.Count; j++){%>
                                        <li><span>
                                            <%=QItm[i].items[j]%></span> </li>
                                        <%}%>
                                    </ul>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <ul id="cur_MonthTotal_<%=i %>">
                                        <%for (int k = 0; k < QItm[i].items.Count; k++){%>
                                        <li class="btLi">
                                            <%=QItm[i].itemsChoices[k] %>
                                        </li>
                                        <%}%>
                                    </ul>
                                </td>
                            </tr>
                            <tr>
                                <td id="cur_YearTotal_<%=i %>" style="background-color: rgb(255,255,153); text-align: center">
                                    <%=QItm[i].yearTotal%>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <%}%>
                    <td class="main_right1">
                        <table style="border-collapse: collapse; border: solid 1px #339966; border-left: none;
                            margin-top: 3px; table-layout: inherit">
                            <tr style="background-color: #339966; height: 24px; text-align: center">
                                <td style="border-bottom: solid 1px white">
                                    <b>TOTAL</b>
                                </td>
                            </tr>
                            <tr style="background-color: rgb(204,255,204); text-align: center; font-size: 14px;">
                                <td id="F_monthTotal" style="border-bottom: solid 1px white">
                                </td>
                            </tr>
                            <tr style="background-color: rgb(204,255,204); text-align: center; font-size: 15px;">
                                <td style="border-bottom: solid 1px white">
                                    100.0%
                                </td>
                            </tr>
                            <tr style="background-color: rgb(255,255,153); text-align: center; font-size: 15px;">
                                <td style="margin-top: 2px; border-bottom: solid 1px white" id="F_YearTotal_t">
                                </td>
                            </tr>
                            <tr style="background-color: rgb(255,255,153); text-align: center; font-size: 15px;">
                                <td>
                                    100.0%
                                </td>
                            </tr>
                            <tr>
                                <td class="listItem" style="vertical-align: top;">
                                    <ul>
                                        <li style="width: 50px"></li>
                                    </ul>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <ul>
                                        <li class="btLi" style="width: 50px"></li>
                                    </ul>
                                </td>
                            </tr>
                            <tr>
                                <td style="background-color: rgb(255,255,153); text-align: center" id="F_YearTotal">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div id="tbl_content">
        <table class="reasonTbl" id="monthR">
            <!--
            <tr>
                <td rowspan="2">
                    本月
                </td>
                <td>
                    Reason
                </td>
                <%for (int i = 0; i < QItm.Count; i++){%>
                <td>
                    <%-- <%=QItm[i].type.ToString().Replace("（请透露影响您离开飞力达的主要原因：请于8-12题选项中选择您离开飞力达最主要的前三项原因，请在选项说明中以1、2、3表示）","")%>--%>
                </td>
                <%}%>
            </tr>
            <tr>
                <td>
                    IDL
                </td>
                <%for (int i = 0; i < QItm.Count; i++){%>
                <td>
                </td>
                <%}%>
            </tr>-->
        </table>
        <table class="reasonTbl" id="yearR">
            <!--
            <tr>
                <td rowspan="2">
                    累计(年)
                </td>
                <td>
                    Reason
                </td>
                <%for (int i = 0; i < QItm.Count; i++){%>
                <td>
                    <%--  <%=QItm[i].type%>--%>
                </td>
                <%}%>
            </tr>
            <tr>
                <td>
                    IDL
                </td>
                <%for (int i = 0; i < QItm.Count; i++){%>
                <td>
                </td>
                <%}%>
            </tr>-->
        </table>
    </div>
</asp:Content>
