<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="RoluserList.aspx.cs" Inherits="Aim.Examining.Web.RoluserList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var StatusEnum = { '1': '有效', '0': '无效' };

        var formStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";
        // 角色编辑框样式
        var roleTypeFormStyle = "dialogWidth:450px; dialogHeight:250px; scroll:yes; center:yes; status:no; resizable:yes;";

        var viewport;
        var store, roleStore;
        var tabs;
        var grid, roleTypeGrid;
        var rolTypeSchField;
        var rolID;
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            // 表格数据
            var myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["UserList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'UserList',
                idProperty: 'UserID',
                data: myData,
                fields: [{ name: 'UserID' }, { name: 'Name' }, { name: 'LoginName' }, { name: 'WorkNo' },
                    { name: 'Status' }, { name: 'Phone' }, { name: 'Email' }, { name: 'Remark' },
                    { name: 'CreateDate', type: 'date' }, { name: 'Rolid' }]
                , listeners: {
                    "aimbeforeload": function (proxy, options) {

                        if (rolTypeSchField) {
                            var rolTypeID = rolTypeSchField.getValue();
                            rolID = rolTypeID;
                            options.data.Rolid = rolTypeID;
                        }
                    }
                }
            });

            roleStore = new Ext.ux.data.AimJsonStore({
                dsname: 'RoleList',
                idProperty: 'RoleID',
                data: { records: AimState["RoleList"] || [] },
                fields: [{ name: 'RoleID' }, { name: 'Name' }, { name: 'Code' }, { name: 'Description' },
                    { name: 'SortIndex' }, { name: 'CreateDate', type: 'date' }, { name: 'CompanyIds' }, { name: 'CompanyNames' }]
            });

            var roleTypeTlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function () {
                        openMdlWin("RolEdits.aspx", "c", roleTypeFormStyle, roleTypeGrid);
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function () {
                        openMdlWin("RolEdits.aspx", "u", roleTypeFormStyle, roleTypeGrid);
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function () {
                        openMdlWin("RolEdits.aspx", "d", roleTypeFormStyle, roleTypeGrid);
                    }
                }]
            });

            roleTypeGrid = new Ext.ux.grid.AimGridPanel({
                id: 'rolePanel',
                store: roleStore,
                region: 'west',
                split: true,
                width: 700,
                minSize: 120,
                maxSize: 800,
                margins: '0 0 5 5',
                cmargins: '0 5 5 5',
                columns: [
                  { id: 'RoleID', header: 'RoleID', dataIndex: 'RoleID', hidden: true },
                  new Ext.ux.grid.AimRowNumberer(),
                  { id: 'Name', header: '角色名', width: 100, renderer: roleTypeRender, sortable: false, dataIndex: 'Name' },
                  { id: 'Code', header: '编号', width: 100, sortable: false, dataIndex: 'Code' },
                  { id: 'CompanyNames', header: '公司权限', width: 100, sortable: false, dataIndex: 'CompanyNames' }
                ],
                autoExpandColumn: 'CompanyNames',
                tbar: roleTypeTlBar
            });

            roleTypeGrid.getSelectionModel().on('rowselect', function (sm, rowIdx, r) {
                rolTypeSchField.setValue(r.data.RoleID);
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

            rolTypeSchField = new Ext.app.AimSearchField({ fieldLabel: '', anchor: '90%', name: 'Code', hidden: true, hideLable: true, store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Equal', field: 'Code' }" });

            // 搜索栏
            var schBar = new Ext.ux.AimSchPanel({
                store: store,
                collapsed: true,
                columns: 3,
                items: [
            { fieldLabel: '姓名', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'Name' }" } },
            { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }" } },
            {
                fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '1 30 0 0', text: '查 询', handler: function () {
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
                    handler: function () {
                        if (rolID) {
                            OpenUserSel(rolID);
                        }
                        else {
                            alert("请先选择角色");
                        }
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function () {
                        var userid = "";
                        var sels = grid.getSelectionModel().getSelections();
                        if (sels.length == 0) {
                            alert("请选择要删除的人员!"); return;
                        }
                        else {
                            for (var i = 0; i < sels.length; i++) {
                                userid += sels[i].json.UserID + ',';
                            }
                        }
                        if (!window.confirm("确定删除？")) return;
                        jQuery.ajaxExec('deleteusers', { "id": rolID, userids: userid }, function (rtn) {
                            if (rtn) {
                                alert("删除成功!");
                                store.reload();
                            }
                        });
                    }
                }, '->', {
                    text: '复杂查询',
                    iconCls: 'aim-icon-search',
                    handler: function () {
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
                 { id: 'UserID', header: 'UserID', dataIndex: 'UserID', hidden: true },
                new Ext.ux.grid.AimRowNumberer(),
                new Ext.ux.grid.AimCheckboxSelectionModel(),
                { id: 'Name', header: '姓名', width: 100, sortable: true, dataIndex: 'Name' },
                { id: 'WorkNo', header: '工号', width: 100, sortable: true, dataIndex: 'WorkNo' },
                { id: 'Status', header: '状态', width: 100, align: 'center', renderer: enumRender, sortable: true, dataIndex: 'Status', hidden: true },
                { id: 'Phone', header: '电话', width: 100, sortable: true, dataIndex: 'Phone' },
                { id: 'Email', header: '邮箱', width: 150, sortable: true, dataIndex: 'Email' },
                { id: 'Remark', header: '备注', width: 65, sortable: true, dataIndex: 'Remark', hidden: true },
                { id: 'CreateDate', header: '创建时间', width: 150, align: 'center', hidden: true, renderer: Ext.util.Format.dateRenderer('m/d/Y'), dataIndex: 'CreateDate' }],
                bbar: pgBar,
                tbar: titPanel,
                frame: true,
                forceLayout: true,
                stripeRows: true,
                autoExpandColumn: 'Remark',
                stateful: true,
                stateId: 'grid'
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, roleTypeGrid, grid]
            });

            //roleTypeGrid.getSelectionModel().selectFirstRow();
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


        function OpenUserSel(id) {
            //{ id: 'Users', header: '人员', width: 50, renderer: linkRender, sortable: true, dataIndex: 'Users' },
            jQuery.ajaxExec('getusers', { "id": id }, function (rtn) {
                if (rtn) {

                    var usrIds = rtn.data.UserId;
                    var names = rtn.data.UserName;
                    var style = "dialogWidth:750px; dialogHeight:550px; scroll:yes; center:yes; status:no; resizable:yes;";
                    var url = "/CommonPages/Select/UsrSelect/MUsrSelect.aspx?rtntype=array";
                    url += "&UserID=" + usrIds + "&Name=" + names;
                    var insRowIdx = store.data.length;
                    OpenModelWin(url, {}, style, function () {
                        if (this.data == null) return;
                        var userIds = "";
                        for (var i = 0; i < this.data.length; i++) {
                            userIds += this.data[i].UserID + ",";
                        }
                        jQuery.ajaxExec('setusers', { "id": id, userids: userIds }, function (rtn) {
                            store.reload();
                        });
                    });
                }
            });
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
                    params[params.length] = "type=" + rolTypeSel.json.RoleID;
                }
            } else if (sel) {
                if (url.indexOf("id=") < 0) {
                    params[params.length] = "id=" + (sel.json.RoleID || sel.json.RoleID).toString();
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
                        roleStore.reload();
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
        <h1>角色列表</h1>
    </div>
</asp:Content>
