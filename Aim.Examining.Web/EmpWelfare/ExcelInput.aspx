<%@ Page Title="Excel导入" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="ExcelInput.aspx.cs" Inherits="Aim.Examining.Web.EmpWelfare.ExcelInput" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            /* 
            background: url(../theme/default/images/public/paperbg.jpg);
           */
            padding: '0px 10px 10px 0px';
        }
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
        .aim-ui-td-caption
        {
        }
        .aim-ui-td-data
        {
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        welfareEnum = { "": "请选择..", "员工配偶保险": "员工配偶保险",
            "员工旅游": "员工旅游", "员工体检": "员工体检", "妇女节福利": "妇女节福利"
        }
        function onPgLoad() {
            tlBar = new Ext.ux.AimToolbar({
                renderTo: 'btnBar',
                items: [{
                    id: 'btnSave',
                    text: '保存',
                    iconCls: 'aim-icon-save',
                    handler: function() {
                        var CouponCost = $("#CouponCost").val() || 0;
                        var MarryCheckCost = $("#MarryCheckCost").val() || 0;
                        var NoMarryCheckCost = $("#NoMarryCheckCost").val() || 0;
                        var CoupleAcceptUsrName = $("#CoupleAcceptUsrName").val() || 0;
                        var ChildAcceptName = $("#ChildAcceptName").val() || 0;
                        var Id = $("#Id").val() || 0;
                        var TravelAcceptUsrName = $("#TravelAcceptUsrName").val() || 0;
                        var HealthyAcceptUsrName = $("#HealthyAcceptUsrName").val() || 0;
                        var WomanAcceptUsrName = $("#WomanAcceptUsrName").val() || 0;

                        var CreateName = $("#CreateName").val() || 0;
                        var opt = $("#Id").val() ? "Update" : "Save";
                        AimFrm.submit(opt, {}, null, function(rtn) { //状态回写
                            $("#Id").val(rtn.data.Id);
                            $("#CouponCost").val(CouponCost);
                            $("#MarryCheckCost").val(MarryCheckCost);
                            $("#NoMarryCheckCost").val(NoMarryCheckCost);
                            $("#Id").val(Id);
                            $("#CoupleAcceptUsrName").val(CoupleAcceptUsrName);
                            $("#ChildAcceptName").val(ChildAcceptName);
                            $("#TravelAcceptUsrName").val(TravelAcceptUsrName);
                            $("#HealthyAcceptUsrName").val(HealthyAcceptUsrName);
                            $("#WomanAcceptUsrName").val(WomanAcceptUsrName);

                            Ext.getCmp("btnSave").setText("保存")
                            AimDlg.show("保存成功!");
                        });
                    }
}]
                });

                setPgUI();
            }




            function UsrSelect(rtn) {
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
            }



            function setPgUI() {

                $("#CreateName").val(AimState.UserInfo.Name);
                $("#btnFileAdd_AddFilesName").text("导入");

                //金额输入验证
                $("#CouponCost,#CouponCost,#MarryCheckCost,#NoMarryCheckCost").keyup(function(e) {
                    if ($(this).val().length > 6) {
                        $(this).val(($(this).val() + "").substring(0, 6));
                    }
                    $(this).val($(this).val().replace(/[^0-9.]/g, ''));
                })

            }

           
            
            
            
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            信息配置</h1>
    </div>
    <div id="btnBar" style="width: 100%">
    </div>
    <fieldset>
        <legend>申报受理人</legend>
        <table class="aim-ui-table-edit">
            <tbody>
                <tr>
                    <td class="aim-ui-td-caption">
                        员工配偶
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="CoupleAcceptUsrName" aimctrl='user' relateid="CoupleAcceptUsrId" name="CoupleAcceptUsrName"
                            class="validate[required]" />
                        <input id="CoupleAcceptUsrId" name="CoupleAcceptUsrId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        员工子女
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="ChildAcceptName" aimctrl='user' relateid="ChildAcceptUsrId" name="ChildAcceptName"
                            class="validate[required]" />
                        <input id="ChildAcceptUsrId" name="ChildAcceptUsrId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        员工旅游
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="TravelAcceptUsrName" aimctrl='user' relateid="TravelAcceptUsrId" name="TravelAcceptUsrName"
                            class="validate[required]" />
                        <input id="TravelAcceptUsrId" name="TravelAcceptUsrId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        员工体检
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="HealthyAcceptUsrName" aimctrl='user' relateid="HealthyAcceptUsrId" name="HealthyAcceptUsrName"
                            class="validate[required]" />
                        <input id="HealthyAcceptUsrId" name="HealthyAcceptUsrId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        妇女节福利
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="WomanAcceptUsrName" aimctrl='user' relateid="WomanAcceptUsrId" name="WomanAcceptUsrName"
                            class="validate[required]" />
                        <input id="WomanAcceptUsrId" name="WomanAcceptUsrId" type="hidden" />
                    </td>
                </tr>
            </tbody>
        </table>
    </fieldset>
    <fieldset>
        <legend>妇女节福利</legend>
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                    </td>
                </tr>
                <%--   <tr>
                    <td class="aim-ui-td-caption">
                        组织结构
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="Text2" name="CompanyName" readonly="readonly" aimctrl="popup" popurl="/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=single"
                            popparam="CompanyId:GroupID;CompanyName:Name" popstyle="width=320,height=400"
                            style="width: 45.3%" />
                        <input id="Hidden1" name="CompanyId" type="hidden" />
                    </td>
                </tr>--%>
                <tr>
                    <td class="aim-ui-td-caption">
                        购物券金额
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CouponCost" name="CouponCost" />&nbsp;<span style="color: Red">￥</span>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        已婚体检费用
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="MarryCheckCost" name="MarryCheckCost" />&nbsp;<span style="color: Red">￥</span>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        未婚体检费用
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="NoMarryCheckCost" name="NoMarryCheckCost" />&nbsp;<span style="color: Red">￥</span>
                    </td>
                </tr>
            </tbody>
        </table>
    </fieldset>
    <fieldset>
        <legend>EXCEL导入</legend>
        <div id="editDiv" align="center">
            <table class="aim-ui-table-edit">
                <tbody>
                    <tr>
                        <td class="aim-ui-td-caption">
                            模板
                        </td>
                        <td class="aim-ui-td-data">
                            <a href="#">员工体检格式.doc</a>
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            福利类型
                        </td>
                        <td class="aim-ui-td-data">
                            <select id="UserName" style="width: 17%" aimctrl='select' enum="welfareEnum" class="validate[required]">
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            日期
                        </td>
                        <td class="aim-ui-td-data">
                            <input id="StartTime" name="StartTime" style="width: 180;" class="Wdate validate[required]"
                                onfocus="var date=$('#EndTime').val()?$('#EndTime').val():'';                                             
				 WdatePicker({maxDate:date,minDate:'%y-%M-%d',dateFmt:'yyyy/MM/dd'})" />&nbsp;至&nbsp;
                            <input id="EndTime" name="EndTime" style="width: 180;" class="Wdate validate[required]"
                                onfocus="var date=$('#StartTime').val()?$('#StartTime').val():new Date();  
				WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            组织结构
                        </td>
                        <td class="aim-ui-td-data" colspan="3">
                            <input name="DeptName" id="DeptName" style="width: 45%" readonly="readonly" aimctrl="popup"
                                popurl="/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=multi" popparam="DeptId:GroupID;DeptName:Name"
                                popstyle="width=450,height=350" />
                            <input name="DeptId" id="DeptId" type="hidden" />
                        </td>
                    </tr>
                    <tr>
                        <td class="aim-ui-td-caption">
                            文件
                        </td>
                        <td class="aim-ui-td-data">
                            <input type="hidden" id="AddFilesName" name="AddFilesName" style="width: 50%;" aimctrl='file'
                                filter='(*.xlsx;*.xls)|*.xlsx;*.xls' />
                        </td>
                    </tr>
                    <%--                    <tr>
                        <td class="aim-ui-td-caption">
                            导入状态
                        </td>
                        <td class="aim-ui-td-data">
                            <textarea style="width: 48%;" rows="4" readonly="readonly"></textarea>
                        </td>
                    </tr>--%>
                    <tr width="100%">
                        <td class="aim-ui-td-caption">
                            录入人
                        </td>
                        <td class="aim-ui-td-data">
                            <input readonly="readonly" id="CreateName" name="CreateName" style="border: 0; border-bottom: 1 solid black;
                                background: rgb(242,242,242);" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </fieldset>
</asp:Content>
