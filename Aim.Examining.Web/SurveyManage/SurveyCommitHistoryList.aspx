<%@ Page Title="历史问卷" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SurveyCommitHistoryList.aspx.cs" Inherits="Aim.Examining.Web.SurveyCommitHistoryList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "SurveyCommitHistoryEdit.aspx";
        var surveyId = $.getQueryString({ ID: 'surveyId' });
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
			{ name: 'SurveyId' },
			{ name: 'SurveyName' },
			{ name: 'DeptName' },
			{ name: 'IsNoName' },
		    { name: 'TotalScore' },
			{ name: 'CropName' },
			{ name: 'WorkNo1' },
			{ name: "ScoreInfo" },
			{ name: 'SurveyedUserId' },
			{ name: 'SurveyedUserName' },
			{ name: 'CommitSurvey' },
			{ name: 'CreateTime' }
			],
                aimbeforeload: function(proxy, options) {
                    options.data = options.data || {};
                    options.data.surveyId = surveyId;
                }
            });


            $.each(store.getRange(), function() {
                var value = this.get("ScoreInfo");
                var ScoreInfo = (value + "").split("$|");
                var strb = "";
                for (var i = 0; i < ScoreInfo.length; i++) {
                    //每一项
                    if (i > 0) strb += "\r\n<br/>";
                    strb += "<b>" + (i + 1) + " " + (ScoreInfo[i] + "").substring(0, (ScoreInfo[i] + "").indexOf(",")) + "</b>";

                    //子项
                    var items = ScoreInfo[i].split(",");
                    for (var j = 1; j < items.length; j++) {
                        strb += "\r\n<br/> &nbsp;" + items[j];
                    }
                }
                this.set("ScoreInfo", strb);
                //this.set("ScoreInfo", strb.substring(strb.indexOf("^|^") + 3, strb.length))
                //this.set("TotalScore", ((value + "").split("^|^")[0]) || "0")
            })

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });
            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                columns: 5,
                collapsed: false,
                items: [
                { fieldLabel: '姓名', id: 'SurveyedUserName', schopts: { qryopts: "{ mode: 'Like', field: 'SurveyedUserName' }"} },
                { fieldLabel: '工号', id: '工号', schopts: { qryopts: "{ mode: 'Like', field: 'A.WorkNo' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("SurveyedUserName"));   //Number 为任意
                }
                }
      ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '问卷列表' });
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
                    //collapsible: true,
                    collapsed: false,
                    region: 'center',
                    viewConfig: { forceFit: true, scrollOffset: 10 },
                    autoExpandColumn: 'CropName',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    { id: 'SurveyedUserId', dataIndex: 'SurveyedUserId', header: '人员编号', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'SurveyedUserName', dataIndex: 'SurveyedUserName', header: '姓名', width: 70, sortable: true, renderer: RowRender },
					{ id: 'WorkNo1', dataIndex: 'WorkNo1', header: '工号', width: 80, sortable: true, renderer: RowRender },
					{ id: 'CropName', dataIndex: 'CropName', header: '所属公司', width: 140 },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 100, sortable: true },
				    { id: 'TotalScore', dataIndex: 'TotalScore', header: '总分', width: 80, sortable: true, renderer: RowRender },
				    { id: 'ScoreInfo', header: '分值详细', dataIndex: 'ScoreInfo', hidden: true, width: 200, renderer: RowRender },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '填写时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                grid.on("rowclick", function(Grid, rowIndex, e) {
                    var Element = document.getElementById("frameContent");
                    if (Element) {
                        var rec = grid.getStore().getAt(rowIndex);
                        // var url = "SurveyedHistory.aspx?SurveyId=" + rec.get("SurveyId") + "&UserId=" + rec.get("SurveyedUserId");
                        var url = "SurveyedHistory_1.aspx?SurveyId=" + rec.get("SurveyId") + "&UserId=" + rec.get("SurveyedUserId");
                        frameContent.location.href = url;
                    }
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid, {
                        title: '问卷详细',
                        // height: parseInt($("body").innerHeight() / 2) - 20,
                        width: '50%',
                        collapsible: true,
                        collapsed: false,
                        region: 'east',
                        split: true,
                        margins: '-2 0 0 0',
                        cls: 'empty',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'}]
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
                        case "TotalScore":
                            if (value == -1) {
                                value = "";
                                cellmeta.style = 'background-color: gray';
                                rtn = value;
                            } else if ((value + "").indexOf("null") > -1) {
                                value = "";
                                cellmeta.style = 'background-color: gray';
                                rtn = value;
                            }
                            else {
                                var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='showInfo(\"" + rowIndex + "\")'> &nbsp;" + value + "&nbsp;&nbsp;</span>";
                                cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                                rtn = str;
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
                        case "ScoreInfo":
                            cellmeta.attr = 'style="white-space:normal;"';
                            rtn = value;
                            break;
                    }
                    return rtn;
                }

                function showInfo(rowIndex) {
                    var rec = grid.getStore().getAt(rowIndex);
                    AimDlg.show(rec.get("ScoreInfo"));
                }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
