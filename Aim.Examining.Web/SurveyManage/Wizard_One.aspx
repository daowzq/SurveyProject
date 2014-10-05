<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="Wizard_One.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Wizard_One" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .aim-ui-td-data
        {
            font-size: 12px;
        }
        fieldset
        {
            margin-top: 15px;
            margin-bottom: 2px;
            width: 100%;
            margin-left: 12px;
            text-align: left;
            padding: 1px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .tip
        {
            font-weight: bold;
            color: Red;
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        var SortIndex = $.getQueryString({ ID: 'SortIndex' });
        var id = $.getQueryString({ ID: "id" });
        var type = $.getQueryString({ ID: "type" });  //操作状态
        var slider;
        function onPgLoad() {
            setPgUI();
            stateInit();
        }

        function setPgUI() {
            //            slider = new Ext.Slider({
            //                renderTo: "awardDiv",
            //                width: 220,
            //                value: 0,
            //                increment: 3,
            //                minValue: 0,
            //                maxValue: 100
            //            });

            //            slider.on("dragend", function(slider, e) {
            //                $("#indicate").text(slider.getValue());
            //                $("#AwardRate").val(slider.getValue());
            //            })
        }

        //----------------提交事件处理-------------
        function doSubmit(successFun, failureFun) {
            if (typeof (successFun) != "function" || typeof (failureFun) != "function") return;
            //验证
            var isture = true;
            $("[class*='validate[required]']").each(function() {
                if ($(this).val()) {
                    clrToolTip($(this).attr("id"));
                } else {
                    setToolTip($(this).attr("id"));
                    failureFun();
                    isture = false;
                }
            })
            if (isture) successFun();
        }

        //设置tip
        function setToolTip(selector, txt) {
            txt = txt || '必填项';
            if ($("#" + selector).next("span").length > 0) return;
            if ($("#" + selector).next("a").length > 0) {  //组织结构
                $("#" + selector).next().after("<span class='tip' >* " + txt + "</span>")
            } else {
                $("#" + selector).after("<span class='tip' >* " + txt + "</span>")
            }
        }
        function clrToolTip(selector) {
            if ($("#" + selector).next("a").length > 0) {
                if ($("#" + selector).next().next("span").length > 0) {
                    $("#" + selector).next().next("span").remove();
                }
            } else {
                if ($("#" + selector).next("span").length > 0) {
                    $("#" + selector).next("span").remove();
                }
            }
        }

        function SuccessSubmit(afterSaveFun) {
            //查看状态
            if (type == "view") {
                parent.afterSave.call(this, "1", "1");
                return;
            }

            //通知方式的选中
            var tmp = "";
            $("#Message,#Email").each(function() {
                if ($(this).attr("checked")) tmp = $(this).val() + "," + tmp;
            });
            $("#NoticeWay").val(tmp);

            //问卷类型
            var SurveyTypeId = "", SurveyTypeName = "";
            SurveyTypeId = $("#SurveyTypeName option:selected").val();
            SurveyTypeName = $("#SurveyTypeName option:selected").text();

            AimFrm.submit(pgAction, { SurveyTypeId: SurveyTypeId, SurveyTypeName: SurveyTypeName }, null, function() {
                //回写
                $("#SurveyTypeName option").each(function() {
                    if (SurveyTypeId == $(this).val()) {
                        $(this).attr("selected", true);
                    }
                });
                var ckVal = $("#NoticeWay").val() || '';
                $("#Message,#Email").each(function() {
                    ckVal.indexOf($(this).val()) > -1 && $(this).attr("checked", true);
                });

                parent.afterSave.call(this, "1", "1");  //调用父类的方法
            });
        }

        //-----状态初始化-----------
        function stateInit() {
            $("#Id").val(id)  // id 赋值

            $("#EffectiveCount").keyup(function(e) {
                $(this).val($(this).val().replace(/\D|^0/g, ''));
            }).css("ime-mode", "disabled");

            //通知方式赋值
            if ($("#NoticeWay").val()) {
                var ckVal = $("#NoticeWay").val();
                $("#Message,#Email").each(function() {
                    ckVal.indexOf($(this).val()) > -1 && $(this).attr("checked", true);
                });
            } else {
                $("#Email").attr("checked", true);
            }
            //匿名
            if ($("#Id").val()) {
                (AimState["frmdata"]["IsNoName"] + "") == "1" && $("#yes").attr("checked", true)
            }

            // slider 赋值无效
            //$("#AwardRate").val() && slider.setValue($("#AwardRate").val(), false);  //slider 赋值
            $("#AwardRate").val() && $("#indicate").text($("#AwardRate").val())

            //问卷类型选择
            $("#SurveyTypeName option").each(function() {
                $(this).val() == $("#SurveyTypeId").val() && $(this).attr("selected", true);
            });
            $("#SurveyTypeName").change(function() {
                $("#AddFilesName").val("").dataBind("");
                $(this).val() && $.ajaxExec("GetTypeInfo", { typeId: $(this).val() }, function(rtn) {
                    $("#AddFilesName").dataBind(rtn.data.TypeInfo[0].AddFilesName || "");
                    //  $("#WorkFlowTxt").text(rtn.data.TypeInfo[0].WorkFlowName);  //流程名称
                    //  $("#WorkFlowName").val(rtn.data.TypeInfo[0].WorkFlowName);  //流程名称
                    //  $("#WorkFlowCode").val(rtn.data.TypeInfo[0].WorkFlowId);    //流程Code
                });
            });

            //问卷模板 TemplateId
            $("#TemplateName").change(function() {
                $(this).children().each(function() {
                    if ($(this).attr("selected")) {
                        $("#TemplateId").val($(this).val());
                        var tplVal = $(this).val();
                        var tplTxt = !!tplVal ? $(this).text() : "";

                        $("#template").children().remove();
                        $("#template").append("<a href=# val='" + tplVal + "' onclick='openTemplateWin(this)' >" + tplTxt + "</a>");
                    }
                })
            })
            if ($("#TemplateName>option:selected").val()) {
                var tpl = $("#TemplateName>option:selected").val();
                var txt = $("#TemplateName>option:selected").text();
                $("#template").append("<a href=# val='" + tpl + "' onclick='openTemplateWin(this)' >" + txt + "</a>");
            }


            //查看工作流
            $("#WorkFlowName").click(function() {
                // if (!$(this).val()) return;   //无值返回
                //openFlowWin();
            });

        }

        function openTemplateWin(obj) {
            var url = "InternetSurvey.aspx?op=v&type=read";
            var EditWinStyle = "dialogWidth=1000px;dialogHeight=600px;scroll=1";
            var id = $(obj).attr('val');
            url += "&Id=" + id;

            if (id) {
                var rtn = window.showModalDialog(url, window, EditWinStyle);
            } else {
                return false;
            }
        }

        //打开流程预览框
        function openFlowWin() {
            AimDlg.show("流程为未定义!");
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            基本设置</h1>
    </div>
    <div id="editDiv" align="center">
        <fieldset>
            <legend>基本信息</legend>
            <table class="aim-ui-table-edit" style="margin: 2px 2px">
                <tbody>
                    <tr style="display: none">
                        <td colspan="4">
                            <input id="Id" name="Id" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷类型
                        </td>
                        <td class="aim-ui-td-data" style="width: 30%">
                            <select id="SurveyTypeName" name="SurveyTypeName" aimctrl="select" enum='AimState["TypeEnum"]'
                                style="width: 77%" class="validate[required]">
                            </select>
                            <input type="hidden" name="SurveyTypeId" id="SurveyTypeId" />
                        </td>
                        <td class="aim-ui-td-caption">
                            问卷编号
                        </td>
                        <td class="aim-ui-td-data" style="width: 30%">
                            <input id="TypeCode" name="TypeCode" class="validate[required]" style="width: 77%" />
                        </td>
                    </tr>
                    <%--                    <tr>
                        <td class="aim-ui-td-caption">
                            审批流程
                        </td>
                        <td colspan="3">
                            <span id="WorkFlowTxt" style="width: 39%; border: 0; border-bottom: 1 solid black;
                                background: #F2F2F2; color: Blue;"></span>
                            <input id="WorkFlowCode" name="WorkFlowCode" type="hidden" />
                            <input id="WorkFlowName" name="WorkFlowName" type="hidden" />
                        </td>
                    </tr>--%>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷标题
                        </td>
                        <td colspan="3">
                            <input id="SurveyTitile" name="SurveyTitile" style="width: 91%" class="validate[required]" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷描述
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <textarea rows="4" style="width: 91%" id="Description" name="Description"></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            开始时间
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="StartTime" readonly name="StartTime" class="Wdate validate[required]"
                                style="width: 70%" onclick="var date=$('#EndTime').val()?$('#EndTime').val():'';                                             
                         WdatePicker({maxDate:date,minDate:new Date(),dateFmt:'yyyy/MM/dd'})" />
                        </td>
                        <td class="aim-ui-td-caption">
                            结束时间
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="EndTime" readonly name="EndTime" class="Wdate validate[required]" style="width: 76%"
                                onclick="var date=$('#StartTime').val()?$('#StartTime').val():new Date();  
                        WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            所属公司
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="CompanyName" name="CompanyName" readonly="readonly" style="width: 74%" />
                            <input id="CompanyId" name="CompanyId" type="hidden" />
                        </td>
                        <td class="aim-ui-td-caption">
                            发布部门
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="DeptName" name="DeptName" readonly="readonly" style="width: 68%" />
                            <input id="DeptId" name="DeptId" type="hidden" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            相关附件
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input id="AddFilesName" name="AddFilesName" aimctrl='file' style="width: 93%" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
        <fieldset>
            <legend>其他信息</legend>
            <table class="aim-ui-table-edit" style="margin: 2px 2px">
                <tbody>
                    <tr>
                        <td class="aim-ui-td-caption">
                            奖励分
                        </td>
                        <td class="aim-ui-td-data" style="width: 30%">
                            <select name="Score" id="Score">
                                <option value="0">0</option>
                                <option value="1">1</option>
                                <option value="3">3</option>
                                <option value="5">5</option>
                                <option value="10">10</option>
                                <option value="15">15</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷模板
                        </td>
                        <td class="aim-ui-td-data">
                            <select id="TemplateName" name="TemplateName" aimctrl='select' enum="tplEnum" style="width: 60%">
                            </select>
                            <input type='hidden' id="TemplateId" name="TemplateId" />
                        </td>
                        <td class="aim-ui-td-data" style="width: 50%" colspan="2">
                            <span id="template" style="width: 50%; border: 0; border-bottom: 1 solid black; background: #F2F2F2;
                                color: Blue;"></span>
                        </td>
                    </tr>
                    <tr>
                        <!--                        <td class="aim-ui-td-caption">
                            是否匿名
                        </td>
                        <td class="aim-ui-td-data">
                            <input type="radio" name="IsNoName" value="1" id="yes" />是&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input
                                type="radio" name="IsNoName" value="0" checked="checked" />否
                        </td>-->
                        <td class="aim-ui-td-caption">
                            随机推送
                        </td>
                        <td class="aim-ui-td-data">
                            <input type="radio" name="IsSendRandom" value="1" />是&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;<input
                                type="radio" name="IsSendRandom" value="0" checked="checked" />否
                        </td>
                        <td class="aim-ui-td-caption">
                            问卷数量
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="EffectiveCount" name="EffectiveCount" style="width: 64%" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            通知方式
                        </td>
                        <td class="aim-ui-td-data" style="width: 30%">
                            <input type="hidden" id="NoticeWay" name="NoticeWay" />
                            <input type="checkbox" name="Notice" value="Email" id="Email" />邮件 &nbsp;&nbsp;
                            <input type="checkbox" name="Notice" value="Message" id="Message" />短信
                        </td>
                        <td class="aim-ui-td-caption">
                            定时提醒
                        </td>
                        <td class="aim-ui-td-data" style="width: 30%">
                            <input id="SetTimeout" name="SetTimeout" class="Wdate" style="width: 64%" onfocus="var date=$('#StartTime').val()?$('#StartTime').val():new Date(); WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" />
                        </td>
                    </tr>
                    <!-- 
                    <tr>
                        <td class="aim-ui-td-caption">
                            有奖调查
                        </td>
                        <td>
                            <div id="awardDiv">
                            </div>
                            <input id="AwardRate" name="AwardRate" type="hidden" />
                        </td>
                        <td colspan="2">
                            <span style="float: left;">中奖率:</span><span id="indicate">0</span>&nbsp;&nbsp;(单位:%)
                        </td>
                    </tr>
                    -->
                </tbody>
            </table>
        </fieldset>
    </div>
</asp:Content>
