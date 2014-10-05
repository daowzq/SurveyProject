<%@ Page Title="选项说明" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="GetPersonalAdvices.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.GetPersonalAdvices" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        /**
        Comment:问卷问题答案选项说明 Eg: this is ture.______________
        Date  : 7/8   
        Author: WGM
        **/
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var ItemId = $.getQueryString({ ID: 'ItemId' });
        var isNoName = $.getQueryString({ ID: 'isNoName' }) || 0;

        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'QuestionItemContent' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'CreateTime' }
			],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.SurveyId = SurveyId;
                    }
                }

            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
                    }
}]
                });
                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar 
                });

                // 表格面板
                grid = new Ext.ux.grid.AimEditorGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'QuestionItemContent',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'QuestionItemContent', dataIndex: 'QuestionItemContent', header: '内容', width: 200, editor: { xtype: 'textarea'} },
				    { id: 'UserName', dataIndex: 'UserName', header: '填写人', width: 100, renderer: RowRender },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '填写时间', width: 120, renderer: ExtGridDateOnlyRender }
                    ],
                    bbar: pgBar,
                    // tbar: AimState["Audit"] == 'admin' ? titPanel : ''
                    tbar: titPanel
                    //tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid]
                });
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }

            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
                    case "UserName":
                        if (isNoName = "0") {
                            rtn = value;
                        } else {
                            rtn = "<font color=gray> 匿名</font>";
                        }
                        break;
                }
                return rtn;
            }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
