<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmMessageListView.aspx.cs" Inherits="Aim.Examining.Web.Message.FrmMessageListView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">

        var ViewWinStyle = CenterWin("width=800,height=600,scrollbars=yes");
        var ViewPageUrl = "FrmMessageView.aspx";

        var store, myData, op, win, winform;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var topid, topnode; //  右键行

        function onPgLoad() {
            topnode = AimState["TopNode"];

            if (topnode) {
                topid = topnode.EnumerationID;
            }
            setPgUI();

            //自动弹出消息提醒
//            var arrary = AimState["msgs"];
//            if (arrary.length > 0) {
//                win.show();
//            }
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
                items: [
                { fieldLabel: '标题', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                { fieldLabel: '类型', xtype: 'combo', enumdata: "AimState['TypeEnum']", schopts: { qryopts: "{ mode: 'Like', field: 'Type' }"}}]
            });

            // 工具栏 new Ext.ux.form.AimComboBox({ enumdata: HTEnum })
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '我的收藏',
                    handler: function() {
                        //jQuery.ajaxExec('SelCollection', { "UserId": AimState.UserInfo.UserID }, onExecuted);
                        op = "SelCollection";
                        store.reload();
                    }
                }, {
                    text: '全部',
                    handler: function() {
                        op = "";
                        store.reload();
                    }
                }, '-',
                {
                    text: "已阅",
                    handler: function() {
                        op = "read";
                        store.reload();
                    }
                },
                {
                    text: "未阅",
                    handler: function() {
                        op = "notread";
                        store.reload();
                    }
                },
                {
                    text: "全部",
                    handler: function() {
                        op = "";
                        store.reload();
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
