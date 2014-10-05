<%@ Page Title="系统模块" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true" CodeBehind="MdlEdit.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.MdlMag.MdlEdit" %>
<%@ OutputCache Duration="1" VaryByParam="None" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<style type= "text/css"  media= "all" >  
    .allow-float  {clear:none!important;}  /* 允许该元素浮动 */    
    .stop-float  {clear:both!important;}  /* 阻止该元素浮动 */ 
    .only-float { float :left;} /* 单纯浮动 */
</style>

<script type="text/javascript">
    var PrimaryKey = "ModuleID";
    var AppMdlStatusEnum = { 1: "启用", 0: "停用" };
    var MdlTypeEnum;
    
    var viewport;
    var form;
    var op = "";
    var action = "";    // 执行提交操作类型
    var tittext = "系统模块";   // 标题字段
    var basicForm;
    var sbButton;   // 提交按钮

    function onPgLoad() {
        MdlTypeEnum = AimState["MdlTypeEnum"] || {};

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
            region: 'center',
            autolayout: true,
            items: [{
                name: PrimaryKey,
                maxLength: 36,
                hidden: true,
                hideLabel: true
            }, {
                xtype: 'textfield',
                fieldLabel: '模块名',
                name: 'Name',
                maxLength: 50,
                allowBlank: false
            }, {
                xtype: 'textfield',
                id: 'codeField',
                fieldLabel: '编号',
                name: 'Code',
                maxLength: 50,
                allowBlank: false
            }, new Ext.ux.form.AimComboBox({
                fieldLabel: '模块类型',
                name: 'Type',
                allowBlank: false,
                hiddenName: 'Type',
                enumdata: MdlTypeEnum
            }), new Ext.form.NumberField({
                flex: 0.8,
                fieldLabel: '排序号',
                name: 'SortIndex'
            }), new Ext.ux.form.AimComboBox({
                fieldLabel: '状态',
                name: 'Status',
                allowBlank: false,
                hiddenName: 'Status',
                enumdata: AppMdlStatusEnum
            }), { xtype: 'panel' }, {
                flex: 2,
                fieldLabel: 'URL',
                name: 'Url',
                maxLength: 100
            }, {
                flex: 2,
                fieldLabel: '图标',
                name: 'Icon',
                maxLength: 50
            }, {
                flex: 2,
                fieldLabel: '描述',
                name: 'Description',
                maxLength: 500,
                xtype: 'textarea'  // anchor width by percentage and height by raw adjustment
            }, {
                flex: 2,
                xtype: 'aimfieldset',
                // checkboxToggle: true,
                title: '配置属性',
                autoHeight: true,
                defaultType: 'textfield',
                collapsed: false,
                autolayout: true,
                name: 'IsEntityPage',
                items: [{
                    flex: 0.6,
                    // emptyValue: false,
                    fieldLabel: '快速搜索',
                    xtype: 'aimcheckbox',
                    id: 'IsQuickSearch',
                    name: 'IsQuickSearch'
                }, {
                    flex: 0.6,
                    fieldLabel: '快速创建',
                    xtype: 'aimcheckbox',
                    id: 'IsQuickCreate',
                    name: 'IsQuickCreate'
                }, {
                    flex: 0.6,
                    fieldLabel: '可回收',
                    xtype: 'aimcheckbox',
                    id: 'IsRecyclable',
                    name: 'IsRecyclable'
                }, {
                    flex: 2,
                    fieldLabel: '编辑页面',
                    name: 'EditPageUrl'
                }, {
                    flex: 2,
                    xtype: 'textarea',
                    fieldLabel: '编辑后操作',
                    align: 'top',
                    name: 'AfterEditScript'
                }
            ]
            }
                ],

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

            if (op != "c" && op != "cs") {
                Ext.getCmp('codeField').setDisabled(true);
            }

            switch (op) {
                case "c":
                    action = "create";
                    break;
                case "cs":
                    action = "createsub";
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
                var fdt = basicForm.getValues();
                fdt.IsQuickSearch = Ext.getCmp('IsQuickSearch').getValue();
                fdt.IsQuickCreate = Ext.getCmp('IsQuickCreate').getValue();
                fdt.IsRecyclable = Ext.getCmp('IsRecyclable').getValue();
                
                Aim.Form.submitData(fdt, act, dt, url, onProcFinished);
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
