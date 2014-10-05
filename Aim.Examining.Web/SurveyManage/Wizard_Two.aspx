<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="Wizard_Two.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Wizard_Two" %>

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

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        var SurveyId = $.getQueryString({ ID: "SurveyId" }); //SurveyId
        var type = $.getQueryString({ ID: "type" });  //操作状态
        var storeAccess, gridAccess, store2, gridNo;
        function onPgLoad() {
            setPgUI();
            stateInit();
        }

        function setPgUI() {
            gridRender(); // grid 呈现
        }

        //----------------提交事件处理-------------
        function doSubmit(successFun, failureFun) {
            if (typeof (successFun) != "function" || typeof (failureFun) != "function") return;
            successFun();
        }

        function SuccessSubmit(afterSaveFun) {
            //查看状态
            if (type == "view") {
                parent.afterSave.call(this, "2", "1");
                return;
            }

            var AddUserNames = storeAccess.getModifiedDataStringArr(storeAccess.getRange());
            var RemoveUserNames = store2.getModifiedDataStringArr(store2.getRange());
            AddUserNames = "[" + AddUserNames.join(",") + "]";
            RemoveUserNames = "[" + RemoveUserNames.join(",") + "]";


            var AgeRange = "";    //工作年限
            $(":checkbox:checked").each(function(i) {
                (i > 0) && (AgeRange += ",");
                AgeRange += $(this).val();
            })

            pgAction = $("#Id").val() ? "update" : "create";
            AimFrm.submit(pgAction, { AddUserNames: AddUserNames,
                RemoveUserNames: RemoveUserNames, AgeRange: AgeRange
            }, null, function(rtn) {//回调函数
                (pgAction == "create") && $("#Id").val(rtn.data.Id || '');

                //回写状态
                Ext.getCmp("addBtn1").setText("添加");
                Ext.getCmp("delBtn1").setText("删除");

                Ext.getCmp("addBtn2").setText("添加");
                Ext.getCmp("delBtn2").setText("删除");

                //* 注意赋值
                $("#AgeRange_18,#AgeRange_21,#AgeRange_31,#AgeRange_41,#AgeRange_50").each(function() {
                    (AgeRange.indexOf($(this).val()) > -1) && $(this).attr("checked", true);
                })
                // parent.afterSave.call(this, "2", "1");  //调用父 页面的方法
            });
        }

        //设置tip
        function setToolTip(selector, txt) {
            txt = txt || '必填项';
            if ($("#" + selector).next().next("span").length > 0) return;
            $("#" + selector).next().after("<span class='tip' >* " + txt + "</span>")
        }
        function clrToolTip(selector) {
            if ($("#" + selector).next("span").length > 0) {
                $("#" + selector).next("span").remove();
            }
        }


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
                height: 230,
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
                height: 230,
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

            //性别 初始化
            if ($("#Id").val()) {
                $(":radio[name='Sex']").each(function() {
                    if (AimState["frmdata"]["Sex"].toString().indexOf($(this).val()) > -1)
                        $(this).attr("checked", true);
                })
            } else {
                $("#SexAll").attr("checked", true); //"不限"
            }
            //工龄初始化
            if ($("#Id").val()) {
                $(":radio[name='WorkAge']").each(function() {
                    if (AimState["frmdata"]["WorkAge"].toString().indexOf($(this).val()) > -1)
                        $(this).attr("checked", true);
                })
            } else {
                $("#WorkAge_All").attr("checked", true); //员工工龄设置为不限
            }
            //年龄范围初始化
            if ($("#Id").val()) {
                $("#AgeRange_18,#AgeRange_21,#AgeRange_31,#AgeRange_41,#AgeRange_50").each(function() {
                    // AimState["frmdata"].hasOwnProperty("AgeRange")
                    (AimState["frmdata"]["AgeRange"].toString().indexOf($(this).val()) > -1) && $(this).attr("checked", true);
                })
            } else {
                $("#AgeRange_All").attr("checked", true).siblings().each(function() { $(this).attr("checked", false) });
            }

            $("#AgeRange_All").click(function() {
                if ($(this).attr("checked")) {
                    $("#AgeRange_18,#AgeRange_21,#AgeRange_31,#AgeRange_41,#AgeRange_50").each(function() {
                        $(this).attr("checked", false);
                    })
                }
            });
            $("#AgeRange_18,#AgeRange_21,#AgeRange_31,#AgeRange_41,#AgeRange_50").click(function() {
                $("#AgeRange_All").attr("checked", false);
            })

            //工作职位
            !$("#porPopup").length && $("[ctrl='popupWin2']").after("<a class='aim-ui-button' id='porPopup' \
             style='width: 20px; padding-right: 4px; padding-left: 4px;\
             margin-left: 5px; cursor: hand;'>...</a>").next().click(function() {
                 // Ext.getBody().mask("数据重新加载中，请稍等...");
                 var checkedId = $("#PostionIds").val();
                 var OrgIds = $("#OrgIds").val();

                 if (!OrgIds && !$("#PostionNames").val()) {
                     AimDlg.show("请选择组织!");
                     return;
                 }
                 var param = "&deptId=" + OrgIds;

                 var url = "/CommonPages/Select/CustomerSlt/PostionSelectView.aspx?seltype=multi" + param;
                 var style = "dialogWidth:430px; dialogHeight:450px; scroll:yes; center:yes; status:no; resizable:no;";
                 OpenModelWin(url, {}, style, function() {
                     //Ext.getBody().unmask();
                     
                     if (this.data == null || this.data.length == 0 || !this.data.length) {
                         $("#PostionNames,#PostionIds").val("");
                         return;
                     }
                     $("#PostionNames,#PostionIds").val("");
                     var temp = "", tempName = "";
                     for (var i = 0; i < this.data.length; i++) {
                         if (i > 0) {
                             temp += ",";
                             tempName += ",";
                         }
                         temp += this.data[i]["Id"];
                         tempName += this.data[i]["Name"];
                     }
                     $("#PostionNames").val(tempName);
                     $("#PostionIds").val(temp);
                 })

             });
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


        //组织结构选择
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

            var OrgIds = $("#OrgIds").val();
            var PostionNames = escape($("#PostionNames").val());
            var Sex = $("input[name='Sex'][checked]").val();
            var WorkAge = $(":radio[name='WorkAge']:checked").val();
            var temp = "";
            var AgeRange = $(":checkbox[name='AgeRange']:checked").each(function(i) {
                if (i > 0) temp += ",";
                temp += $(this).val();
            })
            //入职日期
            var StartWorkTime = $("#StartWorkTime").val();
            var UntileWorkTime = $("#UntileWorkTime").val();
            var url = "OrgIds=" + OrgIds + "&PostionNames=" + PostionNames + "&Sex=" + Sex + "&AgeRange=" + temp + "&StartWorkTime=" + StartWorkTime + "&WorkAge=" + WorkAge + "&UntileWorkTime=" + UntileWorkTime;

            return url;
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            调查对象</h1>
    </div>
    <div id="editDiv" align="center">
        <fieldset>
            <legend>基本信息</legend>
            <table class="aim-ui-table-edit" style="margin: 2px 2px">
                <tbody>
                    <tr style="display: none">
                        <td colspan="4">
                            <input id="Id" name="Id" />
                            <input id="SurveyId" name="SurveyId" />
                        </td>
                    </tr>
                    <tr>
                        <%--                        <td class="aim-ui-td-caption">
                            组织机构
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input name="OrgNames" id="OrgNames" style="width: 85%" readonly="readonly" ctrl="popupWin1" />
                            <input name="OrgIds" id="OrgIds" type="hidden" />
                        </td>--%>
                        <td class="aim-ui-td-caption">
                            组织机构
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input name="OrgNames" id="OrgNames" style="width: 85%" readonly="readonly" aimctrl='popup'
                                aimctrl="popup" popurl="/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=multi&nodeId=<%=nodeId%>"
                                popparam="OrgIds:GroupID;OrgNames:Name" popstyle="width=540,height=450" />
                            <input name="OrgIds" id="OrgIds" type="hidden" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            工作职位
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input id="PostionNames" name="PostionNames" style="width: 85%" ctrl='popupWin2'
                                readonly="readonly" />
                            <input id="PostionIds" name="PostionIds" type="hidden" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            入职时间
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="StartWorkTime" readonly="readonly" name="StartWorkTime" class="Wdate"
                                style="width: 40%" onclick=" WdatePicker({dateFmt:'yyyy/MM/dd'})" />
                            &nbsp;至&nbsp;<input id="UntileWorkTime" readonly="readonly" name="UntileWorkTime"
                                class="Wdate" style="width: 40%" onclick=" var date=$('#StartWorkTime').val()?$('#StartWorkTime').val():new Date();  
				WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" />
                        </td>
                        <td class="aim-ui-td-caption">
                            性别
                        </td>
                        <td class="aim-ui-td-data" style="width: 25%">
                            <input type="radio" name="Sex" id="SexAll" />
                            不限&nbsp;&nbsp;
                            <input type="radio" name="Sex" value="man" id="SexMan" />男&nbsp;
                            <input type="radio" name="Sex" value="woman" id="SexWoman" />女&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            年龄范围
                        </td>
                        <td style="width: 28%">
                            <table style="font-size: 12px;">
                                <tr>
                                    <td>
                                        <input id="AgeRange_All" name="AgeRange" type="checkbox" value="0" />
                                        不限
                                    </td>
                                    <td>
                                        <input id="AgeRange_18" name="AgeRange" type="checkbox" value="18-20" />
                                        18-20
                                    </td>
                                    <td>
                                        <input id="AgeRange_21" name="AgeRange" type="checkbox" value="21-30" />
                                        21-30
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input id="AgeRange_31" name="AgeRange" type="checkbox" value="31-40" />
                                        31-40
                                    </td>
                                    <td>
                                        <input id="AgeRange_41" name="AgeRange" type="checkbox" value="41-50" />
                                        41-50
                                    </td>
                                    <td>
                                        <input id="AgeRange_50" name="AgeRange" type="checkbox" value=">50" />
                                        50以上
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td class="aim-ui-td-caption">
                            资深员工
                        </td>
                        <td>
                            <input id="WorkAge_All" name="WorkAge" type="radio" value="0" />
                            不限
                            <input id="WorkAge_3" name="WorkAge" type="radio" value=">3" />
                            3年以上
                            <input id="WorkAge_5" name="WorkAge" type="radio" value=">5" />
                            5年以上
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
