<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Welfare_Travel.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.Welfare_Travel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=1000,height=520,scrollbars=yes");
        var EditPageUrl = "UsrTravelWelfareEdit.aspx";
        var dataEnum = { "1": "未处理", "2": "同意", "-1": '不同意', "Exception": "导入异常", "%%": "请选择..." };
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            //----------设置年份----------------
            var evalStr = "";
            var year = new Date().getFullYear();
            evalStr += "{";
            evalStr += "\"\":'请选择...',";
            for (var i = 0; i < 6; i++) {
                if (i > 0) evalStr += ",";
                evalStr += (year - 5 + i) + ":" + (year - 5 + i);
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
			{ name: 'TravelTime' },
			{ name: 'Reason' },
		    { name: 'CompanyName' },
			{ name: 'ApplyTime' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' },
			{ name: 'StartDate' },
		    { name: 'EndDate' },
			{ name: 'Ext1' },
			{ name: 'TravelMoney' }
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
                columns: 7,
                items: [
                { fieldLabel: '年度', id: 'Year', xtype: 'aimcombo', required: true,
                    enumdata: YearEnum,
                    schopts: { qryopts: "{ mode: 'Like', field: 'Year' }" },
                    listeners: { "collapse": function(e) {
                        Ext.ux.AimDoSearch(Ext.getCmp("Year"));
                    }
                    }
                },
                { fieldLabel: '状态', emptyText: '请选择...', id: 'WorkFlowState', xtype: 'aimcombo', required: true, enumdata: dataEnum, schopts: { qryopts: "{ mode: 'Like', field: 'WorkFlowState' }" }, listeners: { "collapse": function(e) {

                    if (e.value) Ext.ux.AimDoSearch(Ext.getCmp("WorkFlowState"));
                }
                }
                },
                 { fieldLabel: '公司', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CompanyName' }"} },

                  { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                  { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                  { fieldLabel: '旅游金', id: 'TravelMoney', schopts: { qryopts: "{ mode: 'Like', field: 'TravelMoney' }"} },
				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
				    Ext.ux.AimDoSearch(Ext.getCmp("StartTime"));   //Number 为任意
				}
				}
                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '<font size=2em>导入数据</font>',
                    iconCls: 'aim-icon-trans',
                    handler: function() {
                        if (confirm("请确保导入的文件符合模板规范！确定导入吗？")) {
                            ImpUser(function() {
                                store.reload();
                                AimDlg.show("导入成功！");
                            });
                        }
                    }
                }, {
                    text: '<font size=2em>模板下载</font>',
                    iconCls: 'aim-icon-download',
                    handler: function() {
                        var url = "../CommonPages/File/DownLoad.aspx?FileName=TravelImpTemplate.xls";
                        $("body").append("<iframe style='display:none;' src=" + url + "></iframe>");
                    }
                }, '-', {
                    text: '查看信息',
                    iconCls: 'aim-icon-preview',
                    handler: function() {
                        var Id = grid.getSelectionModel().getSelected().get("Id");
                        var task = new Ext.util.DelayedTask();
                        task.delay(100, function() {
                            opencenterwin("../EmpWelfare/UsrTravelWelfareEdit.aspx?op=u&type=app&id=" + Id, "", 710, 630);
                        });
                    }
                },
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
                     }, {
                         text: '刷新数据',
                         iconCls: 'aim-icon-refresh',
                         handler: function() {

                             //Ext.getBody().mask("数据刷新中...");
                             //$.ajaxExecSync("RefData", { SurveyId: SurveyId }, function(rtn) {

                             //});

                         }
                     }, '-', {
                         text: '导出Excel',
                         iconCls: 'aim-icon-xls',
                         handler: function() {
                             if (store.getRange().length <= 0) {
                                 AimDlg.show("暂无数据,无须导出!");
                                 return;
                             }
                             var WorkFlowState = Ext.getCmp("WorkFlowState").getValue();
                             Ext.getBody().mask("正在导出请稍后...");
                             $.ajaxExec('ImpExcel', { path: "/Excel/Travel.xls", "fileName": "旅游报名汇总", WorkFlowState: WorkFlowState }, function(rtn) {
                                 Ext.getBody().unmask();
                                 if (rtn.data.fileName) {
                                     $("body").append("<iframe style='display:none' src=" + rtn.data.fileName + "></iframe>");
                                 }
                                 //window.open("/Excel/downloadxls.html?filename=" + rtn.data.fileName, 'newwindow', 'height=200,width=400,toolbar=no,menubar=no,scrollbars=no,resizable=no,location=no,status=no')
                             });
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
                    { id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 70, sortable: true },
                    { id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 70, sortable: true },
					{ id: 'Sex', dataIndex: 'Sex', header: '性别', width: 50, sortable: true },
                    { id: 'CompanyName', dataIndex: 'CompanyName', header: '公司全称', width: 160, sortable: true, renderer: RowRender },
                    { id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 100, sortable: true, renderer: RowRender },


				    { id: 'TravelAddr', dataIndex: 'TravelAddr', header: '旅游地点', width: 100, sortable: true },
				    { id: 'TravelTime', dataIndex: 'TravelTime', header: '出行日期', width: 120 },
				    { id: 'TravelMoney', dataIndex: 'TravelMoney', header: '旅游金额', width: 60 },
				    { id: 'HaveFamily', dataIndex: 'HaveFamily', header: '是否带家属', width: 60, renderer: RowRender },

				    { id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: "<font color='red'>状态</font>", width: 60, sortable: true, renderer: RowRender },
					{ id: 'ApplyTime', dataIndex: 'ApplyTime', header: '申请日期', width: 80, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });

            grid.on("rowdblclick", function(Grid, rowIndex, e) {
                var Id = store.getAt(rowIndex).get("Id");
                var task = new Ext.util.DelayedTask();
                task.delay(100, function() {
                    opencenterwin("../EmpWelfare/UsrTravelWelfareEdit.aspx?op=u&type=app&id=" + Id, "", 710, 630);
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
                case "CompanyName":
                    rtn = (value + "").replace("/", "")
                    break;
                case "DeptName":
                    rtn = (value + "").replace("/", "")
                    break;
                case "WorkFlowState":
                    if (value == "2") {
                        rtn = "同意";
                    } else if (value == "1") {
                        rtn = "<font color='red' >未处理</font>";
                    }
                    else if (value == "-1") {
                        rtn = "不同意";
                    }
                    break;
                case "HaveFamily":
                    if (value == "N") {
                        rtn = "否";
                    } else if (value == "Y") {
                        //var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='winOpen(\"" + record.get("Id") + "\")'>" + "&nbsp;&nbsp;是&nbsp;&nbsp;" + "</span>";
                        var str = "<span>" + "是" + "</span>";
                        rtn = str;
                    } else {
                        rtn = "否";
                    }
                    break;
            }
            return rtn;
        }


        //导入人员
        function ImpUser(doSuccessFun) {
            var mode = 'single' //单个文件上传
            var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;";
            var uploadurl = '../CommonPages/File/Upload.aspx?IsSingle=true&Filter=(*.xls;*.xlsx)|*.xls;*.xlsx';
            var rtn = window.showModalDialog(uploadurl, window, UploadStyle);

            Ext.getBody().mask("人员导入中，请稍后！");
            rtn && $.ajaxExec("ImpUser", { FileId: (rtn + "").replace(",", "") }, function(rtn) {
                Ext.getBody().unmask();
                if (rtn.data.State == "1") doSuccessFun();
                else AimDlg.show("导入异常！");

            });
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
        function winOpen() {
            var id = arguments[0] || '';
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                opencenterwin("../EmpWelfare/UsrTravelWelfareEdit.aspx?op=u&type=app&id=" + id, "", 670, 560);
            });
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
