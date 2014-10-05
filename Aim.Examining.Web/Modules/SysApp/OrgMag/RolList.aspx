<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="RolList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.OrgMag.RolList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var StatusEnum = { '1': '有效', '0': '无效' };

        var formStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";
        // 角色编辑框样式
        var roleTypeFormStyle = "dialogWidth:450px; dialogHeight:100px; scroll:yes; center:yes; status:no; resizable:yes;";

        var viewport;
        var store, roleTypeStore;
        var tabs;
        var grid, roleTypeGrid;
        var rolTypeSchField;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            // 表格数据
            var myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["RoleList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'RoleList',
                idProperty: 'RoleID',
                data: myData,
                fields: [{ name: 'RoleID' }, { name: 'Name' }, { name: 'Code' }, { name: 'Description' }, { name: 'SortIndex' }, { name: 'CreateDate', type: 'date'}]
            , listeners: { "aimbeforeload": function(proxy, options) {
                options.schcrit = options.schcrit || {};
                var rolTypeID = parseInt(rolTypeSchField.getValue());
                var schs = options.schcrit["ccrit"] = options.schcrit["ccrit"] || [];
                var flag = false;

                $.each(schs, function(i) {
                    if (this["PropertyName"] == "Type") {
                        this["Value"] = rolTypeID;
                        flag = true;
                    }
                });

                if (!flag) {
                    schs[schs.length] = { PropertyName: "Type", "Value": rolTypeID };
                }
            }
            }
            });

            roleTypeStore = new Ext.ux.data.AimJsonStore({
                dsname: 'RoleTypeList',
                idProperty: 'RoleTypeID',
                data: { records: AimState["RoleTypeList"] || [] },
                fields: [{ name: 'RoleTypeID' }, { name: 'Name'}]
            });

            var roleTypeTlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openMdlWin("RolTypeEdit.aspx", "c", roleTypeFormStyle, roleTypeGrid);
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openMdlWin("RolTypeEdit.aspx", "u", roleTypeFormStyle, roleTypeGrid);
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        openMdlWin("RolTypeEdit.aspx", "d", roleTypeFormStyle, roleTypeGrid);
                    }
}]
                });

                roleTypeGrid = new Ext.ux.grid.AimGridPanel({
                    id: 'roleTypePanel',
                    store: roleTypeStore,
                    region: 'west',
                    split: true,
                    width: 250,
                    minSize: 120,
                    maxSize: 400,
                    margins: '0 0 5 5',
                    cmargins: '0 5 5 5',
                    columns: [
            { id: 'RoleTypeID', header: 'RoleTypeID', dataIndex: 'RoleTypeID', hidden: true },
            { id: 'Name', header: '角色类型', width: 100, renderer: roleTypeRender, sortable: true, dataIndex: 'Name' }
            ],
                    autoExpandColumn: 'Name',
                    tbar: roleTypeTlBar
                });

                roleTypeGrid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                    rolTypeSchField.setValue(r.data.RoleTypeID);
                    store.reload();
                });

                // 分页栏
                var pgBar = new Ext.ux.AimPagingToolbar({
                    pageSize: AimSearchCrit["PageSize"],
                    store: store,
                    displayInfo: true,
                    displayMsg: '当前条目 {0} - {1}, 总条目 {2}',
                    emptyMsg: "无条目显示",
                    items: ['-']
                });

                rolTypeSchField = new Ext.app.AimSearchField({ fieldLabel: '', anchor: '90%', name: 'Type', hidden: true, hideLable: true, store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Equal', field: 'Type' }" });

                // 搜索栏
                var schBar = new Ext.ux.AimSchPanel({
                    store: store,
                    collapsed: false,
                    columns: 5,
                    items: [
                { fieldLabel: '角色名', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'Name' }"} },
                { fieldLabel: '编码', id: 'Code', schopts: { qryopts: "{ mode: 'Like', field: 'Code' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '1 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Name"));
                }
                }
                ]
                });

                // 工具栏
                var tlBar = new Ext.ux.AimToolbar({
                    items: [{
                        text: '添加',
                        iconCls: 'aim-icon-add',
                        handler: function() {
                            openMdlWin("RolEdit.aspx", "c");
                        }
                    }, {
                        text: '修改',
                        iconCls: 'aim-icon-edit',
                        handler: function() {
                            openMdlWin("RolEdit.aspx", "u");
                        }
                    }, {
                        text: '删除',
                        iconCls: 'aim-icon-delete',
                        handler: function() {
                            openMdlWin("RolEdit.aspx", "d");
                        }
                    }, '-', {
                        text: '其他',
                        iconCls: 'aim-icon-cog',
                        menu: [{ text: '刷新系统角色', handler: function() { $.ajaxExec("refreshsys"); } }]
                    }, '->', {
                        text: '复杂查询',
                        iconCls: 'aim-icon-search',
                        handler: function() {
                            schBar.toggleCollapse(false);

                            setTimeout("viewport.doLayout()", 50);
                        }
}]
                    });

                    // 工具标题栏
                    var titPanel = new Ext.ux.AimPanel({
                        tbar: tlBar,
                        items: [schBar]
                    });

                    // 表格面板
                    grid = new Ext.ux.grid.AimGridPanel({
                        store: store,
                        region: 'center',
                        monitorResize: true,
                        columns: [
            { id: 'RoleID', header: 'RoleID', dataIndex: 'RoleID', hidden: true },
            new Ext.ux.grid.AimRowNumberer(),
            new Ext.ux.grid.AimCheckboxSelectionModel(),
            { id: 'Name', header: '角色名', width: 100, renderer: linkRender, sortable: true, dataIndex: 'Name' },
            { id: 'Code', header: '编号', width: 100, sortable: true, dataIndex: 'Code' },
            { id: 'Description', header: '描述', width: 65, sortable: true, dataIndex: 'Description' },
            { id: 'CreateDate', header: '创建时间', width: 150, align: 'center', renderer: Ext.util.Format.dateRenderer('m/d/Y'), dataIndex: 'CreateDate' }
            ],
                        bbar: pgBar,
                        tbar: titPanel,
                        frame: true,
                        forceLayout: true,
                        stripeRows: true,
                        autoExpandColumn: 'Description',
                        stateful: true,
                        stateId: 'grid'
                    });

                    // 页面视图
                    viewport = new Ext.ux.AimViewport({
                        layout: 'border',
                        items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, roleTypeGrid, grid]
                    });

                    roleTypeGrid.getSelectionModel().selectFirstRow();
                }

                // 链接渲染
                function roleTypeRender(val, p, rec) {
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
                            rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"RolEdit.aspx?id=" + rec.id + "\")'>" + val + "</a>";
                            break;
                        case "Users":
                            rtn = "<a class='aim-ui-link' onclick='OpenUserSel();'>人员</a>";
                            break;
                    }

                    return rtn;
                }

                function OpenUserSel() {
                    //{ id: 'Users', header: '人员', width: 50, renderer: linkRender, sortable: true, dataIndex: 'Users' },
                    var rec = grid.getSelectionModel().getSelections()[0];
                    var param = "&UserID=1231233123&Name=管理员";
                    var PopUrl = "/CommonPages/Select/UsrSelect/MUsrSelect.aspx?AfterPopUp=AfterUserSel" + param;
                    var rtn = window.showModalDialog(PopUrl, window, "dialogWidth:700px;dialogHeight:500px;");
                    if (rtn) {
                        rtn.data.UserID;
                        rtn.data.Name;
                        alert(rtn);
                    }
                }
                function AfterUserSel(rtn) {
                    alert(rtn);
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

                // 打开模态窗口
                function openMdlWin(url, op, style, grd) {
                    op = op || "r";
                    style = style || formStyle;

                    grd = grd || grid;

                    var rolTypeSels = roleTypeGrid.getSelectionModel().getSelections();
                    var rolTypeSel;
                    if (rolTypeSels.length > 0) rolTypeSel = rolTypeSels[0];

                    var sels = grd.getSelectionModel().getSelections();
                    var sel;
                    if (sels.length > 0) sel = sels[0];

                    var params = [];
                    params[params.length] = "op=" + op;

                    if (op == "c") {
                        if (rolTypeSel && url.indexOf("type=") < 0) {
                            params[params.length] = "type=" + rolTypeSel.json.RoleTypeID;
                        }
                    } else if (sel) {
                        if (url.indexOf("id=") < 0) {
                            params[params.length] = "id=" + (sel.json.RoleID || sel.json.RoleTypeID).toString();
                        }
                    } else {
                        AimDlg.show('请选择需要操作的行。', '提示', 'alert');
                        return;
                    }

                    url = $.combineQueryUrl(url, params)
                    rtn = window.showModalDialog(url, window, style);
                    if (rtn && rtn.result) {
                        if (rtn.result === 'success') {
                            if (grd == roleTypeGrid) {
                                roleTypeStore.reload();
                            } else {
                                store.reload();
                            }
                        }
                    }
                }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            角色列表</h1>
    </div>
</asp:Content>
