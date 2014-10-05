<%@ Page Title="发布问卷" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="SurveyQuestionWizard.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyQuestionWizard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <link href="js/smart_wizard.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .swMain .stepContainer div.content
        {
            width: 99.9%;
            clear: both;
            height: 500px;
        }
        .aim-ui-td-data
        {
            font-size: 12px;
        }
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
        .tip
        {
            font-weight: bold;
            color: Red;
        }
    </style>
    <script src="js/jquery.smartWizard.js" type="text/javascript"></script>
    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>
    <script src="js/SurveyItemsAdd.js" type="text/javascript"></script>
    <script src="js/SurveyImg.js" type="text/javascript"></script>
    <script src="/js/fckeditor/fckeditor.js" type="text/javascript"></script>
    <script type="text/javascript">

        var SurveyId = $.getQueryString({ ID: "id" }) || "";
        var type = $.getQueryString({ ID: "type" });  // 操作类型 当view时 不保存
        //        var MajorEnum = { "高中": "高中", "大专": "大专", "大学": "大学", "研究生": "研究生", "硕士": "硕士", "博士": "博士" }
        //加载标志
        var WizardInit = "";
        var wizarTwoInit = false;
        var HaveReview = "";  //wizard two 查看预览
        var gridQuestion;
        window.onerror = function (sMessage, sUrl, sLine) {
            return true
        };
        function onPgLoad() {

            window.onbeforeunload = function () {
                var n = window.event.screenX - window.screenLeft;
                var b = n > document.documentElement.scrollWidth - 35;
                if (b && window.event.clientY < 0 || window.event.altKey) {
                    $.ajaxExecSync("Close", { Id: SurveyId || '' }, function (rtn) { //关闭窗口
                        // //判断是否存在store对象,然后进行刷新
                        // if (typeof window.opener.store !== "undefined") {
                        //     window.opener.store.reload();
                        // } else {
                        //     window.opener.location.reload();
                        // }
                        // window.opener.store.reload();
                        // window.close();

                        window.returnValue = "true";  //  模态窗口
                        window.close();
                    });
                }
            }
            setPgUI();
        }
        function setPgUI() {
            $("#Id").val(SurveyId);
            initWizard();

            calcWizardSize();
            wizardOneRender();
            //wizarTwoRender();       //wizard two
            //wizardThreeRender();    //wizard three
            //wizardFourRender();     //wizard four

        }

        function initWizard() {
            $('#wizard').smartWizard({
                labelNext: '下一步',
                labelPrevious: '上一步',
                labelFinish: '完成',
                onLeaveStep: leavestepCallback,
                onShowStep: showstepCallback,
                onFinish: onFinish,
                keyNavigation: false,
                //enableFinishButton: true
                enableAllSteps: true // 允许点击所有步骤
            });
        }


        //离开
        function leavestepCallback(obj) {
            var step_num = obj.attr('rel');
            if (step_num == "1") {
                //----判断---------------
                var isture = true;
                $("[class*='validate[required]']").each(function () {
                    if ($(this).val()) {
                        clrToolTip($(this).attr("id"));
                    } else {
                        setToolTip($(this).attr("id"));
                        isture = false;
                    }
                })
                if (!isture) {
                    AimDlg.show("你有未填的内容");
                    return false;
                };

                //通知方式
                var NoticeWay = "";
                $("#Message,#Email").each(function () {
                    if ($(this).attr("checked")) NoticeWay = NoticeWay + "," + $(this).val();
                });
                //问卷类型
                var SurveyTypeId = "", SurveyTypeName = "";
                SurveyTypeId = $("#SurveyTypeName option:selected").val();
                SurveyTypeName = $("#SurveyTypeName option:selected").text();
                //查看对象配置
                var ReaderObj = "";
                $("input[name='ReaderObj']:checked").each(function (i) {
                    if (i > 0) ReaderWay += ",";
                    ReaderObj += $(this).val();
                })
                //提醒方式 RemindWay
                var RemindWay = "";
                $("input[name='RemindWay']:checked").each(function (i) {
                    if (i > 0) RemindWay += ",";
                    RemindWay += $(this).val();
                })

                //提醒时间
                var RecyleDay = $("#RecyleDay").val();
                var TimePoint = $("#TimePoint").val();
                //描述
                var fck = FCKeditorAPI.GetInstance("Description");

                var isHaveSave = false;
                $.ajaxExecSync("SurveyOneSave", {
                    SurveyId: SurveyId,
                    NoticeWay: NoticeWay,
                    SurveyTypeId: SurveyTypeId,
                    SurveyTypeName: SurveyTypeName,
                    TypeCode: $("#TypeCode").val(),
                    SurveyTitile: $("#SurveyTitile").val(),
                    Description: fck.GetXHTML(),
                    StartTime: $("#StartTime").val(),
                    EndTime: $("#EndTime").val(),
                    CompanyName: $("#CompanyName").val(),
                    CompanyId: $("#CompanyId").val(),
                    DeptName: $("#DeptName").val(),
                    DeptId: $("#DeptId").val(),
                    RemindWay: RemindWay,
                    AddFilesName: $("#AddFilesName").val(),
                    Score: $("#Score").val(),
                    SetTimeout: $("#SetTimeout").val(),
                    ReaderObj: ReaderObj,
                    RecyleDay: RecyleDay,
                    TimePoint: TimePoint
                }, function () {
                    isHaveSave = true;
                });
                return isHaveSave;
            }
            else if (step_num == "2") {

                var isStay = false;
                var operEle = document.documentElement;
                var OrgIds = $("#OrgIds", operEle).val();    //组织机构
                var OrgNames = $("#OrgNames", operEle).val(); //
                if (OrgNames.indexOf("飞力集团") > -1) OrgIds = OrgNames = "";

                var PostionIds = $("#PostionIds", operEle).val();
                var PostionNames = $("#PostionNames", operEle).val();

                var BornAddr = $("#BornAddr", operEle).val(); //籍贯
                BornAddr = (BornAddr + "").indexOf("籍贯") > -1 ? "" : BornAddr;

                var StartWorkTime = $("#StartWorkTime", operEle).val();
                var UntileWorkTime = $("#UntileWorkTime", operEle).val();

                var Sex = $(":radio[name='Sex']:checked", operEle).val(); //性别
                var StartAge = $("#StartAge", operEle).val();        //年龄范围
                var EndAge = $("#EndAge", operEle).val();
                var WorkAge = $(":radio[name='WorkAge']:checked", operEle).val(); //资深员工
                var Major = $("#Major").val();                      //学历

                //   $("[name='Major']:checked", operEle).each(function(i) {
                //       if (i > 0 && $(this).val()) Major += ",";
                //       Major += $(this).val();
                //    });
                var PersonType = "";   //人员类别
                $("input[name='personType']:checked").each(function (i) {
                    if (i > 0 && $(this).val()) PersonType += ",";
                    PersonType += $(this).val();
                });

                //关键岗位
                var CruxPositon = $("input[name='CruxPositon']:checked").val() || "";

                //职位等级
                var PositionDegree0 = $("#PositionDegree_S").val();
                var PositionDegree1 = $("#PositionDegree_E").val();

                var PositionSeq = $("#PositionSeq").val();  //岗位序列
                $.ajaxExecSync("SaveSurveyedObj", {
                    SurveyId: SurveyId,
                    OrgIds: OrgIds,
                    OrgNames: OrgNames,
                    PostionIds: PostionIds,
                    PostionNames: PostionNames,
                    BornAddr: $.trim(BornAddr),
                    StartWorkTime: StartWorkTime,
                    UntileWorkTime: UntileWorkTime,
                    Sex: Sex,
                    StartAge: StartAge,
                    EndAge: EndAge,
                    WorkAge: WorkAge,
                    Major: Major,
                    PositionSeq: PositionSeq,
                    CruxPositon: CruxPositon,
                    PersonType: PersonType,
                    PositionDegree0: PositionDegree0,
                    PositionDegree1: PositionDegree1
                }, function (rtn) {
                    if (!HaveReview) {

                        Ext.getBody().mask("问卷人员生成中，请稍等...");
                        $.ajaxExecSync("CreateUser", { SurveyId: SurveyId }, function (rtn) {
                            Ext.getBody().unmask();
                            if (rtn.data.CreateState == "1") {
                                var task = new Ext.util.DelayedTask();
                                task.delay(50, function () {
                                    // userViewFrm.location.reload(); //重新加载
                                    userViewFrm.location.href = userViewFrm.location.href;
                                });

                                //是否停留该步骤
                                if (confirm("被问卷人员生成成功,是否到下一步配置问卷内容？")) {
                                    HaveReview = true;  //表示生成人员,有人人员
                                } else {
                                    HaveReview = false;  //表示生成人员,有人人员
                                    isStay = true;
                                }
                                // AimDlg.show("调查问卷人员生成成功!");

                            } else if (rtn.data.CreateState == "0") {
                                alert("没有筛选到符合条件的人员!");
                                HaveReview = false; //表示无人员
                                // AimDlg.show("没有筛选到符合条件的人员!")
                            } else {
                                alert("调查问卷人员生成失败!");
                                HaveReview = false;
                                //AimDlg.show("调查问卷人员生成失败!");
                            }
                        }, null, "Comman.aspx");
                    }
                }, null, "Comman.aspx");


                if (HaveReview) {  //生成人员
                    return true;
                } else if (!HaveReview && isStay) {
                    return false;
                }
                else {
                    AimDlg.show("请生成人员或导入人员!");
                    return false;
                }
            }
            else if (step_num == "3") {
                if (!store_Qustion.getRange().length) {
                    AimDlg.show("请添加问卷内容!");
                    return false;
                } else {
                    return true;
                }
            }
            else if (step_num == "4") {
                return true;
            }

        }
        //完成结束
        function onFinish() {
            if (confirm("确定生成此次问卷配置吗？")) {
                // window.opener.opener = null; 关闭窗口
                // if (window.opener.store != undefined) {
                //     window.opener.store.reload();
                // }
                // window.opener.close();
                // window.close();
                //                $.ajaxExec("havaQuestion", { SurveyId: SurveyId }, function(rtn) {
                //                    if (rtn.data.State == "1") {
                //                        window.returnValue = "true";  //  模态窗口
                //                        window.close();
                //                    } else {
                //                        AimDlg.show("请设置调查对象!");
                //                        return;
                //                    }
                //                });
                window.returnValue = "true";  //  模态窗口
                window.close();
            }

            //            var url = "Wizard_Finish.aspx?SurveyId=" + SurveyId + "&type=" + "iframesign";
            //            var task = new Ext.util.DelayedTask();
            //            task.delay(50, function() {
            //                opencenterwin(url, "", 800, 550);
            //            });
        }

        //显示该步
        function showstepCallback(obj) {
            var step_num = obj.attr('rel');  //操作符
            var opg = (pgAction == "c" || pgAction == "create") ? "c" : "r";
            if (step_num == "2") {
                if (!wizarTwoInit) {
                    wizarTwoRender();
                }
            }
            else if (step_num == "4") {
                var task = new Ext.util.DelayedTask();
                task.delay(120, function () {
                    stepFour.location.href = "InternetSurveyView.aspx?SurveyId=" + SurveyId + "&type=" + type;
                });
            } else if (step_num == "3") {
                if (!WizardInit) {
                    wizardThreeRender();
                }
            }
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

        //------------------wizard one ------------------------
        function wizardOneRender() {
            //初始化状态
            if (AimState["frmdata"]) {
                if (AimState['frmdata']["SurveyTypeName"]) {
                    $("#SurveyTypeName option").each(function () {
                        if ($(this).text() == AimState['frmdata']["SurveyTypeName"]) {
                            $(this).attr("selected", true)

                        }
                    });
                }
                if (AimState['frmdata']["NoticeWay"]) {
                    $("input[name='Notice']").each(function () {
                        if ((AimState['frmdata']["NoticeWay"] + "").indexOf($(this).val()) > -1) {
                            $(this).attr("checked", true)
                        } else {
                            $(this).removeAttr("checked")
                        }
                    })
                }
                //查看权限
                if (AimState['frmdata']["ReaderObj"]) {
                    $("input[name='ReaderObj']").each(function () {
                        if ((AimState['frmdata']["ReaderObj"] + "").indexOf($(this).val()) > -1) {
                            $(this).attr("checked", true)
                        }
                        else {
                            $(this).removeAttr("checked")
                        }
                    })
                }

                //提醒方式 RemindWay
                if (AimState['frmdata']["RemindWay"]) {
                    $("input[name='RemindWay']").each(function () {
                        if ((AimState['frmdata']["RemindWay"] + "").indexOf($(this).val()) > -1) {
                            $(this).attr("checked", true)
                        }
                        else {
                            $(this).removeAttr("checked")
                        }
                    })
                }
            }
            //问卷积分
            $("#Score").keyup(function (e) {
                if ($(this).val().length > 2) {
                    $(this).val($(this).val().substring(0, 2))
                }
                $(this).val($(this).val().replace(/\D|^0/g, ''));
            }).css("ime-mode", "disabled");

            //定时提醒
            $("#SetTimeout").click(function () {
                if (!$('#StartTime').val() || !$('#StartTime').val()) {
                    AimDlg.show('请输入问卷开始时间或结束时间!');
                    return;
                };
                var date = $('#StartTime').val() ? $('#StartTime').val() : new Date();
                var maxDate = $('#EndTime').val(); WdatePicker({ minDate: date, dateFmt: 'yyyy/MM/dd HH:mm:ss', maxDate: maxDate })
            });

            $("#RecyleDay").keyup(function (e) {
                if ($(this).val().length > 2) {
                    $(this).val($(this).val().substring(0, 2))
                }

                $(this).val($(this).val().replace(/\D|^0/g, ''));
                var dayDiff = 0;
                if ($("#EndTime").val() && $("#StartTime").val()) {
                    dayDiff = $.dateDiff($.toDate($("#StartTime").val()), $.toDate($("#EndTime").val()));
                    if (parseInt(($(this).val() || 0)) > dayDiff) {
                        $(this).val("");
                        AimDlg.show("请输入小于或等于" + (dayDiff - 1) + " 的数值!");
                        return
                    }
                } else {
                    $(this).val("");
                    AimDlg.show("请设置问卷开始时间和结束时间!");
                    return;
                }
            })
        }

        //------------------wizard two grid------------------------
        function wizarTwoRender() {
            wizarTwoInit = true
            wizardTwoPst(); //职位初始化
            //bornAddr();     //籍贯初始化
            personTypeInit(); //人员类别
            $("#PositionDegree_S").keyup(function () {
                if ($(this).val().length > 2) {
                    $(this).val($(this).val().substring(0, 2))
                }
                $(this).val($(this).val().replace(/\D|^0/g, ''));
            });

            $("#PositionDegree_E").keyup(function () {
                if ($(this).val().length > 2) {
                    $(this).val($(this).val().substring(0, 2))
                }
                $(this).val($(this).val().replace(/\D|^0/g, ''));

                if ($("#PositionDegree_S").val()) {

                    //                    var task = new Ext.util.DelayedTask();
                    //                    task.delay(50, function() {
                    //                    if (parseInt($(this).val() || 0) < parseInt($("#PositionDegree_S").val() || 0)) {
                    //                        $(this).val("");
                    //                    }
                    if ($(this).val() < $("#PositionDegree_S").val()) {
                        $(this).val("");
                    }
                    //});
                }
            }).focusout(function () {
                if ($("#PositionDegree_S").val()) {
                    if ($(this).val() < $("#PositionDegree_S").val()) {
                        $(this).val("");
                    }
                }
            });

            //    //关键岗位
            //    $("#CruxPositon_Y").click(function() {
            //        if ($("#CruxPositon_Y").attr("checked")) {
            //            $("#CruxPositon_N").attr("checked", false);
            //        }
            //    });
            //    $("#CruxPositon_N").click(function() {
            //        if ($("#CruxPositon_N").attr("checked")) {
            //            $("#CruxPositon_Y").attr("checked", false)
            //        }
            //     });

            //初始化状态
            if (AimState["SurveyedObj"]) {

                // 籍贯
                if ($.isEmptyObject(AimState["SurveyedObj"][0]) || !$.trim(AimState["SurveyedObj"][0]["BornAddr"])) {
                    $("#BornAddr").css({ color: "gray" }).val("输入多个籍贯时请使用\",\" 符号分割,如:上海,武汉").focusin(function () {
                        $(this).val("")
                    }).focusout(function () {
                        if (!$(this).val()) {
                            $(this).val("输入多个籍贯时请使用\", \"符号分割,如:上海,武汉").css({ color: 'gray' });
                            $(this).bind("focusin", function () {
                                $(this).val("")
                            });
                        } else {
                            $(this).css({ color: 'black' });
                            $(this).unbind("focusin");
                        }
                    })
                } else {
                    $("#BornAddr").val(AimState["SurveyedObj"][0]["BornAddr"]);
                }

                if (!$.isEmptyObject(AimState["SurveyedObj"][0])) {
                    var surObjVal = AimState["SurveyedObj"][0];

                    $("#OrgIds").val(surObjVal["OrgIds"]);    //组织机构
                    $("#OrgNames").val(surObjVal["OrgNames"]); //

                    $("#PostionIds").val(surObjVal["PostionIds"] || "");
                    $("#PostionNames").val(surObjVal["PostionNames"] || "");
                    $("#StartWorkTime").val(surObjVal["StartWorkTime"] || "");
                    $("#UntileWorkTime").val(surObjVal["UntileWorkTime"] || "");
                    //性别
                    $(":radio[name='Sex']").each(function () {
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
                    } else {
                        $("#CruxPositon_All").attr("checked", true)
                    }

                    //年龄范围
                    !!surObjVal["StartAge"] ? $("#StartAge").val(surObjVal["StartAge"]) : $("#StartAge").val("");
                    !!surObjVal["EndAge"] ? $("#EndAge").val(surObjVal["EndAge"]) : $("#EndAge").val("");

                    $(":radio[name='WorkAge']").each(function () {
                        if ($(this).val() == surObjVal["WorkAge"]) {
                            $(this).attr("checked", true)
                        }
                    })

                    //学历
                    !!surObjVal["Major"] && $("#Major").val(surObjVal["Major"]);

                    //岗位序列
                    !!surObjVal["PositionSeq"] && $("#PositionSeq").val(surObjVal["PositionSeq"]);

                    //人员类别
                    $("input[name='personType']").each(function () {
                        if ((surObjVal["PersonType"] + "").indexOf($(this).val()) > -1) {
                            $(this).attr("checked", true)
                        }
                    });
                    //职位等级
                    surObjVal["PositionDegree0"] && $("#PositionDegree_S").val(surObjVal["PositionDegree0"]);
                    surObjVal["PositionDegree1"] && $("#PositionDegree_E").val(surObjVal["PositionDegree1"]);
                    //PositionDegree_S  PositionDegree_E PositionDegree0 PositionDegree1
                }
            }

            var task = new Ext.util.DelayedTask();
            task.delay(50, function () {
                userViewFrm.location.href = "Tab_SurveyedUser.aspx?SurveyId=" + SurveyId + "&type=iframesign";
            });

        }

        //人员类别初始化
        function personTypeInit() {
            //lc_up.selectByValue("临时工");
            // lc_up.select("1");
            var objArr = AimState["personTypeEnum"] || [];
            var tpl = "<input type='checkbox' name='personType' value='{value}' />&nbsp;{name}&nbsp;";
            var temp = "";
            for (var i = 0; i < objArr.length; i++) {
                temp += tpl.replace("{value}", objArr[i]["Value"]).replace("{name}", objArr[i]["Name"])
            }
            $("#personType_cob").append(temp);

        }

        //学历
        function XLInit() {
            var multistore = new Ext.ux.data.AimJsonStore({
                //dsname: 'personTypeEnum',
                idProperty: 'Value',
                data: {
                    records: [{ Name: '初中', Value: '初中' }, { Name: '高中', Value: '高中' },
                    { Name: '大专', Value: '大专' }, { Name: '大学', Value: '大学' }, { Name: '研究生', Value: '研究生'}]
                },
                fields: [{ name: 'Name' }, { name: 'Value' }
		    ]
            });
            var lc_up = new Ext.ux.form.MultiComboBox({
                id: 'combo ',
                //enableKeyEvents: true,
                renderTo: 'Major_Cob',
                width: 180,
                hideOnSelect: false,
                store: multistore,
                editable: false,
                allowBlank: true,
                triggerAction: 'all',
                valueField: 'Value',
                displayField: 'Name',
                emptyText: '请选择...',
                mode: 'local',
                // , hiddenName: 'idCombo'
                lazyInit: false,
                listeners: {
                    blur: function (obj) {
                    }
                }
            });
        }

        //职位初始化
        function wizardTwoPst() {
            //工作职位
            !$("#porPopup").length && $("[ctrl='popupWin2']").after("<a class='aim-ui-button' id='porPopup' \
             style='width: 20px; padding-right: 4px; padding-left: 4px;\
             margin-left: 5px; cursor: hand;'>...</a>").next().click(function () {
                 // Ext.getBody().mask("数据重新加载中，请稍等...");
                 var checkedId = $("#PostionIds").val();
                 var OrgIds = $("#OrgIds").val();
                 var jobSeq = escape($("#PositionSeq").val() || "");
                 //  if (!OrgIds && !$("#PostionNames").val()) {
                 //      AimDlg.show("请选择组织!");
                 //      return;
                 //   }

                 var param = "&deptId=" + OrgIds + "&jobSeq=" + jobSeq;

                 var url = "/CommonPages/Select/CustomerSlt/PostionSelectView.aspx?seltype=multi" + param;
                 var style = "dialogWidth:430px; dialogHeight:450px; scroll:yes; center:yes; status:no; resizable:no;";
                 OpenModelWin(url, {}, style, function () {
                     //Ext.getBody().unmask();
                     if (this.data == null || this.data.length == 0 || !this.data.length) {
                         $("#PostionNames,#PostionIds").val("");
                         return;
                     }
                     $("#PostionNames,#PostionIds").val("");
                     var temp = "", tempName = "";
                     for (var i = 0; i < this.data.length; i++) {
                         if (i > 0) {
                             temp += ",";
                             tempName += ",";
                         }
                         temp += this.data[i]["Id"];
                         tempName += this.data[i]["Name"];
                     }
                     $("#PostionNames").val(tempName);
                     $("#PostionIds").val(temp);
                 })

             });
        }

        //籍贯筛选条件
        function bornAddr() {
            $("[ctrl='popupWin3']").after("<a class='aim-ui-button' id='porPopup1' \
             style='width: 20px; padding-right: 4px; padding-left: 4px;\
             margin-left: 5px; cursor: hand;'>...</a>").next().click(function () {
                 // Ext.getBody().mask("数据重新加载中，请稍等...");
                 var checkedId = $("#PostionIds").val();
                 var OrgIds = $("#OrgIds").val();
                 //  var param = "&deptId=" + OrgIds;
                 //  var url = "/CommonPages/Select/CustomerSlt/PostionSelectView.aspx?seltype=multi" + param;
                 //  var style = "dialogWidth:430px; dialogHeight:450px; scroll:yes; center:yes; status:no; resizable:no;";
                 //  OpenModelWin(url, {}, style, function() { })

             });
        }

        //--------------------------Wizard three------------------------//
        function wizardThreeRender() {
            WizardInit = true;
            //问卷模板 TemplateId
            $("#TemplateName").change(function () {
                $(this).children().each(function () {
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

            //导入模板
            $("#ExpTpl").click(function () {

                if (!$("#TemplateName option:selected").val()) {
                    AimDlg.show("请选择模板!");
                    return;
                };

                if (confirm("确认将模板导入到问卷吗？")) {

                    var TemplateId = $("#TemplateId").val();
                    $.ajaxExec("ImpTpl", { id: SurveyId, TemplateId: TemplateId }, function (rtn) {
                        Ext.getBody().mask("数据正在导入中，请稍等...");
                        if (rtn.data.QItem) {
                            //first delete
                            store_Qustion.removeAll();

                            var objArr = rtn.data.QItem
                            var recType = store_Qustion.recordType;
                            $(objArr).each(function () {
                                var rec = new recType({
                                    'Id': this["Id"],
                                    'SurveyId': this["SurveyId"],
                                    'SurveyTitle': this["SurveyTitle"],
                                    'QuestionType': this["QuestionType"],
                                    'IsMustAnswer': this["IsMustAnswer"],
                                    'IsComment': this["IsComment"],
                                    'Content': this["Content"],
                                    'SortIndex': this["SortIndex"],
                                    'ImgIds': this["ImgIds"],
                                    'SubItemId': this["SubItemId"],
                                    'SubItems': this["SubItems"],
                                    'CreateId': this["CreateId"],
                                    'CreateName': this["CreateName"],
                                    'CreateTime': this["CreateTime"],
                                    'IsShowScore': this["IsShowScore"],
                                    'Ext1': this["Ext1"]
                                });
                                store_Qustion.insert(store_Qustion.data.length, rec);
                            })
                        }
                        Ext.getBody().unmask(); //去除MASK 
                        //gridQuestion.getStore().reload();
                    });
                }
            })
            //撤销
            $("#CancelTpl").click(function () {
                if (confirm("确认撤销模板吗？")) {
                    $.ajaxExec("CancelTpl", { SurveyId: SurveyId }, function (rtn) {
                        Ext.getBody().mask("撤销中，请稍后...");
                        if (rtn.data.QItem) {
                            //first delete
                            store_Qustion.removeAll();

                            var objArr = rtn.data.QItem
                            var recType = store_Qustion.recordType;
                            $(objArr).each(function () {
                                var rec = new recType({
                                    'Id': this["Id"],
                                    'SurveyId': this["SurveyId"],
                                    'SurveyTitle': this["SurveyTitle"],
                                    'QuestionType': this["QuestionType"],
                                    'IsMustAnswer': this["IsMustAnswer"],
                                    'IsComment': this["IsComment"],
                                    'Content': this["Content"],
                                    'SortIndex': this["SortIndex"],
                                    'ImgIds': this["ImgIds"],
                                    'SubItemId': this["SubItemId"],
                                    'SubItems': this["SubItems"],
                                    'CreateId': this["CreateId"],
                                    'CreateName': this["CreateName"],
                                    'CreateTime': this["CreateTime"],
                                    'IsShowScore': this["IsShowScore"],
                                    'Ext1': this["Ext1"]
                                });
                                store_Qustion.insert(store_Qustion.data.length, rec);
                            })
                        }
                        Ext.getBody().unmask(); //去除MASK 
                        //gridQuestion.getStore().reload();
                    }, null, "Comman.aspx");
                }
            })

            store_Qustion = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList_QItem',
                isclient: true,
                data: { records: AimState["DataList_QItem"] || [] },
                fields: [
			            { name: 'Id' },
			            { name: 'SurveyId' },
			            { name: 'SurveyTitle' },
			            { name: 'QuestionType' },
			            { name: 'IsMustAnswer' },
			            { name: 'IsComment' },
			            { name: 'Content' },
			            { name: 'SortIndex' },
			            { name: 'ImgIds' },
			            { name: 'SubItemId' },
			            { name: 'SubItems' },
			            { name: 'CreateId' },
			            { name: 'CreateName' },
			            { name: 'CreateTime' },
			            { name: 'IsShowScore' },
			            { name: 'Validate' },
			            { name: 'Ext1' }
                   	   ],
                listeners: {
                    aimbeforeload: function (proxy, options) {
                        options.data = options.data || {};
                        options.data.id = Id;
                    }
                }
            });

            //工具栏
            tlBar_wizardThree = new Ext.ux.AimToolbar({
                renderTo: 'SubContentBtn',
                items: [
				{
				    id: 'addBtn_wizrdThree',
				    text: '添加',
				    iconCls: 'aim-icon-add',
				    handler: function () {
				        addQuestion(store_Qustion);
				        if ($("#scorll_ext").length) {
				            //  if ($("#ext-gen72").length > 0) {
				            //      $("#ext-gen72").unwrap();
				            //  } else {
				            //      $(".x-grid3-body").unwrap();
				            //   }

				            //$(".x-grid3-body").unwrap()
				            //$("#ext-gen71").css({ width: "912px", height: "354px" });
				        }
				    }
				},
				{
				    id: 'delBtn_wizardThree',
				    text: '删除',
				    iconCls: 'aim-icon-delete',
				    handler: function () {
				        var recs = gridQuestion.getSelectionModel().getSelections();
				        var dt = store_Qustion.getModifiedDataStringArr(recs);
				        if (!recs || recs.length <= 0) {
				            AimDlg.show("请先选择要删除的记录！");
				            return;
				        }
				        if (confirm("确定删除所选记录？")) {
				            store_Qustion.remove(recs);
				        }
				        var ids = "";
				        $(recs).each(function (i) {
				            if (i > 0) {
				                ids += ",";
				            }
				            ids += "'" + this.get("SubItemId") + "'";
				        });

				        //$.ajaxExec("DeleteItem", { QuestionItemId: recs[0].get("SubItemId"), SurveyId: SurveyId }, null, null, "Comman.aspx")
				        $.ajaxExec("DeleteItem", { QuestionItemId: ids, SurveyId: SurveyId }, null, null, "Comman.aspx")
				    }
				}, '-', {
				    text: '复制上一题',
				    iconCls: 'aim-icon-copy',
				    handler: function () {
				        copySurvey(store_Qustion);
				    }
				}
		    ]
            });

            cb_QuestionType = new Ext.ux.form.AimComboBox({
                id: 'cb_QuestionType',
                enumdata: {
                    "单选项": "单选项",
                    "多选项": "多选项",
                    "填写项": "填写项",
                    "填写项1": "填写项1",  //text
                    "排序项": "排序项",
                    "图片(单选)": "图片(单选)",
                    "图片(多选)": "图片(多选)"
                },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function (obj) {
                        if (gridQuestion.activeEditor) {
                            var rec = store_Qustion.getAt(gridQuestion.activeEditor.row);
                            if (rec) {
                                gridQuestion.stopEditing();
                                rec.set("QuestionType", obj.value);
                                //  if (obj.value.indexOf("图片") > -1) {
                                //      if (imgItem.currentId != rec.get("SubItemId")) {
                                //          imgItem.lastItemId = imgItem.currentId;
                                //          imgItem.currentId = rec.get("SubItemId");
                                //      }
                                //   }
                            }
                        }
                    }
                }
            });

            cb_IsMustAnswer = new Ext.ux.form.AimComboBox({
                id: 'cb_IsMustAnswer',
                enumdata: { "是": "是", "否": "否" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function (obj) {
                        if (gridQuestion.activeEditor) {
                            var rec = store_Qustion.getAt(gridQuestion.activeEditor.row);
                            if (rec) {
                                gridQuestion.stopEditing();
                                rec.set("IsMustAnswer", obj.value);
                            }
                        }
                    }
                }
            });
            cb_IsComment = new Ext.ux.form.AimComboBox({ /*是否评论*/
                id: 'cb_IsComment',
                enumdata: { "否": "否", "是": "是" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function (obj) {
                        if (gridQuestion.activeEditor) {
                            var rec = store_Qustion.getAt(gridQuestion.activeEditor.row);
                            if (rec) {
                                gridQuestion.stopEditing();
                                rec.set("IsComment", obj.value);
                            }
                        }
                    }
                }
            });

            cb_IsScore = new Ext.ux.form.AimComboBox({  /*是否显示分值*/
                id: 'cb_IsScore',
                enumdata: { "否": "否", "是": "是" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function (obj) {
                        if (gridQuestion.activeEditor) {
                            var rec = store_Qustion.getAt(gridQuestion.activeEditor.row);
                            if (rec) {
                                gridQuestion.stopEditing();
                                rec.set("IsShowScore", obj.value);
                            }
                        }
                    }
                }
            });

            cb_validate = new Ext.ux.form.AimComboBox({  /*验证*/
                id: 'cb_validate',
                //enumdata: { "数字": "数字", "日期": "日期", "电话号码": "电话号码", "邮箱": "邮箱", "最大数值10": "最大数值10", "必选10项": "必选10项" },
                enumdata: {
                    "validate[custom[number]]": "数字",
                    "validate[custom[dateFormat]]": "日期",
                    "validate[custom[phone]]": "电话号码",
                    "validate[custom[email]]": "邮箱",
                    "validate[custom[number] max[10]]": "最大数值10",
                    "validate[minCheckbox[1] maxCheckbox[1]] checkbox": "必选1项",
                    "validate[minCheckbox[1]] checkbox": "最少1项",
                    "validate[minCheckbox[2] maxCheckbox[2]] checkbox": "必选2项",
                    "validate[minCheckbox[2]] checkbox": "至少2项",
                    "validate[maxCheckbox[2]] checkbox": "最多2项",
                    "validate[minCheckbox[3] maxCheckbox[3]] checkbox": "必选3项",
                    "validate[minCheckbox[3]] checkbox": "至少3项",
                    "validate[maxCheckbox[3]] checkbox": "最多3项",
                    "validate[minCheckbox[4] maxCheckbox[4]] checkbox": "必选4项",
                    "validate[minCheckbox[4]] checkbox": "至少4项",
                    "validate[maxCheckbox[4]] checkbox": "最多4项",
                    "validate[minCheckbox[5] maxCheckbox[5]] checkbox": "必选5项",
                    "validate[minCheckbox[4]] checkbox": "至少5项",
                    "validate[maxCheckbox[4]] checkbox": "最多5项",
                    "validate[minCheckbox[10] maxCheckbox[10]] checkbox": "必选10项"
                },
                lazyRender: false,
                allowBlank: false,
                autoLoad: false,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function (obj) {
                        if (gridQuestion.activeEditor) {
                            var rec = store_Qustion.getAt(gridQuestion.activeEditor.row);
                            if (rec) {
                                gridQuestion.stopEditing();
                                rec.set("Validate", obj.value);
                            }
                        }
                    },
                    beforeshow: function (obj) {
                        //验证控件是否可用
                        // var rec = store_Qustion.getAt(gridQuestion.activeEditor.row);
                        // if (rec) {
                        //     if ((rec.get("QuestionType") + "").indexOf("填写") > -1) {
                        //         obj.enable();
                        //         return true;
                        //     } else {
                        //         obj.disable();
                        //         return false;
                        //     }
                        // }

                    }
                }
            });

            gridQuestion = new Ext.ux.grid.AimEditorGridPanel({
                //id: 'gridQuestion',
                store: store_Qustion,
                //autoScroll: true,
                height: 400,
                renderTo: 'SubContent',
                //clicksToEdit: 1,
                //region: 'center',
                //autoHeight: true,
                autoExpandColumn: 'Content',
                columns: [
                    { id: 'Id', dataIndex: 'Id', hidden: true },
                    { id: 'SurveyId', dataIndex: 'SurveyId', hidden: true },
                    { id: 'SubItemId', dataIndex: 'SubItemId', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Content', dataIndex: 'Content', header: '<b><font color=red  >题目内容</font></b>', editor: { xtype: 'textarea' }, width: 360, renderer: RowRender },
					{ id: 'QuestionType', dataIndex: 'QuestionType', header: '问题类型', editor: cb_QuestionType, width: 90 },
				    { id: 'IsMustAnswer', dataIndex: 'IsMustAnswer', header: '是否必答', editor: cb_IsMustAnswer, width: 70, menuDisabled: true },
					{ id: 'IsShowScore', dataIndex: 'IsShowScore', header: '显示分值', editor: cb_IsScore, width: 70, menuDisabled: true },
				    { id: 'IsComment', dataIndex: 'IsComment', header: '是否评论', editor: cb_IsComment, width: 70, menuDisabled: true },
				    { id: 'Validate', dataIndex: 'Validate', header: '验证', editor: cb_validate, width: 85, menuDisabled: true },
				    { id: 'SortIndex', dataIndex: 'SortIndex', header: '序号', editor: { xtype: 'numberfield', minValue: 0, maxValue: 100, allowBlank: false }, width: 50 },
					{ id: 'Edit', dataIndex: 'Edit', header: '操作', width: 80, renderer: RowRender }
					],
                //tbar: tlBar_wizardThree,
                listeners: {
                    afteredit: function (e) {
                        var arr = [];
                        arr.push(e.record);
                        var strRec = store_Qustion.getModifiedDataStringArr(arr);
                        $.ajaxExec("SaveItem", { strRec: strRec }, function (rtn) {
                            e.record.commit();
                        }, null, "Comman.aspx")
                    }
                }
            });
            //自动设置滚动条

            //$(Ext.get("gridQuestion").dom).css({ overflow: "scroll" });
        }

        //-----------------Wizard Four-----------------------------------------//
        function wizardFourRender() {
            // 注释后以便于动态加载
            var task = new Ext.util.DelayedTask();
            task.delay(120, function () {
                stepFour.location.href = "InternetSurveyView.aspx?SurveyId=" + SurveyId + "&type=" + type;
            });
        }

        //-------------------------------------------end---------------------------

        //wizardthree RowRender
        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "Edit":
                    //if (record.get("QuestionType") == "填写项" || record.get("QuestionType").indexOf("图片") > -1) {
                    if ((record.get("QuestionType") + "").indexOf("填写项") > -1) {
                        cellmeta.style = 'background-color: gray';
                        rtn = "选择项"
                    }
                    else {
                        var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='windowOpenEdit(\"" + record.get("SurveyId") + "\",\"" + record.get("SubItemId") + "\",\"" + (record.get("Content") || "").replaceAll("\r\n", "").replaceAll("\r", "") + "\",\"" + (record.get("QuestionType") || "") + "\",\"" + (record.get("ImgIds") || "") + "\",\"" + (record.get("Ext1") || "") + "\",\"" + rowIndex + "\")'>" + "选择项" + "</span>";
                        rtn = str;
                    }
                    break;
                case "Content":
                    if (record.get("ImgIds")) {
                        rtn = (value || "") + "<font color='gray'>&nbsp;(附有图片)</font>";
                    } else {
                        rtn = value;
                    }
                    break;
            }
            return rtn;
        }
        //预览
        function windowOpen() {
            var Id = arguments[0] || '';  //ID
            var Title = escape(arguments[1] || ''); //Title
            var task = new Ext.util.DelayedTask();
            task.delay(100, function () {
                opencenterwin("SurveyView.aspx?op=v&Id=" + Id + "&Title=" + Title + "&rand=" + Math.random(), "", 1000, 600);
            });
        }
        /* 答案选择项*/
        function windowOpenEdit() {
            var SurveyId = arguments[0] || '';
            var QuestionItemId = arguments[1] || '';
            var QuestionContent = escape(arguments[2]) || '';
            var QuestionType = escape(arguments[3] || "");
            var ImgIds = escape((arguments[4] + "").replace("null", "") || "");
            var Ext1 = escape((arguments[5] + "").replace("null", "") || "");
            var SortIndex = arguments[6] + "";   //序号

            var task = new Ext.util.DelayedTask();
            task.delay(100, function () {
                var url = "SuryQuestionItemEdit.aspx?op=v&SurveyId=" + SurveyId + "&QuestionItemId=" + QuestionItemId + "&QuestionContent=" + QuestionContent + "&QuestionType=" + QuestionType + "&ImgIds=" + ImgIds + "&Ext1=" + Ext1 + "&type=iframesign";
                if (unescape(QuestionType).indexOf("图片") > -1) {
                    var ModelStyle = "dialogWidth:780px; dialogHeight:560px; scroll:yes; center:yes; status:no; resizable:yes;";
                    //var win = opencenterwin(url, "", 780, 490);

                } else {
                    var ModelStyle = "dialogWidth:760px; dialogHeight:450px; scroll:yes; center:yes; status:no; resizable:yes;";
                    // var win = opencenterwin(url, "", 760, 340);
                    //OpenModelWin(url, ModelStyle);
                }
                OpenModelWin1(url, ModelStyle, SortIndex);
            });
        }

        function OpenModelWin1(url, style, SortIndex) {
            rtn = window.showModalDialog(url, window, style);
            if (rtn) {
                var SubItemId = gridQuestion.getStore().getAt(SortIndex).get("SubItemId")
                $.ajaxExec("ReSetImgIds", { SubItemId: SubItemId }, function (rtn) {
                    if (rtn.data.ImgIds) {
                        var InfoArr = rtn.data.ImgIds.split("[]");
                        gridQuestion.getStore().getAt(SortIndex).set("ImgIds", InfoArr[0])
                        gridQuestion.getStore().getAt(SortIndex).set("Ext1", InfoArr[1])
                    }
                })
            }
        }

        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }
        //Wizard 导航自动布局
        function calcWizardSize() {
            var wizardCount = $("#wizard li").length;
            var bodyWidth = $('body').width();
            var width = (bodyWidth - wizardCount * 9) / wizardCount;
            $(".selected,.done").width(parseInt(width));
        }

        //人员选择
        function openUsrWin(gridSg) {

            var style = "dialogWidth:720px; dialogHeight:430px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "/CommonPages/Select/UsrSelect/MUsrSelect.aspx?seltype=multi&rtntype=array";
            OpenModelWin(url, {}, style, function () {
                if (this.data == null || this.data.length == 0 || !this.data.length) return;
                // var gird = Ext.getCmp(gridSg);
                var gird = gridSg
                var EntRecord = gird.getStore().recordType;
                for (var i = 0; i < this.data.length; i++) {
                    if (gird.store.find("Id", this.data[i]["UserID"]) != -1) continue;
                    var rec = new EntRecord({ Id: this.data[i]["UserID"], Name: this.data[i]["Name"] });
                    gird.getStore().insert(gird.getStore().data.length, rec);
                }
            })
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

        //设置实际有效数量
        EffectiveCount = function (preView, val) {
            preView = preView || 0;

            if (!preView) {
                AimDlg.show("暂无调查对象, 请点击'查看预览'按钮或导入人员!");
                return;
            }

            var sw = new Ext.Window({
                title: '问卷有效数量',
                width: 300,
                height: 200,
                padding: '15 5 5 5',
                autoScroll: true,
                layout: 'form',
                bodyStyle: 'overflow-y:auto;overflow-x:auto;',
                items: [
                {
                    xtype: 'label',
                    fieldLabel: '预计问卷数量',
                    text: preView + " 份"
                }, {
                    id: 'EffectiveCount',
                    xtype: 'textfield',
                    allowBlank: true,
                    fieldLabel: '实际有效数量',
                    regex: /^\d{1,4}$/,
                    regexText: '请输入数字',
                    value: val,
                    width: 150
                }],
                buttons: [{
                    text: '确认',
                    handler: function () {
                        Ext.getBody().mask("信息添加中,请稍等...");
                        $.ajaxExec("EffectiveCount", {
                            "EffectiveCount": Ext.getCmp('EffectiveCount').getValue(),
                            SurveyId: SurveyId
                        }, function () {
                            sw.close();
                            Ext.getBody().unmask();
                        });
                    }
                }, {
                    text: '取消',
                    handler: function () {
                        sw.close();
                    }
                }]
            }).show();
        }

        //获取组织机构
        function GetOrg(rtn) {
            if ($.isEmptyObject(rtn)) {
                $("#OrgNames").val("");
                $("#OrgIds").val("");
                return;
            }
            var orgArr = rtn.GroupID.split(",");
            var orgArrName = rtn.Name.split(",");

            var result = "";
            for (var i = 0; i < orgArr.length; i++) {
                if (i > 0) result += ",";
                if ((orgArrName[i] + "").indexOf("公司") > -1) {
                    result += orgArrName[i];
                } else {
                    $.ajaxExecSync("GetAllPath", { GroupID: orgArr[i] }, function (rtn) {
                        if (rtn.data.State) {
                            result += rtn.data.State;
                        }
                    }, null, "Comman.aspx");
                }
            }

            $("#OrgNames").val(result);
            $("#OrgIds").val(rtn.GroupID);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="wizard" class="swMain">
        <ul>
            <li><a href="#step-1">
                <label class="stepNumber">
                    1</label>
                <span class="stepDesc">基本设置 </span></a></li>
            <li><a href="#step-2">
                <label class="stepNumber">
                    2</label>
                <span class="stepDesc">调查对象 </span></a></li>
            <li><a href="#step-3">
                <label class="stepNumber">
                    3</label>
                <span class="stepDesc">问卷内容</span></a></li>
            <li><a href="#step-4">
                <label class="stepNumber">
                    4</label>
                <span class="stepDesc">预览保存</span></a></li>
        </ul>
        <div id="step-1">
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
                                <td class="aim-ui-td-data" style="width: 35%">
                                    <select id="SurveyTypeName" name="SurveyTypeName" aimctrl="select" enum='AimState["TypeEnum"]'
                                        style="width: 70%" class="validate[required]">
                                    </select>
                                    <input type="hidden" name="SurveyTypeId" id="SurveyTypeId" />
                                </td>
                                <td class="aim-ui-td-caption">
                                    问卷编号
                                </td>
                                <td class="aim-ui-td-data" style="width: 35%">
                                    <input id="TypeCode" name="TypeCode" class="validate[required]" style="width: 80%" />
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    问卷标题
                                </td>
                                <td colspan="3">
                                    <input id="SurveyTitile" name="SurveyTitile" style="width: 92%" class="validate[required]" />
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    问卷描述
                                </td>
                                <td class="aim-ui-td-data" colspan="3">
                                    <textarea aimctrl="editor" rows="4" style="width: 92%; height: 140px;" id="Description"
                                        name="Description"></textarea>
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
                                    <input id="EndTime" readonly name="EndTime" class="Wdate validate[required]" style="width: 80%"
                                        onclick="var date=$('#StartTime').val()?$('#StartTime').val():new Date();  
                        WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" />
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    所属公司
                                </td>
                                <td class="aim-ui-td-data">
                                    <input id="CompanyName" name="CompanyName" readonly="readonly" style="width: 100%" />
                                    <input id="CompanyId" name="CompanyId" type="hidden" />
                                </td>
                                <td class="aim-ui-td-caption">
                                    发布部门
                                </td>
                                <td class="aim-ui-td-data">
                                    <input id="DeptName" name="DeptName" readonly="readonly" style="width: 80%" />
                                    <input id="DeptId" name="DeptId" type="hidden" />
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    相关附件
                                </td>
                                <td class="aim-ui-td-data" colspan="3">
                                    <input id="AddFilesName" name="AddFilesName" aimctrl='file' style="width: 94.5%" />
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    通知方式
                                </td>
                                <td class="aim-ui-td-data" style="width: 30%">
                                    <input type="hidden" id="NoticeWay" name="NoticeWay" />
                                    <input type="checkbox" name="Notice" value="Email" checked id="Email" />邮件 &nbsp;&nbsp;
                                    <input type="checkbox" name="Notice" value="Message" id="Message" />短信
                                </td>
                                <td class="aim-ui-td-caption">
                                    结果查看权限
                                </td>
                                <td class="aim-ui-td-data" colspan="3">
                                    <input type="checkbox" value="sender" name="ReaderObj" checked="checked" />问卷发起者&nbsp;&nbsp;
                                    <input type="checkbox" value="joiner" name="ReaderObj" />问卷参与者&nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    问卷积分
                                </td>
                                <td class="aim-ui-td-data">
                                    <input type="text" id="Score" name="Score" style="width: 15%" />
                                </td>
                                <td class="aim-ui-td-caption">
                                </td>
                                <td class="aim-ui-td-data">
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </fieldset>
                <fieldset>
                    <legend>定时提醒</legend>
                    <table class="aim-ui-table-edit" style="margin: 2px 2px">
                        <tr>
                            <td class="aim-ui-td-caption" style="width: 10%">
                                提醒方式
                            </td>
                            <td class="aim-ui-td-data" colspan="3">
                                <input type="checkbox" name="RemindWay" value="Email" checked />邮件 &nbsp;&nbsp;
                                <input type="checkbox" name="RemindWay" value="Message" style="margin-left: 10px" />短信
                            </td>
                            <!-- <td class="aim-ui-td-caption">
                                提醒时间点一
                            </td>
                            <td class="aim-ui-td-data" style="width: 30%">
                                <input id="SetTimeout" name="SetTimeout" class="Wdate" style="width: 64%" onfocus="var date=$('#StartTime').val()?$('#StartTime').val():new Date(); WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" />
                            </td>-->
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
                                    <input id="TimePoint" name="TimePoint" class="Wdate" style="width: 85px" onfocus=" WdatePicker({dateFmt:'HH:mm:ss'})" />&nbsp;提醒.</div>
                            </td>
                        </tr>
                        <tr>
                            <td class="aim-ui-td-caption">
                                &nbsp;
                            </td>
                            <td class="aim-ui-td-data" colspan="3">
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </div>
        </div>
        <!-------------step-2-------------------------------------------------------------->
        <div id="step-2">
            <div id="editDiv2" align="center">
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
                                    <input name="OrgNames" id="OrgNames" style="width: 85%" readonly="readonly" aimctrl="popup"
                                        style="background-color: rgb(254,255,187)" popurl="/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=multi&popmode=myPop&nodeId=<%=nodeId%>"
                                        popparam="OrgIds:GroupID;OrgNames:Name" popstyle="dialogWidth:540px; dialogHeight:450px; scroll:yes; center:yes; status:no; resizable:no;"
                                        popmode='myPop' afterpopup="GetOrg" />
                                    <input name="OrgIds" id="OrgIds" type="hidden" />
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    岗位序列
                                </td>
                                <td class="aim-ui-td-data" colspan="3">
                                    <input aimctrl='popup' readonly id="PositionSeq" name="PositionSeq" popurl="../CommonPages/SelectGWXL.aspx?seltype=multi"
                                        popparam="PositionSeq:XL" popstyle="width=480,height=450" style="width: 85%" />
                                </td>
                            </tr>
                            <tr>
                                <td class="aim-ui-td-caption">
                                    工作职位
                                </td>
                                <td class="aim-ui-td-data" colspan="3">
                                    <input id="PostionNames" name="PostionNames" style="width: 85%" ctrl='popupWin2'
                                        readonly="readonly" />
                                    <input id="PostionIds" name="PostionIds" type="hidden" />
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
                                    入职日期
                                </td>
                                <td class="aim-ui-td-data">
                                    <input id="StartWorkTime" readonly="readonly" name="StartWorkTime" class="Wdate"
                                        style="width: 40%" onclick=" WdatePicker({dateFmt:'yyyy/MM/dd'})" />
                                    &nbsp;至&nbsp;
                                    <input id="UntileWorkTime" readonly="readonly" name="UntileWorkTime" class="Wdate"
                                        style="width: 40%" onclick=" var date=$('#StartWorkTime').val()?$('#StartWorkTime').val():'';  
				WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" />
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
                                <td style="width: 28%">
                                    <input id="StartAge" readonly="readonly" name="StartAge" class="Wdate" style="width: 40%"
                                        onclick=" WdatePicker({dateFmt:'yyyy-MM'})" />
                                    &nbsp;至&nbsp;
                                    <input id="EndAge" readonly="readonly" name="EndAge" class="Wdate" style="width: 40%"
                                        onclick=" var date=$('#StartAge').val()?$('#StartAge').val():new Date();  
				WdatePicker({minDate:date,dateFmt:'yyyy-MM',maxDate:new Date()})" />
                                </td>
                                <td class="aim-ui-td-caption">
                                    资深员工
                                </td>
                                <td>
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
                                    <div id="Major_Cob" style="display: none">
                                    </div>
                                    <!--  <input id="Radio1" name="Major" type="checkbox" value="初中" />
                                    初中
                                    <input id="Radio2" name="Major" type="checkbox" value="高中" />
                                    高中
                                    <input id="Radio5" name="Major" type="checkbox" value="大专" />
                                    大专
                                    <input id="Radio3" name="Major" type="checkbox" value="大学" />
                                    大学
                                    <input id="Radio4" name="Major" type="checkbox" value="研究生" />
                                    研究生-->
                                    <input aimctrl='popup' readonly id="Major" name="Major" popurl="/CommonPages/SelectXl.aspx?seltype=multi"
                                        popparam="Major:XL" popstyle="width=450,height=450" style="width: 80%" />
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
                                    <input type="hidden" name="personType" id="personType" />
                                </td>
                                <td class="aim-ui-td-caption">
                                    关键岗位
                                </td>
                                <td class="aim-ui-td-data">
                                    <input id="CruxPositon_All" name="CruxPositon" type="radio" value="" />
                                    不限
                                    <input id="CruxPositon_Y" name="CruxPositon" type="radio" value="Y" />
                                    是
                                    <input id="CruxPositon_N" name="CruxPositon" type="radio" value="N" />
                                    否
                                    <!-- <input type="checkbox" id="CruxPositon_Y" name="CruxPositon" value="Y" />&nbsp;是
                                    &nbsp;&nbsp;<input type="checkbox" id="CruxPositon_N" name="CruxPositon" value="N" />&nbsp;否-->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table style="width: 100%; table-layout: fixed">
                        <tr>
                            <td style="width: 100%; height: 290px">
                                <iframe id="userViewFrm" name="userViewFrm" width="100%" height="100%" frameborder="0">
                                </iframe>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </div>
        </div>
        <!--------------------step-3  ----------------------->
        <div id="step-3" align="center">
            <fieldset>
                <legend>问卷内容</legend>
                <table class="aim-ui-table-edit" style="margin: 5px 2px;">
                    <tbody>
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
                                <span id="template" style="width: 50%; border: 0; border-bottom: 1 solid black; background: #F8F8F8;
                                    color: Blue;"></span>&nbsp;&nbsp;&nbsp;&nbsp;
                                <input type="button" id="ExpTpl" value="导入" />
                                <input type="button" id="CancelTpl" value="撤销" />
                            </td>
                        </tr>
                    </tbody>
                </table>
                <div id="SubContentBtn" style="width: 100%;">
                </div>
                <div id="SubContent" style="width: 100%;">
                </div>
            </fieldset>
        </div>
        <div id="step-4">
            <iframe id="stepFour" name="stepFive" width="100%" height="100%" frameborder="0">
            </iframe>
        </div>
    </div>
</asp:Content>
