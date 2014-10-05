<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="SpecialTest.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SpecialTest" %>

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
    </style>

    <script src="js/renderSurvey.js" type="text/javascript"></script>

    <script src="js/forHtml.js" type="text/javascript"></script>

    <script type="text/javascript">
        //http://192.168.0.2:8011/SurveyManage/SpecialTest.aspx?Id=e931e45a-644e-4932-b3ef-e789ff811739&uid=xxxxx
        var id = $.getQueryString({ ID: 'Id' });            // SurveyId
        var op = $.getQueryString({ ID: 'op' });            //
        var type = $.getQueryString({ ID: 'type' });        //type

        var records, survey;
        var UserID = $.getQueryString({ ID: 'uid' }) || ''
        var UserName = "";
        function onPgLoad() {

            $("#btnTJ").click(function() {
                commit();
            });
            $("#btnQx").click(function() {
                cancel();
            });

            addFileRender();
            renderView();
            setPageUI();

            $("#UsrHelp").click(function() {
                var Modelstyle = "dialogWidth:960px; dialogHeight:580px; scroll:yes; center:yes; status:no; resizable:no;";
                var url = "ExportHelp.aspx";
                OpenModelWin(url, window, Modelstyle, null);
            });
        }
        function setPageUI() {
            $(".discuss").click(function() {
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
                    var temp = tpl.replace("{href}", "  /CommonPages/File/DownLoad.aspx?id=" + fileArr[i].substring(0, 36));
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

            //----------------------------------随机标志----
            var rand;
            $("input").attr("readonly", true);
            $("input:radio,input:checkbox").click(function() {
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
                var sepecialObj = selectSpecialItem(); //特殊题处理
                $(".IsExplanation", sepecialObj["specialArr"]).css({ width: "30px" }).keyup(function() {
                    $(this).val($(this).val().replace(/\D|^0/g, '')); //限制数值输入
                    ($(this).val().length > 1) && ($(this).val(($(this).val() + "").substring(0, 1))) //长度限制
                });
            }

        }



        function commit() {/*提交*/
            //必填项验证
            var validate = true;
            var eltObjArr = [];   //未填的元素
            $(".mustInput").each(function() {
                if ($("[name=" + $(this).attr("name") + "]").is("textarea")) {
                    if (!$("[name=" + $(this).attr("name") + "]").text()) {
                        validate = false;
                        eltObjArr.push($("[name=" + $(this).attr("name") + "]"));
                    }
                } else {
                    if (!$("[name=" + $(this).attr("name") + "]:checked").val()) {
                        validate = false;
                        eltObjArr.push($("[name=" + $(this).attr("name") + "]"));
                    }
                }
            })

            if (!validate) {
                var JObj = eltObjArr[0];
                if (typeof (JObj) == "object") {
                    //var totalH = $(document).height();

                    //滚动条的高度
                    var eleH = $(JObj[0]).offset().top;
                    $(document.body).scrollTop(eleH - 20);

                }
                return AimDlg.show("您有未填的必选项!");
            }

            //判断是否固定离职问卷
            var SurveyType = AimState["Survey"] ? (AimState["Survey"]["SurveyTitile"] || "") : "";
            var IsFixed = AimState["Survey"] ? (AimState["Survey"]["IsFixed"] || "") : "";
            if (SurveyType.indexOf("员工离职调查问卷") > -1 && IsFixed == "2") {
                var sepecialObj = selectSpecialItem(); //特殊题处理
                //必填项验证
                var validate = true;
                var eltObjArr = [];   //未填的元素
                $(sepecialObj.specialArr).each(function() {
                    $("input:checked", this).each(function() {
                        eltObjArr.push(this);
                    });

                })

                if (eltObjArr.length < 3) {
                    AimDlg.show("在8-12题选项中,至少选择3 项并在选项后填写'1,2,3'数值标识原因等级!");
                    return;
                }

                //选项说明 是否标识数字
                var noFillDegree = [];
                $(sepecialObj.specialArr).each(function(i) {
                    if (!$(":checked", this).next(".IsExplanation").val()) {
                        noFillDegree.push(i + 8);
                    }
                });
                if (noFillDegree.length > 2) {
                    AimDlg.show("在8-12题选项中,请在选中的选项后填写'1,2,3'数值!");
                    return;
                }
            }




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

                    var tempId = "";
                    var tempConntent = "", itemConten = "";
                    $("[name^=" + recordsObj[i].Id + "]").each(function() {
                        switch (($(this)[0].tagName + "").toUpperCase()) {
                            case "INPUT":
                            case "input":    //选中
                                if ($(this).attr("checked")) {
                                    tempId.length > 0 && (tempId += ",");
                                    tempId += $(this).val();
                                }
                                if ($(this).attr("type") == "text") {
                                    itemConten += $(this).val(); //补充
                                }
                                //   else if (($(this).attr("class") + "").indexOf("IsExplanation ") > -1) {
                                //       itemConten += $(this).val();
                                //    }
                                break;
                            case "TEXTAREA":  //评论
                            case "textarea":
                                tempConntent += $(this).val();
                                break;
                        }
                    });

                    temObj.QuestionItemContent = itemConten; //补充
                    temObj.QuestionItemId = tempId.toString().slice(0, str.length - 1);
                    temObj.QuestionContent = tempConntent;   //评论
                    commitArr.push($.getJsonString(temObj));
                    // QuestionContentId    QuestionItemContent  UserId  UserName CreateTime
                }

                var paramObj = {};

                //处理浏览器差异
                $("input:radio,input:checkbox").each(function() {
                    if ($(this).attr("checked")) {
                        $(this).attr("checked", true);
                    }
                });
                $("input[type=text]").each(function() {
                    if ($(this).val()) {
                        $(this).val($(this).val())
                    }
                });

                $("textarea").each(function() {
                    if ($(this).val()) {
                        $(this).val($(this).val())
                    }
                });
                
                
                var html = $("html").formhtml();

                ///var html = document.getElementsByTagName('html')[0] ? 'innerText' : 'textContent';
                //var html = document.getElementsByTagName('html')[0].innerHTML;

                paramObj["commitArr"] = commitArr;
                paramObj["CommitHistory"] = $.getJsonString({
                    SurveyId: id,
                    SurveyedUserId: UserID,
                    SurveyedUserName: UserName,
                    WorkNo: "",
                    CommitSurvey: html
                });

                if (!records) {
                    AimDlg.show("无问卷内容!");
                    return;
                }

                //* 防止产生多个问卷
                $("#btnTJ").attr("disabled", true);

                AimFrm.submit("Commit", paramObj, null, function() {
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
                    <input value="提交" id='btnTJ' style="height: 35px; width: 60px;" type="button" />&nbsp;&nbsp;
                    <input value="取消" id='btnQx' style="height: 35px; width: 60px;" type="button" />
                </div>
            </td>
        </tr>
    </table>
    <!--    <input value="导出" type="button" onclick="return exportToWord('TestDiv')" />
    &nbsp;&nbsp;&nbsp;<a href="#" id="UsrHelp">使用帮助</a>-->
</asp:Content>
