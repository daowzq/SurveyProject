<%@ Page Title="未提交" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="NoSubmit.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.NoSubmit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "SurveyCommitHistoryEdit.aspx";
        var SurveyId = $.getQueryString({ ID: 'surveyId' }) || "";

        var IsPased = "";
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            if (AimState["IsPased"]) {
                IsPased = AimState["IsPased"] + "";
            }

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'SurveyId' },
			{ name: 'SurveyName' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'CropId' },
			{ name: 'CropName' },
			{ name: 'WorkNo1' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'CreateTime' }
			],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.surveyId = SurveyId;
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
                columns: 4,
                collapsed: false,
                items: [
                { fieldLabel: '姓名', id: 'SurveyTitile', schopts: { qryopts: "{ mode: 'Like', field: 'A.UserName' }"} },
                { fieldLabel: '工号', id: '工号', schopts: { qryopts: "{ mode: 'Like', field: 'B.WorkNo' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Title"));   //Number 为任意
                }
                }
      ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '短信催办',
                    iconCls: 'aim-icon-message',
                    handler: function() {
                        if (IsPased == "1") {
                            AimDlg.show("问卷已过期,无需催办");
                            return;
                        }
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs.length <= 0) {
                            AimDlg.show("请选择数据记录!");
                            return;
                        }
                        var recStr = store.getModifiedDataStringArr(recs);
                        if (confirm("确认短信催办吗?")) {
                            Ext.getBody().mask("系统在努力催办中，请稍等");
                            $.ajaxExec("MsgRemind", { Dt: recStr, SurveyId: SurveyId }, function(rtn) {
                                Ext.getBody().unmask();
                                AimDlg.show("催办成功!");
                                return;
                            });
                        }
                    }
                }, {
                    text: '邮件催办',
                    iconCls: 'aim-icon-email-go',
                    handler: function() {
                        if (IsPased == "1") {
                            AimDlg.show("问卷已过期,无需催办");
                            return;
                        }
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs.length <= 0) {
                            AimDlg.show("请选择数据记录!");
                            return;
                        }
                        var recStr = store.getModifiedDataStringArr(recs);
                        if (confirm("确认邮件催办吗?")) {
                            Ext.getBody().mask("系统在努力催办中，请稍等");
                            $.ajaxExec("EmailRemind", { Dt: recStr, SurveyId: SurveyId }, function(rtn) {
                                Ext.getBody().unmask();
                                AimDlg.show("催办成功!");
                                return;
                            });
                        }
                    }
                }, '->', {
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
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
                    viewConfig: { forceFit: true, scrollOffset: 10 },
                    //autoExpandColumn: 'Name',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    { id: 'UserId', dataIndex: 'UserId', header: '人员编号', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 100, sortable: true },
					{ id: 'WorkNo1', dataIndex: 'WorkNo1', header: '工号', width: 80, sortable: true },
					{ id: 'CropName', dataIndex: 'CropName', header: '所属公司', width: 120 },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 100, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '填写时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                grid.on("rowclick", function(Grid, rowIndex, e) {
                    var Element = document.getElementById("frameContent");
                    if (Element) {
                        var rec = grid.getStore().getAt(rowIndex);
                        var url = "SurveyedHistory.aspx?SurveyId=" + rec.get("SurveyId") + "&UserId=" + rec.get("SurveyedUserId");
                        frameContent.location.href = url;
                    }
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid]
                });
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }

            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
                    case "SurveyedUserName":
                        if (value) {
                            if (record.get("IsNoName") == "1") {
                                value == "匿名";
                            }
                            cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                            rtn = value;
                        }
                        break;
                    case "WorkNo1":
                        if (value) {
                            if (record.get("IsNoName") == "1") {
                                value == "匿名";
                            }
                            cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                            rtn = value;
                        }
                        break;
                }
                return rtn;
            }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
