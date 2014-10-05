<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmMessageDraftList.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmMessageDraftList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=800,height=600,scrollbars=yes");
        var EditPageUrl = "FrmMessageDraft.aspx";

        var store, myData, op, win, winform;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["MessageDraftList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'MessageDraftList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'Title' },
			{ name: 'Content' },
			{ name: 'ReleaseState' },
			{ name: 'ReadState' },
			{ name: 'Type' },
			{ name: 'IsEnforcementUp' },
			{ name: 'FileID' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' }
			], listeners: { "aimbeforeload": function(proxy, options) {
			    if (op) {
			        options.data = options.data || {};
			        options.data.op = op || null;
			    }
			}
			}
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                collapsed: false,
                items: [
                { fieldLabel: '标题', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"}}//, 查询
                //{ fieldLabel: '类型', xtype: 'combo',  schopts: { qryopts: "{ mode: 'Like', field: 'Type' }"}}
                ]

            });

            // 工具栏 new Ext.ux.form.AimComboBox({ enumdata: HTEnum })
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    id: "btnadd",
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                    }
                }, {
                    id: "btnedit",
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        var temp = '';
                        $.each(recs, function(i) {
                            if (recs[i].get("ReleaseState") == "1" || recs[i].get("ReleaseState") == "3") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });
                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "已提交，不能修改");
                            return;
                        }

                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    }
                }, {
                    id: "btndelete",
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }
                        var temp = '';
                        $.each(recs, function(i) {
                            if (recs[i].get("ReleaseState") == "1" || recs[i].get("ReleaseState") == "3") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });
                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "已提交，不能删除");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, {
                    id: "btnsub",
                    iconCls: 'aim-icon-execute',
                    text: '提交',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要提交的记录！");
                            return;
                        }
                        var temp = '';
                        $.each(recs, function(i) {
                            if (recs[i].get("ReleaseState") == "1" || recs[i].get("ReleaseState") == "3") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });
                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "已经提交了，无需再次提交");
                            return;
                        }
                        jQuery.ajaxExec('sub', { "msgid": recs[0].get("Id") }, onExecuted);
                    }
                }, {
                    id: "btnquhui",
                    iconCls: 'aim-icon-execute',
                    text: '取回',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要取回的记录！");
                            return;
                        }
                        var temp = '';
                        $.each(recs, function(i) {
                            if (recs[i].get("ReleaseState") != "1") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });
                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "不处于提交状态，不能取回操作");
                            return;
                        }
                        if (confirm("确定取回所选记录？")) {
                            jQuery.ajaxExec('quhui', { "msgid": recs[0].get("Id") }, onExecuted);
                        }
                    }
                }, '-', {
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
                    }
                }, '->',
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
                grid = new Ext.ux.grid.AimEditorGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'Title',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'FileID', dataIndex: 'FileID', width: 22, renderer: function(val) {
                        if (val) {
                            return "<img style='width:16px; height:17px;' alt='附件' src='../images/attach.png'></img>";
                        }
                        else {
                            return "";
                        }
                    }
                    },
					{ id: 'Title', dataIndex: 'Title', header: '标题', width: 100, sortable: true },
                    { id: 'ReleaseState', dataIndex: 'ReleaseState', header: '状态', width: 100, sortable: true, renderer: function(val) {
                        if (val == "1") {
                            return "已提交";
                        } else if (val == "2") {
                            return "已退回";
                        } else if (val == "3") {
                            return "已发布";
                        } else {
                            return "未提交";
                        }
                    }
                    },
					{ id: 'Type', dataIndex: 'Type', header: '类型', width: 100, sortable: true },
					{ dataIndex: 'IsEnforcementUp', header: '是否强制弹出', width: 100, sortable: true, renderer: function(val) {

					    if (val == "on") {
					        return "是";
					    } else {
					        return "否";
					    }
					}
					},
					{ id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 100, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建时间', width: 100, sortable: true }
					],
                    bbar: pgBar,
                    tbar: titPanel,
                    listeners: { "rowdblclick": function() {

                        var recs = grid.getSelectionModel().getSelections();
                        var temp = '';
                        $.each(recs, function(i) {
                            if (recs[i].get("ReleaseState") == "1") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });
                        if (temp.length > 0) {
                            //AimDlg.show("标题：" + temp + "已提交，不能修改");
                            return;
                        }

                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    }
                    }
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
