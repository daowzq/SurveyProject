<%@ Page Title="问卷问题项" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="SuryQuestionItemEdit.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SuryQuestionItemEdit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #F2F2F2;
        }
        .addImg_item
        {
            float: left;
            margin-left: 5px;
            margin-top: 5px;
            margin-bottom: 5px;
            padding-right: 5px;
            margin-left: 5px;
        }
        .addImg
        {
            display: none;
        }
        .add_Img
        {
            width: 110px;
            height: 118px;
            display: block;
        }
        .clickImg img
        {
            border: solid 2px green;
        }
        .delImg_img
        {
            width: 20px;
            height: 20px;
            cursor: pointer;
            position: absolute;
        }
        .x-grid3-col-UpLoadImg
        {
            padding: 0 0;
        }
        .upBtn
        {
            height: 25px;
            background-image: /images/shared/image_add.png;
        }
    </style>
    <script src="js/SurveyImg.js" type="text/javascript"></script>
    <script type="text/javascript">
        var SurveyId = $.getQueryString({ ID: 'SurveyId' });
        var QuestionItemId = $.getQueryString({ ID: 'QuestionItemId' });
        var QuestionContent = unescape($.getQueryString({ ID: 'QuestionContent' }) || "");  //
        QuestionContent = QuestionContent === "undefined" ? "" : QuestionContent
        var QuestionType = unescape($.getQueryString({ ID: 'QuestionType' }) || "");

        var IsMustAnswer = unescape($.getQueryString({ ID: "IsMustAnswer" }) || "");
        var IsShowScore = unescape($.getQueryString({ ID: "IsShowScore" }) || "");
        var IsComment = unescape($.getQueryString({ ID: "IsComment" }) || "")
        var SortIndex = $.getQueryString({ ID: "SortIndex" }) || "";

        var type = $.getQueryString({ ID: "type" }) || "";
        var currentRowIndex = 0;
        var grid, store, store1;
        function onPgLoad() {

            renderGrid();
            renderItem(QuestionItemId);
            submit();
            // imgInit();
            if (!(QuestionType.indexOf("图片") > -1)) {
                $("#imgSet").hide();
            } else {
                $("#imgSet").show();
            }
        }

        function submit() {

            $("#btnSubmit").click(function () {

                //------------------图片添加------------------------
                var itemArr = [];
                $(".addImg_item").each(function (i) {
                    if (i > 0) {
                        if ((itemArr[itemArr.length - 1] + "").indexOf($(this).attr("SubItemId")) > -1) {
                            var imgId = $(this).find(".imgId").val() || "";
                            imgId = imgId.replace(",", "");
                            var SubItemId = $(this).attr("SubItemId") || "";
                            // var descript = $(this).find(".descript").val() || "";   //描述

                            var attrId = $(this).attr("id");   //rowNumber Id
                            var rowNumber = attrId.split("_")[2];
                            var descript = (store.getAt(rowNumber).get("Ext") || "") + " " + (store.getAt(rowNumber).get("Desc") || "");   //描述
                            var temp = SubItemId + "|" + imgId + "|" + descript + attrId;
                            itemArr[itemArr.length - 1] += "$" + temp;
                        } else {
                            var SubItemId = $(this).attr("SubItemId") || "";
                            var imgId = $(this).find(".imgId").val() || "";
                            imgId = imgId.replace(",", "");
                            //var descript = $(this).find(".descript").val() || "";  //描述

                            var attrId = $(this).attr("id");   //rowNumber Id
                            var rowNumber = attrId.split("_")[2];
                            //var descript = store.getAt(rowNumber).get("Desc") || "";   //描述
                            var descript = (store.getAt(rowNumber).get("Ext") || "") + " " + (store.getAt(rowNumber).get("Desc") || "");   //描述
                            var temp = SubItemId + "|" + imgId + "|" + descript + attrId;

                            itemArr.push(temp);
                        }
                    }
                    if (i == 0) {

                        var SubItemId = $(this).attr("SubItemId") || "";
                        var imgId = $(this).find(".imgId").val() || "";
                        imgId = imgId.replace(",", "");
                        //var descript = $(this).find(".descript").val() || "";

                        var attrId = $(this).attr("id");   //rowNumber Id
                        var rowNumber = attrId.split("_")[2];

                        var descript = (store.getAt(rowNumber).get("Ext") || "") + " " + (store.getAt(rowNumber).get("Desc") || "");   //描述
                        // var descript = store.getAt(rowNumber).get("Desc") || "";   //描述

                        var temp = SubItemId + "|" + imgId + "|" + descript + attrId;
                        itemArr.push(temp);
                    }
                })

                var imgItems = itemArr.length > 0 && itemArr.join(",");   //图片选项
                //-----------------------------------------------------------------------------
                //判断验证
                var recs = store.getRange();
                //答案选项内容验证

                if (recs.length <= 0) {
                    AimDlg.show("请添加选项内容!");
                    return;
                }

                var hasEmpty = false;
                $.each(recs, function () {
                    if (!this.get("Answer")) hasEmpty = true;
                });

                if (hasEmpty) {
                    AimDlg.show("您有未填的选项!");
                    return;
                }
                if ((QuestionType.indexOf("图片") > -1) && $(".addImg_item").length < recs.length) {
                    AimDlg.show("您有未上传的图片项!");
                    return;
                }

                var dt = store.getModifiedDataStringArr(recs);
                AimFrm.submit("Save", { QuestionItemId: QuestionItemId,
                    SurveyId: SurveyId,
                    data: dt,
                    imgItems: imgItems
                    //  ,QuestionContent: QuestionContent,
                    //  QuestionType: QuestionType,
                    //  IsMustAnswer: IsMustAnswer,
                    //  IsShowScore: IsShowScore,
                    //  IsComment: IsComment,
                    //   SortIndex: SortIndex
                }, null, function () {
                    window.returnValue = "1";
                    if (type == "iframesign") {
                        window.close();
                    } else {
                        imgItems ? RefreshClose() : window.close();
                    }
                });
            });

            $("#btnCancel").click(function () {
                if (store.getRange().length) {
                    if (confirm("您有数据未保存！"))
                        window.close();
                } else {
                    window.close();
                }
            });
        }

        /*渲染grid -*/
        function renderGrid() {
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                isclient: true,
                data: { records: AimState["DataList"] || [] },
                fields: [{ name: 'Id' },
                   	    { name: 'SurveyId' },
                   	    { name: 'QuestionItemId' },
                   	    { name: 'QuestionItem' },
                   	    { name: "IsExplanation" },
                   	    { name: 'Answer' },
                   	    { name: 'SortIndex' },
                   	    { name: 'Score' },
                   	    { name: 'Desc' },
                   	    { name: 'Ext' },
                   	    { name: 'IsShowScore' }
                   	   ]
            });

            var Ext1 = unescape($.getQueryString({ ID: "Ext1" }) || "");
            if (Ext1) {
                Ext1 = Ext1.replace("undefined", "").split(",");
                for (var i = 0; i < Ext1.length; i++) {
                    var Desc = Ext1[i].substring(0, (Ext1[i] || "").indexOf("addImg_item_"));  //描述
                    var AttrId = Ext1[i].substring((Ext1[i] || "").indexOf("addImg_item_"), Ext1[i].length);
                    var rowNum = AttrId.split("_")[2];

                    store.getAt(rowNum).set("Ext", Desc.substring(0, 1));   //取序号
                    if (Desc.length > 2)
                        store.getAt(rowNum).set("Desc", Desc.split(" ")[1]);

                }
                store.commitChanges();
            }

            //工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [
				{
				    text: '添加',
				    iconCls: 'aim-icon-add',
				    handler: function () {

				        var recType = store.recordType;
				        var sortIndex = 'A';
				        $.each(store.getRange(), function () {
				            sortIndex = (this.get("SortIndex") || '0').charCodeAt(0) > sortIndex.charCodeAt(0) ? this.get("SortIndex") : sortIndex;
				        });

				        if (sortIndex != 'A' || store.getRange().length > 0) {
				            sortIndex = String.fromCharCode((sortIndex.charCodeAt(0) + 1))
				        }

				        var rec = new recType({
				            SurveyId: SurveyId,
				            QuestionItemId: QuestionItemId,
				            QuestionItem: QuestionContent,
				            SortIndex: sortIndex,
				            IsExplanation: '否',
				            Ext: sortIndex
				        });

				        store.insert(store.data.length, rec);
				    }
				},
				{
				    text: '删除',
				    iconCls: 'aim-icon-delete',
				    handler: function () {
				        var recs = grid.getSelectionModel().getSelections();
				        var dt = store.getModifiedDataStringArr(recs);
				        clrImg(recs[0], currentRowIndex);
				        if (!recs || recs.length <= 0) {
				            AimDlg.show("请先选择要删除的记录！");
				            return;
				        }
				        if (confirm("确定删除所选记录？")) {
				            store.remove(recs);
				        }
				    }
				}]
            });

            var isRemark = new Ext.ux.form.AimComboBox({ /*是否评论*/
                id: 'isRemark',
                enumdata: { "否": "否", "是": "是" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function (obj) {
                        if (grid.activeEditor) {
                            var rec = store.getAt(grid.activeEditor.row);
                            if (rec) {
                                grid.stopEditing();
                                rec.set("IsComment", obj.value);
                            }
                        }
                    }
                }
            });
            var score = new Ext.ux.form.AimComboBox({ /*分值*/
                id: 'score',
                enumdata: { "10": "10", "5": "5", "3": "3", "2": "2", "1": "1", "0": "0" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function (obj) {
                        if (grid.activeEditor) {
                            var rec = store.getAt(grid.activeEditor.row);
                            if (rec) {
                                grid.stopEditing();
                                rec.set("Score", obj.value);
                            }
                        }
                    }
                }
            });


            var gridTitle = (QuestionContent ? "【" + (((QuestionContent.length > 10) ? (QuestionContent.substring(0, 10) + "...") : QuestionContent) + "】") : "") + "选项维护";

            grid = new Ext.ux.grid.AimEditorGridPanel({
                // title: ((gridTitle + "").indexOf("null") > -1 || gridTitle == null) ? "选项维护" : gridTitle,
                title: QuestionContent,
                store: store,
                height: 380,
                // autoHeight: true,
                renderTo: 'SubContent',
                viewConfig: { forceFit: true },
                autoExpandColumn: 'AnswerItems',
                columns: [
                    { id: 'Id', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'SortIndex', dataIndex: 'SortIndex', header: '选项', editor: { xtype: 'textfield', maxLength: '2' }, width: 30 },
                //{ id: 'QuestionItem', dataIndex: 'QuestionItem', header: '题目内容', width: 150, renderer: RowRender },
                    {id: 'Score', dataIndex: 'Score', header: '分值', editor: { xtype: 'textfield', regexText: '^\d{1,2}$', maxLength: 2 }, width: 40 },
					{ id: 'Answer', dataIndex: 'Answer', header: '<b><font color=red>* 选项内容</font></b>', editor: { xtype: 'textarea' }, width: 250 },
                    { id: 'IsExplanation', dataIndex: 'IsExplanation', header: '是否说明', editor: isRemark, width: 50 },
					{ id: 'UpLoadImg', dataIndex: 'UpLoadImg', header: '图片操作', width: 80, renderer: RowRender, hidden: (QuestionType.indexOf("图片") > -1) ? false : true },
				    { id: 'Desc', dataIndex: 'Desc', header: '图片描述', width: 130, editor: { xtype: 'textfield', maxLength: 10 }, hidden: (QuestionType.indexOf("图片") > -1) ? false : true }
					],
                tbar: tlBar
            });

            grid.on("rowclick", function (grid, rowIndex, e) {
                currentRowIndex = rowIndex;
                $("#imgItems>div").removeClass("clickImg img");
                $("#addImg_item_" + rowIndex).addClass("clickImg img");
            });
        }


        //-------------------------------------删除------------------------
        //删除图片
        function delImgFun(e) {
            grid.getSelectionModel().selectRow($(e).attr("id").split("_")[2] || 0);  //选中行
            $(e).siblings().removeClass("clickImg img");
            var SubItemId = $(e).addClass("clickImg img").attr("SubItemId");

            //            var div = "<div class='delImg_img' ><img alt='删除' src='cross.gif' /></div>";
            //            var left = $(e).position().left;
            //            var top = $(e).position().top;
            //            $("body").append(div).find(".delImg_img").css({ left: left + 100, top: top + 5 }).click(function() {
            //                if (confirm("确认要删除吗")) {
            //                    $(e).siblings().each(function() {
            //                        $(this).removeClass("clickImg img");
            //                    });
            //                    $(e).remove();     //删除图片项
            //                    $(this).remove();  //删除图标
            //                }
            //            });
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "QuestionItem":
                    value = value || "";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    cellmeta.style = 'background-color: gray';
                    rtn = value || QuestionContent;
                    break;
                case "UpLoadImg":
                    var serial = record.get("SortIndex");
                    var Ele = "<input type='button' id='imgBtn_" + rowIndex + "' value='添加' onclick=addImg(this,'" + rowIndex + "','" + serial + "') class='upBtn' /><input type='button' class='upBtn' id='imgClr_" + rowIndex + "' value='清除' onclick=clrImg(this,'" + rowIndex + "')  />";
                    value = Ele;
                    //cellmeta.style = 'background-color: gray';
                    rtn = value;
                    break;
            }
            return rtn;
        }

        //添加图片
        function addImg(obj, rowIndex, seq) {

            //文件名
            var filName = addFiles();
            var openImgRtn = "";  //return imgFileName contians ','
            if (filName) {
                openImgRtn = filName;
                filName = filName.split(",")[0];
            } else {
                return;
            }
            //if have img get position,than del
            var postionArr = [];
            $(Ext.query("#imgItems>.addImg_item")).each(function (i) {
                var attId = $(this).attr("id");
                if (attId != "addImg_item_" + rowIndex) {
                    postionArr.push(attId);
                }
            })
            $("#addImg_item_" + rowIndex).remove();
            var hasIMg = postionArr.length > 0 ? true : false;

            //var rec = store.getAt(rowIndex) || {};
            var src = "/Document/" + filName;
            var tpl = "<div class='addImg_item' id='addImg_item_" + rowIndex + "' SubItemId='{SubItemId}' onclick='delImgFun(this)' ><input value='{value}' type='hidden' class='imgId' /><img alt='' {src} class=\"add_Img\" /><div style='text-align:center'>{seq}<div></div>";
            tpl = tpl.replace("{SubItemId}", QuestionItemId).replace("{src}", "src=" + src).replace("{value}", openImgRtn || "").replace("{seq}", seq || "");
            //根据rowindex 判断插入的位置
            if (hasIMg) {
                var maxId = getmaxId(postionArr);
                var tempArr = maxId.split("_"); //addImg_item_1
                if (parseInt(rowIndex) < parseInt(tempArr[2])) {
                    var AttrId = getIndexAttrId(postionArr, rowIndex);
                    $("#" + AttrId).before(tpl);
                } else {
                    $("#" + maxId).after(tpl);
                }
            } else {
                $("#imgItems").append(tpl);
            }
        }

        function getmaxId(arr) {
            var val = -1;
            var idTxt = "";
            for (var i = 0; i < arr.length; i++) {
                if (parseInt((arr[i] + "").replace("addImg_item_", "")) > val) {
                    val = parseInt((arr[i] + "").replace("addImg_item_", ""));
                    idTxt = arr[i];
                }
            }
            return idTxt;
        }

        function getIndexAttrId(arr, val) {
            var tempArr = arr.sort();
            var finnalVal = 0;
            for (var i = 0; i < tempArr.length; i++) {
                var sVal = tempArr[i].split("_")[2];
                if (val > sVal) {
                    finnalVal = sVal;
                } else if (val < sVal) {
                    finnalVal = sVal;
                    break;
                }
            }
            return "addImg_item_" + finnalVal;
        }

        //清除图片预览
        function clrImg(obj, rowIndex) {
            $("#addImg_item_" + rowIndex).remove();
            $(".delImg_img").remove();
        }

        //添加图片项
        function addFiles() {
            var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;";
            var uploadurl = '../CommonPages/File/Upload.aspx?IsSingle=true&Filter=' + escape('图片格式') + '(*.jpg;*.jpeg)|*.jpeg;*.jpg;';
            var rtn = window.showModalDialog(uploadurl, window, UploadStyle);
            return rtn;
            //  rtn && $(e).prev().prev().val(rtn);
            //   rtn && $(e).prev().attr("src", "/Document/" + rtn.split(",")[0]);
        }
        window.onresize = function () {
            var width = $("body").innerWidth() - 10;
            width && grid.setWidth(width);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="SubContent" name="SubContent" style="width: 100%;">
    </div>
    <table class="aim-ui-table-edit">
        <tr id="imgSet">
            <td class="aim-ui-td-caption">
                图片预览
            </td>
            <td height="125" id="imgItems">
                <!--                <div style="float: left; height: 120px; padding-top: 28px; cursor: pointer; display: none">
                    <span id="addImgs">
                        <img alt="点击添加图片" src="imgadd.png" />
                        <span style="display: block; font-size: 12px; color: Gray"><em title="点击添加图片" style="color: Blue">
                            添加图片</em></span></span>
                </div>-->
            </td>
        </tr>
        <tr>
            <td class="aim-ui-button-panel" colspan="8">
                <a id="btnSubmit" class="aim-ui-button">保存</a>&nbsp;&nbsp;<a id="btnCancel" class="aim-ui-button">取消</a>
            </td>
        </tr>
    </table>
</asp:Content>
