<%@ Page Title="统计分析" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FStatisticsGuid.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.FStatisticsGuid" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .x-panel-body x-form
        {
            height: 0px;
        }
        .selected
        {
            color: #666666;
            text-decoration: none;
            border-bottom: #CCCCCC 1px dotted;
            border-bottom-color: #fff;
        }
    </style>
    <script type="text/javascript">

        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';
        var Count = $.getQueryString({ ID: 'Count' }) || "";
        var title = $.getQueryString({ ID: 'title' }) || "";

        function onPgLoad() {
            setPgUI();
            IE_Flash();
        }
        function IE_Flash() {
            try {
                var swf = new ActiveXObject("ShockwaveFlash.ShockwaveFlash");
            } catch (e) {
                if (confirm("您的浏览器中没有安装Flash 插件,可能有些功能无法使用,是否下载？")) {
                    window.open("http://get.adobe.com/cn/flashplayer/", "pop1", "width=" + (window.screen.width - 15) + ",height=" + (window.screen.height - 170) + ",left=0,top=0,toolbar=yes,menubar=yes,scrollbars=yes,resizable=yes,location=yes,status=yes")
                }
            }
        }

        function setPgUI() {

            var url1 = "T_SurveyStatisticTab.aspx?SurveyId=" + SurveyId + "&rand=" + Math.random();
            var Items = "<li><a href='" + url1 + "' style='font-size:12px;' target='subFrameContent' id='cnd_one' >基本统计</a></li>";

            var url3 = "FDimension.aspx?SurveyId=" + SurveyId + "&title=" + title;
            Items += "<li><a href='" + url3 + "' style='font-size:12px;' target='subFrameContent' id='cnd_three'  >维度筛选</a></li>";

            var url4 = "FilterStatictics.aspx?screenType=allscreen&SurveyId=" + SurveyId + "&Count=&title=" + title;
            Items += "<li><a href='" + url4 + "' style='font-size:12px;' target='subFrameContent' id='cnd_three'  >票数统计</a></li>";
            //var url2 = "FilterStatictics.aspx?SurveyId=" + SurveyId + "&Count=" + Count + "&title=" + title;
            //Items += "<li><a href='" + url2 + "' style='font-size:12px;' target='subFrameContent' id='cnd_two'   >条件筛选</a></li>";

            var accordion = new Ext.ux.AimPanel({
                id: 'accordion',
                region: 'west',
                split: true,
                collapsible: true,
                width: 160,
                margins: '3,0,3,3',
                cmargins: '3,3,3,',
                layout: 'accordion',
                items: [
                 new Ext.Panel({
                     id: 'area',
                     title: "<b>统计条件区</b>",
                     html: Items,
                     cls: 'accordion-nav'
                 })
                ]
            });

            var viewport = new Ext.ux.AimViewport({
                items: [accordion, {
                    region: 'center',
                    border: true,
                    margins: '0 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="subFrameContent" name="subFrameContent" frameborder="0" src=""></iframe>'
                }]
            });
            window.setTimeout(function () {
                $('.accordion-nav li a').eq(0).addClass('selected').css({ "border-bottom-color": "#fff" });
                subFrameContent.location.href = url1;
            }, 50)

            $('.accordion-nav li a').click(function (ev) {
                $('.accordion-nav li a.selected').removeClass('selected');
                $(this).addClass('selected').css({ "border-bottom-color": "#fff" });
                if ($(this).attr("id") == "cnd_two") {
                    $("#subFrameContent").attr("src", "");
                    Ext.getCmp("accordion").collapse();
                }
            });

        }
           
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
