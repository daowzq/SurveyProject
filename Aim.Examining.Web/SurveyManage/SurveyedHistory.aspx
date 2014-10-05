<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SurveyedHistory.aspx.cs"
    Inherits="Aim.Examining.Web.SurveyManage.SurveyedHistory" %>

<script type="text/javascript">
    window.onerror = function(sMessage, sUrl, sLine) {
        return true
    };
    window.onload = function() {
        //document.createAttribute("color");
        //        try {
        //              $("#__PAGESTATE").remove();
        //        }catch{}
        try {
            $("#btnDiv").hide();
        } catch (e) { }

        var dom = document.getElementsByTagName("input");
        for (var i = 0; i < dom.length; i++) {
            dom[i].setAttribute("disabled", "disabled");
            dom[i].setAttribute("readonly", "readonly");
        }
        var textarea = document.getElementsByTagName("textarea");
        for (var i = 0; i < textarea.length; i++) {
            textarea[i].setAttribute("disabled", "disabled");
        }

        //图片的呈现
        try {
            $("img[class='questImg']").each(function() {
                var src = $(this).attr("src");
                $(this).attr("src", src.replace(src.substring(0, src.indexOf("/Document")), ""))
            });
        } catch (e) {
        }

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
                        } else {    //填写项
                            $("textarea[name='" + this.QuestionId + "']").text(this.QuestionContent);
                        }
                    });
                }
            });


        }, 500);

        //        } catch (e) {

        //        }
    }

</script>

