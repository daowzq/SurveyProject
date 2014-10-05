<%@ Page Title="���ϵ���" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="InternetSurveyView.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.InternetSurveyView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: White;
        }
        td, body, select, input
        {
            font-size: 12px;
            color: #000000;
            line-height: 18px;
        }
        .header
        {
            background-color: #e0e0e0;
            height: 25px;
        }
        .discuss
        {
            float: left;
            width: 30px;
            border: solid 1 gray;
            margin: 12px 3px 0px 0px;
        }
        .formCtl
        {
            width: 100%;
            padding-left: 12px;
        }
        .question_textarea
        {
            width: 450;
            margin-top: 5px;
            margin-left: 10px;
        }
        .IsExplanation
        {
            border: none;
            width: 160;
            margin-left: 5px;
            border-bottom: 1px #000000 solid;
        }
        .questImg
        {
            width: 160px;
            height: 130px;
            margin-top: 5px;
            margin-bottom: 5px;
            margin-right: 2px;
            margin-left: 16px;
        }
        .txx1
        {
            /*input�ı���*/
            margin-left: 6px;
        }
    </style>

    <script src="js/renderSurvey.js" type="text/javascript"></script>

    <script type="text/javascript">
        var records, survey;
        var SurveyId = $.getQueryString({ ID: 'SurveyId' });
        function onPgLoad() {

            renderView();
            setPageUI();
        }
        function setPageUI() {
            //�Ƿ�����
            $(".discuss").click(function() {
                $(this).parent().append("<textarea rows=3 style='float: left; width: 415;'" + " name=" + $(this).attr("name") + "/>")
                $(this).unbind("click");
            });
        }

        function renderView() {
            if (!AimState["ItemList"]) {

                AimDlg.show("���ڵ�3���������ʾ�����!");
                $("#isshow").hide();
            }

            survey = AimState["Survey"];
            records = AimState["ItemList"] || "[]";
            var recordsObj = eval("(" + records + ")") || [];

            if (recordsObj.length > 0) {
                var html = buildHtml(recordsObj);   //��Ⱦ�ʾ��б�

                $("#SurveyList").children().remove();
                $("#SurveyList").append(html);      //����ʾ���
            }
        }

        function cancel() { /*ȡ��*/
            RefreshClose();
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <table width="750" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table id="isshow" width="750" border="1px" align="center" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <table width="750" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="100%">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="3">
                                            <tr valign="top">
                                                <td width="100%" id="SurveyList">
                                                </td>
                                            </tr>
                                        </table>
                                        <table>
                                            <tr>
                                                <td height="12">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
