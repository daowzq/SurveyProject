﻿<%@ Page Title="问题解答" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Test.aspx.cs" Inherits="Aim.Examining.Web.EmpUserVoice.Test" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
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
            margin-bottom: 10px;
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
        .replyBtn
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
    </style>

    <script type="text/javascript">

        var obj = "";
        function onPgLoad() {
            function Person(name)   //基类构造函数
            {
                this.name = name;
            };

            Person.prototype.SayHello = function()  //给基类构造函数的prototype添加方法
            {
                alert("Hello, I'm " + this.name);
            };

            function Employee(name, salary) //子类构造函数
            {
                Person.call(this, name);    //调用基类构造函数
                this.salary = salary;
            };

            //Employee.prototype = new Person();  //建一个基类的对象作为子类原型的原型
            Employee.prototype = Person.prototype; //引用
            Employee.prototype.constructor = Employee;

            Employee.prototype.ShowMeTheMoney = function()  //给子类添构造函数的prototype添加方法
            {
                alert(this.name + " $" + this.salary);
            };

            //var BillGates = new Person("Bill Gates");   //创建基类Person的BillGates对象
            var SteveJobs = new Employee("Steve Jobs", 1234);   //创建子类Employee的SteveJobs对象

            //BillGates.SayHello();       //通过对象直接调用到prototype的方法
            SteveJobs.SayHello();       //通过子类对象直接调用基类prototype的方法，关注！
            SteveJobs.ShowMeTheMoney(); //通过子类对象直接调用子类prototype的方法

            //alert(BillGates.SayHello == SteveJobs.SayHello); //显示：true，表明prototype的方法是共享的





            // SetPgUI();
        }
        function SetPgUI() {
            //设置最外层Div宽度
            // $("#fristLevel").css("margin-left", parseInt(($("body").width() - 700) * 0.3));
            var tpl = "";
            $("#subId").click(function() {

                $("#acceptCt").append();
            });
        }


        function initState() {
            if (AimState["frmdata"]) {
                var obj = AimState["frmdata"] || '';
                var comment = AimState["frmdata"]["Comment"] || [];

                setQuestion(obj);
                replyAnswer(comment);
            }
        }

        //问题设置
        function setQuestion(obj) {
            //question
            var Id = obj["Id"];
            var Contents = obj["Contents"];
            var Anonymity = obj["Anonymity"];
            var Category = obj["Category"];
            var AnswerCount = obj["AnswerCount"];
            var ViewCount = obj["ViewCount"];
            var NikeName = obj["NikeName"];
            var IsCheck = obj["IsCheck"];
            var CreateTime = obj["CreateTime"];

            if (obj) {
                $("#question").text(Contents);
                $("#qtDate").text(CreateTime.split(" ")[0]);

                NikeName = NikeName ? "无名氏" : "匿名";
                $("#nikeName").text(NikeName);
                $("#typeName").text(Category);
                $("#viewcount").text(ViewCount);
            }
            //  question qtDate nikeName typeName viewcount

        }

        function replyAnswer(comment) {

            //采纳意见head
            var tpl_acptHear = "<div style='margin-left: 30px; margin-right: 30px; margin-top: 15px;'><div style='height: 20px; padding-top: 12px;'>\
                               <div style='float: left'><h2>较好意见</h2></div><div style='float: right; font-size: 12px; color: Gray; margin-top: 5px'>\
                               <span><span>{nikeName}</span>|{date}</span></div></div></div>";
            //采纳意见
            var tpl_accept = "<div style=\"margin-left: 30px; margin-right: 30px; margin-top: 15px;\">\
                           <div style=\"height: 20px; padding-top: 12px;\"> <div style=\"float: left\"><h2>较好意见</h2></div>\
                           <div style=\"float: right; font-size: 12px; color: Gray; margin-top: 5px\">\
                           <span><span>{nikeName}</span>|{date}</span></div></div></div>";
            var tpl_acptConten = "<div style=\"margin-left: 30px; margin-right: 30px; margin-top: 15px; padding-bottom: 12px;\">\
                                 <pre id=\"wordContent\">{content}</pre><div class='commont'><span subId={subId} >评论({count})</span></div></div>";
            //评论的回复
            var tpl_reply = "<div class=\"reply\"><div class=\"reply_area\"><textarea rows=\"4\"></textarea></div><div class=\"replyBtn\">\
                             <input type=\"button\" value=\"发布\" style=\"float: right;\" />\
                              <input type=\"button\" value=\"清空\" style=\"float: right;\" /></div>{replyItem}</div>";
            //评论的回复项
            var tpl_replyItem = "<div class=\"reply_SubCommnet\"><div class=\"reply_SubCommnet_title\">\
                               <span>{nikeName}</span>&nbsp;&nbsp;&nbsp;&nbsp;<span>{date}</span></div><div style='font-size: 12px;'>\
                               <span>{content}</span>&nbsp;<a style=\"text-decoration: none; color: gray;\" href='#'>回复</a></div></div>";
            //其他评论
            var tpl = "<div id=\"otherComment\" style=\"background-color: #ffffff; padding-top: 15px;\">\
                       <div style=\"margin-left: 30px; margin-right: 30px; margin-top: 12px;\"><h2>其他评论</h2></div>{comment}{pager}</div>";
            var tpl_comment = "<div class=\"commentDiv\"><div style=\"font-size: 12px; color: Gray; margin-top: 15px;\">\
                               <span style=\"float: right;\">{date}</span><span>{nikeName}</span></div>\
                               <pre>{content}</pre><div class='commont'><span subId={subId} >评论({count})</span></div></div>";
            //分页
            var tpl_pager = "<p class=\"comment-pager\">{pageNumber}</p>"; //<a href="#">4</a>  class="page_current" style="border: none;"  当前选中页

            //评论>10 分页 回复评论>5 启用分页  
            //带问题详细信息, 评论次数
            //answer

            //有采纳的意见
            var obj = AimState["frmdata"] || '';
            var AcceptAnswerId = obj["AcceptAnswerId"]  //接受

            if (AcceptAnswerId) {
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

            } else {


            }


            if (parseInt(AnswerCount) > 10) {
                //启用分页

            } else {

            }

        }
        

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="fristLevel">
        <div style="margin-top: 20px; margin-left: 30px; margin-right: 30px;">
            <h1>
                <img alt="" src="/images/shared/doubt.png" />
                <span id="question">中国最厉害的特种部队是什么？</span></h1>
        </div>
        <div style="font-size: 12px; color: Gray;">
            <div>
                <span style="float: right; margin-right: 30px; margin-top: 2px" id="qtDate">2013-7-15</span></div>
            <div style="margin-left: 30px; margin-right: 30px; margin-top: 2px">
                <span id="nikeName">我是谁?</span>&nbsp;|<span>分类: <span id="typeName">军事</span> </span>
                &nbsp;| <span>浏览次数:<span id="viewcount">100</span>次</span>
            </div>
        </div>
        <div style="background-color: rgb(239,239,239)" id="content">
            <div style="margin-left: 30px; margin-right: 30px; margin-top: 15px;">
                <div style="height: 20px; padding-top: 12px;">
                    <div style="float: left">
                        <h2>
                            较好意见</h2>
                    </div>
                    <div style="float: right; font-size: 12px; color: Gray; margin-top: 5px">
                        <span><span>水手大兵</span>| 2013-7-15</span></div>
                </div>
            </div>
            <div style="margin-left: 30px; margin-right: 30px; margin-top: 15px; padding-bottom: 12px;"
                id="acceptCt">
                <pre id="wordContent"> 北京军区特种大队，又称“东方神剑”特种大队，是中国七支特种大队之一，直属于北京军区，
   整个大队虽然仅有三千人，但每一个人都是精英中的精英。
 每一个兵士从战场侦察到反恐作战，不仅常规装备运用自如，各种高科技装备也样样精通，
 不管是空中还是海上，他们都能够完成上级下达的各项任务。　　南京军区“飞龙”特种部队。
    “飞龙”建立于1992年，部队主要进行应对非传统安全的训练，
  并在威胁条件下执行“高强度”任务。　　
    广州军区“华南之剑”特种部队。该部队共有4000名士兵，始建于1988年，
 据说是中国军队现代化之后最早建制的一支特种部队，
  并拥有海陆空三栖作战能力。该部队士兵将接受60个海军、空军交叉科目的训练。
 据说该部队有400多名士兵能够驾驶飞机、表演“驾驶特技”并驾驶船只。</pre>
                <div class='commont'>
                    <span id="subId">评论(200)</span>
                </div>
                <div class="reply">
                    <div class="reply_area">
                        <textarea rows="4"></textarea>
                    </div>
                    <div class="submitBtn">
                        <input type="button" value="发布" style="float: right;" />
                        <input type="button" value="清空" style="float: right;" />
                    </div>
                    <div class="reply_SubCommnet">
                        <div class="reply_SubCommnet_title">
                            <span>wzq-dap</span>&nbsp;&nbsp;&nbsp;&nbsp;<span>2013/7/7</span>
                        </div>
                        <div style="font-size: 12px;">
                            <span>我是中陆军某军区的，我是边境侦察兵出身，是缉毒兵，因伤退伍在家养老，你们中有说对一点点的，特种部队，特种兵，他们就是一群疯子 暴力专家，因为他们的行踪诡异，手法极其凶狠，在我们中国曾经有个被国外的特种兵特工等等军事高手称为狼牙。它成立于197几年！我曾经听说他们最后出现在越南战场上，是过不久他们就不知道去向了，他们是我们军人的荣誉
                                军人最高的信仰就是以服从为本，军令如山</span>&nbsp;<a style="text-decoration: none; color: gray;" href="#">回复</a>
                        </div>
                    </div>
                </div>
            </div>
            <div id="otherComment" style="background-color: #ffffff; padding-top: 15px;">
                <div style="margin-left: 30px; margin-right: 30px; margin-top: 12px;">
                    <h2>
                        其他评论</h2>
                </div>
                <div class="commentDiv">
                    <div style="font-size: 12px; color: Gray; margin-top: 15px;">
                        <span style="float: right;">2015-4-4</span> <span>FLY♂骑士</span></div>
                    <pre>
                    北京军区特种大队，又称“东方神剑”特种大队，是中国七支特种大队之一.
                    </pre>
                    <div class='commont'>
                        <span>评论(200)</span>
                    </div>
                </div>
                <div class="commentDiv">
                    <div style="font-size: 12px; color: Gray; margin-top: 15px;">
                        <span style="float: right;">2015-4-4</span> <span>FLY♂骑士</span></div>
                    <pre>
                    北京军区特种大队，又称“东方神剑”特种大队，是中国七支特种大队之一.
                    </pre>
                    <div class='commont'>
                        <span>评论(200)</span>
                    </div>
                </div>
                <p class="comment-pager">
                    <a href="#">1</a> <a href="#" class="page_current" style="border: none;">2</a> <a
                        href="#">3</a> <a href="#">4</a> <a href="#" style="width: 50; text-decoration: none;">
                            下一页</a>
                </p>
            </div>
        </div>
    </div>
</asp:Content>
