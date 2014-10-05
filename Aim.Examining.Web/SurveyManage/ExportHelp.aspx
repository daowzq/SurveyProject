<%@ Page Title="导出帮助" Language="C#" MasterPageFile="~/Masters/Ext/SiteHasDTD.master"
    AutoEventWireup="true" CodeBehind="ExportHelp.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.ExportHelp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        </style>

    <script type="text/javascript">

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div style="margin-top: 5px; font-size: 14px">
        <br />
        <br />
    </div>
    <div style="text-align: center">
        <div style="font-size: 13px;">
            第一步 点击导航栏中的"工具(o)-Internet选项(o)-切换到安全"
            <br />
            <br />
            <img alt="" src="img/First.jpg" />
            <br />
            <br />
        </div>
        <div style="font-size: 13px;">
            第二步 点击"添加-取消勾选对该区域的所有站点要求服务器验证"
            <br />
            <br />
            <img alt="" src="img/Second.jpg" />
            <br />
            <br />
        </div>
        <div style="font-size: 13px;">
            第三步 点击选择区域安全或更改安全设置"受信任的站点-站点(s) "
            <br />
            <br />
            <img alt="" src="img/Third.jpg" />
            <br />
            <br />
        </div>
    </div>
</asp:Content>
