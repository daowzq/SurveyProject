<%@ Page Title="常用问卷" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="Normal_SurveyEdit.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Normal_SurveyEdit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .aim-ui-td-data
        {
            font-size: 12px;
        }
        fieldset
        {
            margin-top: 15px;
            margin-bottom: 15px;
            width: 99.5%;
            margin-left: 2px;
            text-align: left;
            padding: 1px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .tip
        {
            font-weight: bold;
            color: Red;
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
    </style>

    <script src="js/SurveyItemsAdd.js" type="text/javascript"></script>

    <script src="/js/fckeditor/fckeditor.js" type="text/javascript"></script>

    <script type="text/javascript">

        var SurveyId = $.getQueryString({ ID: 'id' });
        var op = $.getQueryString({ ID: 'op' }) || '';

        var modified = false;                 //修改标识
        var imgFlag = "";                     //图片标识
        var saveSign = false;
        var store, grid;

        var imgItem = {
            lastItemId: "",
            currentId: ''
        }
        window.onerror = function(sMessage, sUrl, sLine) {
            return true
        };
        function onPgLoad() {
            //屏蔽鼠标右键
            //document.oncontextmenu = function() { return false; }
            setPgUI();
            renderGrid();
        }

        function setPgUI() {
            window.onbeforeunload = function() {
                var n = window.event.screenX - window.screenLeft;
                var b = n > document.documentElement.scrollWidth - 35;
                if (b && window.event.clientY < 0 || window.event.altKey) {
                    // window.event.returnValue = "是否关闭？";
                    $.ajaxExecSync("Close", { id: SurveyId }, function(rtn) {
                        // window.close();
                        window.returnValue = "true";  //  模态窗口
                        window.close();
                    });
                }
            }

            $("#Id").val(SurveyId);
            initState(); //初始化基本状态
            FormValidationBind('btnSubmit', SuccessSubmit);

            //取消
            $("#btnCancel").click(function() {
                if (store.getRange().length > 0) {
                    if (confirm("你有未保存的数据！确定取消吗？")) {
                        //window.close();
                        $.ajaxExecSync("Close", { id: SurveyId }, function(rtn) {
                            // window.close();
                            window.returnValue = "true";  //  模态窗口
                            window.close();
                        });
                    }
                } else {
                    //window.close();
                    $.ajaxExecSync("Close", { id: SurveyId }, function(rtn) {
                        // window.close();
                        window.returnValue = "true";  //  模态窗口
                        window.close();
                    });
                }
            });

        }

        //----------------提交事件处理-------------
        function SuccessSubmit() {

            //问卷类型
            var SurveyTypeId = "", SurveyTypeName = "";
            SurveyTypeId = $("#SurveyTypeName option:selected").val();
            SurveyTypeName = $("#SurveyTypeName option:selected").text();

            var recs = store.getRange();
            var dt = store.getModifiedDataStringArr(recs);

            if (recs.length <= 0) {
                AimDlg.show("请填写问卷内容!");
                return;
            }
            // var context = ($("#Description").val() + "").replaceAll("\n", " <br/>").replaceAll(" ", "&nbsp;&nbsp;")
            //$("#Description").val(replaceTxt($("#Description").val()));

            AimFrm.submit(pgAction, {
                SurveyId: SurveyId || '',
                SurveyTypeId: SurveyTypeId,
                SurveyTypeName: SurveyTypeName,
                data: dt
            }, null, function() {
                window.returnValue = "true";  //  模态窗口
                window.close();
            });
        }


        function replaceTxt(str) {
            var reg = new RegExp("\n", "g");
            var reg1 = new RegExp(" ", "g");

            str = str.replace(reg, "<br/>");
            str = str.replace(reg1, "<p>");
            return str;
        }


        /*初始化设置*/
        function initState() {

            //问卷模板 TemplateId
            $("#TemplateName").change(function() {
                $(this).children().each(function() {
                    if ($(this).attr("selected")) {
                        $("#TemplateId").val($(this).val());
                        var tplVal = $(this).val();
                        var tplTxt = !!tplVal ? $(this).text() : "";

                        $("#template").children().remove();
                        $("#template").append("<a href=# val='" + tplVal + "' onclick='openTemplateWin(this)' >" + tplTxt + "</a>");
                    }
                })
            })

            //问卷类型选择
            $("#SurveyTypeName option").each(function() {
                $(this).val() == $("#SurveyTypeId").val() && $(this).attr("selected", true);
            });
            $("#SurveyTypeName").change(function() {
                $(this).val() && $.ajaxExec("GetTypeInfo", { typeId: $(this).val() }, function(rtn) {
                    $("#AddFilesName").dataBind(rtn.data.TypeInfo[0].AddFilesName);
                    //  $("#WorkFlowTxt").text(rtn.data.TypeInfo[0].WorkFlowName);  //流程名称
                    //  $("#WorkFlowName").val(rtn.data.TypeInfo[0].WorkFlowName);  //流程名称
                    //  $("#WorkFlowCode").val(rtn.data.TypeInfo[0].WorkFlowId);    //流程Code
                });
            });

            //匿名
            if ($("#Id").val()) {
                (AimState["frmdata"]["IsNoName"] + "") == "1" && $("#yes").attr("checked", true)
            }

        }

        /*渲染grid -*/
        function renderGrid() {
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                isclient: true,
                data: { records: AimState["DataList"] || [] },
                fields: [
			            { name: 'Id' },
			            { name: 'SurveyId' },
			            { name: 'SurveyTitle' },
			            { name: 'QuestionType' },
			            { name: 'IsMustAnswer' },
			            { name: 'IsComment' },
			            { name: 'Content' },
			            { name: 'SortIndex' },
			            { name: 'ImgIds' },
			            { name: 'SubItemId' },
			            { name: 'SubItems' },
			            { name: 'CreateId' },
			            { name: 'CreateName' },
			            { name: 'CreateTime' },
			            { name: 'IsShowScore' },
			            { name: 'Validate' },
			            { name: 'Ext1' }
                   	   ],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.id = SurveyId;
                    }
                }
            });
            //工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [
				{
				    id: 'addBtn',
				    text: '添加',
				    iconCls: 'aim-icon-add',
				    handler: function() {
				        addQuestion(store);
				    }
				}, {
				    id: 'delBtn',
				    text: '删除',
				    iconCls: 'aim-icon-delete',
				    handler: function() {
				        var recs = grid.getSelectionModel().getSelections();
				        var dt = store.getModifiedDataStringArr(recs);
				        if (!recs || recs.length <= 0) {
				            AimDlg.show("请先选择要删除的记录！");
				            return;
				        }
				        if (confirm("确定删除所选记录？")) {
				            store.remove(recs);
				        }


				        var ids = "";
				        $(recs).each(function(i) {
				            if (i > 0) {
				                ids += ",";
				            }
				            ids += "'" + this.get("SubItemId") + "'";
				        });

				        $.ajaxExec("DeleteItem", { QuestionItemId: ids, SurveyId: SurveyId }, null, null, "Comman.aspx")

				    }
				}, '-', {
				    text: '复制上一题',
				    iconCls: 'aim-icon-copy',
				    handler: function() {
				        copySurvey(store)
				    }
				}
		    ]
            });
            cb_QuestionType = new Ext.ux.form.AimComboBox({
                id: 'cb_QuestionType',
                enumdata: {
                    "单选项": "单选项",
                    "多选项": "多选项",
                    "填写项": "填写项",
                    "填写项1": "填写项1",
                    "排序项": "排序项",
                    "图片(单选)": "图片(单选)",
                    "图片(多选)": "图片(多选)"
                },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function(obj) {
                        if (grid.activeEditor) {
                            var rec = store.getAt(grid.activeEditor.row);
                            if (rec) {
                                grid.stopEditing();
                                rec.set("QuestionType", obj.value);
                            }
                        }
                    }
                }
            });

            cb_IsMustAnswer = new Ext.ux.form.AimComboBox({
                id: 'cb_IsMustAnswer',
                enumdata: { "是": "是", "否": "否" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function(obj) {
                        if (grid.activeEditor) {
                            var rec = store.getAt(grid.activeEditor.row);
                            if (rec) {
                                grid.stopEditing();
                                rec.set("IsMustAnswer", obj.value);
                            }
                        }
                    }
                }
            });
            cb_IsComment = new Ext.ux.form.AimComboBox({ /*是否评论*/
                id: 'cb_IsComment',
                enumdata: { "否": "否", "是": "是" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function(obj) {
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
            cb_IsScore = new Ext.ux.form.AimComboBox({  /*是否显示分值*/
                id: 'cb_IsScore',
                enumdata: { "否": "否", "是": "是" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function(obj) {
                        if (grid.activeEditor) {
                            var rec = store.getAt(grid.activeEditor.row);
                            if (rec) {
                                grid.stopEditing();
                                rec.set("IsShowScore", obj.value);
                            }
                        }
                    }
                }
            });

            cb_validate = new Ext.ux.form.AimComboBox({  /*验证*/
                id: 'cb_validate',
                enumdata: { "数字": "数字", "日期": "日期", "电话号码": "电话号码", "邮箱": "邮箱", "最大数值10": "最大数值10" },
                lazyRender: false,
                allowBlank: false,
                autoLoad: false,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function(obj) {
                        if (grid.activeEditor) {
                            var rec = store.getAt(grid.activeEditor.row);
                            if (rec) {
                                grid.stopEditing();
                                rec.set("Validate", obj.value);
                            }
                        }
                    },
                    beforeshow: function(obj) {
                        var rec = store.getAt(grid.activeEditor.row);
                        if (rec) {
                            if ((rec.get("QuestionType") + "").indexOf("填写") > -1) {
                                obj.enable();
                                return true;
                            } else {
                                obj.disable();
                                return false;
                            }
                        }

                    }
                }
            });

            grid = new Ext.ux.grid.AimEditorGridPanel({
                id: 'grid',
                store: store,
                height: 280,
                renderTo: 'SubContent',
                clicksToEdit: 1,
                // region: 'center',
                //autoHeight: true,
                autoExpandColumn: 'Content',
                columns: [
                    { id: 'Id', dataIndex: 'Id', hidden: true },
                    { id: 'SurveyId', dataIndex: 'SurveyId', hidden: true },
                    { id: 'SubItemId', dataIndex: 'SubItemId', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                     new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Content', dataIndex: 'Content', header: '<b><font color=red  >题目内容</font></b>', editor: { xtype: 'textarea' }, width: 150, renderer: RowRender },
					{ id: 'QuestionType', dataIndex: 'QuestionType', header: '问题类型', editor: cb_QuestionType, width: 75 },
					{ id: 'IsMustAnswer', dataIndex: 'IsMustAnswer', header: '是否必答', editor: cb_IsMustAnswer, width: 60, menuDisabled: true },
					{ id: 'IsShowScore', dataIndex: 'IsShowScore', header: '显示分值', editor: cb_IsScore, width: 70, menuDisabled: true },
					{ id: 'IsComment', dataIndex: 'IsComment', header: '是否评论', editor: cb_IsComment, width: 60, menuDisabled: true },
					{ id: 'Validate', dataIndex: 'Validate', header: '验证', editor: cb_validate, width: 80, menuDisabled: true },
				    { id: 'SortIndex', dataIndex: 'SortIndex', header: '序号', editor: { xtype: 'numberfield', minValue: 0, maxValue: 100, allowBlank: false }, width: 50 },
					{ id: 'Edit', dataIndex: 'Edit', header: '操作', width: 80, renderer: RowRender }
					],
                tbar: pgOperation != "v" ? tlBar : "",
                tbar: tlBar,
                listeners: {
                    afteredit: function(e) {
                        var arr = [];
                        arr.push(e.record);
                        var strRec = store.getModifiedDataStringArr(arr);
                        $.ajaxExec("SaveItem", { strRec: strRec }, function(rtn) {
                            e.record.commit();
                        }, null, "Comman.aspx")
                    }
                }
            });

        }


        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "Edit":

                    if ((record.get("QuestionType") + "").indexOf("填写项") > -1) {
                        cellmeta.style = 'background-color: gray';
                        rtn = "选择项"
                    }
                    else {
                        var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='windowOpenEdit(\"" + record.get("SurveyId") + "\",\"" + record.get("SubItemId") + "\",\"" + record.get("Content") + "\",\"" + record.get("QuestionType") + "\",\"" + (record.get("ImgIds") || "") + "\",\"" + (record.get("Ext1") || "") + "\")'>" + "选择项" + "</span>";
                        rtn = str;
                    }
                    break;
                case "Content":
                    if (record.get("ImgIds")) {
                        rtn = (value || "") + "<font color='gray'>&nbsp;(附有图片)</font>";
                    } else {
                        rtn = value;
                    }
                    break;
            }
            return rtn;
        }

        function windowOpenEdit() { /* 答案选择项*/

            var SurveyId = arguments[0] || '';
            var QuestionItemId = arguments[1] || '';
            var QuestionContent = escape(arguments[2]) || '';
            var QuestionType = escape(arguments[3] || "");
            var ImgIds = escape((arguments[4] + "").replace("null", "") || "");
            var Ext1 = escape((arguments[5] + "").replace("null", "") || "");

            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {

                var url = "SuryQuestionItemEdit.aspx?op=v&SurveyId=" + SurveyId + "&QuestionItemId=" + QuestionItemId + "&QuestionContent=" + QuestionContent + "&QuestionType=" + QuestionType + "&ImgIds=" + ImgIds + "&Ext1=" + Ext1;

                if (unescape(QuestionType).indexOf("图片") > -1) {
                    var win = opencenterwin(url, "", 780, 490);
                } else {
                    var win = opencenterwin(url, "", 760, 340);
                }

            });
        }

        function windowOpen() {
            var Id = arguments[0] || '';  //ID
            var Title = escape(arguments[1] || ''); //Title
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                opencenterwin("SurveyView.aspx?op=v&Id=" + Id + "&Title=" + Title + "&rand=" + Math.random(), "", 1000, 600);
            });
        }
        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ', innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }


        function onExecuted() {
            store.reload();
        }
        window.onresize = function() {
            grid.setWidth(0);
            grid.setWidth(Ext.get("SubContent").getWidth());
        }
        function SubFinish(args) {
            window.returnValue = "true";  //  模态窗口
            window.close();
            //RefreshClose();
        }

        function openTemplateWin(obj) {
            var url = "InternetSurvey.aspx?op=v&type=read";
            var EditWinStyle = "dialogWidth=1000px;dialogHeight=600px;scroll=1";
            var id = $(obj).attr('val');
            url += "&Id=" + id;

            if (id) {
                var rtn = window.showModalDialog(url, window, EditWinStyle);
            } else {
                return false;
            }
        }


        //生成模板
        function expandTempLate(e) {
            if (!$("#TemplateName option:selected").val()) {
                AimDlg.show("请选择模板!");
                return;
            };

            if ($("#TemplateId").val() && confirm("确认导入到问卷?")) {
                $.ajaxExec("ExpandTempLate", { SurveyId: SurveyId, TemplateId: $("#TemplateId").val() }, function(rtn) {
                    var ItemArr = rtn.data.QItem;
                    var recType = store.recordType;
                    if (ItemArr.length > 0) {
                        Ext.getBody().mask("数据重新加载中，请稍等");
                    }
                    //first delete
                    store.removeAll();
                    $(ItemArr).each(function() {
                        var rec = new recType({
                            'Id': this["Id"],
                            'SurveyId': this["SurveyId"],
                            'SurveyTitle': this["SurveyTitle"],
                            'QuestionType': this["QuestionType"],
                            'IsMustAnswer': this["IsMustAnswer"],
                            'IsComment': this["IsComment"],
                            'Content': this["Content"],
                            'SortIndex': this["SortIndex"],
                            'ImgIds': this["ImgIds"],
                            'SubItemId': this["SubItemId"],
                            'SubItems': this["SubItems"],
                            'CreateId': this["CreateId"],
                            'CreateName': this["CreateName"],
                            'CreateTime': this["CreateTime"],
                            'IsShowScore': this["IsShowScore"],
                            'Ext1': this["Ext1"]
                        });
                        store.insert(store.data.length, rec);
                    })
                    Ext.getBody().unmask(); //去除MASK    
                });
            }

        }
        //撤销
        function CancelTpl(elm) {
            if (confirm("确认撤销模板吗？")) {
                $.ajaxExec("CancelTpl", { SurveyId: SurveyId }, function(rtn) {
                    Ext.getBody().mask("撤销中，请稍后...");
                    if (rtn.data.QItem) {
                        //first delete
                        store.removeAll();
                        var objArr = rtn.data.QItem
                        var recType = store.recordType;
                        $(objArr).each(function() {
                            var rec = new recType({
                                'Id': this["Id"],
                                'SurveyId': this["SurveyId"],
                                'SurveyTitle': this["SurveyTitle"],
                                'QuestionType': this["QuestionType"],
                                'IsMustAnswer': this["IsMustAnswer"],
                                'IsComment': this["IsComment"],
                                'Content': this["Content"],
                                'SortIndex': this["SortIndex"],
                                'ImgIds': this["ImgIds"],
                                'SubItemId': this["SubItemId"],
                                'SubItems': this["SubItems"],
                                'CreateId': this["CreateId"],
                                'CreateName': this["CreateName"],
                                'CreateTime': this["CreateTime"],
                                'IsShowScore': this["IsShowScore"],
                                'Ext1': this["Ext1"]
                            });
                            store.insert(store.data.length, rec);
                        })
                    }
                    Ext.getBody().unmask(); //去除MASK 
                    //gridQuestion.getStore().reload();
                }, null, "Comman.aspx");
            }
        }
 
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            常用问卷</h1>
    </div>
    <div id="editDiv" align="center">
        <fieldset>
            <legend>基本信息</legend>
            <table class="aim-ui-table-edit" style="margin: 2px 2px">
                <tbody>
                    <tr style="display: none">
                        <td colspan="4">
                            <input id="Id" name="Id" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷类型
                        </td>
                        <td class="aim-ui-td-data">
                            <select id="SurveyTypeName" name="SurveyTypeName" aimctrl="select" enum='AimState["TypeEnum"]'
                                style="width: 77%" class="validate[required]">
                            </select>
                            <input type="hidden" name="SurveyTypeId" id="SurveyTypeId" />
                        </td>
                        <td class="aim-ui-td-caption">
                            问卷编号
                        </td>
                        <td class="aim-ui-td-data" style="width: 30%">
                            <input id="TypeCode" name="TypeCode" class="validate[required]" style="width: 77%" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷标题
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input id="SurveyTitile" name="SurveyTitile" style="width: 92%" class="validate[required]" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷描述
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <textarea aimctrl="editor" rows="3" style="width: 92%" id="Description" name="Description"></textarea>
                        </td>
                    </tr>
                    <!--   <tr>
                        <td class="aim-ui-td-caption">
                            相关附件
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input id="AddFilesName" name="AddFilesName" aimctrl='file' style="width: 95%" />
                        </td>
                    </tr>-->
                    <!--  <tr>
                        <td class="aim-ui-td-caption">
                            是否匿名
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input type="radio" name="IsNoName" value="1" id="yes" />是&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input
                                type="radio" name="IsNoName" value="0" checked="checked" />否
                        </td>
                    </tr>-->
                    <tr>
                        <td class="aim-ui-td-caption">
                            问卷模板
                        </td>
                        <td class="aim-ui-td-data">
                            <select id="TemplateName" name="TemplateName" aimctrl='select' enum="tplEnum" style="width: 60%">
                            </select>
                            <input type='hidden' id="TemplateId" name="TemplateId" />
                        </td>
                        <td class="aim-ui-td-data" style="width: 50%" colspan="2">
                            <span id="template" style="width: 50%; border: 0; border-bottom: 1 solid black; background: #F2F2F2;
                                color: Blue;"></span>&nbsp;&nbsp;&nbsp;&nbsp;<a id="expandTemplate" style="text-decoration: none"
                                    class="aim-ui-button submit" href="#" onclick="expandTempLate(this)">导入</a>&nbsp;&nbsp;&nbsp;
                            <a class="aim-ui-button submit" style="text-decoration: none" href="#" id="CancelTpl"
                                onclick="CancelTpl(this)">撤销</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
        <fieldset>
            <legend>问卷内容</legend>
            <div id="SubContent" style="width: 100%;">
            </div>
            <div id="Div1" style="width: 100%;">
                <table class="aim-ui-table-edit">
                    <tr style="display: none">
                        <td>
                            <input id="SubItemId" name="SubItemId" />
                        </td>
                    </tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSubmit" class="aim-ui-button submit">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                            取消</a>
                    </td>
                </table>
            </div>
        </fieldset>
    </div>
</asp:Content>
