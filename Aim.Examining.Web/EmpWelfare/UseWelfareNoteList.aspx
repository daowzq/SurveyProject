<%@ Page Title="福利申报通知" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master"
    AutoEventWireup="true" CodeBehind="UseWelfareNoteList.aspx.cs" Inherits="Aim.Examining.Web.UseWelfareNoteList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=760,height=560,scrollbars=yes");
        var EditPageUrl = "UseWelfareNoteEdit.aspx";
        var Modelstyle = "dialogWidth:760px; dialogHeight:580px; scroll:no; center:yes; status:no; resizable:no;";
        var ThingsType = { "": "请选择...", "Travel": '员工旅游', "YGPO": "员工配偶保险" };
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["UseWelfareNoteList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'UseWelfareNoteList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'TypeCode' },
			{ name: 'TypeName' },
			{ name: 'Code' },
			{ name: 'Title' },
			{ name: 'StartTime' },
			{ name: 'EndTime' },
			{ name: 'Condition' },
			{ name: 'AddFiles' },
			{ name: 'NoticeWay' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'WorkFlowKey' },
			{ name: 'WorkFlowName' },

			{ name: 'WorkFlowState' },
			{ name: 'WorkFlowCode' },
			{ name: 'WorlFlowResult' },

			{ name: 'State' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
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
                { fieldLabel: '标题', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                { fieldLabel: '类型', id: 'TypeName', xtype: 'aimcombo', required: true, enumdata: ThingsType, schopts: { qryopts: "{ mode: 'Like', field: 'TypeName' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("TypeName")); } } },
                { fieldLabel: '起始时间', id: 'StartTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', endDateField: 'EndTime', schopts: { qryopts: "{ mode: 'GreaterThanEqual', datatype:'Date', field: 'StartTime' }"} },
                { fieldLabel: '截至时间', id: 'EndTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', startDateField: 'StartTime', schopts: { qryopts: "{ mode: 'LessThanEqual', datatype:'Date', field: 'StartTime' }"} },
				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
				    Ext.ux.AimDoSearch(Ext.getCmp("Title"));   //Number 为任意
				}
				}

                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加通知',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        // ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                        var url = EditPageUrl + "?op=c";
                        OpenModelWin(url, window, Modelstyle, function() {
                            store.reload();
                        });
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs[0].get("State") == "1") {
                            AimDlg.show("已发布的福利申报信息不能修改!");
                            return;
                        }

                        //ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                        var url = EditPageUrl + "?id=" + (recs[0].get("Id") || "") + "&op=u";
                        OpenModelWin(url, window, Modelstyle, function() {
                            store.reload();
                        });
                    }

                },
                {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }
                        if (recs[0].get("State") == "1") {
                            AimDlg.show("已发布的福利申报信息不能删除!");
                            return;
                        }

                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, {
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
                    }
                }, '-', {
                    text: '提交审批',
                    iconCls: 'aim-icon-submit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要审批的记录！");
                            return;
                        }

                        if (recs[0].get("WorkFlowState")) {
                            AimDlg.show("流程中或审批结束的记录,不能再进行提交!");
                            return;
                        }

                        //                        $.ajaxExec("GetApprove", {}, function(rtn) {
                        //                            var Status = rtn.data.Status;
                        //                            if (Status == "1") {
                        // opencenterwin("WFChoices.aspx?SurveyId=" + recs[0].get("Id"), "", 725, 385);
                        //                            } else {
                        //                                AimDlg.show("请在系统配置中配置本公司HR经理！");
                        //                                return;
                        //                            }
                        //                        })

                        opencenterwin("WFChoices.aspx?SurveyId=" + recs[0].get("Id"), "", 725, 385);

                    }
                },
                {
                    text: '流程跟踪',
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
                }, '-',
                 {
                     text: '发布通知',
                     iconCls: 'aim-icon-read',
                     handler: function() {


                         var recs = grid.getSelectionModel().getSelections();
                         if (!recs || recs.length <= 0) {
                             AimDlg.show("请先选择要发起的记录！");
                             return;
                         }
                         //                         if (recs[0].get("WorkFlowState")) {
                         //                             if ((recs[0].get("WorlFlowResult") + "").indexOf("同意") < 0) {
                         //                                 AimDlg.show("审批未完成,未通过的问卷不能开始！");
                         //                                 return
                         //                             }
                         //                         } else {
                         //                             AimDlg.show("未审批的通知暂不能发布！");
                         //                             return
                         //                         }

                         if (confirm("确认发起通知？")) {
                             $.ajaxExec("Publish", { Id: recs[0].get("Id") }, function(rtn) {
                                 AimDlg.show("发起通知成功!");
                                 store.reload();
                                 return;
                             });
                         }

                     }
                 },
                 {
                     text: '撤销通知',
                     hidden: true,
                     iconCls: 'aim-icon-undo',
                     handler: function() {
                         var recs = grid.getSelectionModel().getSelections();
                         if (!recs || recs.length <= 0) {
                             AimDlg.show("请先选择要撤销的记录！");
                             return;
                         }
                         if (recs[0].get("State") != "1") {
                             AimDlg.show("只有发起的通知才能撤销!");
                             return;
                         }
                         $.ajaxExec("Undo", { Id: recs[0].get("Id") }, function(rtn) {
                             AimDlg.show("撤销通知成功!");
                             store.reload();
                             return;
                         });

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
                margins: '0 10 10 0',
                autoExpandColumn: 'Title',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'Code', dataIndex: 'Code', header: '编号', width: 100, sortable: true, hidden: true },
					{ id: 'TypeName', dataIndex: 'TypeName', header: '类型名称', width: 120, sortable: true },
					{ id: 'Title', dataIndex: 'Title', header: '标题', width: 160, sortable: true, renderer: RowRender },
					{ id: 'StartTime', dataIndex: 'StartTime', header: '开始时间', width: 100, sortable: true },
					{ id: 'EndTime', dataIndex: 'EndTime', header: '结束时间', width: 100, sortable: true },
					{ id: 'State', dataIndex: 'State', header: '状态', width: 80, sortable: true, renderer: RowRender },
					{ id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: '审批状态', width: 80, renderer: RowRender },
					{ id: 'WorlFlowResult', dataIndex: 'WorlFlowResult', header: '审批结果', width: 80 },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '通知对象', width: 160, sortable: true, renderer: RowRender },
					{ id: 'CreateName', dataIndex: 'CreateName', header: '发布人', width: 100, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '发布时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
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
        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "State":
                    if (value == "0") {
                        rtn = "创建";
                    } else if (value == "1") {
                        rtn = "发布";
                    } else if (value == "2") {
                        rtn = "撤销";
                    }
                    break;
                case "Title":
                    if (value) {
                        value = value || "";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        rtn = value;
                    }
                    break;
                case "DeptName":
                    if (value) {
                        value = value || "";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        rtn = value;
                    }
                    break;
                case "WorkFlowState":
                    if (value == "1" || value == "Start") {
                        rtn = " 审批中 ";
                    } else if (value == "End") {
                        rtn = "审批结束";
                    }
                    break;
            }
            return rtn;
        }

        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
