<%@ Page Title="添加问题" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="AskQuestionEdit.aspx.cs" Inherits="Aim.Examining.Web.AskQuestionEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="../js/fckeditor/fckeditor.js" type="text/javascript"></script>

    <style type="text/css">
        body
        {
            margin: '0px 10px 10px 0px';
        }
    </style>

    <script type="text/javascript">
        var op = $.getQueryString({ ID: 'op' });
        var id = $.getQueryString({ ID: "id" }) || "";
        function onPgLoad() {

            //            tlBar = new Ext.ux.AimToolbar({
            //                renderTo: 'btnsSubmit',
            //                items: [{
            //                    id: 'btnSave',
            //                    text: '保存',
            //                    iconCls: 'aim-icon-save',
            //                    handler: function() {
            //                        AimFrm.submit(pgAction, {}, null, SubFinish);

            //                    }
            //                }, {
            //                    text: '清空',
            //                    iconCls: 'aim-icon-undo',
            //                    handler: function() {
            //                        $("#DeptName,#Category,#Title,#Id,#AwardScore").val("");
            //                        var oEditor = FCKeditorAPI.GetInstance("Contents").SetHTML("");
            //                        $("#Contents").text(oEditor);
            //                    }
            //}]
            //                });

            if (id) $("#btnSubmit").hide();
            setPgUI();
        }

        function setPgUI() {

            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });

        }

        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);


        }
        function SubFinish(args) {
            var rtnEnt = args.data.Ent;
            if (rtnEnt) {
                Ext.getCmp("btnSave").setText("保存");

            }
            RefreshClose();
        }


    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <%--    <div id="btnsSubmit" style='width: 100%'>
    </div>--%>
    <div id="header">
        <h1>
            添加问题</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tr style="display: none">
                <td>
                    <input id="Id" name="Id" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    问题分类
                </td>
                <td class="aim-ui-td-data">
                    <select id="Category" name="Category" style="width: 50%" aimctrl="select" enumdata="AimState['QuestionEnum']"
                        class="validate[required]">
                    </select>&nbsp;
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    所属公司
                </td>
                <td class="aim-ui-td-data">
                    <%--  <input id="CorpName" name="CorpName" readonly="readonly" aimctrl="popup" popurl="/CommonPages/Select/GrpSelect/MGrpSelect.aspx?seltype=single"
                        popparam="CorpId:GroupID;CorpName:Name" popstyle="width=500,height=450" class="validate[required]"
                        style="width: 62%" />--%>
                    <input id="CorpName" name="CorpName" disabled style="width: 70%" />
                    <input id="CorpId" name="CorpId" type="hidden" />
                </td>
                <td class="aim-ui-td-caption">
                    所属部门
                </td>
                <td class="aim-ui-td-data">
                    <input id="DeptName" name="DeptName" style="width: 70%" disabled />
                    <%-- <input id="DeptName" name="DeptName" readonly="readonly" aimctrl="popup" popurl="/CommonPages/Select/GrpSelect/MGrpSelect.aspx?seltype=single"
                        beforepopup="PopBefore();"   popparam="DeptId:GroupID;DeptName:Name" popstyle="width=500,height=450" class="validate[required]"
                        style="width: 62%" />--%>
                    <input id="DeptId" name="DeptId" type="hidden" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    标题
                </td>
                <td class="aim-ui-td-data" colspan="3">
                    <input id="Title" name="Title" type="text" class="validate[required]" style="width: 90%" />
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    提问内容
                </td>
                <td colspan="3" class="aim-ui-td-data">
                    <textarea id="Contents" name="Contents" aimctrl="editor" style="width: 90%; height: 300px"></textarea>
                </td>
            </tr>
            <tr>
                <td class="aim-ui-td-caption">
                    附件
                </td>
                <td colspan="3" class="aim-ui-td-data">
                    <input id="AddFiles" mode="single" name="AddFiles" style="width: 91%" aimctrl='file'
                        filter='(*.docx;*.doc;*.xls)|*.docx;*.doc;*.xls' />
                </td>
            </tr>
            <!--   <tr>
                <td class="aim-ui-td-caption">
                    是否匿名
                </td>
                <td class="aim-ui-td-data" style="width: 300px">
                    <input type="checkbox" name="Anonymity" id="Anonymity" value="1" />
                </td>
                <td class="aim-ui-td-caption" style="display: none">
                    
                    <select name="AwardScore" id="AwardScore" style="width: 20%">
                        <option value="0">0分</option>
                        <option value="5">5分</option>
                        <option value="10">10分</option>
                        <option value="20">20分</option>
                        <option value="50">50分</option>
                        <option value="100">100分</option>
                    </select>
                </td> 
            </tr>-->
            <tr>
                <td class="aim-ui-button-panel" colspan="4">
                    <a id="btnSubmit" class="aim-ui-button">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                        取消</a>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
