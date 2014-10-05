<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="UsrAppealListList.aspx.cs" Inherits="Aim.Examining.Web.UsrAppealListList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=680,height=490,scrollbars=yes");
        var EditPageUrl = "UsrAppealListEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["UsrAppealListList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'UsrAppealListList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'WorkNo' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'IsNoName' },
			{ name: 'AppealTypeCode' },
			{ name: 'AppealTypeName' },
			{ name: 'AppealReason' },
			{ name: 'Title' },
			{ name: 'AddFiles' },
			{ name: 'DealResult' },
			{ name: 'FristAcceptUserID' },
			{ name: 'WorkFlowCode' },
			{ name: 'WorkFlowState' },
			{ name: 'AppealSolve' },
			{ name: 'DeptId' },
			{ name: 'State' },
			{ name: 'DeptName' },
			{ name: 'CreateId' },
			{ name: 'CreateTime' }
			]
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
                columns: 5,
                items: [
                  { fieldLabel: '申诉类型', id: 'AppealTypeName', xtype: 'aimcombo', required: true, enumdata: AimState["AppealTypeName"], schopts: { qryopts: "{ mode: 'Like', field: 'AppealTypeName' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("AppealTypeName")); } } },
               { fieldLabel: '起始时间', id: 'StartTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', endDateField: 'EndTime', schopts: { qryopts: "{ mode: 'GreaterThanEqual', datatype:'Date', field: 'ApplyTime' }"} },
                { fieldLabel: '截至时间', id: 'EndTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', startDateField: 'StartTime', schopts: { qryopts: "{ mode: 'LessThanEqual', datatype:'Date', field: 'ApplyTime' }"} },
				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
				    Ext.ux.AimDoSearch(Ext.getCmp("StartTime"));   //Number 为任意
				}
				}
                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs[0].get("WorkFlowState")) {
                            AimDlg.show("流程中的记录不能修改！");
                            return;
                        }
                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
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

                        if (recs[0].get("WorkFlowState")) {
                            AimDlg.show("流程中的记录不能删除！");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, '-', {
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
                    }
                }, '-',
                   {
                       text: '提交申诉',
                       iconCls: 'aim-icon-submit',
                       handler: function() {
                           var recs = grid.getSelectionModel().getSelections();
                           if (!recs || recs.length <= 0) {
                               AimDlg.show("请先选择要审批的记录！");
                               return;
                           }
                           if (recs[0].get("WorkFlowState")) {
                               AimDlg.show("流程中的记录不能再次提交！");
                               return;
                           }

                           if (!recs[0].get("FristAcceptUserID")) {
                               AimDlg.show("系统暂未配置申诉审批受理人!");
                               return;
                           }

                           if (confirm("确认提交申诉吗？")) {
                               Ext.getBody().mask("提交中,请稍后...");
                               $.ajaxExec("Submit", { id: recs[0].get("Id") }, function(rtn) {
                                   AutoExecuteFlow(rtn)
                               });
                           }

                           // opencenterwin("SubmitFlow.aspx?AppealId=" + recs[0].get("Id"), "", 500, 500);
                       }
                   },
                    {
                        text: '申诉跟踪',
                        iconCls: 'aim-icon-cross1',
                        handler: function() {
                            var recs = grid.getSelectionModel().getSelections();
                            if (!recs || recs.length <= 0) {
                                AimDlg.show("请先选择要跟踪的记录！");
                                return;
                            }
                            if (!recs[0].get("WorkFlowState")) {
                                AimDlg.show("有审批的记录才能跟踪！");
                                return;
                            }

                            opencenterwin("/workflow/TaskExecuteView.aspx?FormId=" + recs[0].get("Id"), "", 1000, 600);
                        }
                    }
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
                autoExpandColumn: 'Title',
                margins: '0 10 10 0',

                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 120, sortable: true, hidden: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 100, sortable: true },
					{ id: 'AppealTypeName', dataIndex: 'AppealTypeName', header: '申诉类型', width: 100, sortable: true },
					{ id: 'Title', dataIndex: 'Title', header: '申诉标题', width: 120, sortable: true },
					{ id: 'AppealReason', dataIndex: 'AppealReason', header: '申诉事由', width: 250, renderer: RowRender },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '所在部门', width: 180, sortable: true },
					{ id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: '状态', width: 80, sortable: true, renderer: RowRender },

					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '申诉时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });

            grid.on("rowdblclick", function(grid, rowIndex, e) {
                ExtOpenGridEditWin(grid, EditPageUrl, "r", EditWinStyle);
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });
        }

        function AutoExecuteFlow(rtn) {
            var NextInfo = rtn.data.NextInfo;
            var task = new Ext.util.DelayedTask();
            task.delay(800, function() {
                jQuery.ajaxExec('AutoExecuteFlow', { NextInfo: NextInfo }, function(rtn) {
                    Ext.getBody().unmask();
                    store.reload();
                    AimDlg.show("提交成功！");
                });
            });
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "WorkFlowState":
                    if (value == "Start") {
                        rtn = "审批中";
                    } else if (value == "End") {
                        rtn = "结束";
                    }
                    else {
                        rtn = "创建";
                    }
                    break;
                case "AppealReason":
                    value = value.length > 300 ? (value.substring(0, 200) + "...") : value;
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = value;
                    break;
            }
            return rtn;
        }
        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',                      innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=                yes,resizable=yes');
        }
        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
