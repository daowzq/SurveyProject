<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="FrmMessageDraft.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmMessageDraft" %>
    
<%@ OutputCache Location="None" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="../Modules/PubNews/fckeditor/fckeditor.js" type="text/javascript"></script>

    <script type="text/javascript">

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            if (!pgOperation || pgOperation == "c" || pgOperation == "cs") {
                $("#CreateName").val(AimState.UserInfo.Name);
                $("#CreateTime").val(jQuery.dateOnly(AimState.SystemInfo.Date));

                $("#ReleDepartment").val(AimState["ReleDepartment"]);
            }

            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);
            FormValidationBind('btnSave', SuccessSave);

            $("#btnRelease").click(function() {
                AimFrm.submit(pgAction, { "roleid": $("#txtroleid").val(), "userid": $("#txtuserid").val() }, null, function(args) { RefreshClose(); });
            });

            $("#btnCancel").click(function() {
                window.close();
            });
        }

        //保存
        function SuccessSave() {
            AimFrm.submit(pgAction, { "Section": $("#Typeid").find("option:selected").text() }, null, SubFinish); //document.getElementById("eWebEditor1").contentWindow.getHTML() , "content": $("#Content").val()
        }
        
        //提交
        function SuccessSubmit() {
            AimFrm.submit("Submit", { "Section": $("#Typeid").find("option:selected").text(), "entId": $("#Id").val(), "content": $("#Content").val() }, null, SubFinish); //document.getElementById("eWebEditor1").contentWindow.getHTML()
        }

        function SubFinish(args) {
            if (opener) {
                RefreshClose();
            }
            else {
                AimDlg.show("添加成功");
                window.close();
            }
        }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            消息发布</h1>
    </div>
    <div id="editDiv">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none;">
                    <td colspan="4">
                        <input id="Id" name="Id" />
                        <input id="CreateId" name="CreateId" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        标题
                    </td>
                    <td class="aim-ui-td-data" style="width:30%;">
                        <input id="Title" name="Title" style="width: 200px;" class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        重要性
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="Importance" name="Importance" aimctrl='select' enumdata="AimState['ImportanceEnum']"
                            style="width: 200px;" class="validate[required]">
                        </select>
                    </td>
                </tr>
                
                <tr>
                    <td class="aim-ui-td-caption">
                        发布部门
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="ReleDepartment" name="ReleDepartment" style="width: 200px;" class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        过期时间
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Period" name="Period" style="width: 200px;" aimctrl="date" class="validate[required]" />
                    </td>
                </tr>
                
                <tr>
                    <td class="aim-ui-td-caption">
                        栏目
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="Typeid" name="Typeid" aimctrl='select' enumdata="AimState['TypeEnum']"
                            style="width: 200px;" class="validate[required]">
                        </select>
                    </td>
                    <td class="aim-ui-td-caption">
                        强制弹出
                    </td>
                    <td class="aim-ui-td-data">
                        <input type="checkbox" id="IsEnforcementUp" name="IsEnforcementUp" />
                    </td>
                </tr>
                
                <tr>
                
                <td class="aim-ui-td-caption">展示图片</td>
                <td class="aim-ui-td-data">
                    <input id="ImgPath" name="ImgPath" aimctrl='file' mode="single" value="" style="width: 200px;" />
                </td>
                <td class="aim-ui-td-caption">提醒天数</td>
                <td class="aim-ui-td-data">
                    <input id="RemindDays" name="RemindDays" class="validate[required custom[onlyInteger]]" style="width: 200px;" />
                </td>
                
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        内容
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Content" name="Content" style="width: 80%; height: 300px;" aimctrl="editor" ></textarea><!-- -->
                        
                        <%--<input type="hidden" id="Content" name="Content" value="" />
                        <iframe id="eWebEditor1" src="/js/ewebeditor/ewebeditor.htm?id=Content&style=standard600&skin=office2003"
                            frameborder="0" scrolling="no" width="80%" height="350"></iframe>--%>
                            
                    </td>
                </tr>
                <tr style="display: none;" id="trfb1">
                    <td class="aim-ui-td-caption">
                        可查看角色
                    </td>
                    <td colspan="3" class="aim-ui-td-data" >
                        <input aimctrl='popup' id="ReadUser" name="ReadUser" style="width: 80%" disabled
                            popurl="/CommonPages/Select/MultiRolSelect/FrmMultiRoleSelect.aspx" popparam="txtroleid:RoleID;ReadUser:Name;txtuserid:UserID"
                            popstyle="width=700,height=500" />
                        <input type="hidden" id="txtroleid" name="txtroleid" />
                        <input type="hidden" id="txtuserid" name="txtuserid" />
                    </td>
                </tr>
                <tr style="display: none;" id="trfb2">
                    <td>
                        发布人：
                    </td>
                    <td>
                        <input id="ReleaseUser" name="ReleaseUser" disabled />
                    </td>
                    <td>
                        发布时间：
                    </td>
                    <td>
                        <input id="ReleaseTime" name="ReleaseTime" disabled />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        附件
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="FileID" name="FileID" aimctrl='file' style="width: 82%; height: 100px;" />
                    </td>
                </tr>
                <tr style="display: none;">
                    <td class="aim-ui-td-caption">
                        创建人
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="CreateName" name="CreateName" disabled />
                    </td>
                    <td class="aim-ui-td-caption">
                        创建日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="CreateTime" name="CreateTime" disabled />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSave" class="aim-ui-button submit">保存</a>
                        <a id="btnSubmit" class="aim-ui-button submit">提交</a>
                        <a id="btnRelease" class="aim-ui-button fabu" style="display: none;">发布</a>
                        <a id="btnCancel" class="aim-ui-button cancel">取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
        <input id="ReleaseId" name="ReleaseId" style="display: none;" />
    </div>
</asp:Content>
