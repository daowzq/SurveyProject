<%@ Page Title="系统用户" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="UsrEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.OrgMag.UsrEdit" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var PrimaryKey = "UserID";
        var StatusEnum = { '1': '有效', '0': '无效' };

        var viewport;
        var form;
        var op = "";
        var action = "";    // 执行提交操作类型
        var tittext = "系统用户";   // 标题字段
        var basicForm;
        var sbButton;   // 提交按钮

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            sbButton = new Ext.Button({ text: '提交',
                iconCls: 'aim-icon-accept',
                handler: function() {
                    submitForm();
                }
            });

            form = new Ext.ux.form.AimFormPanel({
                url: '#',
                region: 'center',
                heigth: 450,
                frame: true,
                bodyStyle: 'padding:5px 5px 0',
                defaultType: 'textfield',

                items: [{
                    name: PrimaryKey,
                    maxLength: 36,
                    hidden: true,
                    hideLabel: true
                }, {
                    fieldLabel: '姓名',
                    name: 'Name',
                    maxLength: 50,
                    allowBlank: false,
                    anchor: '75%'
                }, {
                    fieldLabel: '登录名',
                    name: 'LoginName',
                    maxLength: 50,
                    allowBlank: false,
                    anchor: '75%'
                }, {
                    fieldLabel: '工号',
                    name: 'WorkNo',
                    maxLength: 50,
                    // allowBlank: false,
                    anchor: '75%'
                }, {
                    fieldLabel: '电子邮箱',
                    name: 'Email',
                    maxLength: 100,
                    anchor: '75%'
                },
                 {
                     fieldLabel: '性别',
                     name: 'Sex',
                     maxLength: 100,
                     anchor: '75%'
                 },
                {
                    fieldLabel: '手机',
                    name: 'Phone',
                    maxLength: 100,
                    anchor: '75%'
                },
                {
                    fieldLabel: '入职日期',
                    name: 'IndutyData',
                    maxLength: 100,
                    anchor: '75%'
                },
                {
                    fieldLabel: '离职日期',
                    name: 'OutdutyDate',
                    maxLength: 100,
                    anchor: '75%'
                },
             new Ext.ux.form.AimComboBox({
                 fieldLabel: '用户状态',
                 name: 'Status',
                 allowBlank: false,
                 anchor: '75%',
                 hiddenName: 'Status',
                 enumdata: StatusEnum,
                 listeners: {
                     afterrender: function() { // 设置默认值
                         if (!this.getValue()) {
                             this.setValue('1');
                         }
                     }
                 }
             }), {
                 fieldLabel: '备注',
                 name: 'Remark',
                 maxLength: 500,
                 xtype: 'textarea',
                 anchor: '100% -153'  // anchor width by percentage and height by raw adjustment
}],

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

                op = $.getQueryString({ ID: "op" });
                bindData();

                switch (op) {
                    case "c":
                        action = "create";
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
