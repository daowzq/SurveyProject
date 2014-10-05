<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="SurveyedHistory_1.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyedHistory_1" %>

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

    <script type="text/javascript">
        var id = $.getQueryString({ ID: 'Id' });            // SurveyId
        var op = $.getQueryString({ ID: 'op' });            //
        var type = $.getQueryString({ ID: 'type' });        //type

        var uid = $.getQueryString({ ID: 'uid' }) || '';
        var uname = $.getQueryString({ ID: 'uname' }) || '';
        var workno = $.getQueryString({ ID: 'workno' }) || '';

        var records, survey;
        var UserID = "", UserName = "";
        function onPgLoad() {
            if (uid) {
                UserID = uid;
                UserName = unescape(uname);
            } else {
                UserID = AimState.UserInfo.UserID;
                UserName = AimState.UserInfo.Name;
            }

            addFileRender();
            renderView();
            setPageUI();
        }
        function setPageUI() {

            $(".discuss").click(function() {
                /*是否评论*/
                $(this).parent().append("<textarea rows=3 style='float: left; width: 415;'" + " name=" + $(this).attr("name") + "/>")
                $(this).unbind("click");
            });

            //赋值选中
            // try {
            window.setTimeout(function() {
                var url = "?GetInfo=1&SurveyId=" + $.getQueryString({ ID: 'SurveyId' }) + "&UserId=" + $.getQueryString({ ID: 'UserId' });
                $.post(url, function(rtn) {
                    var Ent = eval(rtn);
                    if (!$.isEmptyObject(Ent) && Ent.length > 0) {
                        $.each(Ent, function() {
                            if (this.QuestionItemId) {
                                if (this.QuestionItemContent) {  //说明项
                                    var qst = this;
                                    $.each(this.QuestionItemId.split(","), function() {
                                        $("[value='" + this + "']").attr("checked", true);
                                        $("[value='" + this + "']").next().val(qst.QuestionItemContent); //* attention
                                        //$("input[name='" + qst.QuestionItemId + "']").find(".IsExplanation").val(this.QuestionItemContent);
                                    });
                                } else {  //选项
                                    $.each(this.QuestionItemId.split(","), function() {
                                        $("[value='" + this + "']").attr("checked", true);
                                    });
                                }
                            } else {
                                if (($("[name='" + this.QuestionId + "']").attr("class") + "").indexOf("txx1") > -1) {        //input填写项
                                    $("input[name='" + this.QuestionId + "']").val(this.QuestionContent);
                                } else if ($("[name='" + this.QuestionId + "']").attr("class") == "qstSort") { // //排序题
                                    var arr = (this.QuestionContent + "").split(",");
                                    var html = "";
                                    $.each(arr, function() {
                                        html += "<option>" + this + "</option>"
                                    })

                                    $(".qstSort[name='" + this.QuestionId + "']").hide().children().remove();
                                    $(html).appendTo(".qstSort[name='" + this.QuestionId + "']");
                                    $(".qstSort[name='" + this.QuestionId + "']").show();
                                }
                                else {//填写项
                                    $("textarea[name='" + this.QuestionId + "']").text(this.QuestionContent);
                                }
                            }
                        });
                    }
                });


            }, 100);

            var dom = document.getElementsByTagName("input");
            for (var i = 0; i < dom.length; i++) {
                dom[i].setAttribute("disabled", "disabled");
                dom[i].setAttribute("readonly", "readonly");
            }
            var textarea = document.getElementsByTagName("textarea");
            for (var i = 0; i < textarea.length; i++) {
                textarea[i].setAttribute("disabled", "disabled");
            }
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

                    //$(JObj[0]).parent().append("<a id='tiptip' href=#>fdsasdfafadsf</a>");
                    //$(JObj[0]).parent().tipTip({ content: 'adfafasdfdfasfasfadfsa', keepAlive: true });
                    //$("#tiptip").tipTip();
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
</asp:Content>
