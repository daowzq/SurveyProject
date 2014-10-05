<%@ Page Title="发布问卷" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SurveyQuestionList.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyQuestionList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script src="../js/FixWidth.js" type="text/javascript"></script>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=960,height=650,scrollbars=0,resizable=0");
        var Modelstyle = "dialogWidth:960px; dialogHeight:650px; scroll:yes; center:yes; status:no; resizable:no;";
        var EditPageUrl = "SurveyQuestionWizard.aspx";

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
			{ name: 'SurveyTypeId' },
			{ name: 'SurveyTypeName' },
			{ name: 'SurveyTitile' },
			{ name: 'TypeCode' },
			{ name: 'Description' },
			{ name: 'StartTime' },
			{ name: 'EndTime' },
			{ name: "State" },
			{ name: 'NoticeWay' },
			{ name: 'EffectiveCount' },
			{ name: 'EffectiveRate' },
			{ name: 'AwardRate' },
			{ name: 'IsNoName' },
			{ name: 'IsSendRandom' },
			{ name: 'TemplateFilesId' },
			{ name: 'TemplateFilesName' },
			{ name: 'AddFilesId' },
			{ name: 'AddFilesName' },
			{ name: 'WorkFlowCode' },
			{ name: 'WorkFlowName' },
			{ name: 'WorkFlowState' },
			{ name: 'WorlFlowResult' },
			{ name: 'UrgencyDegree' },
			{ name: 'SetTimeout' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'IsCheck' },
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
                columns: 6,
                collapsed: false,
                items: [
                { fieldLabel: '问卷标题', id: 'SurveyTitile', schopts: { qryopts: "{ mode: 'Like', field: 'SurveyTitile' }"} },
                       { fieldLabel: '状态', id: 'State', xtype: 'aimcombo', required: true, enumdata: { '%%': '请选择...', '0': '未发布', '1': '启动', '3': '暂停', '2': '结束' }, schopts: { qryopts: "{ mode: 'Like', field: 'State' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("State")) } } },
                { fieldLabel: '起始时间', id: 'StartTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', endDateField: 'EndTime', schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'StartTime' }"} },
                { fieldLabel: '截至时间', id: 'EndTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', startDateField: 'StartTime', schopts: { qryopts: "{ mode: 'LessThan', datatype:'Date', field: 'EndTime' }"} },
       { fieldLabel: '创建人', id: 'CreateName', schopts: { qryopts: "{ mode: 'Like', field: 'CreateName' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("SurveyTitile"));   //Number 为任意
                }
                }
      ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '新建问卷',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        $.ajaxExec("getGuid", {}, function(rtn) {
                            //  var url = EditPageUrl + "?id=" + (rtn.data.Guid + "").replace("#", "");
                            // ExtOpenGridEditWin(grid, url, "u", EditWinStyle);
                            var url = EditPageUrl + "?id=" + (rtn.data.Guid + "").replace("#", "") + "&op=u";
                            OpenModelWin(url, window, Modelstyle, function() {
                                store.reload();
                            });
                        });
                    }
                }, {
                    text: '修改问卷',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (recs.length > 0) {
                            // if (recs[0].get("State") == "3") {   //暂停状态
                            //     AimDlg.show("暂停状态下的问卷无法修改!");
                            //     return;
                            //  }
                            //if (recs[0].get("State") == "1") { //启动
                            //    AimDlg.show("启动中的问卷无法修改!");
                            //    return;
                            //}
                            //if (recs[0].get("State") == "2") {   //结束
                            //    AimDlg.show("已结束的调查问卷无法修改!");
                            //    return;
                            // }
                            //  if (recs[0].get("WorkFlowState")) {
                            //      AimDlg.show("审批中的问卷不能修改!");
                            //      return;
                            //   }
                        }
                        //var url = EditPageUrl + "?id=" + (recs[0].get("Id") + "").replace("#", "") + "&type=update";
                        //ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);

                        if (recs[0].get("State") == "1" && (new Date() < $.toDate(recs[0].get("EndTime")))) {
                            if (!confirm("该问卷正在使用中,是否继续修改")) {
                                return;
                            }
                        }

                        if (recs.length <= 0) {
                            AimDlg.show("请选择要修该的记录!");
                            return;
                        }
                        var url = EditPageUrl + "?id=" + (recs[0].get("Id") + "").replace("#", "") + "&type=update&op=u";
                        OpenModelWin(url, window, Modelstyle, function() {
                            store.reload();
                        });
                    }
                }, {
                    text: '删除问卷',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }
                        if (recs[0].get("State") == "1") {
                            AimDlg.show("启动中的问卷不能删除！");
                            return;
                        }
                        if (recs[0].get("WorkFlowState")) {
                            AimDlg.show("审批状态的记录不能删除！");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, '-',

                {
                    text: '发布启动',
                    iconCls: 'aim-icon-run',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要发布的问卷项！");
                            return;
                        }

                        var isrReturn = false;
                        $.each(recs, function() {
                            //state==2 表示结束
                            if (this.get("State") == "2") {
                                isrReturn = true;
                                AimDlg.show("已结束的问卷不能启动！");
                                return;
                            }
                            if (this.get("State") == "1") {
                                isrReturn = true;
                                AimDlg.show("已启动的问卷不能重复发布！");
                                return;
                            }
                        });
                        if (isrReturn) return;
                        if (recs[0].get("WorkFlowState")) {
                            if ((recs[0].get("WorlFlowResult") + "").indexOf("同意") < 0) {
                                AimDlg.show("审批未通过的问卷不能发布！");
                                return
                            }
                        } else if (recs[0].get("IsCheck") == '1') {
                            //检查是否必须流程审批
                            //                            $.ajaxExecSync("CkFl", { SurveyId: recs[0].get("Id") }, function(rtn) {
                            //                                if (rtn.data.ChState == "1") {
                            //                                    AimDlg.show("该问卷必须走流程审批,请点击\"提交审批\"功能按钮进行配置");
                            //                                    isrReturn = true;
                            //                                    return;
                            //                                }
                            //                            });
                            AimDlg.show("该问卷必须走流程审批,请点击\"提交审批\"功能按钮提交审批。");
                            return;
                        }

                        if (isrReturn) return;


                        Ext.getBody().mask("调查问卷发布中...");

                        $.ajaxExec('Start', { Id: recs[0].get("Id") || '' }, function(rtn) {
                            Ext.getBody().unmask();
                            AimDlg.show("问卷发布成功!");
                            store.reload();
                        });
                    }
                }, {
                    text: '发布暂停',
                    iconCls: 'aim-icon-pause',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要暂停的问卷项！");
                            return;
                        }
                        var isrReturn = false;
                        $.each(recs, function() {
                            if (this.get("State") != "1") {
                                isrReturn = true;
                                AimDlg.show("启动的问卷才能暂停！");
                                return;
                            }
                        });

                        if (isrReturn) return;
                        $.ajaxExec('pause', { Id: recs[0].get("Id") }, function(rtn) {
                            AimDlg.show("暂停成功!");
                            store.reload();
                        });
                    }
                }

                , {
                    text: '发布结束',
                    iconCls: 'aim-icon-stop',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要结束的问卷项！");
                            return;
                        }

                        if (recs[0].get("State") != '1') {
                            AimDlg.show("启动的问卷调查才能结束！");
                            return;
                        }

                        if (confirm("确定要结束本次问卷吗？")) {
                            Ext.getBody().mask("调查问卷结束中。。。。");
                            $.ajaxExec("stop", { Id: recs[0].get("Id") }, function(rtn) {
                                store.reload();
                                Ext.getBody().unmask();
                            });
                        }
                    }
                }, '-',
                 {
                     text: '提交审批',
                     iconCls: 'aim-icon-submit',
                     handler: function() {
                         var recs = grid.getSelectionModel().getSelections();
                         if (!recs || recs.length <= 0) {
                             AimDlg.show("请先选择要审批的记录！");
                             return;
                         }

                         if (recs[0].get("IsCheck") != "1") {
                             AimDlg.show("该问卷不需要审批!");
                             return;
                         }
                         if (recs[0].get("WorkFlowState")) {
                             AimDlg.show("审批中或审批结束的记录,不能再进行提交!");
                             return;
                         }
                         var style = "dialogWidth:725px; dialogHeight:385px; scroll:yes; center:yes; status:no; resizable:no;";
                         //opencenterwin("WorkFlowChoices.aspx?SurveyId=" + recs[0].get("Id"), "", 725, 385);

                         var url = "WorkFlowChoices.aspx?SurveyId=" + recs[0].get("Id");
                         OpenModelWin(url, window, style, function(rtn) {
                             store.reload();
                         });

                     }
                 },
                {
                    text: '跟踪审批',
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
                },
                    '-',
                // {
                //       text: '设置问卷数量',
                //       iconCls: 'aim-icon-cog',
                //       handler: function() {
                //           var recs = grid.getSelectionModel().getSelections();
                //           if (!recs || recs.length <= 0) {
                //               AimDlg.show("请先选择要查看的记录！");
                //               return;
                //           }
                //           //  if (recs[0].get("State") != "0") { //启动
                //           //      AimDlg.show("创建状态的问卷才能设置问卷数量!");
                //           //      return;
                //           //   }
                //           surveyCountWin(recs[0].get("Id"));
                //       }
                //    }, 

                 {
                 text: '调查结果跟踪',
                 iconCls: 'aim-icon-db-import',
                 handler: function() {
                     var recs = grid.getSelectionModel().getSelections();
                     if (!recs || recs.length <= 0) {
                         AimDlg.show("请先选择要跟踪的记录！");
                         return;
                     }

                     if (recs[0].get("State") == "0") {
                         AimDlg.show("发布后的问卷才能跟踪！");
                         return;
                     }
                     UsrChoiceWin(recs[0].get("Id"));
                     //opencenterwin("/workflow/TaskExecuteView.aspx?FormId=" + recs[0].get("Id"), "", 1000, 600);
                 }
             },
                 {
                     text: '调查结果统计',
                     iconCls: 'aim-icon-preview2',
                     handler: function() {
                         var recs = grid.getSelectionModel().getSelections();
                         if (!recs || recs.length <= 0) {
                             AimDlg.show("请先选择要查看的记录！");
                             return;
                         }
                         if (!(recs[0].get("State") == "1" || recs[0].get("State") == "2")) { //启动或结束
                             AimDlg.show("只有启动或结束的问卷才能查看统计结果!");
                             return;
                         }
                         openStatisticWin(recs[0].get("Id"));
                     }
                 },
                        '-', {
                            text: '转存为模板',
                            iconCls: 'aim-icon-save',
                            handler: function() {
                                var recs = grid.getSelectionModel().getSelections();
                                if (!recs || recs.length <= 0) {
                                    AimDlg.show("请先选择要操作的记录！");
                                    return;
                                }

                                if (!confirm("确定将该问卷转存为模板？")) {
                                    return;
                                }
                                var SurveyId = recs[0].get("Id");
                                $.ajaxExec("CkHaveTpl", { SurveyId: SurveyId }, function(rtn) {
                                    if (rtn.data.HaveTpl == "1") {
                                        if (confirm("已存在该问卷的模板,是否重新生成?")) {
                                            Ext.getBody().mask("模板生成中,请稍后...");
                                            $.ajaxExec("SaveTpl", { SurveyId: SurveyId }, function(rtn) {
                                                Ext.getBody().unmask();
                                                AimDlg.show("生成成功!");
                                            }, null, "Comman.aspx");
                                        }
                                    } else {
                                        Ext.getBody().mask("模板生成中,请稍后...");
                                        $.ajaxExec("SaveTpl", { SurveyId: SurveyId }, function(rtn) {
                                            Ext.getBody().unmask();
                                            AimDlg.show("转存成功!");
                                        }, null, "Comman.aspx");
                                    }
                                }, null, "Comman.aspx");

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
                viewconfig: {
                    forceFit: true//当行大小变化时始终填充满
                },
                autoExpandColumn: 'SurveyTitile',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'SurveyTitile', dataIndex: 'SurveyTitile', header: '问卷标题', width: 230, sortable: true, renderer: RowRender },
					{ id: 'SurveyTypeName', dataIndex: 'SurveyTypeName', header: '问卷类型', width: 120, sortable: true },
				    { id: 'IsCheck', dataIndex: 'IsCheck', header: '是否需要审批', width: 90, sortable: true, renderer: RowRender },
					{ id: 'StartTime', dataIndex: 'StartTime', header: '开始时间', width: 100, sortable: true, renderer: ExtGridDateOnlyRender },
					{ id: 'EndTime', dataIndex: 'EndTime', header: '结束时间', width: 100, sortable: true, renderer: ExtGridDateOnlyRender },
                    { id: 'State', dataIndex: 'State', header: '发布状态', width: 80, sortable: true, renderer: RowRender },
					{ id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: '审批状态', width: 80, sortable: true, renderer: RowRender },
					{ id: 'WorlFlowResult', dataIndex: 'WorlFlowResult', header: '审批结果', width: 70 },
                // { id: 'IsNoName', dataIndex: 'IsNoName', header: '匿名', width: 50, renderer: RowRender },

					{id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 80 },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建时间', width: 80, sortable: true, renderer: ExtGridDateOnlyRender },
					{ id: 'Edit', dataIndex: 'Edit', header: '操作', width: 180, renderer: RowRender }
                    ],
                bbar: pgBar,
                // tbar: AimState["Audit"] == 'admin' ? titPanel : ''
                tbar: titPanel
                //tbar: titPanel
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
                        var str = "<span>" + value + "</span>";
                        rtn = str;
                    }
                    break;
                case "State":
                    if (value == "0") {
                        rtn = "<font size=2 color=red >未发布</font>";
                    } else if (value == "1") {
                        rtn = "启动";
                    } else if (value == "2") {
                        rtn = "结束";
                    }
                    else if (value == "3") {
                        rtn = "暂停";
                    }
                    else {
                        rtn = "<font size=2 color=red >未发布</font>";
                    }
                    break;
                case "ExameState":
                    rtn = "<span style=color:Blue; cursor:pointer; text-decoration:underline;>" + "已通过" + "</span>";
                    break;
                case "Edit":
                    var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='windowOpen(\"" + record.get("Id") + "\")'>" + "问卷预览" + "</span>";
                    str += "&nbsp;&nbsp; <span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='openUserWin(\"" + record.get("Id") + "\")'>" + "人员清单" + "</span>";
                    str += "&nbsp;&nbsp; <span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='openSetConfigWin(\"" + record.get("Id") + "\")'>" + "查看详细" + "</span>";
                    rtn = str;
                    break;
                case "IsNoName":
                    if (value == "0") {
                        rtn = "否";
                    } else if (value == "1") {
                        rtn = "是";
                    }
                    break;
                case "WorkFlowState":
                    if (value == "1" || value == "Start") {
                        rtn = " 审批中 ";
                    } else if (record.get("IsCheck") == "1" && !value) {
                        rtn = "未提交";
                    }
                    else if (value == "End") {
                        rtn = "审批结束";
                    }
                    break;
                case "IsCheck":
                    if (value == "1")
                        rtn = "<font size=2 color=red >是</font>";
                    else
                        rtn = "否";
                    break;
            }
            return rtn;
        }

        //问卷跟踪
        function UsrChoiceWin(val) {
            var ModelStyle = "dialogWidth:1000px; dialogHeight:600px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "SurveyTraceTab.aspx?surveyId=" + val;
            //OpenModelWin(url, "", ModelStyle, function() { })
            opencenterwin(url, "", 1200, 600);
            //OpenModelWin
        }
        //查看统计
        function openStatisticWin(surveyId) {
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                var url = "T_SurveyStatisticTab.aspx?SurveyId=" + surveyId + "&rand=" + Math.random();
                opencenterwin(url, "", 1000, 600);
            });
        }

        function openConfigWin(id) {
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                opencenterwin("SurveyQuestionEdit.aspx?op=r&id=" + id, "", 840, 540);
            });
        }

        //打开问卷数量配置页
        function surveyCountWin(id) {
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                opencenterwin("SurveyCounter.aspx?SurveyId=" + id, "", 385, 130);
            });
        }

        //人员清单
        function openUserWin(id, op) {
            var Id = arguments[0] || '';  //ID
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                opencenterwin("Wizard_Finish.aspx?op=r&SurveyId=" + Id, "", 1000, 600);
            });
        }

        function windowOpen(id, op) {
            var Id = arguments[0] || '';  //ID
            var Title = escape(arguments[1] || ''); //Title
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                opencenterwin("InternetSurvey.aspx?op=v&type=read&Id=" + Id, "", 1000, 600);
            });
        }

        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }

        //查看详细
        function openSetConfigWin() {
            var Id = arguments[0] || '';  //SurveyId
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                var url = "SetConfigWin.aspx?op=r&SurveyId=" + Id;
                var iHeight = 490, iWidth = 870;
                var iTop = (window.screen.availHeight - 30 - iHeight) / 2;
                var iLeft = (window.screen.availWidth - 10 - iWidth) / 2;
                window.open(url, "", 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');

            });
        }
    
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
