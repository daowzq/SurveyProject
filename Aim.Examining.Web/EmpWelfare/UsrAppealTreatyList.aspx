<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="UsrAppealTreatyList.aspx.cs" Inherits="Aim.Examining.Web.UsrAppealTreatyList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>
    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=680,height=540,scrollbars=yes");
        var EditPageUrl = "UsrAppealTreatyEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

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
			{ name: 'TreatyTitle' },
			{ name: 'TreatyContent' },
			{ name: "Ext1" },
			{ name: 'TreatyKey' },
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


            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function () {
                        //  ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);

                        if (openTreatyDlg()) {
                            var url = EditPageUrl + "?op=c";
                            // ExtOpenGridEditWin(grid, url, "c", EditWinStyle);
                            OpenModelWin(url, window, Modelstyle, function () {
                                store.reload();
                            });
                        }

                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function () {
                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function () {
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

            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                tbar: tlBar

            });

            // 表格面板
            grid = new Ext.ux.grid.AimGridPanel({
                store: store,
                region: 'center',
                margins: '0 10 10 0',
                // autoExpandColumn: 'Treaty',
                viewConfig: { forceFit: true, scrollOffset: 10 },
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'TreatyTitle', dataIndex: 'TreatyTitle', header: '协议标题', width: 200 },
					{ id: 'TreatyKey', dataIndex: 'TreatyKey', header: '编码', width: 200 },
					{ id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 100, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建日期', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: tlBar
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "State":
                    if (value == "1") {
                        rtn = "启用";
                    } else if (value == "0") {
                        rtn = "停用";
                    }
                    break;
            }
            return rtn;
        }
        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
        function openTreatyDlg() {
            var style = "dialogWidth:930px; dialogHeight:700px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "TreatyDialog.aspx?title=baoxian";
            var bol = false;
            OpenModelWin(url, window, style, function (rtn) {
                bol = true;
            })
            return bol;
        }

    </script>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
