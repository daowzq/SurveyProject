<%@ Page Title="公司切换" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="FrmChangeCorp.aspx.cs" Inherits="Aim.Examining.Web.FrmChangeCorp" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .btn_css
        {
            border-right: #002D96 1px solid;
            padding-right: 2px;
            border-top: #002D96 1px solid;
            padding-left: 2px;
            font-size: 12px;
            filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr=#FFFFFF, EndColorStr=#9DBCEA);
            border-left: #002D96 1px solid;
            cursor: pointer;
            color: black;
            padding-top: 2px;
            border-bottom: #002D96 1px solid;
        }

        td
        {
            font-size: 12px;
            font-family: 微软雅黑;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            //初始化公司
            /*var temp;
            var companyIds = "";
            var corps = AimState["gsbms2"];
            for (var i = 0; i < AimState["gsbms"].length; i++) {
                temp = AimState["gsbms"][i];
                if (companyIds.indexOf(temp.corpId) == -1) {
                    $("#seldept").append("<option value='" + temp.corpId + "'>" + temp.corpName + "</option>");
                    companyIds += temp.corpId;
                }
            }

            var cids, cnames;
            for (var i = 0; i < corps.length; i++) {
                cids = corps[i].CompanyIds.split(',');
                cnames = corps[i].CompanyNames.split(',');
                for (var j = 0; j < cids.length; j++) {
                    if (companyIds.indexOf(cids[j]) == -1) {
                        $("#seldept").append("<option value='" + cids[j] + "'>" + cnames[j] + "</option>");
                        companyIds += cids[j];
                    }
                }
            }

            $("#seldept").val(AimState["corpdeptId"]);*/
        });

        function changeCorp() {
            if ($("#CorpId").val()) {
                jQuery.ajaxExec("changeCorp", { "corpdeptId": $("#CorpId").val() }, function (rtn) {
                    if (rtn.data.error) {
                        alert(rtn.data.error);
                    }
                    else {
                        dialogArguments.$("#bgsqh").html($("#CorpName").val());
                        //刷新页面
                        window.close();
                    }
                });
            }
            else {
                alert("请先选择公司！");
            }
        }

    </script>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <center><div style="margin-top:10px;"></div><table><tr><td>
    <b>选择公司</b></td><td>
        <!--<select id="seldept" style="width: 300px;"></select>-->
        <input type="hidden" id="CorpId" name="CorpId" />
        <input aimctrl="customerquicksel" id="CorpName" name="CorpName" style="width: 400px;"
            popurl='/CommonPages/Select/FrmCompanySel.aspx?seltype=single'
            popstyle='dialogWidth:550px;dialogHeight:550px'
            emptytext="请输入公司代码或点击后面放大镜"
            extparams="selsql:select GroupId as Id, Code+' '+[Name] as Name,Code from SysGroup where corpCode is not null;selColName:Code;SelData:sysgroup;"
            relateid="CorpId" /></td></tr></table>
        <div style="margin-top:15px;"></div>
        <input type="button" value="确　定" class="btn_css" onclick="changeCorp()" />
        <input type="button" value="取　消" class="btn_css" onclick="window.close()" />
    </center>
</asp:Content>
