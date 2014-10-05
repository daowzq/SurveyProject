<%@ Page Title="查看对象" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="Wizard_Three.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Wizard_Three" %>

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
            width: 100%;
            margin-left: 12px;
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
    </style>

    <script type="text/javascript">
        var SurveyId = $.getQueryString({ ID: "SurveyId" });
        var type = $.getQueryString({ ID: "type" });  //操作状态

        function onPgLoad() {
            setPgUI();
            stateInit();
        }

        function setPgUI() {
            gridRender()
        }

        //----------------提交事件处理-------------
        function doSubmit(successFun, failureFun) {
            if (typeof (successFun) != "function" || typeof (failureFun) != "function") return;
            successFun();
        }

        function SuccessSubmit(afterSaveFun) {
            //查看状态
            if (type == "view") {
                parent.afterSave.call(this, "1", "1");
                return;
            }

            var AllowUser = storeAccess.getModifiedDataStringArr(storeAccess.getRange());
            var NoAllowUser = store2.getModifiedDataStringArr(store2.getRange());
            AllowUser = "[" + AllowUser.join(",") + "]";
            NoAllowUser = "[" + NoAllowUser.join(",") + "]";

            pgAction = $("#Id").val() ? "update" : "create";
            AimFrm.submit(pgAction, { AllowUser: AllowUser, NoAllowUser: NoAllowUser
            }, null, function(rtn) {
                (pgAction == "create") && $("#Id").val(rtn.data.Id || '');
                //回写状态
                Ext.getCmp("addBtn1").setText("添加");
                Ext.getCmp("delBtn1").setText("删除");

                Ext.getCmp("addBtn2").setText("添加");
                Ext.getCmp("delBtn2").setText("删除");
                // parent.afterSave.call(this, "2", "1");  //调用父 页面的方法
            });
        }
        //--------------------------------------


        function gridRender() {

            //*********添加人员 ********
            tlBar_dept = new Ext.Toolbar({
                renderTo: 'addUsrTool',
                items: [
                {
                    xtype: 'tbtext',
                    text: '<font color=red ><b>添加人员</b><font/>'
                },
                {
                    id: 'addBtn1',
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openUsrWin(gridAccess);
                    }
                },
               {
                   id: 'delBtn1',
                   text: '删除',
                   iconCls: 'aim-icon-delete',
                   handler: function() {
                       var recs = gridAccess.getSelectionModel().getSelections();
                       if (!recs || recs.length <= 0) {
                           AimDlg.show("请先选择要删除的记录！");
                           return;
                       }
                       if (confirm("确定删除所选记录？")) {
                           for (var i = 0; i < recs.length; i++) {
                               gridAccess.getStore().remove(recs[i]);
                           }
                       }
                   }
               }
]
            });

            myData1 = {
                total: AimSearchCrit["RecordCount"],
                records: eval("(" + (AimState["DataList"] || "[]") + ")")
            };
            storeAccess = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData1,
                fields: [
			      { name: 'Id' }, { name: 'Name'}]
            });


            // 表格面板
            gridAccess = new Ext.ux.grid.AimGridPanel({
                store: storeAccess,
                //region: 'center',
                renderTo: 'addUsrDiv',
                height: 300,
                autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Name', dataIndex: 'Name', header: '姓名', width: 100, sortable: true }
                    ]
            });

            //****************排除人员**********

            tlBar_No = new Ext.Toolbar({
                renderTo: 'noUsrTool',
                items: [
                {
                    xtype: 'tbtext',
                    text: '<font color=red ><b>排除人员</b><font/>'
                },
                {
                    id: 'addBtn2',
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        if (!$("#OrgNames").val()) {
                            AimDlg.show("请先填写组织结构!");
                            return;
                        }
                        openNoUserWin(gridNo);
                    }
                },
               {
                   id: 'delBtn2',
                   text: '删除',
                   iconCls: 'aim-icon-delete',
                   handler: function() {
                       var recs = gridNo.getSelectionModel().getSelections();
                       if (!recs || recs.length <= 0) {
                           AimDlg.show("请先选择要删除的记录！");
                           return;
                       }
                       if (confirm("确定删除所选记录？")) {
                           for (var i = 0; i < recs.length; i++) {
                               gridNo.getStore().remove(recs[i]);
                           }
                       }
                   }
               }
]
            });

            myData2 = {
                total: AimSearchCrit["RecordCount"],
                records: eval("(" + (AimState["DataList1"] || "[]") + ")")
            };
            store2 = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList1',
                idProperty: 'Id',
                data: myData2,
                fields: [
			      { name: 'Id' }, { name: 'Name'}]
            });


            // 表格面板
            gridNo = new Ext.ux.grid.AimGridPanel({
                store: store2,
                //region: 'center',
                renderTo: 'noUsrDiv',
                height: 300,
                autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Name', dataIndex: 'Name', header: '姓名', width: 100, sortable: true }
                    ]
            });
        }

        //基本信息初始化
        function stateInit() {
            // SurveyId 初始化
            SurveyId && $("#SurveyId").val(SurveyId);
        }

        //人员选择
        function openUsrWin(gridSg) {
            var style = "dialogWidth:720px; dialogHeight:430px; scroll:yes; center:yes; status:no; resizable:yes;";

            var url = "/CommonPages/Select/UsrSelect/MUsrSelect.aspx?seltype=multi&rtntype=array";
            OpenModelWin(url, {}, style, function() {
                if (this.data == null || this.data.length == 0 || !this.data.length) return;
                // var gird = Ext.getCmp(gridSg);
                var gird = gridSg
                var EntRecord = gird.getStore().recordType;
                for (var i = 0; i < this.data.length; i++) {
                    if (gird.store.find("Id", this.data[i]["UserID"]) != -1) continue;
                    var rec = new EntRecord({ Id: this.data[i]["UserID"], Name: this.data[i]["Name"] });
                    gird.getStore().insert(gird.getStore().data.length, rec);
                }
            })
        }


        //排除人员选择控件
        function openNoUserWin(gridSg) {


            var paraUrl = postParameter();
            var style = "dialogWidth:450px; dialogHeight:460px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "/SurveyManage/NoSelectUsr.aspx?seltype=multi&rtntype=array&" + paraUrl;

            OpenModelWin(url, {}, style, function(rtn) {
                if (this.data == null || this.data.length == 0 || !this.data.length) return;
                //var gird = Ext.getCmp(gridSg);
                var gird = gridSg;
                var EntRecord = gird.getStore().recordType;
                for (var i = 0; i < this.data.length; i++) {
                    if (gird.store.find("Id", this.data[i]["UserID"]) != -1) continue; //筛选已经存在的部门
                    var rec = new EntRecord({ Id: this.data[i]["UserID"], Name: this.data[i]["Name"] });
                    gird.getStore().insert(gird.getStore().data.length, rec);
                }
            })
        }

        function postParameter() {
            return "OrgIds=" + ($("#OrgIds").val() || '');
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            查看对象</h1>
    </div>
    <div id="editDiv" align="center">
        <fieldset>
            <legend>基本设置</legend>
            <table class="aim-ui-table-edit" style="margin: 2px 2px">
                <tbody>
                    <tr style="display: none">
                        <td colspan="4">
                            <input id="Id" name="Id" />
                            <input id="SurveyId" name="SurveyId" />
                            <input id="SurveyTitle" name="SurveyTitle" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            查看权限
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input type="radio" value="sender" name="ReaderWay" checked="checked" />问卷发起者&nbsp;&nbsp;
                            <input type="radio" value="joiner" name="ReaderWay" />问卷参与者&nbsp; (<b>说明</b>:问卷参与者包含问卷发起者对象)
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            组织机构
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input name="OrgNames" id="OrgNames" style="width: 75%" readonly="readonly" aimctrl="popup"
                                popurl="/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=multi" popparam="OrgIds:GroupID;OrgNames:Name"
                                popstyle="width=540,height=450" />
                            <input name="OrgIds" id="OrgIds" type="hidden" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
        <fieldset>
            <legend>人员设置</legend>
            <table style="width: 100%; table-layout: fixed">
                <tr>
                    <td style="width: 50%">
                        <div id="addUsrTool">
                        </div>
                        <div id="addUsrDiv">
                        </div>
                    </td>
                    <td style="width: 50%">
                        <div id="noUsrTool">
                        </div>
                        <div id="noUsrDiv">
                        </div>
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>
</asp:Content>
