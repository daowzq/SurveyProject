<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true" CodeBehind="WebPartEdit.aspx.cs" Inherits="Aim.Portal.Web.WebPart.WebPartEdit"  ValidateRequest="false"%>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var StatusEnum = { '0': '有效', '1': '无效' };
        var EnumBlock = { portal: "门户", Report: "报表中心", Home: "不登录门户" };

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            //绑定按钮验证
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });

            if (pgOperation == "cp") {
                $("#btnSubmit").css("display", "");
            }
        }

        //验证成功执行保存方法
        function SuccessSubmit() {
            AimFrm.submit(pgAction, {}, null, SubFinish);
        }

        function SubFinish(args) {
            RefreshClose();
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    
    <div id="header"><h1>维护记录</h1></div>
    
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input type="hidden" id="Id" name="Id" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        块名称
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="BlockName" name="BlockName" class="validate[required]"
                            style="width: 95%" />
                    </td>
                    <td class="aim-ui-td-caption">
                        块Key
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="BlockKey" name="BlockKey" class="validate[required]"
                            style="width: 95%" /><input id="BlockImage" name="BlockImage"
                             type=hidden value="/images/shared/copy.gif"/><input id="Color" name="Color"
                             type=hidden value="blue"/>
                    </td>
                </tr>
                 <tr>
                    <td class="aim-ui-td-caption">
                        块标题
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="BlockTitle" name="BlockTitle" class="validate[required]"
                            style="width: 95%" />
                    </td>
                    <td class="aim-ui-td-caption">
                        块类型
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="BlockType" name="BlockType" aimctrl='select' enum="EnumBlock" style="width: 100px">
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        是否有效
                    </td>
                    <td class="aim-ui-td-data">
                        <select id="IsHidden" name="IsHidden" aimctrl='select' enum="StatusEnum" style="width: 50px">
                        </select>
                    </td>
                    <td class="aim-ui-td-caption">
                        延时加载
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="DelayLoadSecond" name="DelayLoadSecond" value=0 class="validate[required]"
                            style="width: 95%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        显示条数
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="RepeatItemCount" name="RepeatItemCount" value=0 class="validate[required]"
                            style="width: 95%" />
                    </td>
                    <td class="aim-ui-td-caption">
                        显示长度
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="RepeatItemLength" name="RepeatItemLength" value=200 class="validate[required]"
                            style="width: 95%" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        默认高度</td>
                    <td class="aim-ui-td-data">
                        <input id="DefaultHeight" name="DefaultHeight" 
                            style="width: 95%" /></td>
                    <td class="aim-ui-td-caption">
                        空值自适应高度</td>
                    <td class="aim-ui-td-data">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        标题头模板
                    </td>
                    <td class="aim-ui-td-data" colspan=3>
                        <textarea id="HeadHtml" name="HeadHtml" class="text ui-widget-content"
                            style="width: 95%" rows="7"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        列表模板
                    </td>
                    <td class="aim-ui-td-data" colspan=3>
                        <textarea id="RepeatItemTemplate" name="RepeatItemTemplate" class="text ui-widget-content"
                            style="width: 95%" rows="7"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        页脚模板
                    </td>
                    <td class="aim-ui-td-data" colspan=3>
                        <textarea id="FootHtml" name="FootHtml" class="text ui-widget-content"
                            style="width: 95%" rows="7"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        数据SQL
                    </td>
                    <td class="aim-ui-td-data" colspan=3>
                        <textarea id="RepeatDataDataSql" name="RepeatDataDataSql" class="text ui-widget-content"
                            style="width: 95%" rows="7"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        相关脚本
                    </td>
                    <td class="aim-ui-td-data" colspan=3>
                        <textarea id="RelateScript" name="RelateScript" class="text ui-widget-content"
                            style="width: 95%" rows="7"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        描述
                    </td>
                    <td class="aim-ui-td-data" colspan=3>
                        <textarea id="Remark" name="Remark" class="text ui-widget-content"
                            rows="7" style="width: 95%"></textarea>
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
