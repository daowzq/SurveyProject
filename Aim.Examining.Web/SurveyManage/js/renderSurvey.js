/*
问卷列表渲染
Version:1.0
Author:WGM
Date:2013-9-6
*/

/*渲染问卷列表*/
function buildHtml(objArr) {

    var table = "<table class='QItems' width=\"100%\" border=\"0\" cellspacing=\"1\" cellpadding=\"3\" style=\"margin-top: 5px;\">{sub}<tr></tr></table>";
    var header = "<tr class=\"header\"><td><b>&nbsp;&nbsp;{Num}.&nbsp;{Question}</b></td></tr>";
    var header_Img = "<tr class=\"header\"><td><b>&nbsp;&nbsp;{Num}.&nbsp;{Question}</b></td></tr><tr class='header_img'><td>{img}<td><tr/>"; //附有图片

    var question_radio = "<tr><td class='formCtl'><div style='float: left; width: 28px;'><span>{SortIndex}</span></div><div style='float: left;'><input type=\"radio\" name=\"{name}\" value=\"{value}\" id='{ID}' class='{valiate}' />{item}</div></td></tr>";
    var question_checkbox = "<tr><td class='formCtl'><div style='float: left; width: 28px;'><span>{SortIndex}</span></div><div style='float: left;'><input type=\"checkbox\" name=\"{name}\" id='{ID}' class='{valiate}' value=\"{value}\" />{item}</div></td></tr>";
    var question_textarea = "<tr><td class='formCtl'><textarea id='{ID}' rows=\"3\" name=\"{name}\" class='{valiate} question_textarea' ></textarea></td></tr>";
    var question_discuss = "<tr><td class='formCtl'><div class=\"discuss\" name=\"{name}\"><span><a>评论</a></span></div></td></tr>";
    var queston_IsExplanation = "<tr><td class='formCtl'><div style='float: left; width: 28px;'><span>{SortIndex}</span></div><div style='float: left;'><input type=\"{type}\" name=\"{name}\" id='{ID}' class='{valiate}' value=\"{value}\" />{item}<input type=\"text\" name=\"{name}\" class='IsExplanation' /></div></td></tr>";
    var question_text = "<tr><td class='formCtl'><div style='float: left; width: 2px;'><span>&nbsp;</span></div> <div style='float: left;'><input id='{ID}' class='{valiate} txx1' type='text' name='{name}' /></div></td></tr>";
    var question_sort = "<tr><td class='formCtl'><div style='float: left; width: 3px;'><span></span></div>\
                    <div style='float: left;margin-top:5px;width:300px;'>\
                    <div style='float: right'>\
                    <div><input type='button' value='上移' onclick='onSelectedUp(this)' /></div>\
                    <div style='margin-top: 10px'><input type='button' value='下移' onclick='onSelectedDown(this)' /></div>\
                    </div>\
                    <div style='float: left'><select class='qstSort' name='{name}' size='{size}' {style} >{option}</select>\
                    </div>\
                    <div style='width: 50px;'></div></div></td></tr>";


    var isMustFill = "<font color='red'><span class=\"mustInput\" name=\"{name}\" ><b>&nbsp;*(必填)</b></span></font>";

    var subStringBud = "";                                          //table 级
    for (var i = 0; i < objArr.length; i++) {

        var stringBuilder = "";
        var hd = objArr[i]["Content"] || '';                         //问卷内容
        var type = objArr[i]["QuestionType"] || "";                  //问卷类型
        var isMustAnswer = objArr[i]["IsMustAnswer"] || '';          //是否必答
        var isComment = objArr[i]["IsComment"] || '';                //是否评论
        var questionItems = objArr[i]["SubItems"] || '';             //答案项
        var name = objArr[i]["Id"] || '';                            //问题项ID
        var haveImg = objArr[i]["ImgIds"] || '';                     //是否有图片
        var IsShowScore = objArr[i]["IsShowScore"] || "";            //是否显示分数
        var Validate = objArr[i]["Validate"] || "";                  //验证

        var Ext1 = objArr[i]["Ext1"] || "";                          //图片描述
        type = type.replace("图片(单选)", "单选项");
        type = type.replace("图片(多选)", "多选项");

        switch (type) {
            case "单选项":
                var type = "radio";
                var questionItemsObj = eval("(" + questionItems + ")"); //答案项

                for (var k = 0; k < questionItemsObj.length; k++) {

                    var SortIndex = questionItemsObj[k]["SortIndex"] || "";    // 问卷序号 eg:A,B,C...
                    if (/^\d$/.test(SortIndex)) SortIndex = "";
                    SortIndex = !!SortIndex ? "&nbsp;" + SortIndex + "&nbsp;" : "";


                    var score = questionItemsObj[k]["Score"] ? (" [" + questionItemsObj[k]["Score"] + "分]") : "";
                    score = (IsShowScore == "是") ? score : "";

                    if (questionItemsObj[k]["IsExplanation"] == "否") {

                        var temp = question_radio.replaceAll("{name}", name).replace("{SortIndex}", SortIndex);
                        temp = temp.replaceAll("{item}", questionItemsObj[k]["Answer"] + score);    //选项 
                        temp = temp.replaceAll("{value}", questionItemsObj[k].Id);
                        temp = temp.replaceAll('{ID}', 'checkbox_' + Math.random());
                        if (!!Validate)
                            temp = temp.replaceAll("{valiate}", Validate || "");
                        else
                            temp = temp.replaceAll("{valiate}", "");
                        stringBuilder += temp;
                    }
                    else if (questionItemsObj[k]["IsExplanation"] == "是") {
                        var temp = queston_IsExplanation.replaceAll("{name}", name).replace("{SortIndex}", SortIndex);

                        temp = temp.replaceAll("{item}", (questionItemsObj[k]["Answer"] || "") + score);
                        temp = temp.replaceAll("{type}", type);
                        temp = temp.replaceAll("{value}", questionItemsObj[k].Id);
                        temp = temp.replaceAll('{ID}', 'checkbox_' + Math.random());
                        if (!!Validate)
                            temp = temp.replaceAll("{valiate}", Validate || "");
                        else
                            temp = temp.replaceAll("{valiate}", "");
                        stringBuilder += temp;
                    }
                }
                if (isComment == "是") {   //呈现评论dom
                    stringBuilder += question_discuss.replaceAll('{name}', name);
                }
                break;
            case "多选项":
                hd += "(多选项)";
                var type = "checkbox";
                var questionItemsObj = eval("(" + questionItems + ")");   //答案项
                for (var k = 0; k < questionItemsObj.length; k++) {

                    var SortIndex = questionItemsObj[k]["SortIndex"] || "";    // 问卷序号 eg:A,B,C...
                    if (/^\d$/.test(SortIndex)) SortIndex = "";
                    SortIndex = !!SortIndex ? "&nbsp;" + SortIndex + "&nbsp;" : "";

                    var score = questionItemsObj[k]["Score"] ? (" [" + questionItemsObj[k]["Score"] + "分]") : "";
                    score = (IsShowScore == "是") ? score : "";

                    if (questionItemsObj[k]["IsExplanation"] == "否") {
                        var temp = question_checkbox.replaceAll("{name}", name).replace("{SortIndex}", SortIndex);
                        temp = temp.replaceAll("{item}", questionItemsObj[k]["Answer"] + score);
                        temp = temp.replaceAll("{value}", questionItemsObj[k].Id);
                        temp = temp.replaceAll('{ID}', 'checkbox_' + Math.random());
                        if (!!Validate) {
                            temp = temp.replaceAll("{valiate}", Validate || "");
                        }
                        else {
                            temp = temp.replaceAll("{valiate}", "");
                        }
                        stringBuilder += temp;
                    }
                    else if (questionItemsObj[k]["IsExplanation"] == "是") {
                        var temp = queston_IsExplanation.replaceAll("{name}", name).replace("{SortIndex}", SortIndex);
                        temp = temp.replaceAll("{item}", (questionItemsObj[k]["Answer"] || "") + score);
                        temp = temp.replaceAll("{type}", type);
                        temp = temp.replaceAll("{value}", questionItemsObj[k].Id);
                        temp = temp.replaceAll('{ID}', 'checkbox_' + Math.random());
                        if (!!Validate) {
                            temp = temp.replaceAll("{valiate}", Validate || "");
                        }
                        else {
                            temp = temp.replaceAll("{valiate}", "");
                        }
                        stringBuilder += temp;
                    }

                }
                if (isComment == "是") {//呈现评论dom
                    stringBuilder += question_discuss.replaceAll('{name}', name);
                }
                break;
            case "填写项":
                var temp = question_textarea.replaceAll("{name}", name)
                temp = temp.replaceAll('{value}', '');
                temp = temp.replaceAll('{ID}', 'textarea_' + name);
                //验证
                temp = temp.replaceAll('{valiate}', Validate || "");
                stringBuilder += temp;
                break;
            case "填写项1":
                var temp = question_text.replaceAll("{name}", name)
                temp = temp.replaceAll('{ID}', 'text_' + name);
                //验证
                temp = temp.replaceAll('{valiate}', Validate || "");
                stringBuilder += temp;
                break;
            case "排序项":
                var questionItemsObj = eval("(" + questionItems + ")"); //答案项
                var temp = question_sort.replaceAll("{name}", name);
                temp = temp.replace("{size}", questionItemsObj.length);

                var optionItem = "", charlength = 0;
                for (var k = 0; k < questionItemsObj.length; k++) {
                    charlength = (questionItemsObj[k]["Answer"].length > charlength) ? questionItemsObj[k]["Answer"].length : charlength;
                    optionItem += "<option value='" + questionItemsObj[k]["Answer"] + "' >" + questionItemsObj[k]["Answer"] + "</option>";
                }

                var styleStr = ' style="width: 80px;"';  //默认宽度
                var tempWidth = "160";
                try {
                    if (/^[\u2E80-\u9FFF]+$/.test(questionItemsObj[0]["Answer"]) && charlength > 6) {

                        styleStr = " style ='width: " + (parseInt((charlength - 6)) * 12 + 100) + "px;' ";
                        tempWidth = (parseInt((charlength - 6)) * 15 + 100) + 40;
                    }
                } catch (e) { }
                temp = temp.replace("width:300px;", "width:" + tempWidth + ";");
                temp = temp.replace("{style}", styleStr);
                temp = temp.replace("{option}", optionItem);
                stringBuilder += temp;
                break;

        }

        if (haveImg) {// 有图片
            var hder = header_Img.replaceAll("{Num}", parseInt(i + 1));
            if (isMustAnswer == "是" && hd) {           //必填
                hd += isMustFill.replaceAll("{name}", objArr[i]["Id"] || '');
            }
            hder = hder.replaceAll("{Question}", hd);
            hder = hder.replaceAll("{img}", renderImg(haveImg, Ext1));
        } else {//无图片
            hder = header.replaceAll("{Num}", parseInt(i + 1));
            if (isMustAnswer == "是" && hd) {           //必填
                hd += isMustFill.replaceAll("{name}", objArr[i]["Id"] || '');
            }
            hder = hder.replaceAll("{Question}", hd);  //问题
        }

        var sub = hder + stringBuilder;
        var tbl = table.replaceAll("{sub}", sub);  // 
        subStringBud += tbl;
    }
    subStringBud += "<table><td height=\"5\"></td></table>";  //处理留白
    return subStringBud;
}
//---------排序项-------------------
function onSelectedUp(ele) { //up
    var select = $(ele).parent().parent().siblings().first();
    if ($("option:selected", select).text()) {
        var optionIndex = $("option:selected", select).index()
        if (optionIndex > 0) {
            select.hide()
            select.find("option:selected").insertBefore($(select).find('option:selected').prev('option'));
            select.show()
        }
    } else {
        AimDlg.show("请选择要排序的项");
    }
}

