<%@ Page Title="信息浏览" Language="C#" AutoEventWireup="true" MasterPageFile="~/Masters/Ext/formpage.master"
    CodeBehind="FrmNoticeView.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmNoticeView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        self.moveTo(200, 0);
        self.resizeTo(screen.availWidth - 400, screen.height - 40);

        //var EnumType = { 1: "启用", 0: "停用" };

        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            $("#btnCancel").click(function() {
                window.close();
            });

            $("label").each(function(i) {
                $("#" + this.id).html(eval("AimState.frmdata." + this.id) || "");
            });
        }

        function doZoom(size) {
            document.getElementById('Content').style.fontSize = size + 'pt';
            document.getElementById('Content').style.lineHeight = size + 10 + 'pt';
        }
    </script>

    <style type="text/css">
        .style1
        {
            font-size: 10px;
            color: #999999;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <table cellspacing="0" cellpading="0" width="100%" border="0">
        <tbody>
            <tr>
                <td>
                    <div align="right">
                        <img style="cursor: pointer;" src="/images/shared/printer.png" border="0" onclick="javascript:window.print();"
                            alt="打印" />
                        <img style="cursor: pointer;" src="/images/shared/cross.gif" border="0" alt="关闭"
                            style="margin-right: 30px" onclick="window.close();" />
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div align="center">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td height="32">
                                    <div align="center">
                                        <font size="5" face="黑体,Arial, Helvetica, sans-serif"><strong>
                                            <label id="Title">
                                            </label>
                                        </strong></font>
                                    </div>
                                </td>
                            </tr>
                        </table>
                        <br>
                        <table width="95%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td align="center" style="color: #990000; font-size: 12px;">
                                    时间：<label id="CreateTime"></label>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" style="font-size: 13px; color: #559933;">
                                    <div>
                                        字体大小：<a style="cursor: pointer;" onclick="doZoom(14)">大</a> <a style="cursor: pointer;"
                                            onclick="doZoom(12)">中</a> <a style="cursor: pointer;" onclick="doZoom(9)">小</a></div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <hr width="100%" style="margin-bottom: 10px;" size="1" noshade>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <tr style="vertical-align: top; height: 350pt;">
                <td>
                    <label style="width: 95%; margin-left: 2.5%; font-size: 9pt; line-height: 19pt;"
                        id="Content">
                    </label>
                </td>
            </tr>
        </tbody>
    </table>
</asp:Content>
