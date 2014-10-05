<%@ Page Title="调查问卷" Language="C#" MasterPageFile="~/Masters/Ext/formpage1.master"
    AutoEventWireup="true" CodeBehind="InternetSurvey.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.InternetSurvey" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        td, body, select, input
        {
            font-size: 12px;
            color: #000000;
            line-height: 18px;
        }
        body
        {
            background-color: White;
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
            height: 25px;
        }
        .discuss
        {
            float: left;
            width: 30px;
            border: solid 1 gray;
            margin: 12px 3px 0px 0px;
        }
        .formCtl
        {
            width: 100%;
            padding-left: 12px;
        }
        .question_textarea
        {
            width: 450;
            margin-top: 5px;
            margin-left: 10px;
        }
        .IsExplanation
        {
            border: none;
            width: 160;
            margin-left: 5px;
            border-bottom: 1px #000000 solid;
        }
        .questImg
        {
            width: 160px;
            height: 130px;
            margin-top: 5px;
            margin-bottom: 5px;
            margin-right: 2px;
            margin-left: 16px;
        }
        #topFile
        {
            background-color: rgb(218,215,212);
            width: 750px;
            height: auto;
            margin-bottom: 30px;
        }
        #expTitle
        {
            font-family: 宋体,Verdana,Tahoma, Arial;
            font-size: 13px;
            margin: 2px 10px;
            margin-top: 12px;
            display: block;
        }
        #fileItem
        {
            font-family: 宋体,Verdana,Tahoma, Arial;
            font-size: 13px;
            margin-left: 60px;
            text-align: left;
            margin-bottom: 10px;
            height: 40px;
        }
        .fileLink
        {
            margin-right: 24px;
        }
        .txx1
        {
            /*input文本框*/
            margin-left: 6px;
        }
    </style>
    <script src="js/renderSurvey.js" type="text/javascript"></script>
    <link href="js/validationEngine.jquery.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">

        var id = $.getQueryString({ ID: 'Id' });            // SurveyId
        var op = $.getQueryString({ ID: 'op' });            //
        var type = $.getQueryString({ ID: 'type' });        //type

        //智能机浏览器版本信息:
        var browser = {
            versions: function () {
                var u = navigator.userAgent, app = navigator.appVersion;
                return {
                    //移动终端浏览器版本信息
                    trident: u.indexOf('Trident') > -1, //IE内核
                    presto: u.indexOf('Presto') > -1, //opera内核
                    webKit: u.indexOf('AppleWebKit') > -1, //苹果、谷歌内核
                    gecko: u.indexOf('Gecko') > -1 && u.indexOf('KHTML') == -1, //火狐内核
                    mobile: !!u.match(/AppleWebKit.*Mobile.*/) || !!u.match(/AppleWebKit/), //是否为移动终端
                    ios: !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/), //ios终端
                    android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1, //android终端或者uc浏览器
                    iPhone: u.indexOf('iPhone') > -1 || u.indexOf('Mac') > -1, //是否为iPhone或者QQHD浏览器
                    iPad: u.indexOf('iPad') > -1, //是否iPad
                    webApp: u.indexOf('Safari') == -1 //是否web应该程序，没有头部与底部
                };
            } (),
            language: (navigator.browserLanguage || navigator.language).toLowerCase()
        }

        var uid = $.getQueryString({ ID: 'uid' }) || '';
        var uname = unescape($.getQueryString({ ID: 'uname' })) || '<%=UserName %>';
        var workno = $.getQueryString({ ID: 'workno' }) || '<%=WorkNo %>';

        var records, survey, accessValidate = true; //accessValidate 是否通过验证标识
        var UserID = "", UserName = "";
        function onPgLoad() {


            if (uid) {
                UserID = uid;
                UserName = uname;
            } else {
                UserID = AimState.UserInfo.UserID;
                UserName = AimState.UserInfo.Name;
            }
            if (!$.isEmptyObject(AimState)) {
                if (AimState.IsHaveUser != "1") {
                    $("table").hide();
                    alert("抱歉，系统中无该用户！");
                    window.close();
                }
            }

            addFileRender();
            renderView();
            setPageUI();

            //是否过期
            if ((AimState["IsPastTime"] != null || AimState["IsPastTime"] != undefined) && AimState["IsPastTime"] == "1") {
                // $("#btnDiv").hide();
                $("#btnTJ,#btnQx").attr("disabled", true);
                type != "read" && AimDlg.show("该问卷已过期!");
            }

            //是否暂停
            if ((AimState["IsPause"] != null || AimState["IsPause"] != undefined) && AimState["IsPause"] == "1") {
                $("#btnTJ,#btnQx").attr("disabled", true);
                AimDlg.show("该问卷已暂停!");
            }


            //help
            $("#UsrHelp").click(function () {
                var Modelstyle = "dialogWidth:960px; dialogHeight:580px; scroll:yes; center:yes; status:no; resizable:no;";
                var url = "ExportHelp.aspx";
                OpenModelWin(url, window, Modelstyle, null);
            });

            /*验证引擎初始化*/
            window.setTimeout(function () {
                if (op == "v") return;  //预览标识 
                //$("head").append("<script src='js/jquery-1.6.min.js' type='text/javascript'>" + "<" + "/" + "script>");
                //$("head").append("<script src='/js/common.js' type='text/javascript'>" + "<" + "/" + "script>");
                $("head").append("<script src='js/jquery.validationEngine.min.js' type='text/javascript'>" + "<" + "/" + "script>");
                $("#aspnetForm").validationEngine({
                    onSuccess: function () {
                        accessValidate = true;
                    },
                    onFailure: function () {
                        accessValidate = false;
                    },
                    scroll: true
                });
            }, 200)

        }
        function setPageUI() {
            if (op == "v") {
                // $("#btnDiv").hide();
                $("#btnTJ,#btnQx").attr("disabled", true);
            }
            $(".discuss").click(function () {
                /*是否评论*/
                $(this).parent().append("<textarea rows=3 style='float: left; width: 415;'" + " name=" + $(this).attr("name") + "/>")
                $(this).unbind("click");
            });
        }

        //附件的呈现
        function addFileRender() {
            $("#topFile").hide();
            var files = AimState["Files"] || "";
            var fileArr = files.split(",");
            var tpl = "<a class=\"fileLink\" href=\"{href}\">{val}</a>";
            var html = "";
            for (var i = 0; i < fileArr.length; i++) {
                if (fileArr[i]) {
                    var temp = tpl.replace("{href}", "  ../CommonPages/File/DownLoad.aspx?id=" + fileArr[i].substring(0, 36));
                    temp = temp.replace("{val}", fileArr[i].split("_")[1] || '');
                    html += temp;
                }
            }
            html && $("#subItems").append(html);
            html && $("#topFile").show();
        }

        function renderView() {

            records = AimState["ItemList"] || "[]";
            survey = AimState["Survey"] || "[]";

            $("#title").text(survey["SurveyTitile"] || '');                               //设置title
            survey["Description"] && $("#content").html('').html(survey["Description"]);  //设置说明
            var recordsObj = eval("(" + records + ")") || [];

            if (recordsObj.length > 0) {
                var html = buildHtml(recordsObj);     //!*渲染问卷列表
                $("#SurveyList").children().remove();
                $("#SurveyList").append(html);       //添加问卷项
            }

            //----------------------------------随机标志 补充说明项----
            var rand;
            $("input").not(".txx1").attr("readonly", true);
            $("input:radio,input:checkbox").click(function () {
                var randChar = ["x", 'c', 'd', 'v', 'z', 'k', 's', 't', 'q', 'p'];

                if ($(this).next().attr("type") == "text") {
                    rand = randChar[parseInt(Math.random() * 10)] + randChar[parseInt(Math.random() * 10)] + randChar[parseInt(Math.random() * 10)] + randChar[parseInt(Math.random() * 10)];
                    $(this).next().attr("readonly", false).addClass(rand);
                } else {

                    //$("." + rand + "").val('').attr("readonly", true);
                    $("." + rand + "").attr("readonly", true); //Chage By WGM 7/8
                }
            });
            //--------------------------------------

            //判断是否固定离职问卷
            var SurveyType = AimState["Survey"] ? (AimState["Survey"]["SurveyTitile"] || "") : "";
            var IsFixed = AimState["Survey"] ? (AimState["Survey"]["IsFixed"] || "") : "";
            if (SurveyType.indexOf("员工离职调查问卷") > -1 && IsFixed == "2") {
                var sepecialObj = selectSpecialItem();                //特殊题处理
                $(".IsExplanation", sepecialObj["specialArr"]).css({ width: "30px" }).keyup(function () {
                    var $obj = $(this), curVal = $obj.val() + "";
                    $obj.val(curVal.replace(/\D|^0/g, ''));                           //限制非数值输入
                    curVal = $obj.val();

                    if (curVal && parseInt(curVal) > 3) {
                        $obj.val('');
                        alert("不得填写大于3的数值！");
                    }

                    $(this).parent().parent().parent().siblings().find("input[type='text']").val("");
                    ($(this).val().length > 1) && ($(this).val(($(this).val() + "").substring(0, 1))) //长度限制
                    $(".IsExplanation", sepecialObj["specialArr"]).not($(this)[0]).each(function () {
                        if (curVal && $(this).val() == curVal) {
                            $obj.val("");
                            alert("您已填写过该数值, 您可以不填该项或选择其他的小于4的数值！");
                            return false;
                        }
                    })
                });
            }

            //                //清空说明项
            //                $(":radio").each(function() {
            //                    $(this).click(function() {
            //                        if ($(this).attr("checked")) {
            //                            //td-->tr item
            //                            $(this).parent().parent().siblings().find(":radio:not(:checked)").next().val("");
            //                        }
            //                    });
            //                });

            //            }


        }



        function commit() {/*提交*/
            //必填项验证
            var validate = true;
            var eltObjArr = [];   //未填的元素
            $(".mustInput").each(function () {
                if ($("[name=" + $(this).attr("name") + "]").is("textarea")) {
                    //填写项
                    if (!$("[name=" + $(this).attr("name") + "]").text()) {
                        validate = false;
                        eltObjArr.push($("[name=" + $(this).attr("name") + "]"));
                    }
                }
                if (($("[name=" + $(this).attr("name") + "]").attr("type") || "").toLowerCase() == "checkbox") {

                    if (!$("[name=" + $(this).attr("name") + "]:checked").val()) {
                        validate = false;
                        eltObjArr.push($("[name=" + $(this).attr("name") + "]"));
                    }
                }
                if (($("[name=" + $(this).attr("name") + "]").attr("type") || "").toLowerCase() == "radio") {
                    //单选项
                    if (!$("[name=" + $(this).attr("name") + "]:checked").val()) {
                        validate = false;
                        eltObjArr.push($("[name=" + $(this).attr("name") + "]"));
                    }
                }
                if ($("[name=" + $(this).attr("name") + "]").is(".txx1")) {
                    //填写项1
                    if (!$("[name=" + $(this).attr("name") + "]").val()) {
                        validate = false;
                        eltObjArr.push($("[name=" + $(this).attr("name") + "]"));
                    }
                }
                //排序项
                if ($("[name=" + $(this).attr("name") + "]").is("select")) {
                    return;
                }

                //手机浏览器
                if (browser.versions.mobile) {
                    var tempVal = ($("[name=" + $(this).attr("name") + "]").val() || $("[name=" + $(this).attr("name") + "]").text()) || $("[name=" + $(this).attr("name") + "]:checked").val();
                    var valength = (tempVal + "").indexOf("*(必填)");
                    if (valength == 1) {
                        validate = false;
                    }
                }

            })

            //-----
            if (!accessValidate) {
                AimDlg.show("您填写的内容不符合规范,请检查后重新填写！");
                return;
            }
            if (!validate && !browser.versions.mobile) {

                var JObj = eltObjArr[0];
                if (typeof (JObj) == "object") {
                    //var totalH = $(document).height();

                    //滚动条的高度
                    var eleH = $(JObj[0]).offset().top;
                    $(document.body).scrollTop(eleH - 20);
                }
                return AimDlg.show("您有未填的必填项!");
            }

            //判断是否固定离职问卷
            var SurveyType = AimState["Survey"] ? (AimState["Survey"]["SurveyTitile"] || "") : "";
            var IsFixed = AimState["Survey"] ? (AimState["Survey"]["IsFixed"] || "") : "";
            if (SurveyType.indexOf("员工离职调查问卷") > -1 && IsFixed == "2") {
                var sepecialObj = selectSpecialItem(); //特殊题处理
                //必填项验证
                var validate = true;
                var eltObjArr = [];   //未填的元素
                $(sepecialObj.specialArr).each(function () {
                    $("input:checked", this).each(function () {
                        eltObjArr.push(this);
                    });

                })

                if (eltObjArr.length < 3) {
                    AimDlg.show("在8-12题选项中,至少选择3 项并在选项后填写'1,2,3'数值标识原因等级!");
                    return;
                }

                //选项说明 是否标识数字
                var noFillDegree = [];
                $(sepecialObj.specialArr).each(function (i) {
                    if (!$(":checked", this).next(".IsExplanation").val()) {
                        noFillDegree.push(i + 8);
                    }
                });
                if (noFillDegree.length > 2) {
                    AimDlg.show("在8-12题选项中,请在选中的选项后填写'1,2,3'数值!");
                    return;
                }
            }
            //            var SurveyType = AimState["Survey"] ? (AimState["Survey"]["SurveyTypeName"] || "") : "";
            //            var IsFixed = AimState["Survey"] ? (AimState["Survey"]["IsFixed"] || "") : "";
            //            if (SurveyType.indexOf("离职") > -1 && IsFixed == "2") {
            //                if ($(":radio:checked").length == 0) {
            //                    AimDlg.show("请至少选择1项！");
            //                    return;
            //                } else {
            //                    var isPassed = true;
            //                    var havPoint = false; // 必须标识1
            //                    $(":radio:checked").each(function(i) {
            //                        if (!$(this).next().val()) {
            //                            AimDlg.show("请在选择项后填写\"1、2、3\",来标识权重(数值越小表示该因素越重要)");
            //                            isPassed = false;
            //                        } else {
            //                            if (!$.isInt($(this).next().val())) {
            //                                AimDlg.show("请填写数值\"1、2、3\"其中的一个");
            //                                isPassed = false;
            //                            }
            //                            if (($(this).next().val() + "").indexOf("1") > -1) havPoint = true;
            //                        }
            //                    })
            //                    if (!isPassed) return;
            //                    if (!havPoint) {
            //                        AimDlg.show("权重填写框必须有一项填写为'\1\' ");
            //                        return;
            //                    }
            //                }
            //            }


            if (confirm("提交后将无法修改,确认提交吗?")) {
                var commitArr = [];
                var recordsObj = eval("(" + records + ")") || [];
                for (var i = 0; i < recordsObj.length; i++) {
                    var temObj = {};

                    //temObj.UserId = AimState.UserInfo.UserID;
                    //temObj.UserName = AimState.UserInfo.Name;  //Comment on 8/12

                    temObj.UserName = UserName;  //8/12
                    temObj.UserId = UserID;

                    temObj.SurveyId = id;
                    temObj.QuestionId = recordsObj[i].Id;   //*

                    var tempId = ""; //选中题项的ID
                    var tempConntent = "", itemConten = "";  //内容
                    var tempItemName = ""; //问题选项txt


                    $("[name^=" + recordsObj[i].Id + "]").each(function () {
                        switch (($(this)[0].tagName + "").toLowerCase()) {
                            case "input":    //选中
                                if ($(this).attr("checked")) {
                                    tempId.length > 0 && (tempId += ",");
                                    tempId += $(this).val();

                                    tempId.length > 0 && (tempItemName += " $ ");
                                    tempItemName += $(this).parent().text();
                                }
                                if (($(this).not(".txx1").attr("type") || "").toLowerCase() == "text") {
                                    itemConten += $(this).val(); //补充项说明
                                }
                                //填写项1
                                if (($(this).filter(".txx1").attr("type") || "").toLowerCase() == "text") {
                                    tempConntent += $(this).val();
                                }
                                break;
                            case "textarea":
                                tempConntent += $(this).val();
                                break;
                            case "select": //排序题
                                var optionStr = "";
                                $(this).find("option").each(function (i) {
                                    if (i > 0) optionStr += " , ";
                                    optionStr += $(this).val();
                                });
                                tempConntent += optionStr;
                                break;
                        }
                    });

                    temObj.QuestionName = recordsObj[i]["Content"]; //question txt

                    temObj.QuestionItemName = tempItemName.toString(); //答案选项名称

                    temObj.QuestionItemContent = itemConten; //补充
                    temObj.QuestionItemId = tempId.toString(); //选项

                    temObj.QuestionContent = tempConntent;   //填写题,排序题
                    commitArr.push($.getJsonString(temObj));
                    // QuestionContentId    QuestionItemContent  UserId  UserName CreateTime
                }

                var paramObj = {};
                var html = document.getElementsByTagName('html')[0].innerHTML;  //

                paramObj["commitArr"] = commitArr;
                paramObj["CommitHistory"] = $.getJsonString({
                    SurveyId: id,
                    SurveyedUserId: UserID,
                    SurveyedUserName: UserName,
                    WorkNo: workno,
                    CommitSurvey: html
                });

                if (!records) {
                    AimDlg.show("无问卷内容!");
                    return;
                }
                //* 防止产生多个问卷
                $("#btnTJ").hide().attr("disabled", true);

                AimFrm.submit("Commit", paramObj, null, function () {
                    alert("问卷提交成功!");
                    RefreshClose();
                });
            }
        }


        //特殊问卷项
        function selectSpecialItem() {
            var specialObj = {  //8-12 题需要特殊处理
                start: 8,
                end: 12,
                specialArr: []
            }
            for (var i = specialObj.start - 1; i < specialObj.end; i++) {
                specialObj.specialArr.push($(".QItems").eq(i)[0]);
            }
            return specialObj;
        }

        function cancel() { /*取消*/
            RefreshClose();
        }

        //指定页面区域内容导入Word
        function exportToWord(controlId) {
            var control = document.getElementById(controlId);
            try {
                var oWD = new ActiveXObject("Word.Application");
                var oDC = oWD.Documents.Add("", 0, 1);
                var oRange = oDC.Range(0, 1);
                var sel = document.body.createTextRange();
                try {
                    sel.moveToElementText(control);
                } catch (notE) {
                    alert("导出数据失败，没有数据可以导出。");
                    window.close();
                    return;
                }
                sel.select();
                sel.execCommand("Copy");
                oRange.Paste();
                oWD.Application.Visible = true;
                //window.close();
            }
            catch (e) {
                alert("浏览器安全限制,下载“导出脚本”用浏览器打开运行，或将当前站点加入信任站点，允许在IE中运行ActiveX控件。");
                //try { oWD.Quit(); } catch (ex) { }
                //window.close();
            }
        }

        function output() {
            var url = "/CommonPages/File/DownLoad.aspx";
            url += "?FileName=" + escape("export.htm");
            $("body").append("<iframe style='display:none' name='frameContent' src=" + url + "></iframe>");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <table width="750" height="31" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left">
                <div id="topFile">
                    <span id="expTitle"><b>说明:</b><font color="red"> *</font>填写问卷前请仔细阅读相关附件,仔细填写。</span>
                    <div id="fileItem">
                        <table>
                            <tr>
                                <td id="subItems">
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </td>
        </tr>
    </table>
    <table width="750" border="0" align="center" cellpadding="0" cellspacing="0" id="TestDiv">
        <tr>
            <td align="center">
                <span id="title" style="font-size: 16px; font-weight: bold; font-family: 宋体, Verdana, Tahoma,Arial;
                    color: rgb(245,61,5)"></span>
            </td>
        </tr>
        <tr>
            <td>
                <table width="750" border="0" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="750" style="margin-top: 12px; margin-bottom: 12px; height: 12px;">
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="750" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>
                                        <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="E0E0E0">
                                            <tr bgcolor="#FFFFFF">
                                                <td>
                                                    <div align="left">
                                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span id="content"></span>
                                                        <br />
                                                    </div>
                                                </td>
                                            </tr>
                                    </td>
                                </tr>
                                <tr bgcolor="#FFFFFF">
                                    <td width="100%">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="3">
                                            <tr valign="top">
                                                <td width="100%" id="SurveyList">
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
    <table width="100%" border="0" cellspacing="1" cellpadding="3" style="margin-top: 10px;">
        <tr>
            <td>
                <div id="btnDiv" style="margin: 0 auto; text-align: center; width: 100%; background-color: #e0e0e0;
                    border: solid 1 gray; margin-top: 1px; font-weight: bold">
                    <input value="提交" id='btnTJ' style="height: 35px; width: 60px;" type="button" onclick="commit()" />&nbsp;&nbsp;
                    <input value="取消" id='btnQx' style="height: 35px; width: 60px;" type="button" onclick="cancel()" />
                </div>
            </td>
        </tr>
    </table>
    <!--    <input value="导出" type="button" onclick="return exportToWord('TestDiv')" />
    &nbsp;&nbsp;&nbsp;<a href="#" id="UsrHelp">使用帮助</a>-->
</asp:Content>
