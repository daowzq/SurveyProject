<%@ Page Title="员工保险" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="EmpInsuranceEdit.aspx.cs" Inherits="Aim.Examining.Web.EmpInsuranceEdit" %>

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
        select
        {
            width: 100%;
        }
        input
        {
            width: 100%;
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        var InsuranceTypeEnum = { '子女保险': '子女保险', '配偶保险': '配偶保险' };
        var id = $.getQueryString({ ID: "id" });
        var op = $.getQueryString({ ID: "op" });
        var store, grid;
        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            //stateInit();
            InitGrid();
            $('#btnSubmit').click(Submit);
            $('#btnSave').click(Save);
            $("#btnCancel").click(function() {
                window.location.href = "EmpInsuranceList.aspx";
            });
        }
        function Save() {
            var recs = store.getRange();
            if (recs.length > 0) {
                var str1 = ""; var str2 = ""; var str3 = "";
                $.each(recs, function() {
                    str1 += str1 ? ";" : "" + this.get("FamilyName");
                    str2 += str2 ? ";" : "" + this.get("FamilyGender");
                    str3 += str3 ? ";" : "" + this.get("FamilyIdentity");
                })
                $("#FamilyNames").val(str1);
                $("#FamilyGenders").val(str2);
                $("#FamilyIdentities").val(str3);
            }
            else {
                alert("请输入家庭成员信息！");
                return;
            }
            $.ajaxExec("update", { JsonString: AimFrm.getJsonString() }, function(rtn) {
                if (rtn.data.Id) {

                    $("#Id").val(rtn.data.Id);
                    alert("保存成功！");
                    window.location.href = "EmpInsuranceList.aspx";
                }
            })
        }
        //暂存方法
        function Submit() {
            var recs = store.getRange();
            if (recs.length > 0) {
                var str1 = ""; var str2 = ""; var str3 = "";
                $.each(recs, function() {
                    str1 += str1 ? ";" : "" + this.get("FamilyName");
                    str2 += str2 ? ";" : "" + this.get("FamilyGender");
                    str3 += str3 ? ";" : "" + this.get("FamilyIdentity");
                })
                $("#FamilyNames").val(str1);
                $("#FamilyGenders").val(str2);
                $("#FamilyIdentities").val(str3);
            }
            else {
                alert("请输入家庭成员信息！");
                return;
            }
            if (confirm("确认需要提交审批吗？")) {
                $.ajaxExec("submit", { JsonString: AimFrm.getJsonString() }, function(rtn) {
                    if (rtn.data.Id) {
                        $("#Id").val(rtn.data.Id);
                        alert("提交成功！");
                        window.location.href = "EmpInsuranceList.aspx";
                    }
                })
            }
        }
        //        function stateInit() {
        //            if (op == "r" || op == "reader") {
        //                $("#submit").hide();
        //            }

        //            $("#Id").val() && AimState["frmdata"]["ChildCount"] && $(":radio[name='ChildCount']").each(function() {
        //                if ($(this).val() == AimState["frmdata"]["ChildCount"]) $(this).attr("checked", true)
        //            });

        //            //入职日期
        //            if (!AimState["frmdata"]["IndutyData"]) {
        //                $("#IndutyData").removeAttr("disabled");
        //            } 
        //            $("#UserId").bind("input propertychange", function() {
        //                var id = $(this).val();
        //                if (id.length != 0) {
        //                    $.ajaxExec("GetWorkNo", { UserID: id }, function(rtn) {
        //                        var Sex = rtn.data.WorkNo.split("|")[1];
        //                        var WorkNo = rtn.data.WorkNo.split("|")[0];
        //                        var IndutyData = rtn.data.WorkNo.split("|")[2];
        //                        $("#IndutyData").val(IndutyData);
        //                        rtn.data.WorkNo && $("#WorkNo").val(WorkNo);
        //                        if (Sex == "男") {
        //                            $("#man").attr("checked", true)
        //                        } else {
        //                            $("#woman").attr("checked", true)
        //                        }
        //                    });
        //                }
        //            });
        //        }
        function sumitForm() {
            $("#submit").click(function() {
                isIDCard2 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{4}$/
                if ($("#IdentityCard").val() && !isIDCard2.test($("#IdentityCard").val())) {
                    AimDlg.show("身份证号码不合法!");
                    return;
                }

                if (!$("#ApproveUserId").val()) {
                    AimDlg.show("系统取不到审批人,请配置审批人!");
                    return;
                }

                if (confirm("确认提交申请？")) {
                    ///userSelect();   ///提交按钮
                    Ext.getBody().mask("提交中,请稍后...");

                    var recs = grid.store.getRange();
                    var dt = store.getModifiedDataStringArr(recs) || [];

                    AimFrm.submit("Submit", { id: id, data: dt }, null, function() { });
                }
            });

        }
        function UsrSelect(rtn) {
            if (op == "c") {
                var UserID = rtn.data.UserID;
                UserID && $.ajaxExec("GetWorkNo", { UserID: UserID }, function(rtn) {
                    var Sex = rtn.data.WorkNo.split("|")[1];
                    var WorkNo = rtn.data.WorkNo.split("|")[0];
                    rtn.data.WorkNo && $("#WorkNo").val(WorkNo);
                    if (Sex == "男") {
                        $("#man").attr("checked", true)
                    } else {
                        $("#woman").attr("checked", true)
                    }
                });
            } else {

            }

        }

        function SubFinish(args) {
            RefreshClose();
        }
        function InitGrid() {
            myData = {
                records: AimState["DataList"] || []
            };
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                data: myData,
                fields: [
			    { name: 'FamilyIdentity' },
			    { name: 'FamilyName' },
			    { name: 'FamilyGender' }
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
            var cm = new Ext.grid.ColumnModel({
                defaults: {
                    resizable: true
                },
                columns: [
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'FamilyName', header: '<label style="color:red;">姓名</label>', editor: new Ext.form.TextField({}), dataIndex: 'FamilyName', width: 120 },
                    { id: 'FamilyGender', header: '<label style="color:red;">性别</label>', editor: cb_QuestionType, dataIndex: 'FamilyGender', width: 100 },
                    { id: 'FamilyIdentity', header: '<label style="color:red;">身份证号</label>', editor: { xtype: 'textfield', allowBlank: false }, dataIndex: 'FamilyIdentity', width: 300 }
                ]
            });
            grid = new Ext.ux.grid.AimEditorGridPanel({
                store: store,
                cm: cm,
                renderTo: "StandardSub",
                //width: 633,
                //autoHeight: true,
                width: Ext.get("StandardSub").getWidth(),
                height: 160,
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
                        handler: function() {

                            var EntRecord = grid.getStore().recordType;
                            var p = new EntRecord({});
                            grid.stopEditing();
                            insRowIdx = store.data.length;
                            store.insert(insRowIdx, p);
                            grid.startEditing(insRowIdx, 1);

                            return;
                        }
                    }, {
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
                }),
                autoExpandColumn: 'Remark'

            });


            if (op != "r") {
                grid.on("afteredit", afterEidt, grid);
            }

            function afterEidt(e) {
                if (e.field == "IDCartNo") {
                    //                    if (!isIScard(e.value)) {
                    //                        e.record.set("IDCartNo", "");
                    //                        AimDlg.show("请输入正确的身份证号码！");
                    //                        return;
                    //                    }
                }
            }
            window.onresize = function() {
                grid.setWidth(0);
                grid.setWidth(Ext.get("StandardSub").getWidth());
            };
        }
        function isIScard(val) {

            var bol = true;
            var isIDCard2 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{4}$/;
            if (!isIDCard2.test(val)) {
                var bol = false;
            }
            return bol
        }

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            员工保险</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit" width="100%">
            <tr style="display: none">
                <td>
                    <input id="Id" name="Id" />
                    <input id="UserId" name="UserId" />
                    <input id="CreateId" name="CreateId" />
                    <input id="CreateName" name="CreateName" />
                    <input id="CreateTime" name="CreateTime" />
                    <input id="FamilyNames" name="FamilyNames" />
                    <input id="FamilyGenders" name="FamilyGenders" />
                    <input id="FamilyIdentities" name="FamilyIdentities" />
                    <input id="State" name="State" />
                    <input id="Result" name="Result" />
                    <input id="ApplyTime" name="ApplyTime" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption" style="width: 20%">
                    申请人
                </td>
                <td class="aim-ui-td-data" style="width: 30%">
                    <input id="UserName" aimctrl='user' relateid="UserId" name="UserName" class="validate[required]" />
                </td>
                <td class="aim-ui-td-caption" style="width: 20%">
                    工号
                </td>
                <td class="aim-ui-td-data" style="width: 30%">
                    <input id="WorkNo" name="WorkNo" readonly="readonly" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    公司名称
                </td>
                <td class="aim-ui-td-data">
                    <input id="CompanyName" name="CompanyName" readonly="readonly" />
                    <input id="CompanyId" name="CompanyId" type="hidden" />
                </td>
                <td class="aim-ui-td-caption">
                    一级部门
                </td>
                <td class="aim-ui-td-data">
                    <input id="DeptName" name="DeptName" readonly="readonly" />
                    <input id="DeptId" name="DeptId" type="hidden" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    身份证号
                </td>
                <td class="aim-ui-td-data">
                    <input id="IdentityCard" name="IdentityCard" />
                </td>
                <td class="aim-ui-td-caption">
                    入职日期
                </td>
                <td class="aim-ui-td-data">
                    <input id="IndutyDate" readonly="readonly" name="IndutyDate" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    申请原因
                </td>
                <td class="aim-ui-td-data" colspan="3">
                    <textarea name="Reason" id="Reason" rows="3" style="width: 100%"></textarea>
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    附件
                </td>
                <td class="aim-ui-td-data">
                    <input type="hidden" id="AddFiles" name="AddFiles" aimctrl='file' mode="single" filter='(*.docx;*.doc;*.xls)|*.docx;*.doc;*.xls' />
                </td>
                <td class="aim-ui-td-caption">
                    保险类型
                </td>
                <td>
                    <select id="InsuranceType" name="InsuranceType" aimctrl='select' enum="InsuranceTypeEnum"
                        class="validate[required]">
                    </select>
                </td>
            </tr>
        </table>
        <fieldset>
            <legend style="font-size: 12px; margin-top: 10px; margin-bottom: 5px;">子女/配偶信息</legend>
            <div id="StandardSub" name="StandardSub" align="left" style="width: 100%;">
            </div>
        </fieldset>
        <table class="aim-ui-table-edit" id="submitBar">
            <tr>
                <td class="aim-ui-button-panel" colspan="4">
                    <a id="btnSubmit" class="aim-ui-button">提交</a> <a id="btnSave" class="aim-ui-button">
                        暂存</a> <a id="btnCancel" class="aim-ui-button cancel">取消</a>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
