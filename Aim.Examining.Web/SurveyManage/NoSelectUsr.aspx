<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="NoSelectUsr.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.NoSelectUsr" %>

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
			{ name: 'UserID' },
			{ name: 'Name' },
			{ name: 'WorkNo' },
		     { name: 'JobName' }
			],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.Sex = $.getQueryString({ ID: "Sex" }) + "";
                        options.data.OrgIds = $.getQueryString({ ID: "OrgIds" }) + "";
                        options.data.PostionNames = $.getQueryString({ ID: "PostionNames" }) + "";
                        options.data.AgeRange = $.getQueryString({ ID: "AgeRange" }) + "";
                        options.data.StartWorkTime = $.getQueryString({ ID: "StartWorkTime" }) + "";
                        options.data.UntileWorkTime = $.getQueryString({ ID: "UntileWorkTime" }) + "";
                        options.data.WorkAge = $.getQueryString({ ID: "WorkAge" }) + "";
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
                buttons: [{ text: '确定', handler: function() { AimGridSelect(); } }, { text: '取消', handler: function() {
                    window.close();
                } }]
                });

                schBar = new Ext.ux.AimSchPanel({
                    store: store,
                    columns: 2,
                    collapsed: true,
                    items: [{ fieldLabel: '姓名', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'C.Name' }"} },
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
                    //autoExpandColumn: 'GroupName',
                    columns: [
                    { id: 'Id', header: '标识', dataIndex: 'Id', hidden: true },
                    { id: 'UserID', header: '用户ID', dataIndex: 'UserID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    AimSelCheckModel,
					 { id: 'Name', header: '姓名', width: 100, sortable: true, dataIndex: 'Name' },
					 { id: 'WorkNo', header: '工号', width: 100, dataIndex: 'WorkNo' },
				    { id: 'JobName', header: '职位', width: 200, sortable: true, dataIndex: 'JobName' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [AimSelGrid, buttonPanel]
                });

                if (store.getRange() <= 0) {
                    AimDlg.show("没有筛选到要排除的人员!");
                    return;
                }
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
