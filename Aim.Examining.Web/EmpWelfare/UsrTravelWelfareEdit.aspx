<%@ Page Title="员工旅游" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="UsrTravelWelfareEdit.aspx.cs" Inherits="Aim.Examining.Web.UsrTravelWelfareEdit" %>

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

        function onPgLoad() {
            setPgUI();
            stateInit();
            InitEditTable();

            if (!!!id) {
                //旅游金额
                var arr = (AimState["TravelMoney"] + "").split("|")
                $("#BaseMoney").text(arr[0] || 0);
                $("#WorkYearMoney").text(arr[1] || 0);
                $("#TravelMoney").val(parseFloat(arr[0] || 0) + parseFloat(arr[1] || 0));
            } else {
                //view state
                $("#NeedMoney_").text(AimState["frmdata"]["NeedMoney"] + "" || "");
            }
        }

        function setPgUI() {

            $("#btnCancel").click(function () {
                window.close();
            });


            FormValidationBind('btnSubmit', SuccessSubmit);

            //select change
            $("#TravelAddr").change(function () {
                if ($(":selected", this).val()) {
                    var val = $(":selected", this).val();
                    $.ajaxExec("GetTimeSeg", { Addr: val }, function (rtn) {
                        var data = rtn.data.Result || "{}";
                        var ObjArr = eval("(" + data + ")");
                        var html = "";
                        $.each(ObjArr, function () {
                            html += "<option value='" + this["K"] + "' >" + this["V"] + "</option>";
                        })
                        $("#TravelTime").children().remove();
                        $("#TravelTime").append(html);
                    });
                }
            });

            //
            $("#TravelTime").change(function () {
                if ($(":selected", this).val()) {
                    var val = $(":selected", this).val();
                    var Addr = $("#TravelAddr option:selected").val();
                    $.ajaxExec("GetDetailInfo", { TimeSeg: val, Addr: Addr }, function (rtn) {

                        var data = rtn.data.Result || "{}";
                        var obj = eval("(" + data + ")");
                        if (!$.isEmptyObject(obj)) {
                            $("#ConfigSetId").val(obj["ConfigId"]);
                            $("#znum").text(obj["TravelCount"]);
                            $("#snum").text(parseInt(obj["LeaveUsrCount"] || 0) <= 0 ? "已无名额" : (obj["LeaveUsrCount"] || 0));
                            $("#NeedMoney_").text(obj["NeedMoney"]);
                            $("#NeedMoney").val(obj["NeedMoney"]);

                            //按钮控制
                            $("#btnSubmit").show();
                            if (parseInt(obj["LeaveUsrCount"] || 0) <= 0) {
                                $("#btnSubmit").hide();
                            }

                            $("#TravelName").text("").append(obj["TravelName"]).css({ color: 'blue', cursor: "pointer" }).click(function () {
                                if ($("#ConfigSetId").val()) {
                                    $.ajaxExec("GetTravelConfig", { ConifgId: $("#ConfigSetId").val() || "" }, function (rtn) {
                                        var data = rtn.data.Info;

                                        var sw = new Ext.Window({
                                            title: '详细信息',
                                            width: 380,
                                            height: 200,
                                            padding: '15 5 5 5',
                                            autoScroll: true,
                                            layout: 'form',
                                            bodyStyle: 'overflow-y:auto;overflow-x:auto;',
                                            items: [{
                                                xtype: 'label',
                                                fieldLabel: '旅游名称',
                                                text: !$.isEmptyObject(data) ? data["TravelName"] : ""
                                            }, {
                                                xtype: 'label',
                                                fieldLabel: '出行地点',
                                                text: !$.isEmptyObject(data) ? data["TravelAddress"] : ""
                                            }, {
                                                xtype: 'label',
                                                fieldLabel: '工   &nbsp;&nbsp;&nbsp;&nbsp;龄',
                                                text: !$.isEmptyObject(data) ? data["WorkAge"] : ""
                                            }, {
                                                xtype: 'label',
                                                fieldLabel: ' 总名额 ',
                                                text: !$.isEmptyObject(data) ? data["TravelCount"] : ""
                                            }, {
                                                xtype: 'label',
                                                fieldLabel: '需要金额 ',
                                                text: !$.isEmptyObject(data) ? data["NeedMoney"] + " (元)" : ""
                                            }]
                                        });
                                        sw.show();
                                    });
                                }
                            });

                        }
                    });
                }
            });
            //------------------
        }


        //暂存保存
        function SuccessSubmit() {
            if (!confirm("确认提交吗")) {
                return;
            }

            var haveFill = false;
            $.ajaxExecSync("GetUsrCount", { ConfigSetId: $("#ConfigSetId").val() }, function (rtn) {
                if ((rtn.data.Result) && parseInt(rtn.data.Result) <= 0) {
                    haveFill = true;
                    AimDlg.show("申报名额已满,请重新选择!");
                    return;
                }
            });
            if (haveFill) return;

            var Arr = $("#TravelTime").val().split("--");
            if (Arr.length > 0) {
                $("#StartDate").val(Arr[0]);
                $("#EndDate").val(Arr[1]);
            }

            var TravelAddr = $("#TravelAddr option:selected").val();
            var TravelTime = $("#TravelTime option:selected").val();
            var Ext1 = $("#TravelName").text();
            var recs = grid.store.getRange();
            var dt = store.getModifiedDataStringArr(recs) || [];

            if (recs.length > 0) $("#HaveFamily").val("Y"); //Y 带家属

            AimFrm.submit(pgAction, {
                data: dt,
                TravelAddr: TravelAddr,
                TravelTime: TravelTime,
                Ext1: Ext1
            }, null, function () {
                // RefreshClose();
                window.returnValue = "true";  //  模态窗口
                window.close();
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
            }
            //审批
            if (type == "app") {
                $("#examfield").show();
                $("#btnSubmit").hide();
                $("#btnApp_Y,#btnApp_N").show();
            }

            $("#btnApp_N").click(function () {
                if (!$("#Result").val()) {
                    AimDlg.show("请输入意见!");
                    return;
                }
                doSubmit("-1", $("#Result").val());
            });
            $("#btnApp_Y").click(function () {
                doSubmit("2", $("#Result").val());
            });

            if (op == "c") {
                $("#btnApp_Y,#btnApp_N").hide();
            }
            //------------
            var Sex = $("input[name=Sex]").val();
            if (Sex == "男") {
                $("#man").attr("checked", true);
            } else { $("#woman").attr("checked", true); }

            if (!$.isEmptyObject(AimState["frmdata"])) {
                var obj = AimState["frmdata"];
                if (obj["TravelTime"]) {
                    var val = obj["TravelTime"];
                    var html = "<option value='' >请选择...</option><option value='" + val + "' selected='selected' >" + val + "</option>";
                    $("#TravelTime").append(html);
                }

                //审批意见区
                if (obj["Result"]) {
                    $("#examfield").show();
                    $("#Result").attr("disabled", true);
                    $("#btnApp_N,#btnApp_Y").hide();
                }
                //旅游名称
                if (obj["Ext1"] && obj["ConfigSetId"]) {

                    $("#TravelName").append(obj["Ext1"]).css({ color: 'blue', cursor: "pointer" }).click(function () {
                        if ($("#ConfigSetId").val()) {
                            $.ajaxExec("GetTravelConfig", { ConifgId: obj["ConfigSetId"] || "" }, function (rtn) {
                                var data = rtn.data.Info;

                                var sw = new Ext.Window({
                                    title: '详细信息',
                                    width: 380,
                                    height: 200,
                                    padding: '15 5 5 5',
                                    autoScroll: true,
                                    layout: 'form',
                                    bodyStyle: 'overflow-y:auto;overflow-x:auto;',
                                    items: [{
                                        xtype: 'label',
                                        fieldLabel: '旅游名称',
                                        text: !$.isEmptyObject(data) ? data["TravelName"] : ""
                                    }, {
                                        xtype: 'label',
                                        fieldLabel: '出行地点',
                                        text: !$.isEmptyObject(data) ? data["TravelAddress"] : ""
                                    }, {
                                        xtype: 'label',
                                        fieldLabel: '工   &nbsp;&nbsp;&nbsp;&nbsp;龄',
                                        text: !$.isEmptyObject(data) ? data["WorkAge"] : ""
                                    }, {
                                        xtype: 'label',
                                        fieldLabel: ' 总名额 ',
                                        text: !$.isEmptyObject(data) ? data["TravelCount"] : ""
                                    }]
                                });
                                sw.show();
                            });
                        }
                    });
                }
            }

        }

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
                { name: 'WelfareTravelId' },
                { name: 'Name' },
                { name: 'Sex' },
                { name: 'Age' },
                { name: 'IsChild' },
                { name: 'Height' },
                { name: 'CreateId' },
                { name: 'CreateName' },
                { name: 'CreateTime' }
                ],
                aimbeforeload: function (proxy, options) {
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
                    blur: function (obj) {
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


            cb_QuestionChild = new Ext.ux.form.AimComboBox({
                id: 'cb_QuestionChild',
                enumdata: { "是": "是", "否": "否" },
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
                                rec.set("IsChild", obj.value);

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
                    { id: 'Name', header: '姓名', editor: new Ext.form.TextField({}), dataIndex: 'Name', width: 120, resizable: true },
                    { id: 'Sex', header: '性别', editor: cb_QuestionType, dataIndex: 'Sex', width: 100, resizable: true },
                    { id: 'Age', header: '年龄', editor: { xtype: 'numberfield', maxValue: 100, allowBlank: false }, dataIndex: 'Age', width: 100, resizable: true },
                    { id: 'IsChild', header: '是否为儿童', editor: cb_QuestionChild, dataIndex: 'IsChild', width: 100, resizable: true },
                    { id: 'Height', header: '身高（m）', editor: { xtype: 'numberfield', maxValue: 2.5, allowBlank: false }, dataIndex: 'Height', width: 120, resizable: true }
                ]
            });

            // 表格面板
            grid = new Ext.ux.grid.AimEditorGridPanel({
                store: store,
                cm: cm,
                renderTo: "StandardSub",
                //autoHeight: true,
                //width: 633,
                width: Ext.get("StandardSub").getWidth(),
                height: 170,
                forceLayout: true,
                columnLines: true,
                viewConfig: {
                    forceFit: true
                },
                plugins: new Ext.ux.grid.GridSummary(),
                tbar: new Ext.Toolbar({
                    hidden: pgOperation == 'r',
                    items: [{
                        text: '添加',
                        iconCls: 'aim-icon-add',
                        handler: function () {
                            var EntRecord = grid.getStore().recordType;
                            var recType = new EntRecord({ Sex: '男', IsChild: '否' });
                            grid.stopEditing();
                            store.insert(store.data.length, recType);
                            //grid.startEditing(insRowIdx, 1);
                            return;
                        }
                    }, {
                        text: '删除',
                        iconCls: 'aim-icon-delete',
                        handler: function () {
                            var recs = grid.getSelectionModel().getSelections();
                            if (!recs || recs.length <= 0) {
                                AimDlg.show("请先选择要删除的记录！");
                                return;
                            }


                            if (confirm("确定删除所选项?")) {
                                var Ids = "";
                                $.each(recs, function (i) {
                                    if (this.data.Id != null) {
                                        Ids += "'" + this.data.Id + "',";
                                    }
                                    store.remove(this);
                                })

                                if (id.length != 0) {
                                    Ids = Ids.substring(0, (Ids.length - 1));
                                    $.ajaxExec("DeleteSub", { idList: Ids }, function (ret) {
                                    });
                                }
                            }
                        }
                    }, {
                        text: '清空',
                        iconCls: 'aim-icon-delete',
                        handler: function () {
                            if (confirm("确定清空所有记录？")) {
                                var Id = "";
                                if (id.length != 0) {
                                    var recs = grid.store.getRange();
                                    $.each(recs, function () {
                                        if (this.data.ID) {
                                            Id += "'" + this.data.ID + "',";
                                        }
                                    }
                                   );
                                    if (Id.length != 0) {
                                        var id1 = id.substring(0, (Id.length - 1));
                                        jQuery.ajaxExec("Del", { idList: id1 }, function (ret) {

                                        });
                                    }
                                }
                                store.removeAll();
                            }
                        }
                    }
]
                }),
                autoExpandColumn: 'Remark'

            });
            // grid.on("afteredit", afterEidt, grid);

            window.onresize = function () {
                grid.setWidth(0);
                grid.setWidth(Ext.get("StandardSub").getWidth());
            };
        }
        //暂存保存  2 同意 -1 不同意
        function doSubmit(state, advise) {
            $.ajaxExec("doAppSubmit", { State: state, Advise: advise, id: id }, function () {
                SubFinish();
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
        function SubFinish(args) {
            RefreshClose();
        }
    </script>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            员工旅游</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                        <input id="HaveFamily" name="HaveFamily" />
                        <input id="ApproveName" name="ApproveName" />
                        <input id="ApproveUserId" name="ApproveUserId" />
                        <input id="ConfigSetId" name="ConfigSetId" />
                        <input id="StartDate" name="StartDate" />
                        <input id="EndDate" name="EndDate" />
                        <input id="NeedMoney" name="NeedMoney" />
                        <input id="Sex" name="Sex" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption" style="width: 20%">
                        申请人
                    </td>
                    <td class="aim-ui-td-data" style="width: 25%">
                        <input id="UserName" name="UserName" readonly />
                        <input id="UserId" name="UserId" type="hidden" />
                    </td>
                    <td class="aim-ui-td-caption" style="width: 20%">
                        工号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="WorkNo" name="WorkNo" readonly="readonly" style="width: 87%" />&nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        所属组织
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CompanyName" name="CompanyName" readonly="readonly" readonly style="width: 94.5%" />
                        <input id="CompanyId" name="CompanyId" type="hidden" />
                        <input id="DeptName" name="DeptName" type="hidden" />
                        <input id="DeptId" name="DeptId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        旅游地点
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="TravelAddr" name="TravelAddr" aimctrl='select' enum="TravelAddrEnum"
                            style="width: 99%" class="validate[required]">
                    </td>
                    <td class="aim-ui-td-caption">
                        出行日期
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="TravelTime" name="TravelTime" style="width: 178px" class="validate[required]">
                    </td>
                </tr>
                <tr id="xlme">
                    <td class="aim-ui-td-caption">
                        线路总名额
                    </td>
                    <td class="aim-ui-td-data">
                        <span id="znum" style="width: 90px; border: 0; border-bottom: 1 solid black;"></span>
                        (单位:人)
                    </td>
                    <td class="aim-ui-td-caption">
                        线路剩余名额
                    </td>
                    <td class="aim-ui-td-data">
                        <span id="snum" style="width: 90px; border: 0; border-bottom: 1 solid black; color: red;">
                        </span>(单位:人)
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        旅游名称
                    </td>
                    <td class="aim-ui-td-data">
                        <span id="TravelName" style="width: 150px; border: 0; border-bottom: 1 solid black;">
                        </span>
                    </td>
                    <td class="aim-ui-td-caption">
                        旅游费用
                    </td>
                    <td class="aim-ui-td-data">
                        <span id="NeedMoney_" style="width: 150px; border: 0; border-bottom: 1 solid black;">
                        </span>&nbsp;(元)
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        旅游金额
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input name="TravelMoney" id="TravelMoney" style="width: 20%" value="" disabled="disabled" />（单位：元）=
                        当年旅游基本津贴（<span id="BaseMoney"></span>元）+ 服务年限奖励金（<span id="WorkYearMoney"></span>元）
                    </td>
                </tr>
                <%--                <tr>
                    <td class="aim-ui-td-caption">
                        旅游地点
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="TravelAddr" name="TravelAddr" style="width: 90%" />
                    </td>
                </tr>--%>
                <!-- <tr>
                    <td colspan="5">
                        <span style="border: 0; border-bottom: solid 1px gray;"></span>
                    </td>
                </tr>-->
                <tr>
                    <td class="aim-ui-td-caption">
                        备注
                    </td>
                    <td class="aim-ui-td-data" colspan="4">
                        <textarea name="Reason" id="Reason" rows="5" style="width: 95%"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        附件
                    </td>
                    <td class="aim-ui-td-data" colspan="4">
                        <input type="hidden" id="AddFiles" style="width: 97%" name="AddFiles" aimctrl='file'
                            mode="single" filter='(*.docx;*.doc;*.xls)|*.docx;*.doc;*.xls' />
                    </td>
                </tr>
            </tbody>
        </table>
        <fieldset>
            <legend style="font-size: 12px; margin-top: 10px; margin-bottom: 5px;">家属信息</legend>
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
