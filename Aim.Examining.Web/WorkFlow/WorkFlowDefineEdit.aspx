<%@ Page Title="流程维护" Language="C#" ValidateRequest="false" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true" CodeBehind="WorkFlowDefineEdit.aspx.cs" Inherits="Aim.Portal.Web.WorkFlow.WorkFlowDefineEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EnumType = { 0: "Developing", 1: "Testing", 2: "Deployed", 3: "Offline", 4: "Online" };
        EnumTypeVersion = { 1: 1.0, 2: 2.0, 3: 3.0, 4: 4.0 };
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c" || pgOperation == "cs") {
                $("#PrjCode").val(AimState.PrjCode);
                $("#PrjName").val(AimState.PrjName);
                
                $("#CreateName").val(AimState.CreateName);
                $("#CreateTime").val(AimState.CreateTime);
            }
            
            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);
        }

        function SubFinish(args) {
            RefreshClose();
        }

        /**********************************************WorkFlow Function Start**************************/
        var permission = {};
        //这里依次统一添加各环节的控件权限
        permission.确认发布内容 = { ReadOnly: "Title,KeyWord,Content", Hidden: "" };
        permission.审批人审批 = { ReadOnly: "Title,KeyWord", Hidden: "" };

        function InitUIForFlow() {
            $("#btnSubmit").hide();
            $("#btnCancel").hide();

            var taskName = window.parent.AimState["Task"].ApprovalNodeName;
            ///控制下一步路由
            if (taskName == "确认发布内容") {
                //SetRoute("公司领导",true);//第一个参数为下一步路由,第二个参数为是否禁止重新选择路由
            }

            if (eval("permission." + taskName)) {
                //只读
                var read = eval("permission." + taskName).ReadOnly;
                for (var i = 0; i < read.split(',').length; i++) {
                    var id = read.split(',')[i];
                    if (document.getElementById(id))
                        document.getElementById(id).readOnly = true;
                }
                //隐藏
                var vis = eval("permission." + taskName).Hidden;
                for (var i = 0; i < vis.split(',').length; i++) {
                    var id = vis.split(',')[i];
                    if (document.getElementById(id))
                        document.getElementById(id).style.display = "none";
                }
            }
        }
        //保存流程和提交流程时触发
        function onSave(task) {
            AimFrm.submit(pgAction, { param: "test" }, null, function() { });
        }
        //提交流程时触发
        function onSubmit(task) {

        }
        //获取下一环节用户
        function onGiveUsers(nextName) {
            var users = { UserIds: "", UserNames: "" };
            switch (nextName) {
                case "提交审批":
                    users.UserIds = $("#PostUserId").val();
                    users.UserNames = $("#PostUserName").val();
                    break;
            }
            return users;
        }
        //流程结束时触发
        function onFinish(task) {
            AimFrm.submit(pgAction, { param: "finish" }, null, function() { });
        }
        //第一个参数为下一步路由,第二个参数为是否禁止重新选择路由
        function SetRoute(name,flag) {
            window.parent.SetRoute("公司领导", flag); 
        }
        /*****************************************************WorkFlow Function End****************************/
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header"><h1>流程维护[由流程工具生成,请不要手动改动流程定义]</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit" style="table-layout:fixed;">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="ID" name="ID" />
                    </td>
                </tr>
                <tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        流程名称
                    </td>
                    <td class="aim-ui-td-data"  colspan=3>
                        <input id="TemplateName" name="TemplateName" class="validate[required]" style = width:100% />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        流程标志Key
                    </td>
                    <td class="aim-ui-td-data"  colspan=3>
                        <input id="Code" name="Code" class="validate[required]" style = width:100% />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        流程定义
                    </td>
                    <td class="aim-ui-td-data"  colspan=3>
                        <textarea id="XAML" name="XAML"  style ="width:100%;height:300px"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption" style="width:10%">
                        版本
                    </td>
                    <td class="aim-ui-td-data" style="width:40%;">
                        <select id="Version" name="Version" aimctrl='select' enum="EnumTypeVersion" style="width: 50px">
                        </select>
                    </td>
                    <td class="aim-ui-td-caption" style="width:10%">
                        状态
                    </td>
                    <td class="aim-ui-td-data" style="width:40%;">
                        <select id="Status" name="Status" aimctrl='select' enum="EnumType" style="width: 50px">
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        描述
                    </td>
                    <td class="aim-ui-td-data"  colspan=3>
                        <textarea id="Description" name="Description" style ="width:100%;height:80px"></textarea>
                    </td>
                </tr>
                <tr width="100%">
                    <td class="aim-ui-td-caption" >
                        录入人
                    </td>
                    <td class="aim-ui-td-data">
                        <input disabled id="Creator" name="Creator" />
                    </td>
                    <td class="aim-ui-td-caption" >
                        录入日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input disabled id="CreateTime" name="CreateTime" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSubmit" class="aim-ui-button submit">提交</a>
                        <a id="btnCancel" class="aim-ui-button cancel">取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>


