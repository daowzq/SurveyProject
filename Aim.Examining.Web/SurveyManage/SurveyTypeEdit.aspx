<%@ Page Title="问卷类型" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="SurveyTypeEdit.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyTypeEdit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .aim-ui-td-data
        {
            width: 35%;
        }
        .aim-ui-td-caption
        {
            width: 15%;
        }
        fieldset
        {
            margin: 15px;
            width: 100%;
            padding: 1px;
            text-align: left;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .body
        {
            font-size: 12px;
        }
    </style>

    <script type="text/javascript">
        var SortIndex = $.getQueryString({ ID: 'SortIndex' });
        var storeAccess, gridAccess, storeSurvey, gridSurvey;
        // var nodeId=<%=nodeId%>
        //{ 员工满意度审批流程: "员工满意度审批流程", 离职调查审批流程: "离职调查审批流程" };
        //        window.onerror = function(sMessage, sUrl, sLine) {
        //            return true
        //        };
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            stateInit();    // 状态初始化
            girdRendere();  //grid 呈现
            FormValidationBind('btnSubmit', SuccessSubmit);
            $("#btnCancel").click(function() {
                window.close();
            });
        }


        //验证成功执行保存方法
        function SuccessSubmit() {
            $("#WorkFlowName  option").each(function() {
                if ($(this).attr("selected")) {
                    $("#WorkFlowId").val($(this).val());
                    $(this).val() && $(this).val($(this).text()); //过滤"请选择"项
                    //$("#WorkFlowName").text($(this).text());
                }
            })

            // $(".aim-ui-button").hide().wrap("<a class='aim-ui-button'>...</a>")

            var MustCheckFlow = $("#MustCheckFlow").attr("checked") ? "1" : "0";

            var resc = gridAccess.getStore().getRange();
            resc = storeAccess.getModifiedDataStringArr(resc);
            resc = "[" + resc.join(",") + "]";
            AimFrm.submit(pgAction, { AccessPower: resc, MustCheckFlow: MustCheckFlow }, null, SubFinish);

        }


        //状态初始化
        function stateInit() {
            (pgAction == "c" || pgAction == "create" || pgAction == "cs") && $("#SortIndex").val(SortIndex);  //SortIndex
            $("#WorkFlowName  option").each(function() {
                $(this).val() == $("#WorkFlowId").val() && $(this).attr("selected", true);
            })

            // !$("#MustCheckFlow").attr("checked") && $(".approve").hide();
            $("#MustCheckFlow").click(function() {
                if ($("#MustCheckFlow").attr("checked")) {
                    // $("#ApproveRoleName").attr("disabled", false)  //$(".approve").show();
                    $("#ApproveRoleName").removeAttr("disabled")

                } else {
                    $("#ApproveRoleName,#ApproveRoleId").val("");
                    $("#ApproveRoleName").attr("disabled", true)
                }
            });

        }

        //grid渲染
        function girdRendere() {
            //------------------------------Access权限------------------
            tlBar_dept = new Ext.Toolbar({
                renderTo: 'Access_bar',
                items: [
                { text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openOrgWin("gridAccess");
                    }
                },
               { text: '删除',
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
                records: eval("(" + (AimState["AccessList"] || "[]") + ")")
            };
            storeAccess = new Ext.ux.data.AimJsonStore({
                dsname: 'AccessList',
                idProperty: 'Id',
                data: myData1,
                fields: [
			      { name: 'Id' }, { name: 'Name' }, { name: 'Orgs' }, { name: 'OrgIds'}]
            });

            var txtField = new Ext.form.TextField({
                id: 'txtfiled',
                listeners: { focus: function(obj) {
                    // AimDlg.show(obj.value);

                    //默认该部门
                    var rec = storeAccess.getAt(gridAccess.activeEditor.row);
                    var par = "?ckId=" + (rec.get("OrgIds") || rec.get("Id"));
                    // var par = "?ckId=" + rec.get("OrgIds");

                    var style = "dialogWidth:360px; dialogHeight:390px; scroll:yes; center:yes; status:no; resizable:yes;";
                    var url = "/CommonPages/Select/CustomerSlt/MiddleOrgSlt.aspx" + par;

                    OpenModelWin(url, {}, style, function() {

                        var rtnData = this || ""; //1002 | 江苏飞力达国际物流股份有限公司
                        if (!rtnData) return;

                        var rec = storeAccess.getAt(gridAccess.activeEditor.row);
                        // if (rec) {

                        rtnData = rtnData.split(",");
                        var rtnDataArr = [];

                        for (var i = 0; i < rtnData.length; i++) {
                            rtnDataArr.push({ GroupID: rtnData[i].split("|")[0], Name: rtnData[i].split("|")[1] });
                        }

                        gridAccess.stopEditing();
                        var tempIds = "", tempNames = "";

                        for (var i = 0; i < rtnDataArr.length; i++) {
                            if (i > 0) {
                                tempIds += ",";
                                tempNames += ",";
                            }
                            tempIds += rtnDataArr[i]["GroupID"];
                            tempNames += rtnDataArr[i]["Name"];
                        }

                        rec.set("OrgIds", tempIds);
                        rec.set("Orgs", tempNames);
                        rec.commit();
                        // }
                    })
                }
                }
            });
            gridAccess = new Ext.ux.grid.AimEditorGridPanel({
                id: "gridAccess",
                store: storeAccess,
                //clicksToEdit: 2,
                height: 150,
                //autoHeight: true,
                renderTo: 'Access_div',
                autoExpandColumn: 'Name',
                columns: [
                     new Ext.ux.grid.AimRowNumberer(),
                     new Ext.grid.MultiSelectionModel(),
                     { id: 'Id', header: "Id", width: 100, dataIndex: 'Id', hidden: true },
                     { id: 'Name', header: "授权组织", dataIndex: 'Name', width: 200 }
                //             { id: 'Orgs', header: "发布范围", dataIndex: 'Orgs', editor: txtField }
                  ]
            });
        }

        function SubFinish(args) {
            //RefreshClose();
            window.returnValue = "true";  //  模态窗口
            window.close();
        }


        //组织结构选择
        function openOrgWin(gridSg) {
             
            var style = "dialogWidth:600px; dialogHeight:400px; scroll:yes; center:yes; status:no; resizable:yes;";
            // var url = "/CommonPages/Select/GrpSelect/MGrpSelect.aspx?seltype=multi&rtntype=array";
            //var url = "/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=multi&rtntype=array";
            var url = "/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=multi&nodeId=<%=nodeId%>";
             
            OpenModelWin(url, {}, style, function(rtn) {

                var gird = Ext.getCmp(gridSg);
                var EntRecord = gird.getStore().recordType;
                if (this.data == null || this.data.length == 0 || !this.data.length) return;
                for (var i = 0; i < this.data.length; i++) {
                    if (gird.getStore().find("Id", this.data[i].Id) != -1) continue; //筛选已经存在的人
                    var rec = new EntRecord({ Id: this.data[i].GroupID, Name: this.data[i].Name });
                    gird.getStore().insert(gird.getStore().data.length, rec);
                }


                //                var rtnData = this || ""; //1002 | 江苏飞力达国际物流股份有限公司
                //                if (!rtnData) return;

                //                rtnData = rtnData.split(",");
                //                var rtnDataArr = [];

                //                for (var i = 0; i < rtnData.length; i++) {
                //                    rtnDataArr.push({ GroupID: rtnData[i].split("|")[0], Name: rtnData[i].split("|")[1] });
                //                }


                //var gird = Ext.getCmp(gridSg);
                //var EntRecord = gird.getStore().recordType;
                //                for (var i = 0; i < rtnDataArr.length; i++) {
                //                    if (Ext.getCmp(gridSg).store.find("Id", rtnDataArr[i]["GroupID"]) != -1) continue; //筛选已经存在的部门
                //                    var rec = new EntRecord({ Id: rtnDataArr[i]["GroupID"], Name: rtnDataArr[i]["Name"], OrgIds: '', Orgs: '' });
                //                    gird.getStore().insert(gird.getStore().data.length, rec);
                //                }
                //  if (Ext.getCmp(gridSg).store.find("Id", rtnDataArr[0]["GroupID"]) != -1) continue; //筛选已经存在的部门

                //var rec = new EntRecord({ Id: rtnDataArr[0]["GroupID"], Name: rtnDataArr[0]["Name"], OrgIds: '', Orgs: '' });
                //gird.getStore().insert(gird.getStore().data.length, rec);
            })
        }

        window.onresize = function() {
            var width = $("#header").width() - 42;
            $("#Access_bar").width(0); $("#Access_bar").width((width));
            gridAccess.setWidth(0); gridAccess.setWidth((width));
        }
        function setval() {

        }
        
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            问卷类型</h1>
    </div>
    <div id="editDiv" align="center">
        <fieldset>
            <legend>基本信息</legend>
            <table class="aim-ui-table-edit">
                <tbody>
                    <tr style="display: none">
                        <td colspan="4">
                            <input id="Id" name="Id" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption" width="100">
                            类型名称
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input id="TypeName" name="TypeName" style="width: 88%" class="validate[required]" />
                        </td>
                        <!--                        <td class="aim-ui-td-caption">
                            类型编号
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="TypeCode" name="TypeCode" style="width: 70%" class="validate[required]" />
                        </td>-->
                    </tr>
                    <tr>
                        <%--  <td class="aim-ui-td-caption">
                            审批流程
                        </td>
                        <td>
                            <select id="WorkFlowName" name="WorkFlowName" aimctrl='select' enum='AimState["WFEnum"]'
                                style="width: 65%">
                            </select>&nbsp;
                            <input type="hidden" id="WorkFlowId" name="WorkFlowId" /><input type="checkbox" value="1"
                                name="MustCheckFlow" id="MustCheckFlow" />必须走流程
                        </td>--%>
                        <td class="aim-ui-td-caption">
                            是否走流程
                        </td>
                        <td>
                            <input type="checkbox" value="1" id="MustCheckFlow" name="MustCheckFlow" />是
                        </td>
                        <td class="aim-ui-td-caption">
                            审批最高层级
                        </td>
                        <td class="aim-ui-td-data">
                            <%-- <input id="ApproveRoleName" name="ApproveRoleName" popafter="setval" readonly="readonly"
                                aimctrl="popup" popurl="/CommonPages/Select/RolSelect/MRolSelect.aspx?seltype=multi"
                                popparam="ApproveRoleId:RoleID;ApproveRoleName:Name" popstyle="width=700,height=400"
                                style="width: 83%" />
                            <input id="ApproveRoleId" name="ApproveRoleId" style="width: 70%" type="hidden" />--%>
                            <select disabled id="ApproveRoleName" name="ApproveRoleName" aimctrl='select' enum="PostionType"
                                style="width: 70%">
                            </select>
                        </td>
                        <!--
                        <td class="aim-ui-td-caption">
                            排序序号
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="SortIndex" style="width: 70%" />
                        </td>
                        -->
                    </tr>
                    <!--  <tr>
                         <td class="aim-ui-td-caption">
                            审批流程
                        </td>
                        <td>
                            <select id="WorkFlowName" name="WorkFlowName" aimctrl='select' enum='AimState["WFEnum"]'
                                style="width: 65%">
                            </select>&nbsp;
                            <input type="hidden" id="WorkFlowId" name="WorkFlowId" /><input type="checkbox" value="1"
                                name="MustCheckFlow" id="MustCheckFlow" />必须走流程
                        </td> 
                    </tr>-->
                    <tr>
                        <td class="aim-ui-td-caption">
                            类型描述
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <textarea id="TypeDescribe" name="TypeDescribe" rows="4" style="width: 88%"></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            相关附件
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input type="hidden" id="AddFilesName" name="AddFilesName" style="width: 91.5%;"
                                aimctrl='file' />
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
        <fieldset id="gridContainer">
            <legend>权限配置项</legend>
            <table style="width: 100%; table-layout: fixed">
                <%--                <tr style="width: 100%">
                    <td>
                        <span style="font-family: 微软雅黑, 黑体,宋体, Verdana; font-size: 12px; font-weight: bold">
                            说明：</span> <span style="font-family: 微软雅黑, 黑体,宋体, Verdana; font-size: 12px; font-weight: normal">
                                组织名称为可访问该问卷类型的组织; 发布范围指问卷的散布范围，若不指定则默认为本组织内散布。 </span>
                    </td>
                </tr>--%>
                <tr>
                    <td style="width: 100%">
                        <div id="Access_bar">
                        </div>
                        <div id="Access_div">
                        </div>
                    </td>
                </tr>
            </table>
        </fieldset>
        <table class="aim-ui-table-edit">
            <tbody>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSubmit" class="aim-ui-button submit">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                            取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
