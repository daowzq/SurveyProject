<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Normal_SurveyList.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Normal_SurveyList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=820,height=645,scrollbars=0");
        var Modelstyle = "dialogWidth:820px; dialogHeight:645px; scroll:1; center:yes; status:no; resizable:no;";
        var EditPageUrl = "Normal_SurveyEdit.aspx";

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
			{ name: 'IsFixed' },
			{ name: 'DeptName' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' },
			{ name: 'OARef' }
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
                { fieldLabel: '状态', id: 'State', xtype: 'aimcombo', required: true, enumdata: { '': '请选择...', '1': '启用', '2': '停用' }, schopts: { qryopts: "{ mode: 'Like', field: 'State' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("State")) } } },
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
                            var url = EditPageUrl + "?id=" + rtn.data.Guid + "&op=u";
                            // ExtOpenGridEditWin(grid, url, "u", EditWinStyle);
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
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要修改的记录！");
                            return;
                        }

                        if (recs[0].get("State") == "1") {
                            if (confirm("修改启用中的问卷会造成收集的数据不一致,确认修改吗？")) {
                                //ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                                var url = EditPageUrl + "?id=" + (recs[0].get("Id") || "") + "&op=u";
                                OpenModelWin(url, window, Modelstyle, function() {
                                    store.reload();
                                });
                            }
                        }

                    }
                }, {
                    text: '删除问卷',
                    hidden: true,
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        var haveStart = false;
                        $.each(recs, function() {
                            (this.get("State") == "1") && (haveStart = true);
                        });

                        if (haveStart) {
                            AimDlg.show("启用的问卷不能删除!");
                            return;
                        }
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }
                        if (recs[0].get("WorkFlowState")) {
                            AimDlg.show("审批的问卷不能修改!");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, '-',
                 {
                     text: '启用',
                     // hidden: true,
                     iconCls: 'aim-icon-run',
                     handler: function() {
                         var recs = grid.getSelectionModel().getSelections();
                         if (!recs || recs.length <= 0) {
                             AimDlg.show("请先选择要启动的问卷项！");
                             return;
                         }

                         //    if (!recs[0].get("WorkFlowState")) {
                         //        AimDlg.show("请先提交审批！");
                         //        return

                         //    } else {
                         //        if ((recs[0].get("WorlFlowResult") + "").indexOf("同意") < 0) {
                         //            AimDlg.show("审批通过的问卷才能启用！");
                         //            return;
                         //        }
                         //     }

                         if (recs[0].get("State") == "1") {
                             isrReturn = true;
                             AimDlg.show("该问卷已启用,无须重复启用！");
                             return;
                         }

                         $.ajaxExec('Start', { Id: recs[0].get("Id") || '' }, function(rtn) {

                             AimDlg.show("启动成功!");
                             store.reload();
                         });
                     }
                 }, {
                     text: '停用',
                     //hidden: true,
                     iconCls: 'aim-icon-stop',
                     handler: function() {
                         var recs = grid.getSelectionModel().getSelections();
                         if (!recs || recs.length <= 0) {
                             AimDlg.show("请先选择要结束的问卷项！");
                             return;
                         }

                         if (recs[0].get("State") != '1') {
                             AimDlg.show("已启用的问卷调查才能停用！");
                             return;
                         }

                         $.ajaxExec("stop", { Id: recs[0].get("Id") }, function(rtn) {
                             store.reload();
                         });
                     }
                 },
                //'-',
                //                 {
                //                     text: '提交审批',
                //                     iconCls: 'aim-icon-submit',
                //                     handler: function() {
                //                         var recs = grid.getSelectionModel().getSelections();
                //                         if (!recs || recs.length <= 0) {
                //                             AimDlg.show("请先选择要审批的记录！");
                //                             return;
                //                         }

                //                         if (recs[0].get("WorkFlowState")) {
                //                             AimDlg.show("流程中或审批结束的记录,不能再进行提交!");
                //                             return;
                //                         }

                //                         opencenterwin("WorkFlowChoices.aspx?SurveyId=" + recs[0].get("Id") + "&type=onlyView", "", 725, 400);
                //                     }
                //                 },
                //                {
                //                    text: '流程跟踪',
                //                    iconCls: 'aim-icon-cross1',
                //                    handler: function() {
                //                        var recs = grid.getSelectionModel().getSelections();
                //                        if (!recs || recs.length <= 0) {
                //                            AimDlg.show("请先选择要跟踪的记录！");
                //                            return;
                //                        }
                //                        if (!recs[0].get("WorkFlowState")) {
                //                            AimDlg.show("有审批的记录才能跟踪！");
                //                            return;
                //                        }
                //                        opencenterwin("/workflow/TaskExecuteView.aspx?FormId=" + recs[0].get("Id"), "", 1000, 600);
                //                
                //                    }
                //                }  ,
                 '-',


                // '-',
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
              }, '-',
                 {
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
}]
            });

            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                tbar: tlBar,
                items: [schBar]
            });


            // 创建combo实例
            var combo = new Ext.form.ComboBox({
                store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: ['Name', 'Value'],
                    data: [['请选择...', ''], ['离职申请', '离职申请'], ['离职结算', '离职结算']]
                }),
                typeAhead: true,
                triggerAction: 'all',
                lazyRender: true,
                mode: 'local',
                displayField: 'Name',
                valueField: 'Value',
                listeners: {
                    blur: function(obj) {
                        if (grid.activeEditor) {
                            if (obj.getValue()) {
                                var val = obj.getValue()
                                //Ext.get('combo_up').dom.value);
                                var rec = store.getAt(grid.activeEditor.row);
                                $.ajaxExec("SetOARef", { SurveyId: rec.get("Id"), Value: val }, function(rtn) {
                                    rec.commit();
                                    store.reload();
                                });
                            }
                            grid.stopEditing();
                        }
                    }
                }
            });


            // 表格面板
            grid = new Ext.ux.grid.AimEditorGridPanel({
                store: store,
                region: 'center',
                margins: '0 10 10 0',
                viewConfig: { forceFit: true, scrollOffset: 10 },
                autoExpandColumn: 'SurveyTitile',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'SurveyTitile', dataIndex: 'SurveyTitile', header: '问卷标题', width: 160, sortable: true, renderer: RowRender },
	                 { id: 'SurveyTypeName', dataIndex: 'SurveyTypeName', header: '问卷类型', width: 100 },

                //{ id: 'Description', dataIndex: 'Description', header: '问卷描述', width: 180, renderer: RowRender },
				   {id: 'State', dataIndex: 'State', header: '问卷状态', width: 80, renderer: RowRender },
                //{ id: 'WorkFlowState', dataIndex: 'WorkFlowState', header: '审批状态', width: 100, sortable: true, renderer: RowRender },
                //{ id: 'WorlFlowResult', dataIndex: 'WorlFlowResult', header: '审批结果', width: 80 },
                //{id: 'IsNoName', dataIndex: 'IsNoName', header: '匿名', width: 50, renderer: RowRender },
					{id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 100 },
			        { id: 'OARef', dataIndex: 'OARef', header: 'OA关联单据', width: 120, editor: combo },

					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建时间', width: 120, renderer: ExtGridDateOnlyRender },
					{ id: 'Edit', dataIndex: 'Edit', header: '操作', width: 120, renderer: RowRender }
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
                    if (value == "1") {
                        rtn = "启用";
                    } else if (value == "2") {
                        rtn = "停用";
                    }
                    else {
                        rtn = "创建";
                    }
                    break;
                case "Description":
                    if (value) {
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        rtn = value.length > 120 ? value.substring(0, 120) + "..." : value;
                    }
                    break;
                case "IsNoName":
                    if (value == "0") {
                        rtn = "否";
                    } else if (value == "1") {
                        rtn = "是";
                    } else {
                        rtn = "否";
                    }
                    break;
                case "WorkFlowState":
                    if (value == "1" || value == "Start") {
                        rtn = " 审批中 ";
                    } else if (value == "End") {
                        rtn = "审批结束";
                    }
                    break;
                case "Edit":
                    var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='windowOpen(\"" + record.get("Id") + "\")'>" + "问卷预览" + "</span>";
                    if (record.get("State") == "1")
                        str += " &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='createUrl(\"" + record.get("Id") + "\")'>" + "URL" + "</span>";
                    rtn = str;
                    break;

            }
            return rtn;
        }

        //外链URL
        function createUrl(val) {
            var Url = "以下是外链URL, 参数可参见API <br/>http://" + '<%=IP%>' + "/SurveyManage/InternetSurvey.aspx?\r\nId=" + val + "&uid=xxx&uname=xxx&workno=xxx";
            //AimDlg.show("外链URL为:\r\n" + Url);

            var tpl = "<div id=\"url\">" + Url + "</div>";
            var sw = new Ext.Window({
                title: '外链URL',
                width: 350,
                height: 300,
                padding: '15 5 5 5',
                autoScroll: true,
                bodyStyle: 'overflow-y:auto;overflow-x:auto;',
                html: tpl,
                buttons: [{
                    text: '取消',
                    handler: function() {
                        sw.close();
                    }
}]
                }).show();
                //创建window 窗口
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

            //打卡人员清单
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
                window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',                      innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=                yes,resizable=yes');
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
