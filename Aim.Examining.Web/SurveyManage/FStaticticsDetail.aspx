<%@ Page Title="查询统计" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master"
    AutoEventWireup="true" CodeBehind="FStaticticsDetail.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.FStaticticsDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "UsrChildWelfareEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var SurveyId = $.getQueryString({ ID: "SurveyId" });
        var title = unescape($.getQueryString({ ID: "title" }));
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
			{ name: 'WorkNo' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'Sex' },
			{ name: 'Corp' },
			{ name: 'Dept' },
			{ name: 'Indutydate' },
			{ name: 'WorkAge' },
			{ name: 'Crux' },
			{ name: 'BornDate' },
			{ name: 'Age' },
			{ name: 'JobName' },
			{ name: 'JobDegree' },
			{ name: 'JobSeq' },
			{ name: 'Skill' },
			{ name: 'Content' },
			{ name: 'QuestionType' },
			{ name: 'Answer' },
			{ name: 'Explanation'}],
                aimbeforeload: function (proxy, options) {
                    options.data = options.data || {};
                    options.data.SurveyId = SurveyId;
                }
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            //----------------------------------------
            var fsf = new Ext.FormPanel({
                labelWidth: 75, // label settings here cascade unless overridden
                frame: true,
                title: '查询维度',
                bodyStyle: 'padding:5px 5px 0',
                width: 350,

                items: [{
                    xtype: 'checkboxgroup',
                    fieldLabel: '维度',
                    columns: 3,
                    items: [
                        { boxLabel: '公司', name: 'cb-auto-1' },
                        { boxLabel: '年龄', name: 'cb-auto-2' },
                        { boxLabel: '性别', name: 'cb-auto-3'}]
                }
            ]

            });

            var text = new Ext.FormPanel({
                labelWidth: 75, // label settings here cascade unless overridden
                frame: true,
                title: '查询条件',
                bodyStyle: 'padding:5px 5px 0',
                width: 350,
                items: [{
                    xtype: 'checkboxgroup',
                    fieldLabel: '维度',
                    columns: 3,
                    items: [
                        { boxLabel: '公司', name: 'cb-auto-1' },
                        { boxLabel: '年龄', name: 'cb-auto-2' },
                        { boxLabel: '性别', name: 'cb-auto-3'}]
                }
            ]

            });


            //                //查询栏
            //                panel = new Ext.Panel({
            //                    title: '查询区域',
            //                    region: 'north',
            //                    layout: 'column',
            //                    tbar: tlBar,
            //                    height: 140,
            //                    border: false,
            //                    autoScroll: true,
            //                    items: [fsf, text]
            //                });

            //	----------------------------列表页面-----------------------------------
            tlBar = new Ext.ux.AimToolbar({
                items: ['->', {
                    text: '刷新数据源',
                    iconCls: 'aim-icon-refresh',
                    handler: function () {
                        Ext.getBody().mask("数据刷新中...");
                        $.ajaxExecSync("RefData", { SurveyId: SurveyId }, function (rtn) {
                            Ext.getBody().unmask();
                            if (rtn.data.State == "1") {
                                store.reload();
                                AimDlg.show("数据刷新成功!");
                            } else {
                                AimDlg.show("数据刷新失败!");
                            }
                        }, null, "Comman.aspx");
                    }
                }, {
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function () {
                        if (store.getRange().length <= 0) {
                            AimDlg.show("暂无数据,无须导出!");
                            return;
                        }
                        Ext.getBody().mask("正在导出请稍后...");
                        $.ajaxExec('ImpExcel', {
                            SurveyId: SurveyId,
                            path: "../Excel/SurveyOne.xls",
                            "fileName": "SurveyOne"
                        }, function (rtn) {
                            Ext.getBody().unmask();
                            if (rtn.data.fileName) {
                                $("body").append("<iframe style='display:none' src=" + rtn.data.fileName + "></iframe>");
                            }
                        });
                    }
                }]
            })


            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                collapsed: false,
                columns: 6,
                items: [
                { fieldLabel: '公司', id: 'Corp', schopts: { qryopts: "{ mode: 'Like', field: 'Corp' }"} },
                { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                { fieldLabel: '岗位', id: 'JobName', schopts: { qryopts: "{ mode: 'Like', field: 'JobName' }"} },
                { fieldLabel: '工龄', id: 'WorkAge', schopts: { qryopts: "{ mode: 'Like', field: 'WorkAge' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function () {
                    Ext.ux.AimDoSearch(Ext.getCmp("WorkNo"));
                }
                }
                 ]
            });


            titPanel = new Ext.ux.AimPanel({
                tbar: tlBar,
                items: [schBar]
            });


            // 表格面板
            grid = new Ext.ux.grid.AimGridPanel({
                title: title,
                store: store,
                region: 'center',
                //heigth: 500,
                // autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'SurveyId', dataIndex: 'SurveyId', header: 'SurveyId', width: 100, sortable: true, hidden: true },
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 100, sortable: true },
					{ id: 'UserId', dataIndex: 'UserId', header: 'UserId', width: 100, sortable: true, hidden: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 80, sortable: true },
					{ id: 'Sex', dataIndex: 'Sex', header: '性别', width: 60, sortable: true },
					{ id: 'Corp', dataIndex: 'Corp', header: '公司', width: 200, sortable: true },
					{ id: 'Dept', dataIndex: 'Dept', header: '部门', width: 150, sortable: true },
					{ id: 'Indutydate', dataIndex: 'Indutydate', header: '入职日期', width: 100, sortable: true },
					{ id: 'WorkAge', dataIndex: 'WorkAge', header: '工龄', width: 50, sortable: true },
					{ id: 'Crux', dataIndex: 'Crux', header: '关键岗位', width: 80, sortable: true, renderer: RowRender },
					{ id: 'BornDate', dataIndex: 'BornDate', header: '出生日期', width: 100, sortable: true },
					{ id: 'Age', dataIndex: 'Age', header: '年龄', width: 50, sortable: true },
					{ id: 'JobName', dataIndex: 'JobName', header: '岗位', width: 100, sortable: true },
					{ id: 'JobDegree', dataIndex: 'JobDegree', header: '岗位等级', width: 60, sortable: true },
					{ id: 'JobSeq', dataIndex: 'JobSeq', header: '岗位序列', width: 100, sortable: true },
					{ id: 'Skill', dataIndex: 'Skill', header: '技能等级', width: 100, sortable: true },
					{ id: 'Content', dataIndex: 'Content', header: '题目', width: 320, sortable: true, renderer: RowRender },
					{ id: 'QuestionType', dataIndex: 'QuestionType', header: '问题类型', width: 100, sortable: true },
					{ id: 'Answer', dataIndex: 'Answer', header: '答案', width: 230, sortable: true },
				    { id: 'Explanation', dataIndex: 'Explanation', header: '说明', width: 100, sortable: true }
                    ],
                tbar: titPanel,
                bbar: pgBar
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [grid]
            });
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "Content":
                    if (value) {
                        value = value || "";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        rtn = value;
                    }
                    break;
                case "Crux":
                    if (value) {
                        if (value == "N") rtn = "否";
                        if (value == "Y") rtn = "是";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    }
                    break;
            }
            return rtn;
        }
        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
    
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
