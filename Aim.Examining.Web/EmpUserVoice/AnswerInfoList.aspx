<%@ Page Title="我的回答" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="AnswerInfoList.aspx.cs" Inherits="Aim.Examining.Web.AnswerInfoList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "AnswerInfoEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["AnswerInfoList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'AnswerInfoList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'Title' },
			{ name: 'Contents' },
			{ name: 'Answer' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'QuestionContent' },
			{ name: 'CreateTime' }
			]
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });


            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        // ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }

                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
}]
                });

                // 搜索栏
                schBar = new Ext.ux.AimSchPanel({
                    store: store,
                    collapsed: false,
                    column: 3,
                    items: [
                { fieldLabel: '标题', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                { fieldLabel: '内容', id: 'Contents', schopts: { qryopts: "{ mode: 'Like', field: 'Contents' }"} },
                { fieldLabel: '查询', xtype: 'button', iconCls: 'aim-icon-search', width: 60, text: '查询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Contents"));
                }
                }
                ]
                });



                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'Answer',
                    margins: '0 10 10 0',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                            new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'QuestionContent', dataIndex: 'QuestionContent', header: '问题', width: 200, sortable: true },
					{ id: 'Answer', dataIndex: 'Answer', header: '我的回答', width: 200, sortable: true, renderer: RowRender },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '回答时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
                    case "Contents":
                        break;
                    case "Answer":
                        if (value) {
                            value = value || "";
                            cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                            rtn = value;
                        }
                        break;
                }
                return rtn;
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
