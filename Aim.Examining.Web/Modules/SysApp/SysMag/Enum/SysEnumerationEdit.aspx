<%@ Page Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true"
    CodeBehind="SysEnumerationEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SysMag.SysEnumerationEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var id, title;

        function onPgLoad() {
            id = $.getQueryString({ ID: 'id' });
            title = $.getQueryString({ ID: 'title', DefaultValue: '系统枚举' });

            $("#header").find('h1').html(title);
            document.title = title;

            setPgUI();
        }

        function setPgUI() {
            if (pgOperation == "c" || pgOperation == "cs") {
                $("#CreaterName").val(AimState.CreaterName);
                $("#CreatedDate").val(AimState.CreatedDate);
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
            try {
                if ($.getQueryString({ ID: 'addtype', DefaultValue: '' }) == "ryhx") {
                    window.opener.location.reload();
                    window.close();
                }
                else {
                    Aim.PopUp.ReturnValue({ id: id, op: pgOperation });
                }
            }
            catch (ex) {
                //alert(ex.messge);
            }
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
        </h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="EnumerationID" name="EnumerationID" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        编码
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Code" name="Code" class="validate[required, length[0,150]]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        名称
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Name" name="Name" class="validate[required, length[0,500]]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        值
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="Value" name="Value" class="validate[length[0,50]]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        &nbsp;
                    </td>
                    <td class="aim-ui-td-data">
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        附加信息
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <input id="Tag" name="Tag" style="width: 98%;" class="validate[length[0,500]]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        描述
                    </td>
                    <td class="aim-ui-td-data" colspan="3">
                        <textarea id="Description" rows="5" style="width: 98%"></textarea>
                    </td>
                </tr>
                <tr width="100%">
                    <td class="aim-ui-td-caption">
                        录入人
                    </td>
                    <td class="aim-ui-td-data">
                        <input disabled id="CreaterName" name="CreaterName" />
                    </td>
                    <td class="aim-ui-td-caption">
                        录入日期
                    </td>
                    <td class="aim-ui-td-data">
                        <input disabled id="CreatedDate" name="CreatedDate" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-button-panel" colspan="4">
                        <a id="btnSubmit" class="aim-ui-button submit">提交</a> <a id="btnCancel" class="aim-ui-button cancel">
                            取消</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
