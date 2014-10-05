<%@ Page Title="福利申报通知" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="UseWelfareNoteEdit.aspx.cs" Inherits="Aim.Examining.Web.UseWelfareNoteEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #F2F2F2;
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
        .x-panel-body x-form
        {
            height: 0px;
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript" language="JScript" src="/js/fckeditor/fckeditor.js"></script>

    <script type="text/javascript">
        var id = $.getQueryString({ ID: 'id' }) || '';
        var op = $.getQueryString({ ID: 'op' }) || '';
        var type = $.getQueryString({ ID: 'type' }) || '';
        var InFlow = $.getQueryString({ ID: "InFlow" });
        var LinkView = $.getQueryString({ ID: "LinkView" });
        var ThingsType = { "": "请选择...", "员工旅游": '员工旅游', "员工配偶保险": "员工配偶保险", "三八妇女节": "三八妇女节" };

        function onPgLoad() {
            setPgUI();
            if (window.parent.AimState["Task"]) {
                taskName = window.parent.AimState["Task"].ApprovalNodeName;
            }
            if (InFlow == "T" || LinkView == "T") {
                IniOpinion();
            }
        }

        function setPgUI() {
            if (!!AimState['frmdata']) {
                $("input[name='NoticeWay']").each(function() {
                    if (AimState['frmdata']["NoticeWay"])
                        AimState['frmdata']["NoticeWay"].indexOf($(this).val()) > -1 && $(this).attr("checked", true)
                });
            }
            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        //验证成功执行保存方法
        function SuccessSubmit() {

            var noteWay = "";
            $("input[name='NoticeWay']:checked").each(function(i) {
                if (i > 0) noteWay += ",";
                noteWay += $(this).val();
            });

            AimFrm.submit(pgAction, { NoticeWay: noteWay }, null, SubFinish);
        }

        function SubFinish(args) {
            // RefreshClose();
            window.returnValue = "true";  //  模态窗口
            window.close();
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
        function onGiveUsers(nextName) {
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


        //获取组织机构
        function GetOrg(rtn) {

            if ($.isEmptyObject(rtn)) {
                $("#DeptName").val("");
                $("#DeptId").val("");
                return;
            }
            var orgArr = rtn.GroupID.split(",");
            var orgArrName = rtn.Name.split(",");

            var result = "";
            for (var i = 0; i < orgArr.length; i++) {
                if (i > 0) result += ",";
                if ((orgArrName[i] + "").indexOf("公司") > -1) {
                    result += orgArrName[i];
                } else {
                    $.ajaxExecSync("GetAllPath", { GroupID: orgArr[i] }, function(rtn) {
                        if (rtn.data.State) {
                            result += rtn.data.State;
                        }
                    }, null, "/SurveyManage/Comman.aspx");
                }
            }
            $("#DeptName").val(result);
            $("#DeptId").val(rtn.GroupID);
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            福利申报通知</h1>
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
                        类型
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="TypeName" name="TypeName" class="validate[required]" aimctrl='select'
                            enum="ThingsType" style="width: 70%">
                    </td>
                    <td class="aim-ui-td-caption">
                        编号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Code" name="Code" style="width: 87%" readonly="readonly" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        通知标题
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="Title" name="Title" class="validate[required]" style="width: 95%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        开始日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="StartTime" name="StartTime" class="Wdate" onfocus="var date=$('#EndTime').val()?$('#EndTime').val():'';                                             
                         WdatePicker({maxDate:date,minDate:new Date(),dateFmt:'yyyy/MM/dd'})" style="width: 180px" />
                    </td>
                    <td class="aim-ui-td-caption">
                        结束日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="EndTime" name="EndTime" class="Wdate" onfocus="var date=$('#StartTime').val()?$('#StartTime').val():new Date();  
				WdatePicker({minDate:date,dateFmt:'yyyy/MM/dd'})" style="width: 180px" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        通知对象
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="DeptName" name="DeptName" readonly="readonly" style="width: 90.5%" aimctrl="popup"
                            popurl="/CommonPages/Select/CustomerSlt/MiddleOrgView.aspx?seltype=multi&popmode=myPop&nodeId=<%=nodeId%>"
                            popparam="DeptId:GroupID;DeptName:Name" popstyle="dialogWidth:540px; dialogHeight:450px; scroll:yes; center:yes; status:no; resizable:no;"
                            afterpopup="GetOrg" popmode='myPop' style="width: 150px" />
                        <input type="hidden" id="DeptId" name="DeptId" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        通知方式
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input type="checkbox" name="NoticeWay" id="Email" value="Email" />邮件
                        <input type="checkbox" name="NoticeWay" id="Message" value="Message" />短信
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        通知内容
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Condition" name="Condition" aimctrl="editor" style="width: 95%; height: 220px;"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        相关附件
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input type="hidden" id="AddFiles" name="AddFiles" aimctrl='file' filter='(*.docx;*.doc;*.xls)|*.docx;*.doc;*.xls' />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSubmit" class="aim-ui-button submit">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                            取消</a>
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
</asp:Content>
