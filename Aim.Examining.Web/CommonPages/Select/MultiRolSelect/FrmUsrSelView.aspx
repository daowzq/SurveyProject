<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmUsrSelView.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.FrmUsrSelView" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/pgfunc-ext-sel.js" type="text/javascript"></script>

    <script type="text/javascript">
        var usrEditStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";

        var viewport;
        var store;
        var grid, pgBar;
        var qryParams = {};
        var pgBar;

        function onPgLoad() {
            var params = $.getAllQueryStrings() || {};
            $.each(params, function() {
                qryParams[this.name] = this.value;
            });

            setPgUI();
        }

        function setPgUI() {
            // 表格数据
            var myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["UsrList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'UsrList',
                idProperty: 'UserID',
                data: myData,
                fields: [{ name: 'UserID' }, { name: 'Name' }, { name: 'LoginName' }, { name: 'WorkNo' }, { name: 'Status'}],
                aimbeforeload: function(proxy, options) {
                    if (options.schtype != "field") {
                        // 按钮查询
                        options.data = qryParams;
                    }
                }
            });
            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });
            // 工具栏
            /*var tlBar = new Ext.ux.AimToolbar({
            items: [{ text: '查询:' }, new Ext.app.AimSearchField({ store: store, pgbar: pgBar, schbutton: true, qryopts: "{ type: 'fulltext' }" })]
            });*/

            var tlBar = new Ext.ux.AimToolbar({
                items: [{ text: '输入条件后回车查询[姓名拼音首字母]'}]
            });
            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                collapsed: false,
                columns: 2,
                padding: '0 0 0 0',
                items: [
                { fieldLabel: '姓名', id: 'Name', width: 100, schopts: { qryopts: "{ mode: 'Like', field: 'Name' }"} },
                { fieldLabel: '工号', id: 'WorkNo', width: 80, schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"}}]
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
                border: false,
                columns: [
            { id: 'UserID', header: 'UserID', dataIndex: 'UserID', hidden: true },
            new Ext.grid.MultiSelectionModel(),
            { id: 'Name', header: '姓名', width: 100, sortable: true, dataIndex: 'Name' },
             { id: 'WorkNo', header: '工号', width: 100, sortable: true, dataIndex: 'WorkNo' },
            { id: 'LoginName', header: '登录名', width: 100, sortable: true, dataIndex: 'LoginName' }
            ],
                bbar: pgBar,
                tbar: titPanel,
                stripeRows: true,
                autoExpandColumn: 'Name',
                stateId: 'grid'

            });

            grid.on("rowclick", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);

                if (typeof (parent.parent.OnSelViewRowClick) == 'function') {
                    parent.parent.OnSelViewRowClick.call(this, rec, { type: 'user' });
                }
            });

            grid.on("rowdblclick", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);

                if (typeof (parent.parent.OnSelViewRowDblClick) == 'function') {
                    parent.parent.OnSelViewRowDblClick.call(this, rec, { type: 'user' });
                }
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });
        }

        // 获取被选中的用户
        function GetSelections(type) {
            var recs = grid.getSelectionModel().getSelections();
            if (recs == null || recs.length == 0) {
                return null;
            }

            switch (type) {
                default:
                    return recs;
            }
        }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            人员列表</h1>
    </div>
</asp:Content>
