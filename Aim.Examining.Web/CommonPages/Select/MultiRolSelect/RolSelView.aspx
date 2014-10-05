<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="RolSelView.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.RolSelView" %>
<%@ OutputCache Duration="1" VaryByParam="None" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var RolTypeEnum = {};
    var usrEditStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";
    
    var viewport;
    var store;
    var grid;
    var qryParams = {};
    var cid;    // 分类id

    function onPgLoad() {
        cid = $.getQueryString({ 'ID': 'cid', 'DefaultValue': false });
        
        var params = $.getAllQueryStrings() || {};
        $.each(params, function() {
            qryParams[this.name] = this.value;
        });

        RolTypeEnum = AimState["RolTypeEnum"] || {};
    
        setPgUI();
    }

    function setPgUI() {
        var reader = new Ext.data.JsonReader({
            idProperty: 'RoleID',
            fields: [
            { name: 'RoleID' }, 
            { name: 'Name' }, 
            { name: 'Code' }, 
            { name: 'Type' }, 
            { name: 'SortIndex' }, 
            { name: 'Description'}]
        });

        // 表格数据源
        store = new Ext.ux.data.AimGroupingStore({
            dsname: 'DtList',
            idProperty: 'RoleID',
            data: AimState["DtList"] || [],
            groupField: 'Type',
            reader:reader
        });

        // 工具栏
        var tlBar = new Ext.ux.AimToolbar({
            items: [{ text: '查询:' }, new Ext.app.AimSearchField({ schbutton: true, aimhandler: function(val) {
                if (val) {
                    store.filterBy(function(rec) {
                        if (rec.json) {
                            var lowerVal = val.toLowerCase();
                            if (rec.json.Name.contains(val, true) || rec.json.Code.contains(val, true)) {
                                return true;
                            }
                        }
                    });
                } else {
                    store.clearFilter();
                }
            }
            })]
        });

        var gconfig = {
            store: store,
            region: 'center',
            border: false,
            columns: [
            { id: 'RoleID', header: 'RoleID', dataIndex: 'RoleID', hidden: true },
            new Ext.grid.CheckboxSelectionModel({ singleSelect: false }),
            { id: 'Name', header: '角色名', width: 100, sortable: true, dataIndex: 'Name' },
            { id: 'Code', header: '编号', width: 100, sortable: true, dataIndex: 'Code' },
            { id: 'Type', header: '类型', renderer: enumRender, groupRenderer: groupRender, width: 100, sortable: true, hidden: true, dataIndex: 'Type' }
            ],
            tbar: tlBar,
            stripeRows: true,
            autoExpandColumn: 'Name'
        }

        if (!cid) {
            gconfig.view = new Ext.grid.GroupingView({
                forceFit: true,
                groupTextTpl: '{group} ({[values.rs.length]} 项)'
            });
        }

        // 表格面板
        grid = new Ext.grid.GridPanel(gconfig);

        grid.on("rowclick", function(grid, rowIndex, e) {
            var rec = grid.store.getAt(rowIndex);

            if (typeof (parent.OnSelViewRowClick) == 'function') {
                parent.OnSelViewRowClick.call(this, rec, { type: 'role' });
            }
        });

        grid.on("rowdblclick", function(grid, rowIndex, e) {
            var rec = grid.store.getAt(rowIndex);

            if (typeof (parent.OnSelViewRowDblClick) == 'function') {
                parent.OnSelViewRowDblClick.call(this, rec, { type: 'role' });
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

    // 枚举渲染
    function enumRender(val, p, rec) {
        var rtn = val;
        switch (this.dataIndex) {
            case "Type":
                rtn = RolTypeEnum[val];
                break;
        }

        return rtn;
    }

    // 组标题渲染
    function groupRender(val, p, rec) {
        return RolTypeEnum[val];
    }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>人员列表</h1></div>
</asp:Content>
