<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="SearchQusetionKeyEdit.aspx.cs" Inherits="Aim.Examining.Web.SearchQusetionKeyEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            margin: 0;
            padding: 0;
            font-family: 宋体, 微软雅黑, Verdana, Andalus, Arial;
        }
        #fristLevel
        {
            width: 700px;
            margin-left: 5%;
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
        .comment-pager
        {
            color: #333;
            font-size: 12px;
            padding-top: 5px;
            padding-bottom: 15px;
            text-align: center;
        }
        .comment-pager a
        {
            width: 23px;
            height: 22px;
            line-height: 22px;
            border: solid 1px #e7cf0;
        }
        .comment_pager_a
        {
            width: 23px;
            height: 22px;
            line-height: 22px;
            border: solid 1px #e7cf0;
        }
        .page_current
        {
            font-weight: bold;
            color: Black;
        }
        .reply
        {
            background-color: #ffffff;
            border: solid 1px rgb(226,226,226);
            margin-top: 2px;
            box-shadow: inset 1px 1px 1px #f2f2f2;
            padding-left: 2%;
            padding-right: 2%;
        }
        .reply_area
        {
            margin-top: 12px;
            border: solid 1px #ccc;
        }
        .reply_area textarea
        {
            width: 605px;
            border: none;
            overflow: scroll;
            display: block;
        }
        .submitBtn
        {
            height: 40px;
            border-bottom: solid 1px #ccc;
            margin-top: 1px;
        }
        .reply_SubCommnet
        {
            border-bottom: dotted 1px #ccc;
            margin-top: 10px;
            padding-bottom: 10px;
            margin-bottom: 10px;
        }
        .reply_SubCommnet_title
        {
            font-family: 微软雅黑, Verdana, Arial;
            font-size: 12px;
            color: Gray;
            margin-bottom: 8px;
        }
        #conts
        {
            text-indent: 24px;
            margin-top: 20px;
            margin-bottom: 20px;
        }
    </style>

    <script type="text/javascript">

        var finalHtml = ""; //系统生成的html页面
        var QuestionId = $.getQueryString({ ID: "QuestionId" }) || "";

        //Html模板
        var template = {
            //采纳意见head
            tpl_acptHear: "<div style='margin-left: 30px; margin-right: 30px; margin-top: 15px;'><div style='height: 20px; padding-top: 12px;'>\
                           <div style='float: left'><h2>较好意见</h2></div><div style='float: right; font-size: 12px; color: Gray; margin-top: 5px'>\
                           <span><span>{nikeName}</span>|{date}</span></div></div></div>",
            //采纳意见
            tpl_accept: "<div style=\"margin-left: 30px; margin-right: 30px; margin-top: 15px;\">\
                         <div style=\"height: 20px; padding-top: 12px;\"> <div style=\"float: left\"><h2>较好意见</h2></div>\
                         <div style=\"float: right; font-size: 12px; color: Gray; margin-top: 5px\">\
                         <span><span>{nikeName}</span>|{date}</span></div></div></div>",

            tpl_acptConten: "<div style=\"margin-left: 30px; margin-right: 30px; margin-top: 15px; padding-bottom: 12px;\">\
                             <pre id=\"wordContent\">{content}</pre>\
                             <div class='commont'><span onclick='commnetClick(this)' class='commentBtn' subId='{subId}' >评论({count})</span></div>\
                             <div class='reply' style='display:none;'><div class='reply_area'><textarea sign='{answerId}' rows='4'></textarea></div>\
                             <div class=\"submitBtn\">\
                             <input type='button' value='发布' onclick='commitReply(this)' sign='{answerId}' style='float: right;' />\
                             <input type='button' value='清空' onclick='clearTxt(this)' style=\"float: right;\" /></div></div></div>",
            //其他评论
            tpl: "<div id=\"otherComment\" style=\"background-color: #ffffff; padding-top: 15px;\">\
                  <div style=\"margin-left: 30px; margin-right: 30px; margin-top: 12px;\"><h2>其他评论</h2></div>{comment}{pager}</div>",

            //subId<==>{answerId}
            tpl_comment: "<div class=\"commentDiv\"><div style=\"font-size: 12px; color: Gray; margin-top: 15px;\">\
                          <span style=\"float: right;\">{date}</span><span>{nikeName}</span></div>\
                          <pre>{content}</pre><div class='commont'><span onclick='commnetClick(this)' class='commentBtn' subId={subId} count='{count}' >评论({count})</span></div>\
                          <div class='reply' style='display:none;'><div class='reply_area'><textarea sign='{answerId}' rows='4'></textarea></div>\
                          <div class=\"submitBtn\">\
                          <input type='button' value='发布' onclick='commitReply(this)' sign='{answerId}' style='float: right;' />\
                          <input type='button' value='清空'  onclick='clearTxt(this)' style=\"float: right;\" /></div></div></div>",
            //回复head
            tpl_reply: "<div class=\"reply\"><div class=\"reply_area\"><textarea sign='{answerId}' rows=\"4\"></textarea>\
                        </div><div class=\"replyBtn\">\
                        <input type=\"button\" value=\"发布\" id='submit' sign='{answerId}' style=\"float: right;\" />\
                        <input type=\"button\" value=\"清空\" id='clear' style=\"float: right;\" /></div>{replyItem}{pager}</div>",
            //评论的回复项{answerId}<==>parentID
            tpl_replyItem: "<div class=\"reply_SubCommnet\"><div class=\"reply_SubCommnet_title\">\
                            <span class='nikeName'>{nikeName}</span>&nbsp;&nbsp;&nbsp;&nbsp;<span>{date}</span></div>\
                            <div style='font-size: 12px;'><span>{content}</span>&nbsp;\
                            <a style=\"text-decoration: none;cursor:pointer;color: gray;\" class='replyBtn' nikeName='{nikeName}'\
                            sign='{answerId}' replyId='{replyId}' onclick='clickReply(this)' >回复</a></div></div>",
            //分页
            tpl_pager: "<p class=\"comment-pager\" type='{type}' >{pageNumber}</p>" //<a href="#">4</a>    当前选中页
        }
        var replyArr = [];
        function onPgLoad() {
            UsrInfo = AimState["UserInfoEnt"][0] || {};
            SetPgUI();
        }
        function SetPgUI() {
            //设置最外层Div宽度
            // $("#fristLevel").css("margin-left", parseInt(($("body").width() - 700) * 0.3));

            $("#QuestionId").val(QuestionId);
            setQuestion();
            setComment();

            //  //点击评论
            //  $(".commentBtn").each(function(i) {

            //      $(this).toggle(function() {//呈现
            //          var obj = this;

            //          var haveRender = false;
            //          $(replyArr).each(function() {
            //              if (this == $(obj).attr("subId")) {
            //                  haveRender = true;
            //              }
            //          });

            //          if (!haveRender) {  //no rendere
            //              var comCount = parseInt($(obj).attr("count") || 0);  //评论的次数
            //              var replyHtml = replyRender($(this).attr("subId"), comCount);
            //              $(this).parent().next().show().children(".submitBtn").after(replyHtml)
            //              replyArr.push($(obj).attr("subId"));
            //          } else {
            //              $(this).parent().next().show();  //展开回复
            //          }

            //      }, function() {//隐藏元素
            //          $(this).parent().next().hide();  //隐藏元素
            //      });

            //   });

        }

        //-----------------------------

        //点击评论
        function commnetClick(e) {
            $(e).toggle(function() {//呈现
                var obj = this;
                var haveRender = false;
                $(replyArr).each(function() {
                    if (this == $(obj).attr("subId")) {
                        haveRender = true;
                    }
                });

                if (!haveRender) {  //no rendere
                    var comCount = parseInt($(obj).attr("count") || 0);  //评论的次数
                    var replyHtml = replyRender($(e).attr("subId"), comCount);
                    $(e).parent().next().show().children(".submitBtn").after(replyHtml)
                    replyArr.push($(obj).attr("subId"));
                } else {
                    $(e).parent().next().show();  //展开回复
                }

            }, function() {//隐藏元素
                debugger;
                $(e).parent().next().hide();  //隐藏元素
            });
        }

        //清空
        function clearTxt(e) {
            $(e).parent().prev().find("textarea").text("");
        }

        //提交回复
        function commitReply(e) {

            var replyId = ($(e).parent().prev().text() + "").indexOf("回复") > -1 ? $("#replyId").val() : ($(e).attr("sign") || "")
            var content = $(e).parent().prev().text();
            //used for debug
            if (!replyId) {
                alert("replyId is null");
                return;
            }

            $.ajaxExec("Reply", { ReplyId: replyId, Content: content }, function(rtn) {
                AimDlg.show("回复成功!");

                //$(e).parent().prev().text(); //textarea  清空

                //回复呈现
                var AnserId = rtn.data.AnserId || "";
                var NikeName = UsrInfo["Nickname"] || "";
                var Date = $.getDatePart();

                var replyItemItem = template.tpl_replyItem;
                var temp = replyItemItem.replaceAll("{nikeName}", NikeName || "无名氏");
                temp = temp.replaceAll("{date}", Date);
                temp = temp.replaceAll("{content}", content);
                temp = temp.replaceAll("{answerId}", replyId);
                temp = temp.replaceAll("{replyId}", AnserId);

                //移除最后一个

                var row = $(e).parent().siblings(".reply_SubCommnet").size();
                if (row > 4) {
                    $(e).parent().siblings(".reply_SubCommnet").last().remove();

                }
                //追加元素
                $(e).parent().after(temp);
                var cot = $(e).parents("div[class='reply']").prev().find("span");
                var thiscot = Number($(cot).attr("count")) + 1;
                $(cot).attr("count", thiscot).html("评论(" + thiscot + ")");
               
                var page = $(e).parent().siblings("p").find("a").size();
                var thispage = thiscot % 5 == 0 ? thiscot / 5 : Math.floor(thiscot / 5) + 1;
                if (page < thispage) {
                    var pag = $(e).parent().siblings("p").find("a").last();
                    var thispag = $(pag).html(thispage).removeAttr("class");
                    $(e).parent().siblings("p").append($(pag).html(thispage).removeAttr("class"));
                }

                return;
            });
        }


        //点击回复项
        function clickReply(e) {
            var obj = e;
            $("textarea").each(function() {
                if ($(this).attr("sign") == $(obj).attr("sign")) {
                    var replyId = $(obj).attr("replyId") || "";
                    $("#replyId").val(replyId);

                    var nike = $(obj).attr("nikeName") || ""
                    $(this).text("回复 [" + nike + "] :");

                }
            })
        }

        //回复分页
        function replyPgClick(e) {
            //当前选中项样式
            $(e).addClass('page_current').css({ border: "none" });
            $(e).siblings().removeClass("page_current").css({ "width": 23, "height": 22, "line-height": "22px" })

            var pg = parseInt($(e).text() || "1");  //当前选中的页
            var AnswerId = $(e).parent().parent().prev().find("span").attr("subId");

            $.ajaxExec("GetReplyPg", { AnswerId: AnswerId, CurrentPg: pg }, function(rtn) { 
                //$("#otherComment")
                if (rtn.data.ReplyEnts) {
                    //首先清空
                    $(e).parent().parent().find(".reply_SubCommnet").remove();

                    //重新绘制
                    var rDrawHtml = replyItemRender(rtn.data.ReplyEnts);
                    $(e).parent().before(rDrawHtml);
                }
            });
        }

        function commentPgClick(e) {
            //当前选中项样式

            $(e).addClass('page_current').css({ border: "none" });
            $(e).siblings().removeClass("page_current").css({ "width": 23, "height": 22, "line-height": "22px" })

            var pg = parseInt($(e).text() || "1");
            var QuestionId = $("#QuestionId").val().replace("#", ""); //莫名其妙多了#

            $.ajaxExec("GetCommentPg", { QuestionId: QuestionId, PageSize: 10, CurrentPg: pg }, function(rtn) {
                //$("#otherComment")
                if (rtn.data.CommentEnts) {
                    //首先清空

                    $(".commentDiv").remove();  //$("#otherComment")
                    //重新绘制
                    var rDrawHtml = commenItemRender(rtn.data.CommentEnts);
                    $("#otherComment>div:eq(0)").after(rDrawHtml);
                }
            });

        }
        //--------------------------------------------------------------
        //问题设置
        function setQuestion() {

            var obj = AimState["frmdata"] || '';

            var Id = obj["Id"];
            var Contents = obj["Contents"];
            var Anonymity = obj["Anonymity"];
            var Category = obj["Category"];
            var AnswerCount = obj["AnswerCount"];
            var ViewCount = obj["ViewCount"];
            var NikeName = obj["NikeName"];
            var CreateTime = obj["CreateTime"];
            if (obj) {
                $("#question").html(Contents);
                $("#qtDate").text(CreateTime.split(" ")[0]);

                NikeName = NikeName ? NikeName : "匿名";
                $("#nikeName").text(NikeName);
                $("#typeName").text(Category);
                $("#viewcount").text(ViewCount);
                $("#conts").text(Contents);
            }
            //  question qtDate nikeName typeName viewcount

        }


        /*  回复项呈现
        par: total 评论次数
        */
        function replyRender(answerId, total) {

            var repHtmlObj = {
                replyHead: "",
                replyBody: "",
                replyPager: ""
            }

            //分页模板Html
            var tpl_pager = template.tpl_pager;

            $.ajaxExecSync("RendReply", { AnswerId: answerId }, function(rtn) {
                if (rtn.data.ReplyEnt) {
                    var replyEnt = rtn.data.ReplyEnt;
                    if (replyEnt.length > 0) {

                        repHtmlObj.replyBody = replyItemRender(replyEnt);
                        //分页
                        repHtmlObj.replyPager = replyPager(total);
                    }
                }
            });

            //tpl_reply.replace("{answerId}", answerId || "");
            var repHtml = repHtmlObj.replyBody + repHtmlObj.replyPager;
            return repHtml;
        }

        function setComment() {

            //采纳意见head
            var tpl_acptHear = template.tpl_acptHear;
            var tpl_accept = template.tpl_accept;
            var tpl_acptConten = template.tpl_acptConten;

            //其他评论
            var tpl = template.tpl;
            var tpl_comment = template.tpl_comment;
            //分页
            var tpl_pager = template.tpl_pager;   //<a href="#">4</a>    当前选中页

            // 评论项对象
            var htmlObj = {
                acceptHtml: '',        //接受的意见
                commentContainer: '',  //其他评论= commentItemHtml+ externalPgHtml 
                commentItemHtml: '',   //其他的评论项
                externalPgHtml: '',     //分页
                finalHtml: ''
            }

            var obj = AimState["topDate"] || '';
            var comment = AimState["Comment"] || [];
            var otherPgCount = obj["AnswerCount"] || 0; //其他评论总数


            if (obj["AcceptAnswerId"]) {
                var Id = obj["Id"];                     //问题ID
                var AnswerCount = obj["AnswerCount"];   //回答次数
                var A_Id = obj["A_Id"];
                var Answer = obj["Answer"];
                var A_Anonymity = obj["A_Anonymity"];
                var ParentId = obj["ParentId"];
                var IsLeaf = obj["IsLeaf"];
                var IsCheck = obj["A_IsCheck"];
                var A_NikeName = obj["A_NikeName"];
                var A_CreateTime = obj["A_CreateTime"];
                if (A_Anonymity == 1) A_NikeName = "匿名";
                A_CreateTime = A_CreateTime.split(" ")[0];

                var temp1 = "", tempHead = "";
                temp1 = tpl_acptConten.replaceAll("{comment}", Answer);
                // temp1 = temp1.replaceAll("{count}", ReplyCount);         //count>0 表示有回复项
                temp1 = temp1.replaceAll("{subId}", A_Id);               //回答项ID
                temp1 = temp1.replaceAll("{replyItem}", "");

                //Head 部分
                tempHead = tpl_accept.replaceAll("{nikeName}", A_NikeName || "无名氏");
                tempHead = tempHead.replaceAll("{date}", A_CreateTime);

                htmlObj.acceptHtml = tempHead + temp1;


                htmlObj.commentItemHtml = commenItemRender(comment);
                // var tpl = tpl.replace("其他评论", "相关评论");
            } else {  //无采纳意见
                tpl = tpl.replace("其他评论", "相关评论");
                htmlObj.commentItemHtml = commenItemRender(comment);
            }


            //分页
            htmlObj.externalPgHtml = commentPager(otherPgCount);

            //呈现
            var finalHtml = htmlObj.acceptHtml + tpl.replaceAll("{comment}", htmlObj.commentItemHtml).replace("{pager}", htmlObj.externalPgHtml);
            $("#content").append(finalHtml);

        }

        //----------------------------------分页----------------------------------------------
        //评论分页
        function commentPager(otherPgCount) {
            //pageSize 默认为10 页
            var externalPg = "", pageSize = 10;
            var tpl_pager = template.tpl_pager;

            if (parseInt(otherPgCount) > pageSize) {
                var total = parseInt(otherPgCount);
                var pgCount = parseInt((total / pageSize)) + ((total % pageSize) > 0 ? 1 : 0);
                var Pgtp = "";
                for (var i = 0; i < pgCount; i++) {
                    //默认为选中第1页
                    if (i == 0) {
                        Pgtp += " <a href='#' onclick='commentPgClick(this)' class='page_current' style='border: none;' >" + (i + 1) + "</a>"
                    } else {
                        Pgtp += "<a href='#' onclick='commentPgClick(this)' >" + (i + 1) + "</a>";
                    }
                }
                externalPg = tpl_pager.replaceAll("{pageNumber}", Pgtp);
                externalPg = externalPg.replaceAll("{type}", "external");  //type=external 标识外层分页
            }
            return externalPg;
        }

        //评论的回复分页
        function replyPager(othenReplyCount) {
            //pageSize 默认为5页
            var innerPg = "", pageSize = 5;
            var tpl_pager = template.tpl_pager;

            if (parseInt(othenReplyCount) > pageSize) {  //启用分页
                var tal = parseInt(othenReplyCount);
                pgTal = parseInt(tal / pageSize) + (tal % pageSize > 0 ? 1 : 0);
                var Pgtp = "";
                for (var i = 0; i < pgTal; i++) {
                    //默认为选中第1页
                    if (i == 0) {
                        Pgtp += " <a href='#' onclick='replyPgClick(this)' class='page_current' style='border: none;' >" + (i + 1) + "</a>"
                    } else {
                        Pgtp += "<a  onclick='replyPgClick(this)' href='#'>" + (i + 1) + "</a>";
                    }
                }

                innerPg = tpl_pager.replaceAll("{pageNumber}", Pgtp);
                innerPg = innerPg.replaceAll("{type}", " inner"); //type=external 回复分页
            }
            return innerPg;
        }
        //--------------------------------------end--------------------------------


        //--------------------------------------子项呈现---------------------------
        function replyItemRender(repEnts) {

            //used to debug
            if (!repEnts.length > 0) {
                alert("No Ents !");
                return;
            }

            var replyEnt = repEnts;
            var tpl_replyItem = template.tpl_replyItem;  //指定模板

            var replyFaily = "";
            for (var i = 0; i < replyEnt.length; i++) {
                var tempObj = replyEnt[i];
                var Id = tempObj["Id"];
                var NikeName = tempObj["NikeName"];
                var CreateTime = tempObj["CreateTime"] || "";
                var Anonymity = tempObj["Anonymity"];
                var ParentId = tempObj["ParentId"];
                var Answer = tempObj["Answer"];
                CreateTime = CreateTime.split(" ")[0];
                if (Anonymity) NikeName = "匿名";

                var temp = tpl_replyItem.replaceAll("{nikeName}", NikeName || "无名氏");
                temp = temp.replaceAll("{date}", CreateTime);
                temp = temp.replaceAll("{content}", Answer);
                temp = temp.replaceAll("{answerId}", ParentId);
                temp = temp.replaceAll("{replyId}", Id);
                replyFaily += temp;

            }
            return replyFaily;
        }

        //评论项呈现
        function commenItemRender(comment) {
            //used to debug
            if (!comment.length > 0) {
                alert("No comment Ents !");
                return;
            }

            var tpl_comment = template.tpl_comment;   //指定模板

            var itemTemp = "";
            for (var i = 0; i < comment.length; i++) {
                var tempObj = comment[i];

                var Id = tempObj["Id"];
                var Answer = tempObj["Answer"];
                var Anonymity = tempObj["Anonymity"];
                var IsLeaf = tempObj["IsLeaf"];
                var NikeName = tempObj["NikeName"];
                var ReplyCount = tempObj["ReplyCount"];
                var CreateTime = tempObj["CreateTime"] || "";
                CreateTime = CreateTime.split(" ")[0];
                var NikeName = tempObj["NikeName"];
                if (Anonymity) NikeName = "匿名";

                var temp = "";
                temp = tpl_comment.replaceAll("{date}", CreateTime);
                temp = temp.replaceAll("{content}", Answer);
                temp = temp.replaceAll("{nikeName}", NikeName || "无名氏");
                temp = temp.replaceAll("{count}", ReplyCount || 0);         //count>0 表示有回复项
                temp = temp.replaceAll("{subId}", Id);   //子项ID
                temp = temp.replaceAll("{answerId}", Id); //answertId <=>Id
                temp = temp.replaceAll("{replyItem}", "");
                itemTemp += temp;
            }
            return itemTemp;
        }
        //-----------------------------------------------------------end-------------------------

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div style="display: none">
        <input name="QuestionId" id="QuestionId" type="hidden" />
        <input name="replyId" id="replyId" type="hidden" />
    </div>
    <div id="fristLevel">
        <div style="margin-top: 20px; margin-left: 30px; margin-right: 30px;">
            <h1>
                <img alt="" src="/images/shared/doubt.png" />
                <span id="question">飞力企业文化系统评论怎么用？</span></h1>
        </div>
        <div style="font-size: 12px; color: Gray;">
            <div>
                <span style="float: right; margin-right: 30px; margin-top: 2px" id="qtDate">2013-7-15</span></div>
            <div style="margin-left: 30px; margin-right: 30px; margin-top: 2px">
                <span id="nikeName">匿名</span>&nbsp;|<span>分类: <span id="typeName">生活</span> </span>
                &nbsp;| <span>浏览次数:<span id="viewcount">0</span>次</span>
            </div>
            <div id="conts">
            </div>
        </div>
        <div style="background-color: rgb(239,239,239); padding-bottom: 20px" id="content">
        </div>
    </div>
</asp:Content>
