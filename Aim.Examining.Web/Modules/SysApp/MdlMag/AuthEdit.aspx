<%@ Page Title="系统权限" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true" CodeBehind="AuthEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.MdlMag.AuthEdit" %>
<%@ OutputCache Duration="1" VaryByParam="None" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var PrimaryKey = "AuthID";
    var StatusEnum = { '1': '有效', '0': '无效' };
    var AuthTypeEnum;
    
    var viewport, form;
    var op = "";
    var action = "";    // 执行提交操作类型
    var tittext = "系统权限";   // 标题字段
    var basicForm;
    var authTypeField;
    var sbButton;   // 提交按钮

    function onPgLoad() {
        AuthTypeEnum = AimState["AuthTypeEnum"] || {};
        setPgUI();
    }

    function setPgUI() {

        sbButton = new Ext.Button({ text: '提交',
        iconCls: 'aim-icon-accept',
            handler: function() {
                submitForm();
            }
        });

        authTypeField = new Ext.ux.form.AimComboBox({
            fieldLabel: '权限类型',
            name: 'Type',
            allowBlank: false,
            anchor: '75%',
            hiddenName: 'Type',
            enumdata: AuthTypeEnum
        });

        form = new Ext.ux.form.AimFormPanel({
            url: '#',
            region: 'center',
            frame: true,
            bodyStyle: 'padding:5px 5px 0',
            defaultType: 'textfield',

            items: [{
                name: PrimaryKey,
                maxLength: 36,
                hidden: true,
                hideLabel: true
            }, {
                fieldLabel: '权限名',
                name: 'Name',
                maxLength: 50,
                allowBlank: false,
                anchor: '75%'
            }, {
                fieldLabel: '权限编码',
                name: 'Code',
                maxLength: 50,
                allowBlank: false,
                anchor: '75%'
            }, authTypeField, {
                fieldLabel: '描述',
                name: 'Description',
                xtype: 'textarea',
                maxLength: 500,
                anchor: '100% -153'
}],

                buttons: [sbButton, {
                    text: '取消',
                    iconCls: 'aim-icon-cancel',
                    handler: function() {
                        ReturnClose({ result: "cancel" });
                    }
}]
                });

            viewport = new Ext.Viewport({
                layout: 'border',
                items: [form]
            });

            basicForm = form.getForm();

            op = $.getQueryString({ ID: "op" });
            bindData();

            switch (op) {
                case "c":
                case "cs":
                    var authType = $.getQueryString({ ID: "type" });
                    if (authType || authType === 0) {
                        authTypeField.setValue(authType);
                        authTypeField.setReadOnly(true);
                    }
                    action = (op == 'c' ? "create" : "createsub");
                    break;
                case "u":
                    action = "update"; 
                    break;
                case "d":
                    action = "delete";
                    sbButton.setIconClass("aim-icon-delete");
                    sbButton.setText("删除");
                    form.setReadOnly(true);
                    break;
                default:
                    sbButton.hide();
                    form.setReadOnly(true);
                    break;
            }
        }

        function bindData() {
            var frmdata = AimState["frmdata"] || {};
            frmdata["ModuleName"] = frmdata["Module"] ? frmdata["Module"]["Name"] : "";
            basicForm.setValues(frmdata);
        }

        function submitForm(act, dt, url, onProcFinished) {
            // enable 隐藏主键以便于提交
            $(":input[name=" + PrimaryKey + "]").attr("disabled", false);
            onProcFinished = onProcFinished || onSubmitFinished;
            act = act || action;    // 对应服务器端的RequestAction
            if (basicForm.isValid() && basicForm.el) {
                Aim.Form.submitData(basicForm.getValues(), act, dt, url, onProcFinished);
            }
        }

        // 处理完成
        function onSubmitFinished(args) {
            var data, frmdata;
            if (args && args.data) { frmdata = args.data.frmdata }
            
            ReturnClose(frmdata);
        }
    
</script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">

</asp:Content>
