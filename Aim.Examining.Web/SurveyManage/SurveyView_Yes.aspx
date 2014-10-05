<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SurveyView_Yes.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyView_Yes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=950,height=600,scrollbars=yes");
        var EditPageUrl = "SurveyQuestionEdit.aspx";
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {

            setPgUI();
        }
        function setPgUI() {

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
			{ name: 'SurveyTitile' },
			{ name: 'Description' },
			{ name: 'StartTime' },
			{ name: 'DeptName' },
			{ name: 'DeptId' },
			{ name: 'EndTime' },
			{ name: 'IsNoName' },
			{ name: 'HasPower' },
			{ name: 'State' },
			{ name: 'CreateId' },
			{ name: 'CT' }
			]
            });


            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                columns: 4,
                collapsed: false,
                items: [
                { fieldLabel: '问卷标题', id: 'SurveyTitile', schopts: { qryopts: "{ mode: 'Like', field: 'SurveyTitile' }"} },

       { fieldLabel: '开始时间', id: 'StartTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', endDateField: 'EndTime', schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'StartTime' }"} },
                { fieldLabel: '截至时间', id: 'EndTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', startDateField: 'StartTime', schopts: { qryopts: "{ mode: 'LessThan', datatype:'Date', field: 'EndTime' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Title"));   //Number 为任意
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
                }, '-', {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    }
                }, '-', {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
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
}]
                });

                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    // tbar: tlBar,
                    items: [schBar]
                });
                // 分页栏
                pgBar = new Ext.ux.AimPagingToolbar({
                    pageSize: AimSearchCrit["PageSize"],
                    store: store
                });

                // 表格面板
                grid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'SurveyTitile',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'SurveyTitile', dataIndex: 'SurveyTitile', header: '问卷标题', width: 140, sortable: true, renderer: RowRender },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '发起部门', width: 120, sortable: true },
					{ id: 'StartTime', dataIndex: 'StartTime', header: '开始时间', width: 120, sortable: true, renderer: ExtGridDateOnlyRender },
					{ id: 'EndTime', dataIndex: 'EndTime', header: '结束时间', width: 120, sortable: true, renderer: ExtGridDateOnlyRender },
				    { id: "IsNoName", dataIndex: "IsNoName", header: "是否匿名", width: 100, sortable: true, renderer: RowRender },

                    //  { id: 'IsPasted', dataIndex: 'IsPasted', header: '是否过期', width: 120, sortable: true, renderer: RowRender },
					{id: 'Edit', dataIndex: 'Edit', header: '操作', width: 160, renderer: RowRender }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
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
                    case "SurveyTitile":
                        if (value) {
                            cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + "标题:" + value + "</br>内容:" + record.get("Description").substring(0, 30) + "..." + '"';
                            rtn = value;
                        }
                        break;

                    case "IsNoName":
                        if (value) {
                            rtn = value == "1" ? "是" : "否"
                        }
                        break;
                    case "Edit":

                        var str = "<span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='renderCommitSurvey(\"" + record.get("Id") + "\")'>" + "查看记录" + "</span>";
                        if (record.get("HasPower") == "joiner" || AimState.UserInfo.UserID == record.get("CT")) {
                            str += "<span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='statitcsWin(\"" + record.get("Id") + "\")'>" + "&nbsp;&nbsp;查看统计" + "</span>";
                        } else {
                            str += "&nbsp;&nbsp;<span style='color:gray;text-decoration:underline;'>" + "&nbsp;&nbsp;查看统计" + "</span>";
                        }

                        rtn = str;
                        break;
                }
                return rtn;
            }

            //查看已完成的调查问卷
            function renderCommitSurvey(SurveyId, UserID) {
                var url = "SurveyedHistory.aspx?SurveyId=" + SurveyId + "&rand=" + Math.random();
                opencenterwin(url, "", 1000, 600);
            }

            //查看统计 
            function statitcsWin(SurveyId, UserID) {
                var url = "T_SurveyStatisticTab.aspx?SurveyId=" + SurveyId + "&rand=" + Math.random();
                opencenterwin(url, "", 1000, 600);
            }

            function windowOpen() {
                var Id = arguments[0] || '';  //ID
                var Title = escape(arguments[1] || ''); //Title
                var task = new Ext.util.DelayedTask();
                task.delay(100, function() {
                    opencenterwin("InternetSurveyView.aspx?op=v&Id=" + Id + "&Title=" + Title + "&rand=" + Math.random(), "", 1000, 600);
                });
            }

            function opencenterwin(url, name, iWidth, iHeight) {
                var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
                var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
                window.open(url, name, 'height=' + iHeight + ',,innerHeight=' + iHeight + ',width=' + iWidth + ',                      innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=                yes,resizable=yes');
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
