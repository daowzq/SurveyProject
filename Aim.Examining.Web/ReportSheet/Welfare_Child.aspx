<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Welfare_Child.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.Welfare_Child" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">


        var YearEnum = "";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var type = $.getQueryString({ ID: 'type' });

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
                records: AimState["DataList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },

			{ name: 'Year' },
			{ name: 'Month' },


			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'WorkNo' },
			{ name: 'Sex' },

			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
			{ name: 'IdentityCard' },
			{ name: 'IndutyData' },
			{ name: 'WelfareType' },
            { name: 'WorkFlowState' },
            { name: 'ChildName' },
            { name: 'ChlidSex' },
            { name: 'ChildIdCart' },
             { name: 'ApplyTime' },
			{ name: 'CreateTime' }
			],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.type = type;
                    }
                }
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            var items = [{ fieldLabel: '年度', id: 'Year', xtype: 'aimcombo', required: true,
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
                    listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("Year")); } }
                },
                { fieldLabel: '保险类型', id: 'WelfareType', xtype: 'aimcombo', required: true, enumdata: { "double": "员工配偶保险", "child": "员工子女保险", "": "请选择..." }, schopts: { qryopts: "{ mode: 'Like', field: 'WelfareType' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("WelfareType")); } } },
            //{ fieldLabel: '状态', id: 'WorkFlowState', xtype: 'aimcombo', required: true, enumdata: { "1": " 未处理", "2,-1": "已处理", "": "请选择..." }, schopts: { qryopts: "{ mode: 'Like', field: 'WorkFlowState' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("WelfareType")); } } },

                {fieldLabel: '公司', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CompanyName' }"} },
                { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Year"));   //Number 为任意
                }
                }
                ];

            if (type == "y") {
                var tempObj = {
                    fieldLabel: '处理结果',
                    id: 'DealState',
                    xtype: 'aimcombo',
                    required: true, enumdata: { "2": " 同意", "-1": " 不同意", "": "请选择..." },
                    schopts: { qryopts: "{ mode: 'Like', field: 'WorkFlowState' }" },
                    listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("WelfareType")); } }
                }
                items.push(tempObj);
            }

            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                columns: 7,
                collapsed: false,
                items: items
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [
                {
                    text: '批量处理',
                    iconCls: 'aim-icon-submit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs.length <= 0) {
                            AimDlg.show("请选择要处理的记录!");
                            return
                        }
                        var needDeal = [];
                        $.each(recs, function() {
                            if (this.get("WorkFlowState") == "1") {
                                needDeal.push(this.get("Id"));
                            }
                        });

                        var sw = new Ext.Window({
                            title: '批量处理',
                            width: 380,
                            height: 220,
                            padding: '15 5 5 5',
                            autoScroll: true,
                            layout: 'form',
                            bodyStyle: 'overflow-y:auto;overflow-x:auto;',
                            items: [{
                                xtype: 'label',
                                fieldLabel: '总条目',
                                text: recs.length + " 条"
                            },
                            {
                                xtype: 'label',
                                fieldLabel: '待处理条目',
                                text: needDeal.length + " 条"
                            },
                             {
                                 id: 'result',
                                 xtype: 'textarea',
                                 fieldLabel: '处理意见',
                                 width: 200,
                                 height: 60,
                                 text: ""
}],
                            buttons: [
            {
                text: "同意",
                handler: function() {
                    if (needDeal.length <= 0) {
                        AimDlg.show("没有需要处理的记录!");
                        return;
                    }
                    var result = Ext.getCmp("result").getValue();
                    var ids = needDeal.join(",");
                    $.ajaxExec("AppSubmit", { result: result, ids: ids, state: '2' }, function(rtn) {
                        store.reload();
                        AimDlg.show("处理成功!");
                        sw.close();
                        return;
                    });
                }
            },
            {
                text: "不同意",
                handler: function() {
                    if (needDeal.length <= 0) {
                        AimDlg.show("没有需要处理的记录!");
                        return;
                    }
                    var result = Ext.getCmp("result").getValue();
                    if (!result) {
                        AimDlg.show("请填写处理意见");
                        return;
                    } else {
                        var ids = needDeal.join(",");
                        $.ajaxExec("AppSubmit", { result: result, ids: ids, state: '-1' }, function(rtn) {
                            store.reload();
                            AimDlg.show("处理成功!");
                            sw.close();
                            return;
                        });
                    }
                }
            },
             {
                 text: "取消",
                 handler: function() {
                     sw.close();
                 }
             }

        ]
                        });
                        sw.show();

                    }
                }, '-', {
                    text: '导出<font size=1 >Excel</font>',
                    iconCls: 'aim-icon-xls',
                    handler: function() {

                        if (store.getRange().length <= 0) {
                            AimDlg.show("暂无数据,无须导出!");
                            return;
                        }

                        var month = Ext.getCmp("month").getValue();
                        var year = Ext.getCmp("Year").getValue();
                        // var WorkFlowState = Ext.getCmp("WorkFlowState").getValue();
                        var dealState = Ext.getCmp("DealState") ? Ext.getCmp("DealState").getValue() : "";
                        var WelfareType = Ext.getCmp("WelfareType").getValue();

                        Ext.getBody().mask("正在导出请稍后...");
                        $.ajaxExec('ImpExcel', {
                            year: year,
                            month: month,
                            type: type,
                            DealState: dealState,
                            WorkFlowState: "",
                            WelfareType: WelfareType
                        }, function(rtn) {
                            Ext.getBody().unmask();
                            if (rtn.data.fileName) {
                                // var url = "/CommonPages/File/DownLoad.aspx?FileName=SurveyUsrImp.xlsx";
                                var fileNameArr = (rtn.data.fileName + "").split("|");
                                if (fileNameArr.length > 1) {
                                    $("body").append("<iframe style='display:none' src=" + fileNameArr[0] + "></iframe>");
                                    window.setTimeout(function() {
                                        $("body").append("<iframe style='display:none' src=" + fileNameArr[1] + "></iframe>");
                                    }, 500);
                                } else {
                                    $("body").append("<iframe style='display:none' src=" + fileNameArr + "></iframe>");
                                }

                                //window.open("/Excel/downloadxls.html?filename=" + rtn.data.fileName, 'newwindow', 'height=200,width=400,toolbar=no,menubar=no,scrollbars=no,resizable=no,location=no,status=no')
                            }
                        });
                    }
                }, {
                    xtype: 'tbtext',
                    text: '<font color=red>(说明:&nbsp; 双击数据记录行可进行处理)</font>'
}]
                });

                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.grid.AimGridPanel({
                    margins: '0 10 10 0',
                    store: store,
                    region: 'center',
                    viewConfig: { forceFit: true, scrollOffset: 10 },
                    //autoExpandColumn: 'Name',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),

					{ id: 'Year', dataIndex: 'Year', header: '年度', width: 80, sortable: true },
					{ id: 'Month', dataIndex: 'Month', header: '月份', width: 80, sortable: true },
					{ id: 'WelfareType', dataIndex: 'WelfareType', header: '保险类型', width: 100, sortable: true, renderer: RowRender },
					  { id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 80, sortable: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 100, sortable: true },
				    { id: 'Sex', dataIndex: 'Sex', header: '性别', width: 60 },
			        { id: 'CompanyName', dataIndex: 'CompanyName', header: '公司名称', width: 200, sortable: true },
				    { id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 130, sortable: true },
					{ id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: "<font color='red'>状态</font>", width: 60, sortable: true, renderer: RowRender },
					{ id: 'DealState', dataIndex: 'WorkFlowState', header: "<font color='red'>处理结果</font>", width: 60, sortable: true, renderer: RowRender },
					{ id: 'ApplyTime', dataIndex: 'ApplyTime', header: '申报日期', width: 100, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                grid.on("rowdblclick", function(Grid, rowIndex, e) {
                    var Id = store.getAt(rowIndex).get("Id");
                    var task = new Ext.util.DelayedTask();
                    task.delay(100, function() {
                        opencenterwin("../EmpWelfare/UsrChildWelfareEdit.aspx?op=u&type=app&id=" + Id, "", 670, 630);
                    });
                });
                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid]
                });
            }
            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
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
            function opencenterwin(url, name, iWidth, iHeight) {
                var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
                var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
                window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
