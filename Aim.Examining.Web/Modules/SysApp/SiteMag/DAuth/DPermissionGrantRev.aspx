<%@ Page Title="动态权限反向授权" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DPermissionGrantRev.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DPermissionGrantRev" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>
    <script src="/js/ext/ux/TabScrollerMenu.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var EntRecord, store;
        var viewport, grid, pcTab;
        var gd = "o";   // 授权方向（正向授权p, 反向授权o）
        var AllowOps = [];
        var OpDivChar = ',';
        var id, type, pcatalog;   // 授权对象id, 授权对象类型, 授权类型

        function onPgLoad() {
            gd = $.getQueryString({ "ID": "gd", "DEFAULT": "o" });
            id = $.getQueryString({ "ID": "id" });
            type = $.getQueryString({ "ID": "type" });

            AllowOps = AimState["AllowOperation"] || [];
            OpDivChar = AimState["OpDivChar"] || ',';   // 操作分割符
            
            setPgUI();
        }

        function OPColumnName(code) {
            return "OP_" + code;
        }

        function FormatOpData(data) {
            var opstr = "";
            $.each(AllowOps, function() {
                if (data[OPColumnName(this.Code)] == true) {
                    opstr += this.Code + OpDivChar;
                }
                delete (data[OPColumnName(this.Code)]);
            });

            opstr = opstr.trimEnd(OpDivChar);

            data.Operation = opstr;

            return data;
        }

        function setPgUI() {
            var data = AimState["EntList"] || [];
            var pCatalogData = AimState["PCatalogList"] || [];

            fields = [
			{ name: 'DynamicAuthID' },
			{ name: 'Name' },
			{ name: 'CatalogCode' },
			{ name: 'ParentID' },
			{ name: 'Path' },
			{ name: 'PathLevel' },
			{ name: 'IsLeaf' },
			{ name: 'Data' },
			{ name: 'EditStatus' },
			{ name: 'Creatable' },
			{ name: 'Deletable' },
			{ name: 'Editable' },
			{ name: 'Grantable' },
			{ name: 'Tag' },
			{ name: 'Description' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate'}];

			$.each(AllowOps, function() {
                fields.push({ name: (OPColumnName(this.Code)), defaultValue: false });
            });

            EntRecord = Ext.data.Record.create(fields);

            store = new Ext.ux.maximgb.tg.AdjacencyListStore({
                autoLoad: true,
                parent_id_field_name: 'ParentID',
                leaf_field_name: 'IsLeaf',
                data: data,
                reader: new Ext.ux.data.AimJsonReader({ id: 'DynamicAuthID', dsname: 'EntList' }, EntRecord),
                proxy: new Ext.ux.data.AimRemotingProxy({
                    aimbeforeload: function(proxy, options) {
                        options.id = options.anode;
                    }
                })
            });

            grid = buildGrid();

            var scrollerMenu = new Ext.ux.TabScrollerMenu({
                menuPrefixText: '项目',
                maxText: 15,
                pageSize: 5
            });

            var pgTabItems = [];

            $.each(pCatalogData, function(i) {
                var grantUrl = ((gd == "o") ? this.OppositeGrantUrl : this.PositiveGrantUrl);

                if (grantUrl) {
                    var titem = { title: this.Name, id: this.DynamicPermissionCatalog, code: this.Code, granturl: grantUrl };
                    titem.listeners = { activate: handleActivate };
                    titem.html = "<div style='display:none;'></div>";

                    pgTabItems.push(titem);
                }
            });

            pcTab = new Ext.TabPanel({
                enableTabScroll: true,
                defaults: { autoScroll: true },
                plugins: [scrollerMenu],
                region: 'north',
                margins: '0 0 0 0',
                activeTab: 0,
                width: document.body.offsetWidth - 5,
                height: 10,
                border: 0,
                items: pgTabItems
            });

            // 页面视图
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, {
                    layout: 'border',
                    region: 'west',
                    width: 250,
                    minSize: 250,
                    maxSize: 500,
                    margins: '0 0 0 0',
                    items: [pcTab, {
                        region: 'center',
                        margins: '0 0 0 0',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src=""></iframe>'}]
                    }, grid]
                });

                handleActivate();
            }

            function buildGrid() {
                var chkCols = [];

                if (AllowOps && $.isArray(AllowOps)) {
                    $.each(AllowOps, function() {
                        chkCols.push(new Ext.ux.grid.AimCheckColumn({ header: this["Name"], dataIndex: OPColumnName(this["Code"]), defaultValue: this["Deafult"], align: 'center' }));
                    });
                };

                // 搜索栏
                var schBar = new Ext.ux.AimSchPanel({});

                // 工具栏
                var tlBar = new Ext.ux.AimToolbar({
                    items: [{
                        id:'btnSave',
                        text: '保存',
                        iconCls: 'aim-icon-save',
                        handler: function() {
                            DoSave(onExecuted);
                        }
                    }, '-', {
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
                    region: 'center',
                    plugins: chkCols,
                    split: true,
                    columns: [
		            { id: 'Name', header: "权限名", width: 200, sortable: true, dataIndex: 'Name' },
		            { header: "权限信息", width: 100, sortable: true, hidden: true, dataIndex: 'Data' },
		            { header: "描述", width: 100, sortable: true, hidden: true, dataIndex: 'Description' }
          ],
                autoExpandColumn: 'Name',
                tbar: titPanel
            });

            $.each(chkCols, function() {
                grid.addColumn(this, null, null, false);
            });

            return grid;
        }

        function OnSelViewRowClick(rec, param) {
            id = rec.id;
            type = param['type'];

            if (type == 'group') {
                if (rec.json && (rec.json.GroupTypeID || rec.json.GroupTypeID == 0)) {
                    Ext.getCmp('btnSave').setDisabled(true);
                } else {
                    Ext.getCmp('btnSave').setDisabled(false);
                }
            } else if (type == 'role') {
                
            } else {
                Ext.getCmp('btnSave').setDisabled(false);
            }

            ResetPermission();
        }

        // 重设权限
        function ResetPermission() {
            if (id && type) {
                $.ajaxExec('getpermission', { 'id': id, 'type': type }, OnGetPermissionFinished, null, null, "处理中...");
            }
        }

        // 重设操作状态
        function OnGetPermissionFinished(rtn) {
            if (rtn.data) {
                ResetOpChkColumn();
                
                var pls = rtn.data.DPList || [];
                $.each(pls, function() {
                    var tpl = this;
                    var rec = store.getById(tpl.AuthID);

                    if (rec && tpl.Operation) {
                        $.each(AllowOps, function() {
                            var opcolname = OPColumnName(this.Code);
                            rec.permissionid = tpl.DynamicPermissionID;
                            rec.set(opcolname, tpl.Operation.indexOf(this.Code) >= 0);
                        });
                    }
                });
                
                store.commitChanges();
            } else {
                throw "获取权限信息失败！";
            }
        }

        // 清空操作列
        function ResetOpChkColumn() {
            var recs = store.getRange();

            $.each(recs, function() {
                var trec = this;
                trec.permissionid = trec.DynamicPermissionID || null;

                $.each(AllowOps, function() {
                    var opcolname = OPColumnName(this.Code);
                    trec.set(opcolname, false);
                });
            });

            store.commitChanges();
        }

        function DoSave(onSaveFinish) {
            if (id && type) {
                var pids = [];
                var aids = [];
                var ops = [];
                var recs = store.getModifiedRecords();

                $.each(recs, function() {
                    pids.push(this.permissionid || ' ');
                    aids.push(this.json.DynamicAuthID || ' ');
                    ops.push(FormatOpData(this.data).Operation || ' ');
                });

                $.ajaxExec('update', { "id": id, "type": type, 'pcatalog': pcatalog, "pidList": pids, "aidList": aids, "opList": ops }, onSaveFinish);
            }
        }

        function onExecuted() {
            // store.commitChanges();
            ResetPermission();
        }

        function handleActivate() {
            var actTab = pcTab.getActiveTab();
            var actRecs = grid.getSelectionModel().getSelections();

            if (actTab) {
                pcatalog = actTab.code;
                var url = $.combineQueryUrl(actTab.granturl, {});
                $("#frameContent").attr('src', url);
            }

            ResetOpChkColumn();
        }

        // 链接渲染
        function linkRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Name":
                    rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"GrpEdit.aspx?id=" + rec.id + "\")'>" + val + "</a>";
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
    <div id="header"><h1>动态权限反向授权</h1></div>
</asp:Content>
