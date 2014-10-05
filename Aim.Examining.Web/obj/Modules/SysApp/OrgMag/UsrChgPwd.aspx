<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true" CodeBehind="UsrChgPwd.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.OrgMag.UsrChgPwd" %>
<%@ OutputCache Duration="1" VaryByParam="None" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var PrimaryKey = "UserID";
    var StatusEnum = { '1': '有效', '0': '无效' };
    
    var viewport;
    var form;
    var op = "";
    var action = "";    // 执行提交操作类型
    var tittext = "修改密码";   // 标题字段
    var basicForm;
    var sbButton;   // 提交按钮

    var orgPwdField, newPwdFiled, rePwdField;

    function onPgLoad() {
        setPgUI();
    }

    function setPgUI() {

        sbButton = new Ext.Button({ text: '提交',
        iconCls: 'aim-icon-accept',
            handler: function() {
                submitForm("chgpwd");
            }
        });

        orgPwdField = new Ext.form.TextField({
            fieldLabel: '原密码',
            name: 'OrgPassword',
            inputType: 'password',
            maxLength: 50,
            allowBlank: true,
            anchor: '75%'
        });

        newPwdFiled = new Ext.form.TextField({
            fieldLabel: '新密码',
            name: 'Password',
            inputType: 'password',
            maxLength: 50,
            allowBlank: true,
            anchor: '75%'
        });

        rePwdField = new Ext.form.TextField({
            fieldLabel: '重复密码',
            name: 'RePassword',
            inputType: 'password',
            allowBlank: true,
            maxLength: 50,
            anchor: '75%'
        });

        form = new Ext.ux.form.AimFormPanel({
            url: '#',
            region: 'center',
            frame: true,
            bodyStyle: 'padding:5px 5px 0',
            defaultType: 'textfield',

            items: [{
                fieldLabel: '登录名',
                name: 'LoginName',
                allowBlank: false,
                maxLength: 50,
                anchor: '75%'
        }, orgPwdField, newPwdFiled, rePwdField],

        buttons: [sbButton, {
            text: '取消',
            iconCls: 'aim-icon-cancel',
            handler: function() {
                returnClose({ result: "cancel" });
            }
}]
        });

            viewport = new Ext.Viewport({
                layout: 'border',
                items: [form]
            });

            basicForm = form.getForm();
        }

        function bindData() {
            var frmdata = AimState["frmdata"] || {};
            basicForm.setValues(frmdata);
        }

        function submitForm(act, dt, url, onProcFinished) {
            if (newPwdFiled.getValue() != rePwdField.getValue()) {
                AimDlg.show("密码不一致，请重新输入！");
                return;
            }
        
            // enable 隐藏主键以便于提交
            $(":input[name=" + PrimaryKey + "]").attr("disabled", false);
            onProcFinished = onProcFinished || onSubmitFinished;
            act = act || action;    // 对应服务器端的RequestAction
            if (basicForm.isValid() && basicForm.el) {
                Aim.Form.submitData(basicForm.getValues(), act, dt, url, onProcFinished);
            }
        }

        function returnClose(rtn) {
            window.returnValue = rtn;
            window.close();
        }

        // 处理完成
        function onSubmitFinished(args) {
            var data, frmdata;
            if (args && args.data) { frmdata = args.data.frmdata }
            var data = frmdata || basicForm.getValues();
            
            returnClose({ result: "success", data: data });
        }
    
</script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">

</asp:Content>
