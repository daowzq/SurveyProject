<%@ Page Title="调查问卷人员" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="Wizard_Finish.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Wizard_Finish" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #F2F2F2;
        }
        fieldset
        {
            margin: 15px;
            width: 100%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .x-panel-body x-form
        {
            height: 0px;
        }
    </style>

    <script type="text/javascript">

        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';
        var op = $.getQueryString({ ID: 'op' }) || '';
        var type = $.getQueryString({ ID: 'type' }) || '';
        function onPgLoad() {
            setPgUI();
            createUser();
        }


        function setPgUI() {
            // 初始化tooltip
            Ext.apply(Ext.QuickTips.getQuickTip(), { dismissDelay: 0 });

            tabs = ["调查对象"];
            tabArray = [];

            for (var a = 0; a < tabs.length; a++) {
                var tab = {
                    title: tabs[a],
                    tooltip: a,
                    listeners: { activate: handleActivate },
                    autoScroll: true,
                    border: false,
                    layout: 'border',
                    html: "<div style='display:none;'></div>"
                };
                tabArray.push(tab);
            }

            tabpanel = new Ext.TabPanel({
                enableTabScroll: true,
                border: true,
                region: 'north',
                activeTab: 0,
                items: [tabArray]
            });

            //功能按钮
            buttonPanel = new Ext.form.FormPanel({
                id: 'btn',
                region: 'south',
                hidden: op == "r" ? true : false,
                frame: true,
                buttonAlign: 'center',
                buttons: [{
                    text: '确定',
                    handler: function() {
                        if (op == "r") return;    //***
                        $.ajaxExec("Question", { SurveyId: SurveyId }, function(rtn) {
                            if (rtn.data.State.indexOf("1") > -1) {
                                AimDlg.show("本次问卷无调查对象,请配置调查对象或导入人员!");
                                return;
                            }
                            if (rtn.data.State.indexOf("2") > -1) {
                                AimDlg.show("无问卷内容,请配置问卷内容!");
                                return;
                            }
                            if (confirm("确定生成此次问卷配置吗？")) {
                                // window.opener.opener = null; 关闭窗口
                                window.opener.close()
                                window.close();
                            }
                        });

                    }
                },
                {
                    text: '取消',
                    handler: function() {
                        // window.opener.opener = null;   关闭窗口
                        if (confirm("你有未保存的数据,确定取消吗?")) {
                            $.ajaxExecSync("Close", { SurveyId: SurveyId }, function(rtn) {
                                window.opener.close()
                                window.close();
                            });
                        }
                    }
}]
                });


                var viewport = new Ext.ux.AimViewport({
                    id: 'viewport',
                    items: [
                    buttonPanel, {
                        region: 'center',
                        margins: '-2 0 0 0',
                        cls: 'empty',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'}]
                    });
                    //var obj = Ext.getCmp("btn")
                    //var items = Ext.getCmp('viewport').items;
                    //viewport.remove(items[1]);
                    // viewport.doLayout();

                    if (document.getElementById("frameContent")) {
                        frameContent.location.href = "Tab_SurveyedUser.aspx?type=add&SurveyId=" + SurveyId + "&op=" + op;
                    }
                }

                function handleActivate(tab) {
                    if (document.getElementById("frameContent")) {
                        switch (tab.title) {
                            case "调查对象":
                                frameContent.location.href = "/SurveyManage/Tab_SurveyedUser.aspx?&type=addSurveyId=" + SurveyId + "&op=" + op;
                                break;
                            case "查看对象":
                                frameContent.location.href = "Tab_ReadUser.aspx?SurveyId=" + SurveyId + "&op=" + op;
                                break;
                        }
                    }
                }

                //人员生成中
                function createUser() {
                    if (op == "r") return;    //***
                    $.ajaxExec("IsCreate", { SurveyId: SurveyId }, function(rtn) {
                        if (rtn.data.IsCreate != "1") {
                            Ext.getBody().mask("人员生成中，请稍等!");
                            var task = new Ext.util.DelayedTask();
                            task.delay(200, function() {
                                $.ajaxExec("CreateUser", { SurveyId: SurveyId }, function(rtn) {
                                    if (rtn.data.CreateState == "1") {
                                        AimDlg.show("调查问卷人员生成成功!");
                                        frameContent.location.reload();
                                    } else {
                                        AimDlg.show("调查问卷人员生成失败!");
                                    }
                                    Ext.getBody().unmask(); //去除MASK
                                }, null, "Comman.aspx");
                            });
                        }
                    });
                }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
