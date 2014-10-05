<%@ Page Title="员工配偶保险" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="UsrDoubleWelfareEdit.aspx.cs" Inherits="Aim.Examining.Web.UsrDoubleWelfareEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        fieldset
        {
            margin: 15px;
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
        var InFlow = $.getQueryString({ ID: "InFlow" });
        var LinkView = $.getQueryString({ ID: "LinkView" });
        var id = $.getQueryString({ ID: "id" });
        var op = $.getQueryString({ ID: "op" });
        function onPgLoad() {

            sumitForm();
            setPgUI();
            if (window.parent.AimState["Task"]) {
                taskName = window.parent.AimState["Task"].ApprovalNodeName;
            }
            if (InFlow == "T" || LinkView == "T") {
                IniOpinion();
            }


            if ($.getQueryString({ ID: "userid" })) {
                $("#btnSubmit").hide();
            }



            if (AimState.frmdata) {
                if (AimState.frmdata.NoticeId) {
                    $("#submitBar").hide();
                }
            }


        }

        function setPgUI() {

            stateInit();

            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        //获取用户信息设置状态
        function UsrSelect(rtn) {
            // rtn.data.Name
            var UserID = rtn.data.UserID;
            if (op == "c") {
                UserID && $.ajaxExec("GetWorkNo", { UserID: UserID }, function(rtn) {
                    var Sex = rtn.data.WorkNo.split("|")[1];
                    var WorkNo = rtn.data.WorkNo.split("|")[0];
                    var IndutyData = rtn.data.WorkNo.split("|")[2];
                    rtn.data.WorkNo && $("#WorkNo").val(WorkNo);
                    $("#IndutyData").val(IndutyData);
                    if (Sex == "男") {
                        $("#man").attr("checked", true);
                        $("#SexW").attr("checked", true);
                    } else {
                        $("#woman").attr("checked", true);
                        $("#SexM").attr("checked", true);
                    }
                });
            }

        }

        //pg状态
        function stateInit() {
            //隐藏提交按钮
            if (op == "r" || op == "reader") {
                $("#submit").hide();
            }
            //身份号码 输入验证
            $("#IdentityCard").change(function() {
                if ($(this).val().length > 18) {
                    $(this).val(($(this).val() + "").substring(0, 18));
                }

            }).keyup(function(e) {
                $(this).val((/[0-9]{1,}[xX]?/g).test($(this).val() || "") ? $(this).val() : "");
            })

            $("#OtherIdentityCard").change(function() {
                if ($(this).val().length > 18) {
                    $(this).val(($(this).val() + "").substring(0, 18));
                }
            }).keyup(function(e) {
                $(this).val((/[0-9]{1,}[xX]?/g).test($(this).val() || "") ? $(this).val() : "");
            })

            //性别
            var Sex = $("#Sex").val();
            if (Sex == "男") {
                $("#man").attr("checked", true);
                $("#SexW").attr("checked", true)
            } else {
                $("#woman").attr("checked", true);
                $("#SexM").attr("checked", true)
            }



            $("#UserId").bind("input propertychange", function() {

                var id = $(this).val();
                if (id.length != 0) {
                    $.ajaxExec("GetWorkNo", { UserID: id }, function(rtn) {
                        var Sex = rtn.data.WorkNo.split("|")[1];
                        var WorkNo = rtn.data.WorkNo.split("|")[0];
                        var IndutyData = rtn.data.WorkNo.split("|")[2];
                        rtn.data.WorkNo && $("#WorkNo").val(WorkNo);
                        $("#IndutyData").val(IndutyData);
                        if (Sex == "男") {
                            $("#man").attr("checked", true);
                            $("#SexW").attr("checked", true);
                        } else {
                            $("#woman").attr("checked", true);
                            $("#SexM").attr("checked", true);
                        }
                    });
                }
            });


        }
        //暂存
        function SuccessSubmit() {
            //isIDCard2 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{4}$/
            //if ($("#IdentityCard").val() && !isIDCard2.test($("#IdentityCard").val())) {
            //    AimDlg.show("身份证号码不合法!");
            //    return;
            //}
            //if ($("#OtherIdentityCard").val() && !isIDCard2.test($("#OtherIdentityCard").val())) {
            //    AimDlg.show("身份证号码不合法!");
            //    return;
            // }
            // NSSFNo1  Sex1

            var sex = $("#man").attr("checked") ? "男" : "女";
            var mss = $("#SexM").attr("checked") ? "男" : "女";
            $("#NSSFNo").val(mss);  //配偶性别
            $("#Sex").val(sex);

            AimFrm.submit(pgAction, {}, null, SubFinish);

        }


        //提交流程  ------------------------------------------------
        function sumitForm() {
            //提交审批
            $("#submit").click(function() {


                //--判定是否在通知范围内
                var valida = true;
                $.ajaxExecSync("ckNotice", { Id: $("#Id").val() }, function(rtn) {
                    if (!rtn.data.State) {
                        AimDlg.show("请在通知的时间范围内申报!");
                        valida = false;
                    }
                });
                if (!valida) return;
                //-----------------------

                var sex = $("#man").attr("checked") ? "男" : "女";
                var mss = $("#SexM").attr("checked") ? "男" : "女";
                $("#NSSFNo").val(mss);
                $("#Sex").val(sex);

                if (!$("#ApproveUserId").val()) {
                    AimDlg.show("系统取不到审批人,请配置审批人!");
                    return;
                }

                if (confirm("确认提交申请？")) {
                    Ext.getBody().mask("提交中,请稍后...");
                    AimFrm.submit("Submit", { id: id }, null, AutoExecuteFlow);
                }

            });


        }

        //下一节点流程
        function AutoExecuteFlow(rtn) {
            var NextInfo = rtn.data.NextInfo;
            var task = new Ext.util.DelayedTask();
            task.delay(800, function() {
                jQuery.ajaxExec('AutoExecuteFlow', { NextInfo: NextInfo }, function(rtn) {
                    Ext.getBody().unmask();
                    AimDlg.show("提交成功！");
                    SubFinish();
                });
            });
        }
        function IniOpinion() {

            var tab = document.getElementById("tbOpinion");
            var myData = AimState["Opinion"] || [];
            if (AimState["Opinion"] && AimState["Opinion"].length > 0) {
                $("#examfield").show();
                for (var i = 1; i < myData.length; i++) {//从1开始 是为了不显示自动提交的任务
                    var tr = tab.insertRow(); tr.height = 32;
                    var td = tr.insertCell();
                    td.innerHTML = myData[i].ApprovalNodeName ? myData[i].ApprovalNodeName + "意见" : '';
                    td.rowSpan = 2;
                    td.className = "aim-ui-td-caption";
                    td.style.width = "25%";
                    td.style.textAlign = "right";
                    var td = tr.insertCell();
                    var Description = myData[i].Description ? myData[i].Description : '';
                    td.innerHTML = '<textarea rows="2" disabled style="width: 97%;">' + Description + '</textarea>';
                    td.colSpan = 6;
                    var tr = tab.insertRow();
                    var td = tr.insertCell();
                    td.innerHTML = '审批结果:';
                    td.style.width = "100px";
                    var td = tr.insertCell();
                    //不同意,打回,拒绝,退回  如果包含上述文字。结果就是不同意。否则就是同意 
                    if (myData[i].Result && (myData[i].Result.indexOf("不同意") >= 0 || myData[i].Result.indexOf("打回") >= 0 || myData[i].Result.indexOf("拒绝") >= 0) || myData[i].Result.indexOf("退回") >= 0) {
                        td.innerHTML = "不同意";
                    }
                    else {
                        td.innerHTML = "同意";
                    }
                    td.style.textDecoration = "underline";
                    var td = tr.insertCell(); td.innerHTML = '签名:';
                    var td = tr.insertCell();
                    td.innerHTML = '<img style="width: 70px; height: 25px;" src="/CommonPages/File/DownLoadSign.aspx?UserId=' + myData[i].OwnerId + '" />';
                    var td = tr.insertCell(); td.innerHTML = '审批时间:';
                    var td = tr.insertCell();
                    td.innerHTML = myData[i].FinishTime ? myData[i].FinishTime : '';
                    td.style.textDecoration = "underline";
                }
            }
            if (LinkView != "T") {
                $("#examfield").show();
                var tr = tab.insertRow(); tr.height = 32; var td = tr.insertCell();
                td.innerHTML = taskName + "意见";
                td.className = "aim-ui-td-caption";
                td.style.width = "25%"; td.style.textAlign = "right"; var td = tr.insertCell();
                td.innerHTML = '<textarea id="TaskNameOpinion" name="TaskNameOpinion" style="width: 97%;background-color:rgb(254, 255, 187)"  rows="2"></textarea>';
                td.colSpan = 6;
                if (AimState["UnSubmitOpinion"]) {
                    $("#TaskNameOpinion").val(AimState["UnSubmitOpinion"]);
                }
            }
        }
        //-----------------------------------------------

        function SubFinish(args) {
            RefreshClose();
        }
    </script>

    <script language="javascript" type="text/javascript">
        //保存流程和提交流程时触发
        function onSave(task) {
            //SuccessSubmit
            if (window.parent.document.getElementById("textOpinion")) {
                window.parent.document.getElementById("textOpinion").value = $("#TaskNameOpinion").val() ? $("#TaskNameOpinion").val() : "";
            }
        }
        //提交流程时触发
        function onSubmit(task) {
            if ($("#TaskNameOpinion").css("display") == "inline" && !$("#TaskNameOpinion").val()) {
                AimDlg.show("提交时必须填写审批意见！");
                return false;
            }
        }
        function onGiveUsers(nextName) {        //在此处理选人
            var users = { UserIds: "", UserNames: "" };
            $.ajaxExecSync("GetNextUsers", { taskName: taskName, id: id, nextName: nextName }, function(rtn) {
                if (rtn.data.NextUsers["nextUserId"]) {
                    users.UserIds = rtn.data.NextUsers["nextUserId"];
                    users.UserNames = rtn.data.NextUsers["nextUserName"];
                }
            });

            return users;
        }

        //流程结束时触发
        function onFinish(task) {
            jQuery.ajaxExec('submitfinish', { id: id, ApproveResult: window.parent.document.getElementById("id_SubmitState").value
            }, function() {
                RefreshClose();
            });
        }
        
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            员工配偶保险</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                        <input id="ApproveName" name="ApproveName" />
                        <input id="ApproveUserId" name="ApproveUserId" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        申请人
                    </td>
                    <td class="aim-ui-td-data" style="width: 35%">
                        <%-- <input id="UserName" aimctrl='user' relateid="UserId" popafter="UsrSelect" name="UserName"
                            class="validate[required]" />--%>
                        <input id="UserName" aimctrl='user' relateid="UserId" name="UserName" class="validate[required]" />
                        <input id="UserId" name="UserId" type="hidden" />
                    </td>
                    <td class="aim-ui-td-caption">
                        工号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="WorkNo" name="WorkNo" readonly="readonly" style="width: 89.5%" />&nbsp;
                    </td>
                </tr>
                <tr style="display: none">
                    <td class="aim-ui-td-caption">
                        性别
                    </td>
                    <td class="aim-ui-td-data">
                        <input type="radio" name="Sex1" id="man" value="男" />男
                        <input type="radio" name="Sex1" id="woman" value="女" />
                        女
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        身份证号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="IdentityCard" name="IdentityCard" style="width: 90%" />
                    </td>
                    <td class="aim-ui-td-caption">
                        入职日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="IndutyData" name="IndutyData" disabled="disabled" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy/MM/dd'})"
                            style="width: 89.5%" />
                        <%--    <input id="IndutyData" name="IndutyData" style="width: 89.5%" />--%>
                    </td>
                </tr>
                <!-- <tr>
                   <td class="aim-ui-td-caption">
                        审批人
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="ApproveName" aimctrl='user' relateid="ApproveUserId" name="ApproveName"
                            class="validate[required]" />
                        <input id="ApproveUserId" name="ApproveUserId" type="hidden" />
                    </td>
                </tr>-->
                <tr>
                    <td class="aim-ui-td-caption">
                        公司名称
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="CompanyName" name="CompanyName" readonly="readonly" style="width: 95%"
                            style="width: 150px" />
                        <input type="hidden" id="CompanyId" name="CompanyId" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        一级部门
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="DeptName" name="DeptName" readonly="readonly" style="width: 95%" />
                        <input id="DeptId" name="DeptId" type="hidden" />
                    </td>
                </tr>
                <tr>
                    <td colspan="5">
                        <span style="border: 0; border-bottom: solid 1px gray;"></span>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        配偶姓名
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="OtherUserName" name="OtherUserName" class="validate[required]" style="width: 89.5%" />
                    </td>
                    <td class="aim-ui-td-caption">
                        配偶身份证号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="OtherIdentityCard" name="OtherIdentityCard" style="width: 87%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        性别
                    </td>
                    <td class="aim-ui-td-data">
                        <input type="radio" name="NSSFNo1" id="SexM" value="男" />男
                        <input type="radio" name="NSSFNo1" id="SexW" value="女" />
                        女
                        <%--            <input id="NSSFNo" name="NSSFNo" style="width: 89%" />--%>
                    </td>
                </tr>
                <tr>
                    <td colspan="5">
                        <span style="border: 0; border-bottom: solid 1px gray;"></span>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        申请原因
                    </td>
                    <td class="aim-ui-td-data" colspan="4">
                        <textarea name="Reason" id="Reason" rows="4" style="width: 95.5%"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        附件
                    </td>
                    <td class="aim-ui-td-data" colspan="4">
                        <input type="hidden" id="AddFiles" name="AddFiles" aimctrl='file' style="width: 98%"
                            mode="single" filter='(*.docx;*.doc;*.xls)|*.docx;*.doc;*.xls' />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="submit" class="aim-ui-button">提交</a> <a id="btnSubmit" class="aim-ui-button submit">
                            暂存</a> <a id="btnCancel" class="aim-ui-button cancel">取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <fieldset id="examfield" style="display: none">
        <legend>审批意见区</legend>
        <table width="100%" id="tbOpinion" style="font-size: 12px; border: none;" class="aim-ui-table-edit">
        </table>
    </fieldset>
    <input type="hidden" name="Sex" id="Sex" />
    <input type="hidden" name="NSSFNo" id="NSSFNo" />
</asp:Content>
