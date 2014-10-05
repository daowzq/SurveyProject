<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmMessageList.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmMessageList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=800,height=600,scrollbars=yes");
        var EditPageUrl = "FrmMessage.aspx";

        var ViewWinStyle = CenterWin("width=800,height=600,scrollbars=yes");
        var ViewPageUrl = "FrmMessageView.aspx";

        var store, myData, op, win, winform;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var topid, topnode; //  右键行
        var comboxData = [['全部', '全部'], ['1', '已发布'], ['', '未发布']];
        var enumType = { '': '全部', '1': '已发布', '2': '已退回' };
        //var comboxData = [];

        function onPgLoad() {
            topnode = AimState["TopNode"];

            if (topnode) {
                topid = topnode.EnumerationID;
            }

            //comboxData = AimState["TypeEnum"];

            setPgUI();

            //权限  menuItemUpdate menuItemCanelUp menuItemDelete
            var Permissions = AimState["Permissions"]; //add,edit,delete,fb,unRelease,back, canelup
            //添加
            if (Permissions.indexOf("add") <= -1) {
                $("#btnadd").css("display", "none");
            }
            //修改
            if (Permissions.indexOf("edit") <= -1) {
                $("#btnedit").css("display", "none");
            }
            //删除
            if (Permissions.indexOf("delete") <= -1) {
                $("#btndelete").css("display", "none");
            }
            //发布
            if (Permissions.indexOf("fb") <= -1) {
                $("#btnfb").css("display", "none");
            }
            //撤销发布
            if (Permissions.indexOf("unRelease") <= -1) {
                $("#btncx").css("display", "none");
            }
            //退回
            if (Permissions.indexOf("back") <= -1) {
                $("#btnback").css("display", "none");
            }

            //自动弹出消息提醒
            var arrary = AimState["msgs"];
            if (arrary && arrary.length > 0) {
                //win.show();
                for (var i = 0; i < arrary.length; i++) {
                    window.open('/Message/FrmMessageView.aspx?Id=' + arrary[i]["Id"] + '&op=r', 'asdf' + i, '');
                }
            }
        }

        function setPgUI() {
            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["MessageList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'MessageList',
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
                columns: 4,
                items: [
                { id: 'txttitle', fieldLabel: '标题', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} }, //, 查询 enumdata: AimState["TypeEnum"], 
                {fieldLabel: '发布状态', id: 'ReleaseState', xtype: 'aimcombo', required: true, enumdata: enumType, schopts: { qryopts: "{ mode: 'Like', field: 'ReleaseState' }"} }
                ]

            });

            // 工具栏
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
                            if (recs[i].get("ReleaseState") == "1") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });
                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "已发布，不能修改");
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
                            if (recs[i].get("ReleaseState") == "1") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });
                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "已发布，不能删除");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, {
                    id: "btnfb",
                    text: '发布',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        ExtOpenGridEditWin(grid, EditPageUrl, "fb", EditWinStyle);
                        //AimDlg.show("发布");
                    }
                }, {
                    id: "btnback",
                    iconCls: 'aim-icon-execute',
                    text: '退回',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs.length == 0) {
                            AimDlg.show("请先选择要撤销的记录！");
                            return;
                        }

                        var temp = '';
                        $.each(recs, function(i) {
                            if (recs[i].get("ReleaseState") == "1") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });

                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "已发布，不能退回");
                            return;
                        }

                        if (confirm("确定退回？")) {
                            jQuery.ajaxExec('back', { "msgid": recs[0].get("Id") }, function(rtn) {
                                alert(rtn.data.result);
                                store.reload();
                            });
                        }
                    }
                }, {
                    id: "btncx",
                    iconCls: 'aim-icon-execute',
                    text: '撤销发布',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs.length == 0) {
                            AimDlg.show("请先选择要撤销的记录！");
                            return;
                        }

                        var temp = '';
                        $.each(recs, function(i) {
                            if (recs[i].get("ReleaseState") != "1") {
                                temp = temp + recs[i].get("Title") + " ";
                            }
                        });

                        if (temp.length > 0) {
                            AimDlg.show("标题：" + temp + "未发布");
                            return;
                        }

                        if (confirm("确定撤销发布？")) {
                            jQuery.ajaxExec('unRelease', { "msgid": recs[0].get("Id") }, onExecuted);
                        }
                    }
                }, {
                    text: '我的收藏',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        //jQuery.ajaxExec('SelCollection', { "UserId": AimState.UserInfo.UserID }, onExecuted);
                        op = "SelCollection";
                        store.reload();
                    }
                }, {
                    text: '已过期',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        op = "Expired";
                        store.reload();
                    }
                }, {
                    text: '全部',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        op = "";
                        store.reload();
                    }
                },
                //{
                //    text: 'show',
                //    handler: function() {
                //        win.show();
                //    }
                //}, 
                '-', {
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

                var temp = "";
                var arrary = AimState["msgs"];
                //                if (arrary && arrary.length > 0 && arrary.length < 10) {
                //                    for (var i = 0; i < arrary.length; i++) {
                //                        temp += (i + 1) + "、<label style='cursor:pointer;' onclick='window.open(\"FrmMessageView.aspx?op=r&id=" + arrary[i]["Id"] + "\")'>" + arrary[i]["Title"] + "</label><br />";
                //                    }
                //                }
                //                else if (arrary.length >= 10) {
                //                    temp = "您有<labe style='cursor:pointer;'l onclick='window.open(\"FrmMessageList.aspx\")'>" + arrary.length + "</label>条未读系统消息";
                //                }

                winform = new Ext.Panel({
                    items: [{ html: "<div style='width:590px; height:30px; border-width:thin; background-color:#DFE8F6;'>" + temp + "</div>"}]
                });

                win = new Ext.Window({
                    title: "消息提醒",
                    layout: "form",
                    modal: true,
                    resizable: false,
                    height: 350,
                    width: 600,
                    frame: true,
                    closeAction: 'hide',
                    items: winform,
                    buttons: [{ text: "取 消", handler: function() { win.hide(); } }]
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
					{ id: 'Title', dataIndex: 'Title', header: '标题', linkparams: { url: ViewPageUrl, style: ViewWinStyle }, width: 100, sortable: true },
                    { id: 'ReleaseState', dataIndex: 'ReleaseState', header: '发布状态', width: 100, sortable: true, renderer: function(val) {
                        if (val == "1") {
                            return "已发布";
                        }
                        else if (val == "2") {
                            return "已退回";
                        } else {
                            return "未发布";
                        }
                    }
                    },
                    { id: 'ReadState', dataIndex: 'ReadState', header: '阅读状态', width: 100, sortable: true, renderer: function(val) {
                        if ((val + "").indexOf(AimState.UserInfo.UserID) >= 0) {
                            return "已阅";
                        } else {
                            return "未阅";
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
                        if (!recs || recs.length <= 0) {
                            return;
                        }
                        //查看
                        ExtOpenGridEditWin(grid, ViewPageUrl, "r", EditWinStyle);
                    }
                    }
                });


                grid.on('rowcontextmenu', function(grid, rowIdx, e) {
                    e.preventDefault(); // 抑制IE右键菜单

                    var grid = this;
                    var store = this.store;
                    var xy = e.getXY();

                    grid.contextRow = store.getAt(rowIdx);

                    grid.getSelectionModel().selectRow(rowIdx);

                    if (!grid.rowContextMenu) {
                        grid.rowContextMenu = new Ext.menu.Menu({ id: 'contextMenu', items: [
                        {
                            id: 'menuItemView',
                            text: '查看',
                            iconCls: 'aim-icon-View',
                            handler: function() {
                                ExtOpenGridEditWin(grid, ViewPageUrl, "r", EditWinStyle);
                            }
                        }, {
                            id: 'menuItemUpdate',
                            text: '修改',
                            iconCls: 'aim-icon-update',
                            handler: function() {
                                ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                            }
                        }, {
                            id: 'menuItemCanelUp',
                            text: '取消强制弹出',
                            //iconCls: 'aim-icon-update',
                            handler: function() {
                                if (confirm("是否取消强制弹出？")) {
                                    var rec = store.getAt(rowIdx);
                                    jQuery.ajaxExec('batchcanelup', { "Id": rec.get("Id") }, onExecuted);
                                }
                            }
                        }, {
                            id: 'menuItemDelete',
                            iconCls: 'aim-icon-delete',
                            text: '删除',
                            handler: function() {
                                if (confirm("确定删除吗？")) {
                                    var recs = [];
                                    var rec = store.getAt(rowIdx);
                                    recs.push(rec);
                                    ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                                }
                            }
                        }
]
                        });
                    }

                    if (grid.contextRow) {
                        var rec = store.getAt(rowIdx);
                        if (rec.get("ReleaseState") != "1") {
                            Ext.getCmp('menuItemUpdate').setDisabled(false);
                            Ext.getCmp('menuItemDelete').setDisabled(false);
                        }
                        else {
                            Ext.getCmp('menuItemUpdate').setDisabled(true);
                            Ext.getCmp('menuItemDelete').setDisabled(true);
                        }

                        if (rec.get("IsEnforcementUp") != "on") {
                            Ext.getCmp('menuItemCanelUp').setDisabled(true);
                        }
                        else {
                            Ext.getCmp('menuItemCanelUp').setDisabled(false);
                        }
                    }

                    //判断权限（右击菜单）
                    var Permissions = AimState["Permissions"];
                    //取消强制弹出
                    if (Permissions.indexOf("canelup") <= -1) {
                        Ext.getCmp('menuItemCanelUp').setDisabled(true);
                    }
                    if (Permissions.indexOf("edit") <= -1) {
                        Ext.getCmp('menuItemUpdate').setDisabled(true);
                    }
                    //删除
                    if (Permissions.indexOf("delete") <= -1) {
                        Ext.getCmp('menuItemDelete').setDisabled(true);
                    }

                    this.rowContextMenu.showAt(xy);
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

            function UserSel(rtn) {
                if (rtn && rtn.data && grid.activeEditor) {
                    var rec = store.getAt(grid.activeEditor.row);
                    if (rec) {
                        jQuery.ajaxExec('getdept', { "UserIds": rtn.data.UserID }, function(rtns) {
                            rec.set("Uid", rtn.data.Name || rtn.data[0].Name);
                            grid.activeEditor.setValue(rtn.data.Name || rtn.data[0].Name);
                        });
                    }
                }
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
