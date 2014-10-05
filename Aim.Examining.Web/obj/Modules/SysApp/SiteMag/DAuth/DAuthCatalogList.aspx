
<%@ Page Title="权限分类" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DAuthCatalogList.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DAuthCatalogList" %>

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
            records: AimState["DynamicAuthCatalogList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'DynamicAuthCatalogList',
            idProperty: 'DynamicAuthCatalogID',
            data: myData,
            fields: [
			{ name: 'DynamicAuthCatalogID' },
			{ name: 'Code' },
			{ name: 'Name' },
			{ name: 'SortIndex' },
			{ name: 'Description' },
			{ name: 'Editable' },
			{ name: 'Deletable' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate' }
			]
        });

        // 分页栏
        pgBar = new Ext.ux.AimPagingToolbar({
            pageSize: AimSearchCrit["PageSize"],
            store: store
        });

        // 搜索栏
        schBar = new Ext.ux.AimSchPanel({
            hidden: true,
            items: []
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    id:'btnAdd',
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openEditWin("DAuthCatalogEdit.aspx", "c");
                    }
                }, {
                    id: 'btnEdt',
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openEditWin("DAuthCatalogEdit.aspx", "u");
                    }
                }, {
                    id: 'btnDel',
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
                }, '-', { text: '导出Excel', iconCls: 'aim-icon-xls', handler: function() {
                    ExtGridExportExcel(grid, { store: null, title: '权限分类' });
                    }
                }, '->', { text: '查询:' },
                new Ext.app.AimSearchField({ store: store, schbutton: true, qryopts: "{ type: 'fulltext' }" })
                ]
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
                    border:false,
                    columns: [
                    { id: 'DynamicAuthCatalogID', header: '标识', dataIndex: 'DynamicAuthCatalogID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Code', header: '编号', width: 100, sortable: true, dataIndex: 'Code' },
					{ id: 'Name', header: '名称', width: 150, renderer: linkRender, sortable: true, dataIndex: 'Name' },
					{ id: 'SortIndex', header: '排序号', hidden: true, width: 100, sortable: true, dataIndex: 'SortIndex' },
					{ id: 'Description', header: '描述', width: 100, sortable: true, dataIndex: 'Description' },
					{ id: 'CreaterName', header: '创建人', width: 100, sortable: true, dataIndex: 'CreaterName' },
					{ id: 'LastModifiedDate', header: '最后修改日期', hidden:true , width: 100, sortable: true, dataIndex: 'LastModifiedDate' },
					{ id: 'CreatedDate', header: '创建日期', width: 100, sortable: true, dataIndex: 'CreatedDate' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel,
                    autoExpandColumn: 'Description'
                });

                grid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                    Ext.getCmp("btnEdt").setDisabled(!r.data.Editable);
                    Ext.getCmp("btnDel").setDisabled(!r.data.Deletable);
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
                        rtn = "<a class='aim-ui-link' onclick='openEditWin(\"DAuthCatalogEdit.aspx?id=" + rec.id + "\")'>" + val + "</a>";
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
                style = style || CenterWin("width=700,height=450,scrollbars=yes");

                var sels = grid.getSelectionModel().getSelections();
                var sel;
                if (sels.length > 0) sel = sels[0];

                var params = [];
                params[params.length] = "op=" + op;
                if (op !== "c") {
                    if (sel) {
                        if (url.indexOf("id=") < 0) {
                            params[params.length] = "id=" + sel.json.DynamicAuthCatalogID;
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
                        idList.push(this.json["DynamicAuthCatalogID"]);
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
    <div id="header" style="display:none;"><h1>权限分类</h1></div>
</asp:Content>


