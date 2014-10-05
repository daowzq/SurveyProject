<%@ Page Title="申报配置" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="WelfareConfigEdit.aspx.cs" Inherits="Aim.Examining.Web.WelfareConfigEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var op = $.getQueryString({ ID: "op" });
        var grid, store;
        function onPgLoad() {
            gridInit();
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c" || pgOperation == "cs") {
                $("#CreateName").val(AimState.UserInfo.Name);
                $("#CreateTime").val(jQuery.dateOnly(AimState.SystemInfo.Date));
            }

            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        function gridInit() {
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
			{ name: 'CreateId' },
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

            var cm = new Ext.grid.ColumnModel({
                defaults: {
                    resizable: true
                },
                columns: [
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'UsrName', header: '<label style="color:red;">姓名</label>', editor: new Ext.form.TextField({}), dataIndex: 'UsrName', width: 120, resizable: true },
                    { id: 'Sex', header: '<label style="color:red;">性别</label>', editor: cb_QuestionType, dataIndex: 'Sex', width: 100, resizable: true },
                    { id: 'IDCartNo', header: '<label style="color:red;">身份证号</label>', editor: new Ext.form.TextField({}), dataIndex: 'IDCartNo', width: 300, resizable: true }
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
                    if (isIScard(e.value)) { } else {
                        e.record.set("UsrName", "");
                        e.record.set("IDCartNo", "");
                        e.record.set("Sex", "");
                        AimDlg.show("请输入正确的身份证号码！");
                        return;
                    };
                }
            }
            window.onresize = function() {
                grid.setWidth(0);
                grid.setWidth(Ext.get("StandardSub").getWidth());
            };
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);
        }

        function SubFinish(args) {
            RefreshClose();
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            申报配置</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        公司
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id='CorpName' name="CorpName" aimctrl="popup" popurl="/CommonPages/Select/GrpSelect/MGrpSelect.aspx?seltype=single"
                            popparam="CorpId:GroupID;CorpName:Name" popstyle="width=450,height=450" class="validate[required]"
                            style="width: 80%" />
                        <input id="CorpId" name="CorpId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        部门
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="DeptName" name="DeptName" aimctrl="popup" popparam="CorpId:GroupID;CorpName:Name"
                            popstyle="width=450,height=450" style="width: 80%" />
                        <input id="DeptId" name="DeptId" type="hidden" />
                    </td>
                </tr>
            </tbody>
        </table>
        <div id="StandardSub" name="StandardSub" style="width: 100%;">
        </div>
        <table class="aim-ui-table-edit">
            <tr>
                <td class="aim-ui-button-panel" colspan="4">
                    <a id="btnSubmit" class="aim-ui-button submit">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                        取消</a>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
