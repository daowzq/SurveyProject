<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="UsrTravelWelfareList.aspx.cs" Inherits="Aim.Examining.Web.UsrTravelWelfareList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>
    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>
    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=670,height=600,scrollbars=yes");
        var EditWinStyle1 = CenterWin("width=800,height=600,scrollbars=yes");
        var EditPageUrl = "UsrTravelWelfareEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["UsrTravelWelfareList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'UsrTravelWelfareList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'Sex' },
			{ name: 'WorkNo' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'IdentityCard' },
			{ name: 'NSSFNo' },
			{ name: 'ApproveUserId' },
		    { name: 'ApproveName' },
			{ name: 'TravelAddr' },
			{ name: 'HaveFamily' },
			{ name: 'OtherName' },
			{ name: 'UserCount' },
			{ name: 'WorkFlowState' },
			{ name: 'WorkFLowCode' },
			{ name: 'Reason' },
			{ name: 'ApplyTime' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' },
			{ name: 'StartDate' },
		    { name: 'EndDate' },
		    { name: 'TravelTime' },
			{ name: 'Ext1' }
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
                columns: 4,
                items: [
                { fieldLabel: '起始时间', cls: 'Wdate', id: 'StartTime', format: 'Y-m-d', xtype: 'textfield', schopts: { qryopts: "{ mode: 'GreaterThanEqual', datatype:'Date', field: 'ApplyTime' }" }, listeners: { focus: function (obj) {
                    WdatePicker({
                        dateFmt: "yyyy-MM-dd"
                    });
                }, blur: function (obj) {
                    return false;
                }
                }
                },
                { fieldLabel: '截至时间', cls: 'Wdate', id: 'EndTime', format: 'Y-m-d', xtype: 'textfield', schopts: { qryopts: "{ mode: 'LessThanEqual', datatype:'Date', field: 'ApplyTime' }" }, listeners: { focus: function (obj) {
                    WdatePicker({
                        dateFmt: "yyyy-MM-dd"
                    });
                }, blur: function (obj) {
                    return false;
                }
                }
                },
				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function () {
				    Ext.ux.AimDoSearch(Ext.getCmp("StartTime"));   //Number 为任意
				}
				}
                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    //disabled: !!AimState["NoticeState"] ? false : true,
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function () {

                        //  $.ajaxExec("CheckApply", {}, function(rtn) {
                        // ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                        //  });


                        if (openTreatyDlg()) {
                            var url = EditPageUrl + "?op=c";
                            var style = "dialogWidth:710px; dialogHeight:570px; scroll:yes; center:yes; status:no; resizable:no;";
                            // ExtOpenGridEditWin(grid, url, "c", EditWinStyle);
                            OpenModelWin(url, window, style, function () {
                                store.reload();
                            });
                        }


                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function () {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs.length <= 0) {
                            AimDlg.show("请选择要修改的记录!");
                            return
                        }
                        if (recs[0].get("WorkFlowState") == '2' || recs[0].get("WorkFlowState") == '-1' || recs[0].get("WorkFlowState") == '1') {
                            AimDlg.show("有申报状态的记录不能修改!");
                            return;
                        }
                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function () {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }
                        if (recs[0].get("WorkFlowState") == '2' || recs[0].get("WorkFlowState") == '-1' || recs[0].get("WorkFlowState") == '1') {
                            AimDlg.show("有申报状态的记录不能删除!");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, '-', {
                    xtype: 'tbtext',
                    text: '<font color=red>(说明:&nbsp; 双击数据记录行可查看详细)</font>'
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
                margins: '0 10 10 0',
                viewConfig: { forceFit: true, scrollOffset: 10 },
                // autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    { id: 'UserId', dataIndex: 'UserId', header: '标识', hidden: true },
                    { id: 'DeptId', dataIndex: 'DeptId', header: '部门ID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 80, sortable: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '申请人', width: 90, sortable: true },
				        	{ id: 'Sex', dataIndex: 'Sex', header: '性别', width: 60, sortable: true },
                //{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 150, sortable: true },

					{id: 'TravelAddr', dataIndex: 'TravelAddr', header: '旅游地点', width: 120, sortable: true },
				    { id: 'TravelTime', dataIndex: 'TravelTime', header: '出行日期', width: 120, renderer: ExtGridDateOnlyRender },
				    { id: 'HaveFamily', dataIndex: 'HaveFamily', header: '是否带家属', width: 80, renderer: RowRender },
				    { id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: "<font color='red' >状态</font>", width: 60, sortable: true, renderer: RowRender },
					{ id: 'ApplyTime', dataIndex: 'ApplyTime', header: '申请日期', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });

            grid.on("rowdblclick", function (Grid, rowIndex, e) {
                var WinStyle = CenterWin("width=670,height=580,scrollbars=yes");
                ExtOpenGridEditWin(grid, EditPageUrl, "r", WinStyle);
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });
        }
        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "WorkFlowState":
                    if (value == "1") {
                        rtn = "处理中";
                    } else if (value == "2") {
                        rtn = "同意";
                    } else if (value == "-1") {
                        rtn = "不同意";
                    }
                    else {
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + "请点击'提交申报' 按钮及时申报!" + '"';
                        rtn = "<font color='red' >未申报</font>";
                    }
                    break;
                case "HaveFamily":
                    if (value == "N") {
                        rtn = "否";
                    } else if (value == "Y") {
                        var str = "<span>" + "&nbsp;&nbsp;是&nbsp;&nbsp;" + "</span>";
                        rtn = str;
                    } else {
                        rtn = "否";
                    }
                    break;
            }
            return rtn;
        }
        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }

        function openTreatyDlg() {
            var style = "dialogWidth:930px; dialogHeight:700px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "TravelTreatyDialog.aspx?title=baoxian";
            var bol = false;
            OpenModelWin(url, window, style, function (rtn) {
                bol = true;
            })
            return bol;
        }

    </script>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
