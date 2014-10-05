<%@ Page Title="统计填写项" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="T_SurveyStatisticFill.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.T_SurveyStatisticFill" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var SurveyId = $.getQueryString({ ID: 'SurveyId' });
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
			{ name: 'SurveyTitile' },
			{ name: 'IsNoName' },
			{ name: 'Content' },
			{ name: 'QuestionContent' },
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
            
            $.isEmptyObject(AimState["QuestionItem"]) ? (AimState["QuestionItem"] = { '%': '请选择...' }) : (AimState["QuestionItem"]["%"] = "请选择...");
            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                columns: 4,
                collapsed: false,
                items: [
                { fieldLabel: '填写人', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                { fieldLabel: '问卷问题', id: 'Question', xtype: 'aimcombo', required: true, enumdata: AimState["QuestionItem"],
                    schopts: { qryopts: "{ mode: 'Like', field: 'QuestionItem' }" },
                    listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("Question")); } }
                },
                { fieldLabel: '回答内容', id: 'SurveyTitile', schopts: { qryopts: "{ mode: 'Like', field: 'QuestionContent' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("SurveyTitile"));   //Number 为任意
                }
                }
      ]
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
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.grid.AimEditorGridPanel({
                    store: store,
                    region: 'center',
                    viewconfig: {
                        forceFit: true//当行大小变化时始终填充满
                    },
                    autoExpandColumn: 'QuestionContent',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    //{ id: 'UserId', dataIndex: 'UserId', header: '填写人', width: 100, hidden: true },
                    {id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 100, hidden: true },
					{ id: 'SurveyTitile', dataIndex: 'SurveyTitile', header: '问卷标题', width: 150, sortable: true, renderer: RowRender },
                    //{ id: 'IsNoName', dataIndex: 'IsNoName', header: '是否匿名', width: 80, sortable: true, renderer: RowRender },
					{id: 'Content', dataIndex: 'Content', header: '问卷问题', width: 200, sortable: true },
					{ id: 'QuestionContent', dataIndex: 'QuestionContent', header: '内容', width: 200, editor: { xtype: 'textarea'} },
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
                    case "SurveyTitile":
                        if (value) {
                            rtn = value;
                        }
                        break;
                    case "IsNoName":
                        if (value == "1") {
                            rtn = "是";
                        } else {
                            rtn = "否";
                        }
                        break;
                    case "UserName":
                        if (record.get("IsNoName") != "1") {
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
