<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="AuthGroup.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.MdlMag.AuthGroup" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var viewport, store, grid;
        var DataRecord;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            var data = adjustData(AimState["DtList"]);

            DataRecord = Ext.data.Record.create([
        { name: 'ID', type: 'string' },
        { name: 'ParentID', type: 'string' },
        { name: 'IsLeaf', type: 'bool' },
        { name: 'Name' },
        { name: 'Code' },
        { name: 'Type' },
        { name: 'Url' },
        { name: 'Status' },
        { name: 'Description' },
        { name: 'CreateDate'}]);

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
                }, DataRecord),
                proxy: new Ext.ux.data.AimRemotingProxy({
                    aimbeforeload: function(proxy, options) {
                        var rec = store.getById(options.anode);
                        options.reqaction = "querychildren";
                        options.type = rec.data.Type;
                        options.data = rec ? (rec.json || {}) : {};
                    }
                })
            });

            // 搜索栏
            var schBar = new Ext.Panel({
                collapsed: true,
                unstyled: true,
                padding: 5,
                layout: 'column',
                items: []
            });

            // 工具栏
            var tlBar = new Ext.Toolbar({
                items: [{
                    text: '其他',
                    iconCls: 'aim-icon-cog',
                    menu: [{ text: '展开下一层', handler: function() { store.expandAll(); } }]
}]
                });

                // 工具标题栏
                var titPanel = new Ext.Panel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.maximgb.tg.GridPanel({
                    store: store,
                    master_column_id: 'Name',
                    region: 'west',
                    split: true,
                    border: false,
                    width: 280,
                    minSize: 200,
                    maxSize: 500,
                    columns: [
				{ id: 'Name', header: "组分类 / 组", width: 160, sortable: true, dataIndex: 'Name' },
				{ header: "编号", width: 100, sortable: true, dataIndex: 'Code' }
      ],
                    autoExpandColumn: 'Name',
                    tbar: titPanel
                });

                grid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                    if (r.json.Type != "GType") {
                        frameContent.location.href = "AuthTree.aspx?type=group&op=r&id=" + r.json.GroupID;
                    }
                });

                // 页面视图
                viewport = new Ext.Viewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid, {
                        region: 'center',
                        margins: '0 0 0 0',
                        cls: 'empty',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src=""></iframe>'}]
                    });

                    //store.expandAll();

                    grid.getSelectionModel().selectFirstRow();
                }

                // 应用或模块数据适配
                function adjustData(jdata) {
                    if ($.isArray(jdata)) {
                        $.each(jdata, function() {
                            if (this.GroupID) {
                                this.ID = this.GroupID;
                                this.ParentID = this.ParentID;
                            }
                        });

                        return jdata;
                    } else {
                        return [];
                    }
                }

                function adjustDataold(jdata) {
                    if ($.isArray(jdata)) {
                        $.each(jdata, function() {
                            if (this.GroupID) {
                                this.ID = this.GroupID;
                                this.ParentID = $.isSetted(this.ParentID) ? this.ParentID : this.Type;
                            } else if (this.GroupTypeID) {
                                this.ID = this.GroupTypeID;
                                this.Type = "GType";
                                this.ParentID = null;
                                this.IsLeaf = $.isSetted(this.HasGroup) ? !this.HasGroup : false;
                            }
                        });

                        return jdata;
                    } else {
                        return [];
                    }
                }

                // 链接渲染
                function grpRender(val, p, rec) {
                    var rtn = val;
                    switch (this.dataIndex) {
                        case "Name":
                            rtn = "<a class='aim-ui-link'>" + val + "</a>";
                            break;
                    }

                    return rtn;
                }

                // 链接渲染
                function linkRender(val, p, rec) {
                    var rtn = val;
                    switch (this.dataIndex) {
                        case "Name":
                            rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"GrpEdit.aspx?id=" + p.value + "\")'>" + val + "</a>";
                            break;
                    }

                    return rtn;
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