function onSelectedDown(ele) { //down
    var select = $(ele).parent().parent().siblings().first();
    var optionLength = $("option", select).length;
    var optionIndex = $("option:selected", select).index()

    if ($("option:selected", select).text()) {
        if (optionIndex < (optionLength - 1)) {
            select.hide()
            select.find("option:selected").insertAfter($(select).find('option:selected').next('option'));
            select.show()
        }
    } else {
        AimDlg.show("请选择要排序的项");
    }
}
//-------- end-----------------

//呈现图片 Ext1 图片描述
function renderImg(imgs, Ext1) {
    var imgObj = {
        imgFormat: "<div style='float:left'> <img alt={alt} src='##Path##' class='questImg' style='display:block'  /><span style='margin-left:15px;width:160px; text-align:center'>{alt1}</span> </div>"
    };
    var strBuilder = "";
    var arr = imgs.split(",");
    var extArr = Ext1.split(",");

    for (var i = 0; i < arr.length; i++) {
        var finalExt = (extArr[i] || "").split("addImg_item_")[0]; //相关描述 WGM 9/20
        if (!arr[i]) continue;
        var path = "../Document/" + arr[i];               //图片路径 注意.路径
        var temp = imgObj.imgFormat.replaceAll("##Path##", path);
        temp = temp.replace("{alt}", finalExt || "'' ").replace("{alt1}", finalExt);
        strBuilder += temp;
    }
    return strBuilder
}