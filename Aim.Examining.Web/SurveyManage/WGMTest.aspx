<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="WGMTest.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.WGMTest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {

            Ext.QuickTips.init();
            Ext.form.Field.prototype.msgTarget = "qtip";
            var data = [
                ["1", "男", new Date(1979, 09, 06), "tom", 21, "you_5214@sina.com"],
                ["2", "女", new Date(1980, 08, 07), "tony", 46, "you_5214@sina.com"],
                ["3", "男", new Date(1990, 07, 08), "Jet Li", 31, "you_5214@sina.com"],
                ["4", "女", new Date(1910, 06, 09), "washington", 29, "you_5214@sina.com"]
    ];
            var fields = ['id', 'sex', 'brithday', 'name', 'age', 'eamil'];
            var cm = new Ext.grid.ColumnModel([
        { header: "ID", width: 60, sortable: true, dataIndex: 'id',
            editor: new Ext.form.TextField({ allowBlank: false })
        },
        { header: "性别", width: 70, sortable: true, dataIndex: 'sex',
            editor: new Ext.form.ComboBox({
                editable: false,
                allowBlank: false,
                displayField: "sex",
                valueField: "sex",
                triggerAction: "all",
                mode: "local",
                store: new Ext.data.SimpleStore({
                    fields: ["sex"],
                    data: [["男"], ["女"]]
                })
            })
        },
        { header: "生日", width: 130, sortable: true, dataIndex: 'brithday',
            editor: new Ext.form.DateField()
        },
        { header: "姓名", width: 100, sortable: true, dataIndex: 'name' },
        { header: "年龄", width: 100, sortable: true, dataIndex: 'age',
            editor: new Ext.form.NumberField({
                allowBlank: false
            })
        },
        { header: "Email", width: 120, sortable: true, dataIndex: 'eamil',
            editor: new Ext.form.TextField({
                vtype: "email"
            })
        }
    ]);
            var store = new Ext.data.GroupingStore({
                data: data,
                reader: new Ext.data.ArrayReader({ id: "id" }, fields)
            });
            var gridForm = new Ext.FormPanel({
                id: 'user_info',
                applyTo: Ext.getBody(),
                frame: true,
                autoHeight: true,
                labelAlign: 'left',
                title: '员工信息表',
                bodyStyle: 'padding:5px',
                width: 600,
                items: [new Ext.grid.GridPanel({
                    title: "人员信息列表",
                    width: 600,
                    autoHeight: true,
                    fram: true,
                    cm: cm,
                    store: store,
                    sm: new Ext.grid.RowSelectionModel({
                        singleSelect: true,
                        listeners: {
                            rowselect: function(sm, row, rec) {
                                Ext.getCmp("user_info").getForm().loadRecord(rec);
                            }
                        }
                    }),
                    view: new Ext.grid.GroupingView({
                        hideGroupedColumn: true,
                        showGroupsText: "分组显示",
                        groupByText: "使用当前字段排序",
                        forceFit: true,
                        columnsText: "隐藏/显示字段",
                        sortAscText: "升序排列",
                        sortDescText: "降序排列"
                    })
                }), {
                    xtype: 'fieldset',
                    labelWidth: 150,
                    title: '加载grid信息内容',
                    defaultType: 'textfield',
                    autoHeight: true,
                    items: [{
                        fieldLabel: 'ID',
                        name: 'id',
                        anchor: '55%'
                    }, {
                        fieldLabel: '性别',
                        name: 'sex',
                        anchor: '55%'
                    }, {
                        fieldLabel: '生日',
                        name: 'brithday',
                        anchor: '55%'
                    }, {
                        fieldLabel: '年龄',
                        name: 'age',
                        anchor: '55%'
                    }, {
                        fieldLabel: '邮箱',
                        name: 'eamil',
                        anchor: '55%'
}]
}]
                    });

                }
     
       
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
