<%@ Page Title="问卷配置信息" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="SetConfigWin.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SetConfigWin" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        fieldset
        {
            margin-top: 15px;
            margin-bottom: 2px;
            width: 99.5%;
            margin-left: 12px;
            text-align: left;
            padding: 1px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        function onPgLoad() {
            setPageUI();
        }

        function setPageUI() {
            var objArr = AimState["personTypeEnum"] || [];
            var tpl = "<input type='checkbox' name='personType' value='{value}' />&nbsp;{name}&nbsp;";
            var temp = "";
            for (var i = 0; i < objArr.length; i++) {
                temp += tpl.replace("{value}", objArr[i]["Value"]).replace("{name}", objArr[i]["Name"])
            }
            $("#personType_cob").append(temp);

            if (!$.isEmptyObject(AimState["SurveyedObj"][0])) {
                var surObjVal = AimState["SurveyedObj"][0];


                $("#OrgNames").val(surObjVal["OrgNames"]);  //组织机构
                $("#PostionNames").val(surObjVal["PostionNames"] || "");
                $("#StartWorkTime").val(surObjVal["StartWorkTime"] || "");
                $("#UntileWorkTime").val(surObjVal["UntileWorkTime"] || "");
                //性别
                $(":radio[name='Sex']").each(function() {
                    if ($(this).val() == surObjVal["Sex"]) {
                        $(this).attr("checked", true)
                    }
                })

                //关键岗位
                if (surObjVal["CruxPositon"]) {
                    var val = surObjVal["CruxPositon"] + "";
                    if (val.indexOf("Y") > -1)
                        $("#CruxPositon_Y").attr("checked", true);
                    else if (val.indexOf("N") > -1)
                        $("#CruxPositon_N").attr("checked", true);
                }

                //年龄范围
                !!surObjVal["StartAge"] ? $("#StartAge").val(surObjVal["StartAge"]) : $("#StartAge").val("");
                !!surObjVal["EndAge"] ? $("#EndAge").val(surObjVal["EndAge"]) : $("#EndAge").val("");

                $(":radio[name='WorkAge']").each(function() {
                    if ($(this).val() == surObjVal["WorkAge"]) {
                        $(this).attr("checked", true)
                    }
                })
                //学历
                !!surObjVal["Major"] && $("#Major").val(surObjVal["Major"]);

                //岗位序列
                !!surObjVal["PositionSeq"] && $("#PositionSeq").val(surObjVal["PositionSeq"]);


                //人员类别
                $("input[name='personType']").each(function() {
                    if ((surObjVal["PersonType"] + "").indexOf($(this).val()) > -1) {
                        $(this).attr("checked", true)
                    }
                });
                //职位等级
                surObjVal["PositionDegree0"] && $("#PositionDegree_S").val(surObjVal["PositionDegree0"]);
                surObjVal["PositionDegree1"] && $("#PositionDegree_E").val(surObjVal["PositionDegree1"]);
            }
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            问卷配置信息</h1>
    </div>
    <div id="editDiv" align="center">
        <fieldset>
            <legend>基本信息</legend>
            <table class="aim-ui-table-edit">
                <tbody>
                    <tr style="display: none">
                        <td>
                            <input id="Id" name="Id" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption" style="width: 18%">
                            是否审批
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="ISCheck" name="ISCheck" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption" style="width: 18%">
                            问卷结果查看权限
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="ReaderObj" name="ReaderObj" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷积分
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="Score" name="Score" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            通知方式
                        </td>
                        <td class="aim-ui-td-data">
                            <input disabled id="NoticeWay" name="NoticeWay" name="CreateName" />
                        </td>
                    </tr>
                    <tr width="100%">
                        <td class="aim-ui-td-caption">
                            提醒方式
                        </td>
                        <td class="aim-ui-td-data">
                            <input disabled id="RemindWay" name="RemindWay" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            提醒时间
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <div>
                                【定时提醒】
                                <input id="SetTimeout" name="SetTimeout" class="Wdate" style="width: 150px" />
                            </div>
                            <div>
                                【循环提醒】 <span>问卷结束前&nbsp;</span><input type="text" id="RecyleDay" name="RecyleDay"
                                    style="width: 30px" />&nbsp;天, 在时间点
                                <input id="TimePoint" name="TimePoint" class="Wdate" style="width: 85px" />&nbsp;提醒.</div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
        <fieldset>
            <legend>调查对象</legend>
            <table class="aim-ui-table-edit" style="margin: 2px 2px">
                <tbody>
                    <tr style="display: none">
                        <td colspan="4">
                            <input id="Text1" name="Id" />
                            <input id="SurveyId" name="SurveyId" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            组织机构
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input name="OrgNames" id="OrgNames" style="width: 85%" readonly="readonly" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            工作职位
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input id="PostionNames" name="PostionNames" style="width: 85%" readonly="readonly" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            籍贯
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input type="text" id="BornAddr" name="BornAddr" style="width: 85%" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            入职时间
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="StartWorkTime" readonly="readonly" name="StartWorkTime" class="Wdate"
                                style="width: 40%" />
                            &nbsp;至&nbsp;
                            <input id="UntileWorkTime" readonly="readonly" name="UntileWorkTime" class="Wdate"
                                style="width: 40%" />
                        </td>
                        <td class="aim-ui-td-caption">
                            性别
                        </td>
                        <td class="aim-ui-td-data" style="width: 25%">
                            <input type="radio" name="Sex" id="SexAll" />
                            不限&nbsp;&nbsp;
                            <input type="radio" name="Sex" value="man" id="SexMan" />男&nbsp;
                            <input type="radio" name="Sex" value="woman" id="SexWoman" />女&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            出生日期
                        </td>
                        <td style="width: 28%" class="aim-ui-td-data">
                            <input id="StartAge" readonly="readonly" name="StartAge" class="Wdate" style="width: 40%" />
                            &nbsp;至&nbsp;
                            <input id="EndAge" readonly="readonly" name="EndAge" class="Wdate" style="width: 40%" />
                        </td>
                        <td class="aim-ui-td-caption">
                            资深员工
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="WorkAge_All" name="WorkAge" type="radio" value="0" />
                            不限
                            <input id="WorkAge_3" name="WorkAge" type="radio" value=">3" />
                            3年以上
                            <input id="WorkAge_5" name="WorkAge" type="radio" value=">5" />
                            5年以上
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            学历
                        </td>
                        <td class="aim-ui-td-data">
                            <input readonly id="Major" name="Major" style="width: 80%" />
                        </td>
                        <td class="aim-ui-td-caption">
                            职位等级
                        </td>
                        <td class="aim-ui-td-data">
                            <input name="PositionDegree_S" id="PositionDegree_S" style="width: 30px" />&nbsp;―&nbsp;
                            <input name="PositionDegree_E" id="PositionDegree_E" style="width: 30px" />
                            (请填写1-100内的数值)
                            <input type="hidden" name="PositionDegree" id="PositionDegree" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            人员类别
                        </td>
                        <td class="aim-ui-td-data">
                            <div id="personType_cob">
                            </div>
                        </td>
                        <td class="aim-ui-td-caption">
                            关键岗位
                        </td>
                        <td class="aim-ui-td-data">
                            <input type="checkbox" id="CruxPositon_Y" name="CruxPositon" value="Y" />&nbsp;是
                            &nbsp;&nbsp;<input type="checkbox" id="CruxPositon_N" name="CruxPositon" value="N" />&nbsp;否
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            岗位序列
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input readonly id="PositionSeq" name="PositionSeq" style="width: 20%" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
    </div>
</asp:Content>
