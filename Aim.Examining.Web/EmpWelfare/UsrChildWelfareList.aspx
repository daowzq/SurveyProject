<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="UsrChildWelfareList.aspx.cs" Inherits="Aim.Examining.Web.UsrChildWelfareList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=680,height=560,scrollbars=yes");
        var EditPageUrl = "UsrChildWelfareEdit.aspx";
        var Modelstyle = "dialogWidth:680px; dialogHeight:560px; scroll:yes; center:yes; status:no; resizable:no;";

        var YearEnum = "";
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        function onPgLoad() {
            //----------设置年份----------------
            var evalStr = "";
            var year = new Date().getFullYear();
            evalStr += "{";
            evalStr += "\"\":'请选择...',";
            for (var i = 0; i < 5; i++) {
                if (i > 0) evalStr += ",";
                evalStr += (year - i) + ":" + (year - i);
            }
            evalStr += "}";
            YearEnum = eval("(" + evalStr + ")");
            //-- -- -- -- -- -- -- -- -- -- -- --  

            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["UsrChildWelfareList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'UsrChildWelfareList',
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
			{ name: 'ChildCount' },
			{ name: 'Addr' },
			{ name: 'Reason' },
			{ name: 'WelfareType' },
            { name: "ApproveUserId" },
            { name: "ApproveName" },
            { name: "WorkFlowCode" },
            { name: "WorkFlowState" },
			{ name: "AddFiles" },
			{ name: 'ApplyTime' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' },
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
                columns: 5,
                items: [
                // { fieldLabel: '保险类型', id: 'WelfareType', xtype: 'aimcombo', required: true, enumdata: { "": "请选择...", "double": "员工配偶保险", "child": "员工子女保险" }, schopts: { qryopts: "{ mode: 'Like', field: 'WelfareType' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("WelfareType")); } } },
                {fieldLabel: '年度', id: 'Year', xtype: 'aimcombo', required: true,
                enumdata: YearEnum,
                schopts: { qryopts: "{ mode: 'Like', field: 'Year' }" },
                listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("Year")); } }
            },
                 { fieldLabel: '月份', id: 'month', xtype: 'aimcombo', required: true,
                     enumdata: {
                         "": "请选择..",
                         "1": "1月份",
                         "2": "2月份",
                         "3": "3月份",
                         "4": "4月份",
                         "5": "5月份",
                         "6": "6月份",
                         "7": "7月份",
                         "8": "8月份",
                         "9": "9月份",
                         "10": "10月份",
                         "11": "11月份",
                         "12": "12月份"
                     },
                     schopts: { qryopts: "{ mode: 'Like', field: 'Month' }" },
                     listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("month")); } }
                 },
               { fieldLabel: '申报日期', cls: 'Wdate', id: 'StartTime', format: 'Y-m-d', xtype: 'textfield', endDateField: 'EndTime', schopts: { qryopts: "{ mode: 'GreaterThanEqual', datatype:'Date', field: 'ApplyTime' }" }, listeners: { focus: function(obj) {
                   var maxDate = Ext.getCmp("EndTime").getValue() ? Ext.getCmp("EndTime").getValue() : '';
                   WdatePicker({
                       dateFmt: "yyyy-MM-dd",
                       maxDate: maxDate
                   });
               }, blur: function(obj) {
                   return false;
               }
               }
               },
                { fieldLabel: '截至日期', id: 'EndTime', cls: 'Wdate', format: 'Y-m-d', xtype: 'textfield', startDateField: 'StartTime', schopts: { qryopts: "{ mode: 'LessThanEqual', datatype:'Date', field: 'ApplyTime' }" }, listeners: { focus: function(obj) {
                    var minDate = Ext.getCmp("StartTime").getValue() ? Ext.getCmp("StartTime").getValue() : '';
                    WdatePicker({
                        dateFmt: "yyyy-MM-dd",
                        minDate: minDate
                    });
                }, blur: function(obj) {
                    return false;
                }
                }
                },
				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
				    Ext.ux.AimDoSearch(Ext.getCmp("StartTime"));   //Number 为任意
				}
				}
                ]
        });

        // 工具栏
        tlBar = new Ext.ux.AimToolbar({
            items: [{
                text: '填写申报',
                iconCls: 'aim-icon-add',
                handler: function() {
                    //                    if (openTreatyDlg()) {
                    //                        var url = EditPageUrl + "?op=c";
                    //                        // ExtOpenGridEditWin(grid, url, "c", EditWinStyle);
                    //                        OpenModelWin(url, window, Modelstyle, function() {
                    //                            store.reload();
                    //                        });
                    //                    }
                    ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                }
            }, {
                text: '修改',
                iconCls: 'aim-icon-edit',
                handler: function() {
                    //-1 不同意 1
                    var recs = grid.getSelectionModel().getSelections();
                    // if (recs[0].get("WorkFlowState") == '2') {
                    //     AimDlg.show("已处理且同意的记录不能修改!");
                    //     return;
                    //  }
                    ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    //                    if (recs.length <= 0) {
                    //                        AimDlg.show("请选择要修改的记录!");
                    //                        return
                    //                    }
                    //var url = EditPageUrl + "?op=u&id=" + recs[0].get("Id");
                    //ExtOpenGridEditWin(grid, url, "c", EditWinStyle);
                    //                    OpenModelWin(url, window, Modelstyle, function() {
                    //                        store.reload();
                    //                    });
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
                    if (recs[0].get("WorkFlowState") == '2' || recs[0].get("WorkFlowState") == '-1') {
                        AimDlg.show("已处理的记录不能删除!");
                        return;
                    }
                    if (confirm("确定删除所选记录？")) {
                        ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                    }
                }
            }, '-', {
                hidden: true,
                text: '提交申报',
                iconCls: 'aim-icon-submit',
                handler: function() {
                    var recs = grid.getSelectionModel().getSelections();
                    if (!recs || recs.length <= 0) {
                        AimDlg.show("请先选择要申报的记录！");
                        return;
                    }
                    if (recs[0].get("WorkFlowState") == "1" || recs[0].get("WorkFlowState") == "-1" || recs[0].get("WorkFlowState") == "2") {
                        AimDlg.show("已提交申报,无需重复提交申报!");
                        return;
                    }
                    if (confirm("确认提交申报吗？")) {
                        //提交审批
                        $.ajaxExec("Submit", { Id: recs[0].get("Id") }, function(rtn) {
                            if (rtn.data.State == '1') {
                                AimDlg.show("提交申报成功!");
                                store.reload();
                                return;
                            }
                        });
                    }

                }
            }, {
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
                margins: '0 10 10 0',
                region: 'center',
                viewConfig: { forceFit: true, scrollOffset: 10 },
                // autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    { id: 'UserId', dataIndex: 'UserId', header: '标识', hidden: true },
                    { id: 'DeptId', dataIndex: 'DeptId', header: '部门ID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),

					{ id: 'UserName', dataIndex: 'UserName', header: '申请人', width: 100, sortable: true },
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 80, sortable: true },
					{ id: 'Sex', dataIndex: 'Sex', header: '性别', width: 80, sortable: true },
                    { id: 'WelfareType', dataIndex: 'WelfareType', header: '保险类型', width: 80, sortable: true, renderer: RowRender },
                //{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 200, sortable: true },
                // { id: 'ChildCount', dataIndex: 'ChildCount', header: '子女个数', width: 80, sortable: true },
                // {id: 'ApproveName', dataIndex: 'ApproveName', header: '审批人', width: 80 },
					{id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: "<font color='red' >状态</font>", width: 60, sortable: true, renderer: RowRender },
					{ id: 'DealState', dataIndex: 'WorkFlowState', header: "<font color='red' >处理结果</font>", width: 60, sortable: true, renderer: RowRender },
					{ id: 'Year', dataIndex: 'ApplyTime', header: '申请年份', width: 80, sortable: true, renderer: RowRender },
					{ id: 'Month', dataIndex: 'ApplyTime', header: '申请月份', width: 60, sortable: true, renderer: RowRender },
					{ id: 'ApplyTime', dataIndex: 'ApplyTime', header: '申请日期', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });
            grid.on("rowdblclick", function(Grid, rowIndex, e) {
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
                case "Year":
                    if (value) {
                        rtn = $.toDate(value).getFullYear();
                    }
                    break;
                case "Month":
                    if (value) {
                        rtn = $.toDate(value).getMonth() + 1;
                    }
                    break;
                case "WorkFlowState":
                    if (value == "1") {
                        rtn = "未处理";
                    } else if (value == "2" || value == "-1") {
                        rtn = "已处理";
                    }
                    break;
                case "DealState":
                    if (value == "2") {
                        rtn = "同意";
                    }
                    else if (value == "-1") {
                        rtn = "不同意";
                    }
                    break;
                case "WelfareType":
                    if (value == "double") {
                        rtn = "员工配偶保险";
                    } else if (value == "child") {
                        rtn = "员工子女保险";
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
            var url = "/EmpWelfare/TreatyDialog.aspx?title=baoxian";
            var bol = false;
            OpenModelWin(url, window, style, function(rtn) {
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
