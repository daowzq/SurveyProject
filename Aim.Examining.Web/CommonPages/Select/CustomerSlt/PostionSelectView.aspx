<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="PostionSelectView.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.Select.CustomerSlt.PostionSelectView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .x-panel-body x-form
        {
            height: 0px;
        }
    </style>

    <script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

    <script type="text/javascript">

        var store, AimSelGrid;

        function onSelPgLoad() {
            setPgUI();
            $(".x-panel-ml").remove();
        }

        function setPgUI() {
            var myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };

            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'GroupID' },
		    { name: 'Name' }

			],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.deptId = $.getQueryString({ ID: 'deptId' });
                    }
                }
            });

            pgBar = new Ext.ux.AimPagingToolbar({
                displayMsg: '{0} - {1} 共:{2}条',
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            //功能按钮
            buttonPanel = new Ext.form.FormPanel({
                region: 'south',
                frame: true,
                height: 40,
                buttonAlign: 'center',
                buttons: [
                { text: '确定', handler: function() { AimGridSelect(); } },
                { text: '清除', handler: function() {
                    Aim.PopUp.ReturnValue();
                }
                },
                { text: '取消', handler: function() {
                    AimGridSelect();
                    window.close();
                } }]
                });

                schBar = new Ext.ux.AimSchPanel({
                    store: store,
                    columns: 2,
                    collapsed: false,
                    items: [{ fieldLabel: '职位', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'MName' }"} },
        				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
        				    Ext.ux.AimDoSearch(Ext.getCmp("Name"));
        				}
        				}
                    ]
                });

                tlBar = new Ext.ux.AimToolbar({
                    items: ['<font color=red>请点击复选框选择/取消选择记录</font>', '->',
            {
                text: '复杂查询',
                iconCls: 'aim-icon-search',
                hidden:true,
                handler: function() {
                    schBar.toggleCollapse(false);
                    setTimeout("viewport.doLayout()", 50);
                } }]
                });


                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });


                AimSelGrid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'Name',
                    columns: [

                    // { id: 'GroupID', header: 'GroupID', dataIndex: 'GroupID', hidden: true },
                    {id: 'GroupID', header: 'GroupID', dataIndex: 'Name', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    AimSelCheckModel,
                    //{ id: 'Name', header: '姓名', width: 100, sortable: true, dataIndex: 'Name' },
					{id: 'Name', header: '职位名称', width: 200, sortable: true, dataIndex: 'Name' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [AimSelGrid, buttonPanel]
                });
            }

            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
                    case "Status":
                        rtn = (value == "0") ? "未启用" : "启用";
                        break;
                }
                return rtn;
            }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
