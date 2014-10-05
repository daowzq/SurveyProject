<%@ Page Title="集团管理层" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="ManagerSet.aspx.cs" Inherits="Aim.Examining.Web.Modules.SysApp.SysMag.ManagerSet" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=600,height=445,scrollbars=yes");
        var EditPageUrl = "ManagementEdit.aspx";

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
			{ name: 'MGroupId' },
			{ name: 'MName' },
			{ name: 'MCode' },
			{ name: 'GroupsSet' },
			{ name: 'GroupsName' },
			{ name: 'SortIndex' },
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
                items: [
                { fieldLabel: '职位名称', id: 'MName', schopts: { qryopts: "{ mode: 'Like', field: 'MName' }"} },
                { fieldLabel: '序号', id: 'SortIndex', schopts: { qryopts: "{ mode: 'Like', field: 'SortIndex' }"}}]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        var recType = store.recordType;
                        var resc = grid.getStore().getRange();
                        var index = 0;
                        $.each(resc, function() {
                            if (parseInt(this.get("SortIndex")) > index)
                                index = parseInt(this.get("SortIndex"));
                        });
                        var rec = new recType({ SortIndex: index + 1 });
                        store.insert(store.data.length, rec);
                        var top = $(".x-grid3-body").innerHeight() - $(".x-grid3-scroller").innerHeight();
                        $(".x-grid3-scroller").scrollTop(top);
                    }
                }, {
                    text: '保存',
                    iconCls: 'aim-icon-save',
                    handler: function() {
                        // 保存修改的数据
                        var recs = store.getModifiedRecords();
                        if (recs && recs.length > 0) {
                            var dt = store.getModifiedDataStringArr(recs) || [];
                            jQuery.ajaxExec('batchsave', { "data": dt }, function() {
                                store.commitChanges();

                                AimDlg.show("保存成功！");
                            });
                        }
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
                }, '->',
                {
                    text: '复杂查询',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        schBar.toggleCollapse(false);

                        setTimeout("viewport.doLayout()", 50);
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
                    clicksToEdit: 2,
                    //autoExpandColumn: 'GroupsSet',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'MName', dataIndex: 'MName', header: '职位名称', width: 230, sortable: true, editor: { xtype: 'textfield'} },
					{ id: 'SortIndex', dataIndex: 'SortIndex', header: '序号', width: 100, sortable: true, editor: { xtype: 'textfield'} }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
