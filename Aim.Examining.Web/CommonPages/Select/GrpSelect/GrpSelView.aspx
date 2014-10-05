<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="GrpSelView.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.GrpSelView" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { '1': '有效', '0': '无效' };
        var usrEditStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";

        var viewport;
        var store;
        var grid, pgBar;
        var qryParams = {};

        function onPgLoad() {
            var params = $.getAllQueryStrings() || {};
            $.each(params, function() {
                qryParams[this.name] = this.value;
            });

            setPgUI();
        }

        function setPgUI() {

            var data = adjustData(AimState["DtList"] || []);

            EntRecord = Ext.data.Record.create([
        { name: 'ID', type: 'string' },
        { name: 'GroupID', type: 'string' },
        { name: 'ParentID', type: 'string' },
        { name: 'IsLeaf', type: 'bool' },
        { name: 'Name' },
        { name: 'Code' },
        { name: 'Type' },
        { name: 'Status' },
        { name: 'Description' },
        { name: 'CreateDate' }
]);

            store = new Ext.ux.maximgb.tg.AdjacencyListStore({
                autoLoad: true,
                parent_id_field_name: 'ParentID',
                leaf_field_name: 'IsLeaf',
                data: data,
                reader: new Ext.ux.data.AimJsonReader({ id: 'ID', dsname: 'DtList', aimread: function(rd, resp, dt) {
                    if (dt) {
                        dt = adjustData(dt);
                    }
                }
                }, EntRecord),
                proxy: new Ext.ux.data.AimRemotingProxy({
                    aimbeforeload: function(proxy, options) {
                        var rec = store.getById(options.anode);
                        options.reqaction = "querychildren";
                        options.type = rec.data.Type;
                        options.CompanyId = $.getQueryString({ "ID": "CompanyId" });
                        options.tp = $.getQueryString({ "ID": "tp" });
                        options.data = { 'id': rec.id.toString(), 'type': rec.data.Type };
                    }
                })
            });

            //   store.on("load", function() {
            //      store.expandAll();
            // });

            // 工具栏
            var tlBar = new Ext.Toolbar({
                items: []
            });

            // 工具标题栏
            var titPanel = new Ext.Panel({
                hidden: true,
                tbar: tlBar,
                items: []
            });

            // 表格面板
            grid = new Ext.ux.maximgb.tg.GridPanel({
                store: store,
                frame: false,
                border: false,
                master_column_id: 'Name',
                region: 'center',
                columns: [
            { id: 'GroupID', header: 'GroupID', dataIndex: 'GroupID', hidden: true },
            new Ext.grid.CheckboxSelectionModel({ singleSelect: false, renderer: function(v, p, rec) {
                if (!IsGroupTypeRec(rec)) {
                    return '<div class="x-grid3-row-checker">&#160;</div>';
                } else {
                    return '';
                }
            }
            }),
            { id: 'Name', header: "组名", sortable: true, dataIndex: 'Name' },
            { id: 'Code', header: '编号', width: 70, sortable: true, dataIndex: 'Code' },
			{ header: "状态", width: 1, renderer: enumRender, hidden: true, sortable: true, align: 'center', dataIndex: 'Status' },
			{ id: "Description", header: "描述", width: 1, hidden: true, sortable: true, dataIndex: 'Description' },
			{ header: "创建日期", width: 1, sortable: true, hidden: true, dataIndex: 'CreateDate'}],
                autoExpandColumn: 'Name',
                tbar: titPanel
            });

            grid.on("rowmousedown", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);
                if (IsGroupTypeRec(rec)) {
                    return false;
                }
            });

            grid.on("rowclick", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);

                if (IsGroupTypeRec(rec)) {
                    return false;
                }

                if (typeof (parent.OnSelViewRowClick) == 'function') {
                    parent.OnSelViewRowClick.call(this, rec, { type: 'group' });
                }
            });

            grid.on("rowdblclick", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);

                if (IsGroupTypeRec(rec)) {
                    return false;
                }

                if (typeof (parent.OnSelViewRowDblClick) == 'function') {
                    parent.OnSelViewRowDblClick.call(this, rec, { type: 'group' });
                }
            });

            // 页面视图
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });

            store.expandAll();
        }

        function IsGroupTypeRec(rec) {
            if (rec && rec.json && rec.json.Type) {
                var t = rec.json.Type;
                if (typeof (t) == "string" && t.toLowerCase() == "gtype") {
                    return true;
                }
            }

            return false;
        }

        // 获取被选中的用户(由主显示页面调用)
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

        // 应用或模块数据适配
        function adjustData(jdata) {
            if ($.isArray(jdata)) {
                /*$.each(jdata, function() {
                if (this.GroupID) {
                this.ID = this.GroupID;
                // this.ParentID = $.isSetted(this.ParentID) ? this.ParentID : this.Type;
                } else if (this.GroupTypeID) {
                this.ID = this.GroupTypeID;
                this.Type = "GType";
                this.ParentID = null;
                this.IsLeaf = $.isSetted(this.HasGroup) ? !this.HasGroup : false;
                }
                });*/

                return jdata;
            } else {
                return [];
            }
        }

        // 枚举渲染
        function enumRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Status":
                    rtn = StatusEnum[val];
                    break;
            }

            return rtn;
        }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            组列表</h1>
    </div>
</asp:Content>
