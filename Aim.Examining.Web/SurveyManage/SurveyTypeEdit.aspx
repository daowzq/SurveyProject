<%@ Page Title="�ʾ�����" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
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
        //{ Ա���������������: "Ա���������������", ��ְ������������: "��ְ������������" };
        //        window.onerror = function(sMessage, sUrl, sLine) {
        //            return true
        //        };
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            stateInit();    // ״̬��ʼ��
            girdRendere();  //grid ����
            FormValidationBind('btnSubmit', SuccessSubmit);
            $("#btnCancel").click(function() {
                window.close();
            });
        }


        //��֤�ɹ�ִ�б��淽��
        function SuccessSubmit() {
            $("#WorkFlowName  option").each(function() {
                if ($(this).attr("selected")) {
                    $("#WorkFlowId").val($(this).val());
                    $(this).val() && $(this).val($(this).text()); //����"��ѡ��"��
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


        //״̬��ʼ��
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

        //grid��Ⱦ
        function girdRendere() {
            //------------------------------AccessȨ��------------------
            tlBar_dept = new Ext.Toolbar({
                renderTo: 'Access_bar',
                items: [
                { text: '���',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openOrgWin("gridAccess");
                    }
                },
               { text: 'ɾ��',
                   iconCls: 'aim-icon-delete',
                   handler: function() {
                       var recs = gridAccess.getSelectionModel().getSelections();
                       if (!recs || recs.length <= 0) {
                           AimDlg.show("����ѡ��Ҫɾ���ļ�¼��");
                           return;
                       }
                       if (confirm("ȷ��ɾ����ѡ��¼��")) {
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

                    //Ĭ�ϸò���
                    var rec = storeAccess.getAt(gridAccess.activeEditor.row);
                    var par = "?ckId=" + (rec.get("OrgIds") || rec.get("Id"));
                    // var par = "?ckId=" + rec.get("OrgIds");

                    var style = "dialogWidth:360px; dialogHeight:390px; scroll:yes; center:yes; status:no; resizable:yes;";
                    var url = "/CommonPages/Select/CustomerSlt/MiddleOrgSlt.aspx" + par;

                    OpenModelWin(url, {}, style, function() {

                        var rtnData = this || ""; //1002 | ���շ�������������ɷ����޹�˾
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
                     { id: 'Name', header: "��Ȩ��֯", dataIndex: 'Name', width: 200 }
                //             { id: 'Orgs', header: "������Χ", dataIndex: 'Orgs', editor: txtField }
                  ]
            });
        }

        function SubFinish(args) {
            //RefreshClose();
            window.returnValue = "true";  //  ģ̬����
            window.close();
        }


        //��֯�ṹѡ��
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
                    if (gird.getStore().find("Id", this.data[i].Id) != -1) continue; //ɸѡ�Ѿ����ڵ���
                    var rec = new EntRecord({ Id: this.data[i].GroupID, Name: this.data[i].Name });
                    gird.getStore().insert(gird.getStore().data.length, rec);
                }


                //                var rtnData = this || ""; //1002 | ���շ�������������ɷ����޹�˾
                //                if (!rtnData) return;

                //                rtnData = rtnData.split(",");
                //                var rtnDataArr = [];

                //                for (var i = 0; i < rtnData.length; i++) {
                //                    rtnDataArr.push({ GroupID: rtnData[i].split("|")[0], Name: rtnData[i].split("|")[1] });
                //                }


                //var gird = Ext.getCmp(gridSg);
                //var EntRecord = gird.getStore().recordType;
                //                for (var i = 0; i < rtnDataArr.length; i++) {
                //                    if (Ext.getCmp(gridSg).store.find("Id", rtnDataArr[i]["GroupID"]) != -1) continue; //ɸѡ�Ѿ����ڵĲ���
                //                    var rec = new EntRecord({ Id: rtnDataArr[i]["GroupID"], Name: rtnDataArr[i]["Name"], OrgIds: '', Orgs: '' });
                //                    gird.getStore().insert(gird.getStore().data.length, rec);
                //                }
                //  if (Ext.getCmp(gridSg).store.find("Id", rtnDataArr[0]["GroupID"]) != -1) continue; //ɸѡ�Ѿ����ڵĲ���

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
            �ʾ�����</h1>
    </div>
    <div id="editDiv" align="center">
        <fieldset>
            <legend>������Ϣ</legend>
            <table class="aim-ui-table-edit">
                <tbody>
                    <tr style="display: none">
                        <td colspan="4">
                            <input id="Id" name="Id" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption" width="100">
                            ��������
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input id="TypeName" name="TypeName" style="width: 88%" class="validate[required]" />
                        </td>
                        <!--                        <td class="aim-ui-td-caption">
                            ���ͱ��
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="TypeCode" name="TypeCode" style="width: 70%" class="validate[required]" />
                        </td>-->
                    </tr>
                    <tr>
                        <%--  <td class="aim-ui-td-caption">
                            ��������
                        </td>
                        <td>
                            <select id="WorkFlowName" name="WorkFlowName" aimctrl='select' enum='AimState["WFEnum"]'
                                style="width: 65%">
                            </select>&nbsp;
                            <input type="hidden" id="WorkFlowId" name="WorkFlowId" /><input type="checkbox" value="1"
                                name="MustCheckFlow" id="MustCheckFlow" />����������
                        </td>--%>
                        <td class="aim-ui-td-caption">
                            �Ƿ�������
                        </td>
                        <td>
                            <input type="checkbox" value="1" id="MustCheckFlow" name="MustCheckFlow" />��
                        </td>
                        <td class="aim-ui-td-caption">
                            ������߲㼶
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
                            �������
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="SortIndex" style="width: 70%" />
                        </td>
                        -->
                    </tr>
                    <!--  <tr>
                         <td class="aim-ui-td-caption">
                            ��������
                        </td>
                        <td>
                            <select id="WorkFlowName" name="WorkFlowName" aimctrl='select' enum='AimState["WFEnum"]'
                                style="width: 65%">
                            </select>&nbsp;
                            <input type="hidden" id="WorkFlowId" name="WorkFlowId" /><input type="checkbox" value="1"
                                name="MustCheckFlow" id="MustCheckFlow" />����������
                        </td> 
                    </tr>-->
                    <tr>
                        <td class="aim-ui-td-caption">
                            ��������
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <textarea id="TypeDescribe" name="TypeDescribe" rows="4" style="width: 88%"></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            ��ظ���
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
            <legend>Ȩ��������</legend>
            <table style="width: 100%; table-layout: fixed">
                <%--                <tr style="width: 100%">
                    <td>
                        <span style="font-family: ΢���ź�, ����,����, Verdana; font-size: 12px; font-weight: bold">
                            ˵����</span> <span style="font-family: ΢���ź�, ����,����, Verdana; font-size: 12px; font-weight: normal">
                                ��֯����Ϊ�ɷ��ʸ��ʾ����͵���֯; ������Χָ�ʾ��ɢ����Χ������ָ����Ĭ��Ϊ����֯��ɢ���� </span>
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
                        <a id="btnSubmit" class="aim-ui-button submit">����</a> <a id="btnCancel" class="aim-ui-button cancel">
                            ȡ��</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
