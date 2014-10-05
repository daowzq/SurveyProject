<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site2.Master" AutoEventWireup="true"
    CodeBehind="Top.aspx.cs" Inherits="Aim.Examining.Web.Top" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .mi-icon
        {
            background: no-repeat center center;
            height: 38px;
        }
        .x-tab-strip-text
        {
            color: #fff !important;
        }
        .x-tab-strip-active
        {
            height: 54px;
            width: 78px;
            color: #fff;
            background-image: url(/theme/topnav/topnavcur.gif) !important;
        }
    </style>
    <link href="../theme/default/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="../theme/default/css/style.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../resource/js/jay-top.js"></script>

    <script type="text/javascript">
        if ((typeof Range !== "undefined") && !Range.prototype.createContextualFragment) {
            Range.prototype.createContextualFragment = function(html) {
                var frag = document.createDocumentFragment(),
                div = document.createElement("div");
                frag.appendChild(div);
                div.outerHTML = html;
                return frag;
            };
        }
    </script>

    <script type="text/javascript">

        $(document).ready(function() {
            /*if (AimState["Modules"] && AimState["Modules"].length > 0) {
            $.each(AimState["Modules"], function () {
            $("#sysapp").prepend('<a href="#" class="meunIthems fz-1 tx-sd-1"><i class="mi-icon" style="background-image:url(' + this.Description + ')"></i>' + this.Name + '</a>');
            })
            }*/

            $("#bgsqh").html(AimState["CompanyName"]);

            //初始化公司
            return;
            var temp;
            for (var i = 0; i < AimState["gsbms"].length; i++) {
                temp = AimState["gsbms"][i];
                $("#seldept").append("<option value='" + temp.corpId + "'>" + temp.corpName + "</option>");
            }

            $("#seldept").val(AimState["corpdeptId"]);
        });

        function DoRelogin() {
            window.parent.location.href = "/Unlogin.aspx";
        }

        function changeCorp(obj) {
            jQuery.ajaxExec("changeCorp", { "corpdeptId": obj.value }, function(rtn) {
                //刷新页面
            });
        }

        //公司切换
        function doChangeCorp() {
            window.showModalDialog("/FrmChangeCorp.aspx", window, "resizable:yes;scroll:yes;status:no;dialogWidth=480px;dialogHeight=220px;center=yes;help=no'");
        }

        function dolinmh() {
            window.parent.framemainArea.location.href = "/Home.aspx?BlockType=Portal";
        }

    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <div class="logo">
            <img src="../resource/images/logo.gif" alt="" />
        </div>
        <div class="head-right head-right2">
            <span class="hr-name fz-1 valTop" id="hrname"><b>
                <div id="bgsqh" style="display: inline;">
                </div>
                &nbsp;&nbsp;
                <%= UserInfo.Name %>&nbsp;&nbsp;欢迎登录！&nbsp;&nbsp;</b> </span>
            <!--em class="flags valTop">
                    <i class="icons icons-1"></i></!--em><em class="flags valTop"><i class="icons icons-2"></i></em>
            <em class="flags valTop"><i class="icons icons-3"></i></em-->
            <em class="flags valTop"><i class="icons icons-4" title="注销" onclick="DoRelogin()"></i>
            </em>
            <!--<a href="#" class="valTop">
                <img src="../resource/images/topnav/exitbtn.png" alt="" /></a>-->
        </div>
        <br />
        <br />
        <div class="head-right" style="height: 25px;">
            <span style="color: white; font-size: 12px; font-family: 微软雅黑;"><b style="text-decoration: underline;
                cursor: pointer;" onclick="dolinmh()">应用门户</b></span>&nbsp;&nbsp; <span style="color: white;
                    font-size: 12px; font-family: 微软雅黑;"><b onclick="doChangeCorp()" style="text-decoration: underline;
                        cursor: pointer; margin-right: 10px;">公司切换</b>
                    <select id="seldept" style="width: 300px; display: none;" onchange="changeCorp(this)">
                    </select>
                </span>
        </div>
        <!--<div class="head-right-bot clearfix" id="sysapp">
        </div>-->
    </div>
</asp:Content>
