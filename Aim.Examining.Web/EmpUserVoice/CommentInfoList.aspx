<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="CommentInfoList.aspx.cs" Inherits="Aim.Examining.Web.CommentInfoList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "CommentInfoEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["CommentInfoList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'CommentInfoList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'Title' },
			{ name: 'Contents' },
			{ name: 'comment' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' }
			]
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                collapsed: false,
                columns: 4,
                items: [
                 { fieldLabel: '标题', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                { fieldLabel: '内容', id: 'Contents', schopts: { qryopts: "{ mode: 'Like', field: 'Contents' }"} },
                { fieldLabel: '评论', id: 'comment', schopts: { qryopts: "{ mode: 'Like', field: 'comment' }"} },
                { fieldLabel: '查询', xtype: 'button', iconCls: 'aim-icon-search', width: 60, text: '查询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("comment"));
                }
                }
                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: []
            });

            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                items: [schBar]
            });

            // 表格面板
            grid = new Ext.ux.grid.AimGridPanel({
                store: store,
                region: 'center',
                autoExpandColumn: 'comment',
                margins: '0 10 10 0',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Title', dataIndex: 'Title', header: '标题', width: 100, sortable: true },
					{ id: 'Contents', dataIndex: 'Contents', header: '内容', linkparams: { url: EditPageUrl, style: EditWinStyle }, width: 100, sortable: true },
					{ id: 'comment', dataIndex: 'comment', header: '我的评论', width: 100, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '评论时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });
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
