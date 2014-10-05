<%@ Page Title="【企业文化系统】用户登录" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master" AutoEventWireup="true"
    CodeBehind="Login.aspx.cs" Inherits="Aim.Examining.Web.Login" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <script type="text/javascript">
        if ((typeof Range !== "undefined") && !Range.prototype.createContextualFragment) {
            Range.prototype.createContextualFragment = function (html) {
                var frag = document.createDocumentFragment(),
                div = document.createElement("div");
                frag.appendChild(div);
                div.outerHTML = html;
                return frag;
            };
        }
    </script>
    <style type="text/css">
        body
        {
            margin: 0px;
            filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=0,startColorStr=#FAFBFF,endColorStr=#C7D7FF);
            font-size: 12px;
            color: #003399;
            font-family: Verdana, Arial, Helvetica, sans-serif;
        }

        .text-input
        {
            border: solid 1px #8FAACF;
        }

        .lbl-message
        {
            color: Red;
        }

        #main
        {
            position: absolute;
            top: 40%;
            left: 50%;
            margin-left: -350px;
            margin-top: -150px;
        }
    </style>

    <script language="javascript" type="text/javascript">
        var islogining = false;
        var deptdata;
        var reUrl = $.getQueryString({ ID: 'ReturnUrl' }) || "";
        function onPgLoad() {

            $("#divseldept").hide();

            $(document).bind("keydown", function (e) {
                // 回车
                if (e.keyCode == 13 && !islogining) {
                    DoLogin();
                }
            });

            getCookie();    // 获取Cookie

            if (!$("#uname").val()) {
                $("#uname").focus();
            } else if (!$("#pwd").val()) {
                $("#pwd").focus();
            } else {
                //$("#imgDoLogin").focus();
            }
        }

        function DoLogin() {
            if (islogining) {
                return;
            }

            setLoginStatus(true);

            if (!$("#uname").val()) {
                $("#message").text("提示：请输入用户名。");
                $("#uname").focus();

                setLoginStatus(false);
                return;
            }
            if (!$("#CorpId").val())
            {
                $("#message").text("提示：请选择公司。");
                setLoginStatus(false);
                return;
            }

            setCookie();
            jQuery.ajaxExec("dologin", { "uname": $("#uname").val(), "pwd": $("#pwd").val(), 'ReturnUrl': reUrl, "CorpId": $("#CorpId").val() }, function(rtn) {
                setLoginStatus(false);
                if (rtn.data.type == "multidept") {
                }
                else if (rtn.data.error) {     
                    if (rtn.data.error == "nullpwd")
                    {
                        alert("密码不能为空，请修改密码再登录！");
                        OpenWin("/Modules/SysApp/OrgMag/UsrChgPwd.aspx", "_blank", CenterWin("width=350,height=180,scrollbars=yes"));
                    }
                    else
                    {
                        $("#message").text(rtn.data.error);
                    }
         
                }
                else if (rtn.data.url) {
                    window.location = rtn.data.url;
                }
            });
        }

        function OpenPwdChgPage() {
            rtn = OpenWin("/Modules/SysApp/OrgMag/UsrChgPwd.aspx", "_blank", CenterWin("width=350,height=180,scrollbars=yes"));
        }

        function setLoginStatus(flag) {
            if (flag) {
                islogining = true;
                $("input").attr("disabled", true);
                $("#imgDoLogin").attr("disabled", true);

                $("#span-loading").css("display", ""); // 显示进度条
            } else {
                islogining = false;
                $("input").attr("disabled", false);
                $("#imgDoLogin").attr("disabled", false);
                $("#span-loading").css("display", "none"); // 隐藏进度条
            }
        }

        function setCookie() {
            var isSaveAccount = $("#saveAcount").attr("checked");
            var isSavePassword = $("#savePassword").attr("checked");

            if (isSaveAccount) {
                SetCookie("uname", $("#uname").val());
                SetCookie("saveAcount", isSaveAccount);
            } else {
                SetCookie("uname", null, { expires: 300 });
                SetCookie("saveAcount", null, { expires: 300 });
            }

            if (isSavePassword) {
                SetCookie("pwd", $("#pwd").val());
                SetCookie("savePassword", isSavePassword);
            } else {
                SetCookie("pwd", null, { expires: 300 });
                SetCookie("savePassword", null, { expires: 300 });
            }
        }

        function getCookie() {
            var isSaveAccount = GetCookie("saveAcount");
            var isSavePassword = GetCookie("savePassword");
            if (isSaveAccount && isSaveAccount != "null") {
                $("#saveAcount").attr("checked", true);
                $("#uname").val(GetCookie("uname"));
            }

            if (isSavePassword && isSavePassword != "null") {
                $("#savePassword").attr("checked", true);
                $("#pwd").val(GetCookie("pwd"));
            }
        }
        function SetCookie(sName, sValue) {
            date = new Date();
            document.cookie = sName + "=" + escape(sValue) + "; expires=Fri, 31 Dec 2099 23:59:59 GMT;";
        }

        function GetCookie(sName) {
            var aCookie = document.cookie.split("; ");
            for (var i = 0; i < aCookie.length; i++) {
                var aCrumb = aCookie[i].split("=");
                if (sName == aCrumb[0]) {
                    if (aCrumb[1])
                        return unescape(aCrumb[1]);
                    else
                        return "";
                }
            }
            return "";
        }
    </script>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="main" align="center">
        <div style="padding: 5px; width: 665; background-color: #e2eefe; border: 1px solid #738DB4; height: 155px;"
            align="center">
            <table id="__01" width="661" border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td colspan="4" bgcolor="#b8d5fc">
                        <img src="images/logo.gif" width="70" height="60" /><img src="images/logoFont.png" width="520" height="40" /></td>
                </tr>
                <tr>
                    <td colspan="4">
                        <img src="images/portal/logo.jpg" width="661" height="129" alt=""></td>
                </tr>
                <tr>
                    <td colspan="4">
                        <img src="images/portal/login/Login_Sliceup_04.gif" width="661" height="10" alt=""></td>
                </tr>
                <tr>
                    <td rowspan="2" style="background-image: url(images/portal/login/Login_Sliceup_05.gif); background-repeat: no-repeat; height: 113px">&nbsp;
                    </td>
                    <td colspan="2" style="background-color: #e2eefe; height: 106px;">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0"
                            style="height: 42px" style="padding: 5px; font-size: 12px;">
                            <tr style="font-size: 12px;">
                                <td colspan="3"><table  style="font-size: 12px;"><tr><td>公　司：</td><td>
                                    <input type="hidden" id="CorpId" name="CorpId" />
                                    <input aimctrl="customerquicksel" id="CorpName" name="CorpName" style="width: 400px;"
                                        popurl='/CommonPages/Select/FrmCompanySel.aspx?seltype=single'
                                        popstyle='dialogWidth:550px;dialogHeight:550px'
                                        extparams="selsql:select GroupId as Id, Code+' '+[Name] as Name,Code from SysGroup where corpCode is not null;selColName:Code;SelData:sysgroup;"
                                        relateid="CorpId" value='102' /></td></tr></table>
                                </td>
                            </tr>
                            <tr style="height: 5px;">
                                <td colspan="3"></td>
                            </tr>
                            <tr style="font-size: 12px;">
                                <td colspan="3">用户名：
                                    <input id="uname" name="uname" class="text-input" style="width: 120px;" value="" />
                                    &nbsp;&nbsp;
                                密&nbsp;&nbsp;码：
                                    <input id="pwd" name="pwd" class="text-input" type="password" style="width: 120px;" />
                                    &nbsp;&nbsp;
                                    <input type="checkbox" name="saveAcountName" id="saveAcount" value="true" />
                                    <label for="checkbox">保存帐号</label>
                                    <input type="checkbox" name="savePassword" id="savePassword" value="true" />
                                    <label for="checkbox">保存密码</label>
                                </td>
                            </tr>
                            <tr style="font-size: 12px;">
                                <td width="15%" valign="top">
                                    <img id="imgDoLogin" onclick="DoLogin();" alt="" src="images/portal/login/Login_btn.png" style="cursor: pointer;" /></td>
                                <td width="20%">
                                    <a href="#" onclick="OpenPwdChgPage()">修改密码</a>
                                </td>
                                <td>
                                    <label class="lbl-message" id="message" name="message"></label>
                                    <span id="span-loading" style="display:none;">
                                        <img src="images/portal/loading.gif" />
                                    </span>
                                </td>
                                <!--<td>
                                    <span id="span-loading" style="display: none;">
                                        <img src="images/portal/loading.gif" />
                                    </span>
                                    <span id="divseldept" style="display: block;">
                                        <label style="color: Red; vertical-align: middle;">请选择公司</label>
                                        <select id="seldept" style="width: 250px; vertical-align: middle;">
                                        </select>
                                    </span>
                                </td>-->
                            </tr>
                        </table>
                    </td>
                    <td rowspan="2" style="background-image: url(images/portal/login/Login_Sliceup_07.gif); background-repeat: no-repeat; height: 113px">&nbsp;
                    </td>
                </tr>
                <tr>
                    <td colspan="2" valign="top">
                        <img src="images/portal/login/Login_Sliceup_08.jpg" width="620" height="7" alt="" /></td>
                </tr>
                <tr>
                    <td>
                        <img src="images/portal/login/spacer.gif" width="21" height="1" alt=""></td>
                    <td>
                        <img src="images/portal/login/spacer.gif" width="285" height="1" alt=""></td>
                    <td>
                        <img src="images/portal/login/spacer.gif" width="335" height="1" alt=""></td>
                    <td>
                        <img src="images/portal/login/spacer.gif" width="20" height="1" alt=""></td>
                </tr>
            </table>
        </div>
    </div>

    <!--input type="hidden" id="CorpId" name="CorpId" />
        <input aimctrl="customerquicksel" id="CorpName" name="CorpName" style="width: 600;"
            popurl='/CommonPages/Select/FrmVehicleSel.aspx?seltype=single'
            popstyle='dialogWidth:450px;dialogHeight:450px'
            extparams='selsql:select top 30 GroupId as Id, [Name],corpCode as Code from fl_portalhr..sysgroup where corpCode is not null;selColName:corpCode;SelData:sysgroup;'
            relateid="CorpId" /-->
</asp:Content>
