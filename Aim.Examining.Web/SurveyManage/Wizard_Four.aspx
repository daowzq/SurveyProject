<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="Wizard_Four.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Wizard_Four" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #F2F2F2;
        }
        fieldset
        {
            margin: 15px;
            width: 99.6%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
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

    <script src="js/SurveyImg.js" type="text/javascript"></script>

    <script type="text/javascript">

        var SurveyId = $.getQueryString({ ID: 'SurveyId' });
        var modified = false;                 //修改标识
        var imgFlag = "";                     //图片标识
        var store, grid;

        var imgItem = {
            lastItemId: "",
            currentId: ''
        }


        function onPgLoad() {
            setPgUI();
            renderGrid();
        }

        function setPgUI() {
            initState(); //初始化基本状态
            FormValidationBind('btnSubmit', SuccessSubmit);
            $("#btnCancel").click(function() { window.close() });

        }

        //----------------提交事件处理-------------
        function doSubmit(successFun, failureFun) {
            if (typeof successFun == "function") successFun();
        }
        function SuccessSubmit() {
            //----------------图片-------------------
            var itemArr = [];

            $(".addImg_item").each(function(i) {
                if (i > 0) {
                    if ((itemArr[itemArr.length - 1] + "").indexOf($(this).attr("SubItemId")) > -1) {
                        var imgId = $(this).find(".imgId").val() || "";
                        imgId = imgId.replace(",", "");
                        var SubItemId = $(this).attr("SubItemId") || "";
                        var descript = $(this).find(".descript").val() || "";
                        var temp = SubItemId + "|" + imgId + "|" + descript;
                        itemArr[itemArr.length - 1] += "$" + temp;
                    } else {
                        var SubItemId = $(this).attr("SubItemId") || "";
                        var imgId = $(this).find(".imgId").val() || "";
                        imgId = imgId.replace(",", "");
                        var descript = $(this).find(".descript").val() || "";
                        var temp = SubItemId + "|" + imgId + "|" + descript;
                        itemArr.push(temp);
                    }
                }
                if (i == 0) {

                    var SubItemId = $(this).attr("SubItemId") || "";
                    var imgId = $(this).find(".imgId").val() || "";
                    imgId = imgId.replace(",", "");
                    var descript = $(this).find(".descript").val() || "";
                    var temp = SubItemId + "|" + imgId + "|" + descript;
                    itemArr.push(temp);
                }
            })
            var imgItems = itemArr.length > 0 && itemArr.join(",");   //图片选项

            //--------------------------------------

            var recs = store.getRange();
            var dt = store.getModifiedDataStringArr(recs);

            AimFrm.submit("Save", { SurveyId: SurveyId || '', imgItems: imgItems, data: dt }, null, function() {
                //回写状态
                Ext.getCmp("addBtn").setText("添加");
                Ext.getCmp("delBtn").setText("删除");
            });
        }

        /*初始化设置*/
        function initState() {
            //图片设置初始化
            imgInit();
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
			            { name: 'Ext1' }
                   	   ],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.id = Id;
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
				},
				{
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
				        $.ajaxExec("DeleteItem", { QuestionItemId: recs[0].get("SubItemId"), SurveyId: SurveyId }, null, null, "Comman.aspx")
				    }
				}, '-', {
				    text: '复制上一题',
				    iconCls: 'aim-icon-copy',
				    handler: function() {
				        copySurvey(store);
				    }
				}, { xtype: 'tbtext', text: '(编辑后系统会自动保存)' }, '->'
		    ]
            });
            cb_QuestionType = new Ext.ux.form.AimComboBox({
                id: 'cb_QuestionType',
                enumdata: { "单选项": "单选项", "多选项": "多选项", "填写项": "填写项", "图片(单选)": "图片(单选)", "图片(多选)": "图片(多选)" },
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
                                if (obj.value.indexOf("图片") > -1) {
                                    if (imgItem.currentId != rec.get("SubItemId")) {
                                        imgItem.lastItemId = imgItem.currentId;
                                        imgItem.currentId = rec.get("SubItemId");
                                    }
                                }
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

            grid = new Ext.ux.grid.AimEditorGridPanel({
                id: 'grid',
                store: store,
                height: 440,
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
                     new Ext.grid.SingleSelectionModel(),
					{ id: 'Content', dataIndex: 'Content', header: '题目内容', editor: { xtype: 'textarea' }, width: 150, renderer: RowRender },
					{ id: 'QuestionType', dataIndex: 'QuestionType', header: '问题类型', editor: cb_QuestionType, width: 90 },
				    { id: 'IsMustAnswer', dataIndex: 'IsMustAnswer', header: '是否必答', editor: cb_IsMustAnswer, width: 60, menuDisabled: true },
					{ id: 'IsShowScore', dataIndex: 'IsShowScore', header: '显示分值', editor: cb_IsScore, width: 70, menuDisabled: true },
				    { id: 'IsComment', dataIndex: 'IsComment', header: '是否评论', editor: cb_IsComment, width: 60, menuDisabled: true },
				    { id: 'SortIndex', dataIndex: 'SortIndex', header: '序号', editor: { xtype: 'numberfield', minValue: 0, maxValue: 100, allowBlank: false }, width: 80 },
					{ id: 'Edit', dataIndex: 'Edit', header: '操作', width: 90, renderer: RowRender }
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
                    //if (record.get("QuestionType") == "填写项" || record.get("QuestionType").indexOf("图片") > -1) {
                    if (record.get("QuestionType") == "填写项") {
                        cellmeta.style = 'background-color: gray';
                        rtn = "选择项"
                    }
                    else {
                        var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='windowOpenEdit(\"" + record.get("SurveyId") + "\",\"" + record.get("SubItemId") + "\",\"" + record.get("Content") + "\",\"" + (record.get("QuestionType") || "") + "\",\"" + (record.get("ImgIds") || "") + "\",\"" + (record.get("Ext1") || "") + "\")'>" + "选择项" + "</span>";
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
            RefreshClose();
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            问卷内容</h1>
    </div>
    <fieldset>
        <legend>问题维护</legend>
        <div id="SubContent" style="width: 100%;">
        </div>
    </fieldset>
</asp:Content>
