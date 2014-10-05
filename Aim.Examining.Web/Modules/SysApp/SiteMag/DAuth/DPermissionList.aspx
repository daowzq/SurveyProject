
<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DPermissionList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DPermissionList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var StatusEnum = { '1': '有效', '0': '无效' };
    
    var viewport;
    var store, myData;
    var pgBar, schBar, tlBar, titPanel, grid;

    function onPgLoad() {
        setPgUI();
    }

    function setPgUI() {

        // 表格数据
        myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["DynamicPermissionList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'DynamicPermissionList',
            idProperty: 'DynamicPermissionID',
            data: myData,
            fields: [
			{ name: 'DynamicPermissionID' },
			{ name: 'Name' },
			{ name: 'CatalogCode' },
			{ name: 'Auth' },
			{ name: 'Operation' },
			{ name: 'Data' },
			{ name: 'Tag' },
			{ name: 'EditStatus' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate' }
			]
        });

        // 分页栏
        pgBar = new Ext.ux.AimPagingToolbar({
            pageSize: AimSearchCrit["PageSize"],
            store: store,
            displayInfo: true,
            displayMsg: '当前条目 {0} - {1}, 总条目 {2}',
            emptyMsg: "无条目显示",
            items: ['-']
        });

        // 搜索栏
        schBar = new Ext.ux.AimSchPanel({
            collapsed: true,
            unstyled: true,
            padding: 5,
            layout: 'column',
            items: [
				{ layout: 'form', unstyled: true, columnWidth: .33,
                items: [new Ext.app.AimSearchField({ fieldLabel: '查询字段11', anchor: '90%', name: 'Field11', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Field11' }" }),
                new Ext.app.AimSearchField({ fieldLabel: '查询字段21', anchor: '90%', name: 'Field21', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Field21' }" })]}, 
                { layout: 'form', unstyled: true, columnWidth: .33,
                items: [new Ext.app.AimSearchField({ fieldLabel: '查询字段12', anchor: '90%', name: 'Field12', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Field12' }" }),
                new Ext.app.AimSearchField({ fieldLabel: '查询字段22', anchor: '90%', name: 'Field22', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Field22' }" })]}, 
                { layout: 'form', unstyled: true, columnWidth: .33,
                items: [new Ext.app.AimSearchField({ fieldLabel: '查询字段13', anchor: '90%', name: 'Field13', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Field13' }" }),
                new Ext.app.AimSearchField({ fieldLabel: '查询字段23', anchor: '90%', name: 'Field23', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Field23' }" })]
                }]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openEditWin("DynamicPermissionEdit.aspx", "c");
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openEditWin("DynamicPermissionEdit.aspx", "u");
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
                            batchOperate('batchdelete', recs);
                        }
                    }
                }, '-', {
                    text: '其他',
                    iconCls: 'aim-icon-cog',
                    menu: [{ text: '导出Excel', iconCls: 'aim-icon-xls', handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
                    } }]
                }, '->', { text: '查询:' },
                new Ext.app.AimSearchField({ store: store, schbutton: true, qryopts: "{ type: 'fulltext' }" }),
                '-',
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
                grid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    monitorResize: true,
                    columns: [
                    { id: 'DynamicPermissionID', header: '标识', dataIndex: 'DynamicPermissionID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Name', header: 'Name', width: 100,  renderer: linkRender,  sortable: true, dataIndex: 'Name' },
					{ id: 'CatalogCode', header: 'CatalogCode', width: 100,  sortable: true, dataIndex: 'CatalogCode' },
					{ id: 'Auth', header: 'Auth', width: 100,  sortable: true, dataIndex: 'Auth' },
					{ id: 'Data', header: 'Data', width: 100,  sortable: true, dataIndex: 'Data' },
					{ id: 'Tag', header: 'Tag', width: 100,  sortable: true, dataIndex: 'Tag' },
					{ id: 'EditStatus', header: 'EditStatus', width: 100,  sortable: true, dataIndex: 'EditStatus' },
					{ id: 'CreaterID', header: 'CreaterID', width: 100,  sortable: true, dataIndex: 'CreaterID' },
					{ id: 'CreaterName', header: 'CreaterName', width: 100,  sortable: true, dataIndex: 'CreaterName' },
					{ id: 'LastModifiedDate', header: 'LastModifiedDate', width: 100,  sortable: true, dataIndex: 'LastModifiedDate' },
					{ id: 'CreatedDate', header: 'CreatedDate', width: 100,  sortable: true, dataIndex: 'CreatedDate' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel,
                    frame: true,
                    forceLayout: true,
                    stripeRows: true,
                    //autoExpandColumn: 'Name',
                    stateful: true,
                    stateId: 'grid'
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

            // 链接渲染
            function linkRender(val, p, rec) {
                var rtn = val;
                switch (this.dataIndex) {
                    case "Name":
                        rtn = "<a class='aim-ui-link' onclick='openEditWin(\"DynamicPermissionEdit.aspx?id=" + rec.id + "\")'>" + val + "</a>";
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
            
            // 打开模态窗口
            function openEditWin(url, op, style) {
                op = op || "r";
                style = style || CenterWin("width=650,height=600,scrollbars=yes");

                var sels = grid.getSelectionModel().getSelections();
                var sel;
                if (sels.length > 0) sel = sels[0];

                var params = [];
                params[params.length] = "op=" + op;
                if (op !== "c") {
                    if (sel) {
                        if (url.indexOf("id=") < 0) {
                            params[params.length] = "id=" + sel.json.Id;
                        }
                    } else {
                        if (url.indexOf("id=") < 0) {
                            AimDlg.show('请选择需要操作的行。', '提示', 'alert');
                            return;
                        }
                    }
                }

                url = jQuery.combineQueryUrl(url, params)
                rtn = OpenWin(url, "_blank", style);
                if (rtn && rtn.result) {
                    if (rtn.result === 'success') {
                        store.reload();
                    }
                }
            }

            function batchOperate(action, recs, params, url) {
                if (!url) url = null;

                idList = [];

                if (recs != null) {
                    jQuery.each(recs, function() {
                        idList.push(this.json["DynamicPermissionID"]);
                    })
                }

                params = params || {};
                params["IdList"] = idList;

                jQuery.ajaxExec(action, params, onExecuted);
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>标题</h1></div>
</asp:Content>


