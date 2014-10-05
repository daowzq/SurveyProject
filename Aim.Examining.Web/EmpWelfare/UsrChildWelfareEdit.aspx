<%@ Page Title="保险申报" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="UsrChildWelfareEdit.aspx.cs" Inherits="Aim.Examining.Web.UsrChildWelfareEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        fieldset
        {
            margin: 15px 0px 15px 0px;
            width: 100%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .x-panel-body x-form
        {
            height: 0px;
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        var id = $.getQueryString({ ID: "id" });
        var op = $.getQueryString({ ID: "op" });
        var type = $.getQueryString({ ID: 'type' });
        var grid, store;

        var IsDoubleWorkers = false;  ////是否双职工
        var IsSingleChild = false;   ////是否独生子女

        function onPgLoad() {
            $(".x-panel-tbar-noheader").hide()
            setPgUI();
        }

        function setPgUI() {
            InitEditTable();
            stateInit();
            $('#btnSubmit').click(function() {
                SuccessSubmit();
            });

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        //暂存方法
        function SuccessSubmit(val, func) {

            if ($("#double").attr("checked")) {
                if (!$("#OtherUserName").val() || !$("#OtherIdentityCard").val()) {
                    AimDlg.show("请填写配偶的姓名,身份证号码及性别!");
                    return;
                }
                if (!$(":radio[name='OSex']:checked").val()) {
                    AimDlg.show("请选择配偶的性别!");
                    return;
                }
                if (!isIScard($("#OtherIdentityCard").val())) {
                    AimDlg.show("身份证号码不合法!");
                    return;
                }
            }

            //双职工
            if (IsDoubleWorkers) {

                if (!$("#OtherUserName").val() || !$("#OtherUserWorkNo").val()) {
                    AimDlg.show("请填写配偶姓名和工号!");
                    return;
                }
            }

            //--------
            var recs = grid.store.getRange();
            var dt = store.getModifiedDataStringArr(recs) || [];
            if (!recs.length > 0) {
                AimDlg.show("请添加被保险人信息!");
                return;
            }

            //信息完成验证
            var isReutrn = false;
            $.each(recs, function() {
                if (!this.get("UsrName") || !this.get("Sex") || !this.get("IDCartNo")) {
                    isReutrn = true;
                    return;
                }
            });
            if (isReutrn) {
                AimDlg.show("被保险人的信息填写不完整，姓名,性别,身份证号为必填!");
                return;
            };
            //

            AimFrm.submit(pgAction, { data: dt }, null, function() {
                //RefreshClose();
                if (val != "1") SubFinish();
                else func();
            });
        }


        //pg状态
        function stateInit() {

            //隐藏提交按钮
            if (op == "r" || op == "reader") {
                $("#submit").hide();
            }
            if (op == "u") {
                $("#btnApp_N,#btnApp_Y").hide();
                $("#Result").attr("disabled", true);
            }

            //审批
            if (type == "app") {
                $("#examfield").show();
                $("#btnSubmit,#btnCancel").hide();
                $("#btnApp_Y,#btnApp_N").show();
                $("#Result").removeAttr("disabled");
                //$(":radio[name='IsSingleChild']").attr("disabled", true);
                //$(":radio[name='IsDoubleWorker']").attr("disabled", true);

                //Ext.getCmp("bt_Add").setDisabled(true);
                //Ext.getCmp("bt_Del").setDisabled(true);
                //Ext.getCmp("bt_Clr").setDisabled(true);
            }

            $("#btnApp_N").click(function() {
                if (!$("#Result").val()) {
                    AimDlg.show("请输入意见!");
                    return;
                }
                var result = $("#advices").val();
                doSubmit("-1", result);
            });

            $("#btnApp_Y").click(function() {
                var result = $("#Result").val();
                doSubmit("2", result);
            });

            if (op == "c") {
                $("#btnApp_Y,#btnApp_N").hide();
            }

            //赋值 
            if (!$.isEmptyObject(AimState["frmdata"])) {
                $("#advices").val(AimState["frmdata"]["Result"]); //审批意见

                $(":radio[name='Sex']").each(function() {
                    if ($(this).val() == AimState["frmdata"]["Sex"]) {
                        $(this).attr("checked", true);
                    }
                });

                $(":radio[name='OSex']").each(function() {
                    if ($(this).val() == AimState["frmdata"]["OSex"]) {
                        $(this).attr("checked", true);
                    }
                });

                //是否双职工
                $(":radio[name='IsDoubleWorker']").each(function() {
                    if ($(this).val() == AimState["frmdata"]["IsDoubleWorker"]) {
                        $(this).attr("checked", true);
                        $(this).val() == "Y" ? $("#dblWorker").show() : $("#dblWorker").hide();
                    }
                });


                //是否独生子女
                $(":radio[name='IsSingleChild']").each(function() {
                    if ($(this).val() == AimState["frmdata"]["IsSingleChild"]) {
                        $(this).attr("checked", true);
                    }
                });

                //审批意见
                if (AimState["frmdata"]["WorkFlowState"] == "2" || AimState["frmdata"]["WorkFlowState"] == "-1") {
                    $("#examfield").show();
                }
            }

            //event 是否双职工 
            $(":radio[name='IsDoubleWorker']").each(function() {
                $(this).click(function() {
                    if ($(this).attr("checked") && $(this).val() == "Y") {
                        $("#dblWorker").show();
                        $("#WelfareType").val("double");
                        IsDoubleWorkers = true; //双职工
                    } else {
                        $("#dblWorker").hide();
                        IsDoubleWorkers = false; //N
                    }
                });
            })

            //event 是否独生子女
            $(":radio[name='IsSingleChild']").each(function() {
                $(this).click(function() {
                    if ($(this).attr("checked") && $(this).val() == "Y") {
                        //add store
                        if (store.find('BeRelation', '子女') < 0) {
                            // var EntRecord = grid.getStore().recordType;
                            // var p = new EntRecord({ "BeRelation": '子女' });
                            // insRowIdx = store.data.length;
                            // store.insert(insRowIdx, p);
                            //  grid.startEditing(insRowIdx, 1);
                        }
                        // AimDlg.show("温馨提示,选择'独生子女'时须上传附件!");
                        IsSingleChild = true; //独生子女
                        return;
                    } else {
                        IsSingleChild = false; //独生子女
                    }
                });
            })

            //类型切换判断
            $(":radio[name='WelfareType']").click(function() {
                if ($(this).val() == "child" && $(this).attr("checked")) {
                    $("#OtherUserName,#OtherIdentityCard").val("").attr("disabled", true);
                    $(":radio[name='OSex']").removeAttr("checked").attr("disabled", true)
                    Ext.getCmp("bt_Add").setDisabled(false);
                    Ext.getCmp("bt_Del").setDisabled(false);
                    Ext.getCmp("bt_Clr").setDisabled(false);
                }
                if ($(this).val() == "double" && $(this).attr("checked")) {
                    $("#OtherUserName,#OtherIdentityCard").removeAttr("disabled");
                    $(":radio[name='OSex']").removeAttr("disabled")
                    store.removeAll();
                    Ext.getCmp("bt_Add").setDisabled(true);
                    Ext.getCmp("bt_Del").setDisabled(true);
                    Ext.getCmp("bt_Clr").setDisabled(true);
                }
            });
            //----------

        }


        function SubFinish(args) {
            // RefreshClose();
            window.returnValue = "true";  //  模态窗口
            window.close();
        }

        //-------------------------------------------
        function InitEditTable() {

            // 表格数据
            myData = {
                records: AimState["datalist"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'datalist',
                data: myData,
                fields: [

			{ name: 'Id' },
			{ name: 'UsrName' },
			{ name: 'Sex' },
			{ name: 'IDCartNo' },
			{ name: 'ChildWelfareId' },
			{ name: 'IDType' },
			{ name: 'Remark' },
			{ name: 'CreateId' },
			{ name: 'BeRelation' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' }
			    ],
                aimbeforeload: function(proxy, options) {
                    options.data = options.data || {};
                    options.data.id = Id;
                }
            });


            cb_QuestionType = new Ext.ux.form.AimComboBox({
                id: 'cb_QuestionType',
                enumdata: { "男": "男", "女": "女" },
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
                                rec.set("Sex", obj.value);
                            }
                        }
                    }
                }
            });

            cb_rea = new Ext.ux.form.AimComboBox({
                id: 'cb_rea',
                enumdata: { "子女": "子女", "配偶": "配偶" },
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
                            }
                        }
                    }
                }
            });

            cb_card = new Ext.ux.form.AimComboBox({
                id: 'cb_card',
                enumdata: { "身份证": "身份证", "出生证明": "出生证明", "护照": "护照" },
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
                            }
                        }
                    }
                }
            });


            var cm = new Ext.grid.ColumnModel({
                defaults: {
                    resizable: true
                },
                columns: [
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'BeRelation', header: '被保险人关系', editor: cb_rea, dataIndex: 'BeRelation', width: 120, resizable: true },
                    { id: 'UsrName', header: '姓名', editor: new Ext.form.TextField({}), dataIndex: 'UsrName', width: 120, resizable: true },
                    { id: 'Sex', header: '性别', editor: cb_QuestionType, dataIndex: 'Sex', width: 100, resizable: true },
                    { id: 'IDType', header: '证件类型', editor: cb_card, dataIndex: 'IDType', width: 100, resizable: true },
                    { id: 'IDCartNo', header: '证件号码',
                        editor: {
                            xtype: "textfield",
                            regexText: '身份证格式不正确',
                            maxLength: 19,
                            listeners: {
                                "blur": function(obj) {
                                    var rec = store.getAt(grid.activeEditor.row);
                                    if (rec.get("IDType") == "身份证") {
                                        var reg = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{4}$/;
                                        if (!reg.test(obj.getValue())) {
                                            AimDlg.show("身份证号码不合法!");
                                            obj.setValue("")
                                        }
                                    }
                                }
                            }
                        }, dataIndex: 'IDCartNo', width: 280, resizable: true
                    },
                    { id: 'Remark', header: '备注', editor: { xtype: 'textarea' }, dataIndex: 'Remark', width: 150, resizable: true }


                ]
            });


            // 表格面板
            grid = new Ext.ux.grid.AimEditorGridPanel({
                store: store,
                cm: cm,
                renderTo: "StandardSub",
                //width: 633,
                //autoHeight: true,
                width: Ext.get("StandardSub").getWidth(),
                height: 180,
                forceLayout: true,
                columnLines: true,
                viewConfig: {
                    forceFit: true
                },
                plugins: new Ext.ux.grid.GridSummary(),
                tbar: new Ext.Toolbar({
                    hidden: pgOperation == 'r',
                    items: [{
                        id: 'bt_Add',
                        text: '添加',
                        iconCls: 'aim-icon-add',
                        handler: function() {
                            var BeRelation = IsSingleChild ? "子女" : "";
                            var EntRecord = grid.getStore().recordType;
                            var p = new EntRecord({ BeRelation: BeRelation });
                            grid.stopEditing();
                            insRowIdx = store.data.length;
                            store.insert(insRowIdx, p);
                            grid.startEditing(insRowIdx, 1);

                            return;
                        }
                    }, {
                        id: 'bt_Del',
                        text: '删除',
                        iconCls: 'aim-icon-delete',
                        handler: function() {
                            var recs = grid.getSelectionModel().getSelections();
                            if (!recs || recs.length <= 0) {
                                AimDlg.show("请先选择要删除的记录！");
                                return;
                            }

                            if (confirm("确定删除所选项?")) {
                                var id = "";
                                $.each(recs, function() {
                                    if (this.data.Id != null) {
                                        id += "'" + this.data.Id + "',";
                                    }
                                    store.remove(this);
                                })

                                if (id.length != 0) {
                                    var id1 = id.substring(0, (id.length - 1));
                                    jQuery.ajaxExec("Del", { idList: id1 }, function(ret) {

                                    });
                                }
                            }
                        }
                    }, {
                        id: 'bt_Clr',
                        text: '清空',
                        iconCls: 'aim-icon-delete',
                        handler: function() {
                            if (confirm("确定清空所有记录？")) {
                                var Id = "";
                                if (id.length != 0) {
                                    var recs = grid.store.getRange();
                                    $.each(recs, function() {
                                        if (this.data.ID) {
                                            Id += "'" + this.data.ID + "',";
                                        }
                                    }
                                   );
                                    if (Id.length != 0) {
                                        var id1 = id.substring(0, (Id.length - 1));
                                        jQuery.ajaxExec("Del", { idList: id1 }, function(ret) {

                                        });
                                    }
                                }
                                store.removeAll();
                            }
                        }
                    }
]
                })

            });
            grid.on("afteredit", function(e) {
                if (e.field == "IDCartNo") {
                    if (!e.value) return;
                    $.ajaxExec("CheckApply", { year: new Date().getFullYear(), IDCartNo: e.value }, function(rtn) {
                        if (rtn.data.state == "1") {
                            e.record.set("IDCartNo", "");
                            AimDlg.show(e.UsrName + ",该年度已被您申报过,无须重复申报!");
                            return;
                        }
                    });
                }
            });


            window.onresize = function() {
                grid.setWidth(0);
                grid.setWidth(Ext.get("StandardSub").getWidth());
            };
        }

        //暂存保存  2 同意 -1 不同意
        function doSubmit(state, advise) {
            SuccessSubmit("1", function() {
                $.ajaxExec("doAppSubmit", { State: state,
                    preAdvice: $("#advices").val(),
                    Advise: advise,
                    id: id
                }, function() {
                    RefreshClose();
                });
            });
        }

        function isIScard(val) {
            var bol = true;
            var isIDCard2 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{4}$/;
            if (!isIDCard2.test(val)) {
                var bol = false;
            }
            return bol
        }


        //User选中后
        function selectAfter(rtn) {
            if (rtn && !$.isEmptyObject(rtn.data)) {
                rtn.data.WorkNo && ($("#OtherUserWorkNo").val(rtn.data.WorkNo))
            }
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            保险申报</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                        <input id="ApproveName" name="ApproveName" />
                        <input id="ApproveUserId" name="ApproveUserId" />
                        <input id="WelfareType" name="WelfareType" />
                        <input id="advices" type="hidden" name="advices" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        公司名称
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CompanyName" name="CompanyName" readonly="readonly" style="width: 96%" />
                        <input id="CompanyId" name="CompanyId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        部门
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="DeptName" name="DeptName" readonly="readonly" style="width: 96%" />
                        <input id="DeptId" name="DeptId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption" style="width: 20%">
                        申请人
                    </td>
                    <td class="aim-ui-td-data" style="width: 25%">
                        <input id="UserName" name="UserName" readonly="readonly" class="validate[required]" />
                        <input id="UserId" name="UserId" type="hidden" />
                    </td>
                    <td class="aim-ui-td-caption" style="width: 20%">
                        工号
                    </td>
                    <td class="aim-ui-td-data" style="width: 28%">
                        <input id="WorkNo" name="WorkNo" readonly="readonly" style="width: 88%" />&nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption" style="width: 20%">
                        性别
                    </td>
                    <td class="aim-ui-td-data" style="width: 28%">
                        <input type="radio" name="Sex" disabled="disabled" value="男" />男
                        <input type="radio" name="Sex" disabled="disabled" value="女" />女
                    </td>
                    <td class="aim-ui-td-caption">
                        入职日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="IndutyData" disabled="disabled" name="IndutyData" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})"
                            style="width: 89%" />
                    </td>
                </tr>
                <tr>
                    <td colspan="5">
                        <span style="border: 0; border-bottom: solid 1px gray;"></span>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        是否独生子女
                    </td>
                    <td class="aim-ui-td-data">
                        <input type="radio" name="IsSingleChild" checked="checked" value="Y" />是
                        <input type="radio" name="IsSingleChild" value="N" />否
                    </td>
                    <td class="aim-ui-td-caption">
                        是否双职工
                    </td>
                    <td class="aim-ui-td-data">
                        <input type="radio" name="IsDoubleWorker" value="Y" />是
                        <input type="radio" name="IsDoubleWorker" checked="checked" value="N" />否
                    </td>
                </tr>
                <tr id="dblWorker" style="display: none">
                    <td class="aim-ui-td-caption" style="width: 20%">
                        配偶姓名
                    </td>
                    <td class="aim-ui-td-data" style="width: 25%">
                        <input id="OtherUserName" aimctrl='user' popafter="selectAfter" name="OtherUserName"
                            class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption" style="width: 20%">
                        配偶工号
                    </td>
                    <td class="aim-ui-td-data" style="width: 28%">
                        <input id="OtherUserWorkNo" name="OtherUserWorkNo" readonly="readonly" class="validate[required]"
                            style="width: 87%" />&nbsp;
                    </td>
                </tr>
                <tr>
                    <td colspan="5">
                        <span style="border: 0; border-bottom: solid 1px gray;"></span>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        备注
                    </td>
                    <td class="aim-ui-td-data" colspan="4">
                        <textarea name="Reason" id="Reason" rows="3" style="width: 95.5%"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        附件
                    </td>
                    <td class="aim-ui-td-data" colspan="4">
                        <input type="hidden" id="AddFiles" style="width: 97.5%" name="AddFiles" aimctrl='file'
                            mode="single" filter='(*.docx;*.doc;*.xls)|*.docx;*.doc;*.xls' />
                    </td>
                </tr>
            </tbody>
        </table>
        <fieldset>
            <legend style="font-size: 12px; margin-top: 10px; margin-bottom: 5px;">被保险人信息</legend>
            <div id="StandardSub" name="StandardSub" align="left" style="width: 100%;">
            </div>
        </fieldset>
        <fieldset id="examfield" style="display: none">
            <legend>处理意见区</legend>
            <table width="100%" id="tbOpinion" style="font-size: 12px; border: none;" class="aim-ui-table-edit">
                <td>
                    <textarea id="Result" name="Result" style="width: 100%" rows="3"></textarea>
                </td>
            </table>
        </fieldset>
        <table class="aim-ui-table-edit" id="submitBar">
            <tbody>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4" style="border: none;">
                        <a id="btnApp_Y" class="aim-ui-button submit">同意</a> <a id="btnApp_N" class="aim-ui-button submit">
                            不同意</a> <a id="btnSubmit" class="aim-ui-button submit">提交</a> <a id="btnCancel" class="aim-ui-button cancel">
                                取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
