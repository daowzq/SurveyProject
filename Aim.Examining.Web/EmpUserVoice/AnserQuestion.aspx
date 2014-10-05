<%@ Page Title="问题回答" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="AnserQuestion.aspx.cs" Inherits="Aim.Examining.Web.EmpUserVoice.AnserQuestion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: White;
            margin: 0;
            padding: 0;
            font-family: 宋体, 微软雅黑, Verdana, Andalus, Arial;
        }
        #fristLevel
        {
            width: 700px;
            margin-left: 5%;
            margin-right: auto;
            margin-top: 10px;
            border: solid 1px rgb(226,226,226);
        }
        h1
        {
            line-height: 26px;
            font-family: 微软雅黑, Arial, Verdana;
            font-size: 16px;
            font-style: normal;
            font-weight: bold;
            font-size-adjust: none;
            font-stretch: normal;
        }
        h2
        {
            line-height: 24px;
            font-family: 微软雅黑, Arial;
            font-size: 15px;
            font-style: normal;
            font-weight: bold;
        }
        pre
        {
            font-family: arial,courier new,courier,宋体,monospace;
            white-space: pre-wrap;
            word-wrap: break-word;
            margin-top: 12px;
        }
        .commentDiv
        {
            margin-left: 30px;
            margin-right: 30px;
            margin-top: 12px;
            padding-bottom: 10px;
            border-bottom: dotted 1px gray;
        }
        .commont
        {
            font-size: 12px;
            color: #2d64b3;
            cursor: pointer;
            padding-left: 80%;
        }
    </style>

    <script src="../js/fckeditor/fckeditor.js" type="text/javascript"></script>

    <script type="text/javascript">
        var QuestionId = $.getQueryString({ ID: "QuestionId" });
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            initState();
            $("#btnSubmit").click(function() {
                if ($("#Id").val()) {
                    if (!confirm("该问题已被您回答过,是否再次回答该问题!"))
                        return;
                }

                var Anonymity = $("#Anonymity").attr("checked") ? "1" : "";  //1匿名 表示
                var oEditor = FCKeditorAPI.GetInstance("Answer").GetXHTML(true);
                AimFrm.submit("create", { Anonymity: Anonymity, Answer: oEditor, QuestionId: QuestionId }, null, function() { RefreshClose(); });

            });
        }



        //状态初始化
        function initState() {

            if (AimState["frmdata"]) {

                var QuestionId = AimState["frmdata"]["QuestionId"];
                var Id = AimState["frmdata"]["Id"];

                var Contents = AimState["frmdata"]["Contents"];
                var Anonymity = AimState["frmdata"]["Anonymity"];
                var CreateTime = AimState["frmdata"]["CreateTime"];
                var Category = AimState["frmdata"]["Category"];
                var ViewCount = AimState["frmdata"]["ViewCount"] || "0";

                CreateTime = CreateTime.split(" ")[0];   //日期

                if (Anonymity == "1") {
                    $("#publishUsr").text("匿名用户")
                } else {
                    $("#publishUsr").text("暂无")
                }

                Id && $("#Id").val(Id);
                $("#question").html(Contents);          //问题内容
                $("#publishDate").text(CreateTime);      //发布日期 
                $("#QuestonType").text(Category);       //类型
                $("#viewCount").text(ViewCount);        //浏览次数

                $("#QuestionId").val(QuestionId)        //问题ID
                $("#QuestionContent").val(Contents);    //
            }

        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div style="display: none">
        <input name="Id" id="Id" type="hidden" />
        <input name="QuestionId" id="QuestionId" type="hidden" />
        <input name="QuestionContent" id="QuestionContent" type="hidden" />
    </div>
    <div id="fristLevel">
        <div style="margin-top: 20px; margin-left: 30px; margin-right: 30px;">
            <!-- <h1>
                <span id="question"></span>
            </h1>-->
        </div>
        <!--        <div style="font-size: 12px; color: Gray;">
            <div>
                <span id="publishDate" style="float: right; margin-right: 30px; margin-top: 2px">
                </span>
            </div>
            <div style="margin-left: 30px; margin-right: 30px; margin-top: 2px">
                <!-- <span id="publishUsr"></span>&nbsp;| 分类:<span id="QuestonType"> </span>-->
        <!--<span> &nbsp;|浏览次数:<span id="viewCount">100</span>次</span>
    </div>
    </div> -->
        <div style="background-color: rgb(239,239,239)">
            <div style="margin-left: 30px; margin-right: 30px; margin-top: 15px;">
                <div style="height: 20px; padding-top: 12px;">
                    <div style="float: left">
                        <h2>
                            我来回答</h2>
                    </div>
                </div>
            </div>
            <div style="margin-left: 30px; margin-right: 30px; margin-top: 15px; padding-bottom: 12px;">
                <textarea id="Answer" name="Answer" aimctrl="editor" style="width: 95%; height: 300px"></textarea>
                <div style="padding-left: 70%; margin-top: 5px; font-size: 12px; text-align: center">
                    <a id="btnSubmit" class="aim-ui-button"><b>提交</b> </a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
