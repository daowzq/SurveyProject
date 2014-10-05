
//问卷图片
function imgInit() {
    //-------------------添加图片----------------------
    var tpl = "<div class='addImg_item' SubItemId='{SubItemId}' onclick='delImgFun(this)' ><input type='hidden' class='imgId' /><img alt='' src='' class=\"add_Img\" />\
                   <a  onclick='addFiles(this)' class=\"aim-ui-button\" style=\"margin-left: 10px; margin-top: 3px; background-color: #d5d5d5; display: block; color: black; width: 80px; text-align: center\">\
                   上传图片</a> <span style=\"display: block\">描述：<input class='descript' style=\"width: 100px; border: 0; border-bottom: 1 solid black; background: rgb(242,242,242);\" /></span></div>";

    $("#addImgs").click(function() {
        if (!(unescape($.getQueryString({ ID: "QuestionType" }) || "").indexOf("图片") > -1)) {
            AimDlg.show("请设置问题的题目类型为“图片项”！");
            return;
        }

        if ($(".addImg_item").length > 8) {
            return;
        }

        //var temp = tpl.replace("{SubItemId}", imgItem.currentId);
        var temp = tpl.replace("{SubItemId}", QuestionItemId);
        $(this).parent().before(temp);

        //字数限制
        $(".descript").last().val("(20字之内)").css({ color: 'gray' }).click(function() {
            if ($(this).val() == "(20字之内)") {
                $(this).val("").css({ color: 'black' });
            }
        }).keyup(function() {
            if ($(this).val().length > 20) {
                $(this).val(($(this).val() + "").substring(0, 19));
                AimDlg.show("已超过字数最大限制!");
            }
        });

    });
}

//添加图片项
function addFiles(e) {
    var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;";
    var uploadurl = '../CommonPages/File/Upload.aspx?IsSingle=true&Filter=' + escape('图片格式') + '(*.jpg;*.jpeg)|*.jpeg;*.jpg;';
    var rtn = window.showModalDialog(uploadurl, window, UploadStyle);

    rtn && $(e).prev().prev().val(rtn);
    rtn && $(e).prev().attr("src", "../Document/" + rtn.split(",")[0]);
}

//ImgItem Render
function renderItem(itemId) {
    
    //先找是否有itemId 的div  second: 从store 取相关数据, 重新绘制
    if (!((unescape($.getQueryString({ ID: "QuestionType" }) || "")).indexOf("图片") > -1)) {
        return;
    }
    if (!$.getQueryString({ ID: "ImgIds" })) return;

    if ($(".addImg_item[SubItemId=" + itemId + "]").length > 0) {
        $(".addImg_item[SubItemId=" + itemId + "]").show();
    } else {

        //        var tpl = "<div class='addImg_item' SubItemId='{SubItemId}' onclick='delImgFun(this)' ><input type='hidden' value='{value}' class='imgId' /><img alt='' src='{src}' class=\"add_Img\" />\
        //                   <a  onclick='addFiles(this)' class=\"aim-ui-button\" style=\"margin-left: 10px; margin-top: 3px; background-color: #d5d5d5; display: block; color: black; width: 80px; text-align: center\">\
        //                   上传图片</a> <span style=\"display: block\">描述：<input value='{descriptVal}' class='descript' style=\"width: 100px; border: 0; border-bottom: 1 solid black; background: rgb(242,242,242);\" /></span></div>";

        var tpl = "<div class='addImg_item' id='{id}' SubItemId='{SubItemId}' onclick='delImgFun(this)' ><input type='hidden' value='{value}' class='imgId' /><img alt='' src='{src}' class=\"add_Img\" /><div style='text-align:center'>{seq}</div></div>";

        var SubItemId = itemId;
        var ImgIds = unescape($.getQueryString({ ID: "ImgIds" }) || ""); // rec.get("ImgIds") || "";
        var Ext1 = unescape($.getQueryString({ ID: "Ext1" }) || ""); // rec.get("ImgIds") || "";

        ImgIds = ImgIds.length > 0 && ImgIds.split(",");
        Ext1 = Ext1.split(",");

        var tempHtml = "";
        for (var i = 0; i < ImgIds.length; i++) {
            var temp = tpl.replace("{SubItemId}", SubItemId);
            temp = temp.replace("{value}", ImgIds[i] || "");

            temp = temp.replace("{src}", "../Document/" + ImgIds[i].split(",")[0]);
            temp = temp.replace("{seq}", (Ext1[i] || "").substring(0, 1));   //* 10-9

            var attId = Ext1[i].substring((Ext1[i] || "").indexOf("addImg_item_"), Ext1[i].length)
            temp = temp.replace("{id}", attId);
            // temp = temp.replace("{descriptVal}", Ext1[i] || "");
            tempHtml += temp;
        }
        // var temp = tpl.replace("{SubItemId}", imgItem.currentId);

        //设置store Desc
        //        for (var i = 0; i < Ext1.length; i++) {
        //            var Desc = Ext1[i].substring(0, (Ext1[i] || "").indexOf("addImg_item_"));  //描述
        //            var AttrId = Ext1[i].substring((Ext1[i] || "").indexOf("addImg_item_"), Ext1[i].length); //rownumber
        //            var rowNum = AttrId.split("_")[2];
        //            store.getAt(rowNum).set("Desc", Desc)
        //            store.getAt(rowNum).commit();
        //        }


        //$("#addImgs").parent().before(tempHtml);   //呈现
        $("#imgItems").append(tempHtml);   //呈现

    }

}


//删除图片
function delImgFun(e) {

    $(e).siblings().removeClass("clickImg img"); //移除同辈元素属性
    $('.delImg_img').remove();                   //删除图标
    var SubItemId = $(e).addClass("clickImg img").attr("SubItemId");


    var div = "<div class='delImg_img' ><img alt='删除' src='cross.gif' /></div>";
    var left = $(e).position().left;
    var top = $(e).position().top;

    $("body").append(div).find(".delImg_img").css({ left: left + 100, top: top + 5 }).click(function() {
        if (confirm("确认要删除吗")) {
            $(e).siblings().each(function() {
                $(this).removeClass("clickImg img");
            });
            $(e).remove();     //删除图片项
            $(this).remove();  //删除图标
        }
    });
}