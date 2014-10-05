<%@ Page Title="接收人员选择" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master"
    AutoEventWireup="true" CodeBehind="FrmNeedUserSelect.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.Select.FrmNeedUserSelect" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

    <script type="text/javascript">
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onSelPgLoad() {
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
			    { name: 'UserID' },
			    { name: 'WorkNo' },
			    { name: 'Name'}]
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            var buttonPanel = new Ext.form.FormPanel({
                region: 'south',
                frame: true,
                buttonAlign: 'center',
                buttons: [{ text: '确定', handler: function() { AimGridSelect(); } }, {
                    text: '取消', handler: function() {
                        window.close();
                    }
}]
                });

                // 分页栏
                pgBar = new Ext.ux.AimPagingToolbar({
                    pageSize: AimSearchCrit["PageSize"],
                    store: store
                });

                // 搜索栏
                schBar = new Ext.ux.AimSchPanel({
                    store: store,
                    columns: 3,
                    collapsed: false,
                    items: [
                { fieldLabel: '姓名', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'Name' }"} },
                { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                {
                    items: [{
                        fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', style: { marginRight: '30px' }, text: '查 询', handler: function() {
                            Ext.ux.AimDoSearch(Ext.getCmp("Name"));
                        }
}]
}]
                });

                // 工具栏
                tlBar = new Ext.ux.AimToolbar({
                    items: ['<font color=red style="font-size:12px;">请点击复选框选择/取消选择记录</font>']
                });

                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });

                //Ext.override(Ext.grid.CheckboxSelectionModel, {
                //    handleMouseDown: function(g, rowIndex, e) {
                //        if (e.button !== 0 || this.isLocked()) {
                //            return;
                //        }
                //        var view = this.grid.getView();
                //        if (e.shiftKey && !this.singleSelect && this.last !== false) {
                //            var last = this.last;
                //            this.selectRange(last, rowIndex, e.ctrlKey);
                //            this.last = last; // reset the last     
                //            view.focusRow(rowIndex);
                //        } else {
                //            var isSelected = this.isSelected(rowIndex);
                //            if (isSelected) {
                //                this.deselectRow(rowIndex);
                //            } else if (!isSelected || this.getCount() > 1) {
                //                this.selectRow(rowIndex, true);
                //                view.focusRow(rowIndex);
                //            }
                //        }
                //    }
                //});

                // 表格面板
                grid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'Name',
                    columns: [
                { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                new Ext.ux.grid.AimRowNumberer(),
                AimSelCheckModel,
                { id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 120, sortable: true },
                { id: 'Name', dataIndex: 'Name', header: '姓名', width: 200, sortable: true }
                    //{ id: 'Name', dataIndex: 'Name', header: '部门名称', width: 200, sortable: true },
                    // { id: 'Post', dataIndex: 'Post', header: '岗位', width: 200, sortable: true, hidden: true }*/
                ], viewConfig: {
                    scrollOffset: 0
                },
                    bbar: pgBar,
                    tbar: titPanel,
                    sm: new Ext.grid.CheckboxSelectionModel()
                });
                AimSelGrid = grid;
                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid, buttonPanel]
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
