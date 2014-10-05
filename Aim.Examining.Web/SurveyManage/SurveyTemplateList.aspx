<%@ Page Title="问卷模板" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SurveyTemplateList.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyTemplateList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=800,height=570,scrollbars=1");
        var EditPageUrl = "SurveyTemplateEdit.aspx";
        var Modelstyle = "dialogWidth:800px; dialogHeight:570px; scroll:no; center:yes; status:no; resizable:no;";
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
			{ name: 'GrantCorpId' },
			{ name: 'GrantCorpName' }
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
                columns: 5,
                collapsed: false,
                items: [
                { fieldLabel: '问卷标题', id: 'SurveyTitile', schopts: { qryopts: "{ mode: 'Like', field: 'SurveyTitile' }"} },
                { fieldLabel: '状态', id: 'State', xtype: 'aimcombo', required: true, enumdata: { '1': '启用', '2': '停用', '%%': '请选择...' }, schopts: { qryopts: "{ mode: 'Like', field: 'State' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("State")) } } },
       { fieldLabel: '公司', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CompanyName' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("SurveyTitile"));   //Number 为任意
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
                        $.ajaxExec("getGuid", {}, function(rtn) {
                            var url = EditPageUrl + "?id=" + rtn.data.Guid + "&op=u";
                            //ExtOpenGridEditWin(grid, url, "u", EditWinStyle);
                            OpenModelWin(url, window, Modelstyle, function() {
                                store.reload();
                            });
                        });
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要修改的记录！");
                            return;
                        }
                        var url = EditPageUrl + "?id=" + (recs[0].get("Id")) + "&op=u";
                        // ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                        OpenModelWin(url, window, Modelstyle, function() {
                            store.reload();
                        });
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

                        var isCancel = false;
                        $.each(recs, function() {
                            if (this.get("State") == "1") {
                                isCancel = true;
                            }
                        })
                        if (isCancel) {
                            AimDlg.show("启用的模板不能删除!");
                            return;
                        }

                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, {
                    id: 'Grant',
                    text: '模板授权',
                    hidden: AimState["IsCanGrant"] == "1" ? false : true,
                    iconCls: 'aim-icon-key',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要操作的记录！");
                            return;
                        }
                        var CompanyName = recs[0].get("CompanyName") || "";
                        var GrantName = recs[0].get("GrantCorpName") || ""; //授权公司名称

                        $("#GrantCorpId").val(GrantName);

                        $("#GrantCorpId").val(recs[0].get("Id"));
                        $("#GrantCorpName").val(GrantName);


                        var sw = new Ext.Window({
                            title: '模板授权',
                            width: 450,
                            height: 230,
                            padding: '15 5 5 5',
                            autoScroll: true,
                            layout: 'form',
                            bodyStyle: 'overflow-y:auto;overflow-x:auto;',
                            items: [
                {
                    xtype: 'label',
                    fieldLabel: '所属公司',
                    text: CompanyName
                }, {
                    id: 'OrgSlt',
                    xtype: 'aimdeptselector',
                    allowBlank: true,
                    fieldLabel: '授权公司',
                    value: GrantName,
                    //popparam: "GrantCorpId:GroupID;GrantCorpName:Name",
                    // popUrl: "/CommonPages/Select/GrpSelect/MGrpSelect.aspx?rtntype=array&cid=2&seltype=single&CompanyId=" + $("#GrantCorpId").val(),

                    width: 300,
                    seltype: 'multi',
                    popAfter: function(rtn) {

                        if (!rtn || !rtn.data) return;
                        var data = rtn.data || [];

                        var temp = "";
                        var tempid = "";

                        if (data.length) {
                            for (var i = 0; i < data.length; i++) {
                                temp += data[i].Name + ",";
                                tempid += data[i].GroupID + ",";
                            }
                            if (temp.length > 0) {
                                temp = temp.substring(0, temp.length - 1);
                                tempid = tempid.substring(0, tempid.length - 1);
                            }
                        }
                        else {
                            temp = data.Name;
                            tempid = data.GroupID;
                        }

                        Ext.getCmp('OrgSlt').setValue(temp);

                        $("#GrantCorpName").val(temp);
                        $("#GrantCorpId").val(tempid);

                    }
}],
                            buttons: [{
                                text: '确认',
                                handler: function() {
                                    Ext.getBody().mask("模板授权中,请稍等...");
                                    $.ajaxExec("Grant", {
                                        Id: recs[0].get("Id") || "",
                                        GrantCorpId: $("#GrantCorpId").val() || "",
                                        GrantCorpName: $("#GrantCorpName").val() || ""
                                    }, function(rtn) {
                                        Ext.getBody().unmask();
                                        $("#GrantCorpId").val("");
                                        $("#GrantCorpName").val("")
                                        store.reload();
                                        sw.close();
                                        return;
                                    });

                                }
                            }, {
                                text: '取消',
                                handler: function() {
                                    sw.close();
                                }
}]
                            }).show();
                        }

                    }, '-', {
                        text: '启用',
                        iconCls: 'aim-icon-run',
                        handler: function() {
                            var recs = grid.getSelectionModel().getSelections();
                            if (!recs || recs.length <= 0) {
                                AimDlg.show("请先选择要启用的问卷模板！");
                                return;
                            }

                            ExtBatchOperate('Start', null, { id: recs[0].get("Id") }, null, onExecuted);
                        }
                    }, {
                        text: '停用',
                        iconCls: 'aim-icon-stop',
                        handler: function() {
                            var recs = grid.getSelectionModel().getSelections();
                            if (!recs || recs.length <= 0) {
                                AimDlg.show("请先选择要停用的问卷模板！");
                                return;
                            }
                            ExtBatchOperate('Stop', null, { id: recs[0].get("Id") }, null, onExecuted);
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
                    viewConfig: { forceFit: true, scrollOffset: 10 },
                    autoExpandColumn: 'SurveyTitile',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'SurveyTitile', dataIndex: 'SurveyTitile', header: '问卷标题', width: 150, sortable: true, renderer: RowRender },
                    //{ id: 'Description', dataIndex: 'Description', header: '问卷描述', width: 200, sortable: true, renderer: RowRender },
					{id: 'State', dataIndex: 'State', header: '状态', width: 60, renderer: RowRender },

                    //{id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 100 },
					{id: 'CreateTime', dataIndex: 'CreateTime', header: '创建时间', width: 120, renderer: ExtGridDateOnlyRender },
					{ id: 'CompanyName', dataIndex: 'CompanyName', header: '公司', width: 120, sortable: true },
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
                    case "Description":
                        if (value) {

                            cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                            rtn = value.length > 120 ? value.substring(0, 120) + "..." : value;
                        }
                        break;
                    case "ExameState":
                        rtn = "<span style=color:Blue; cursor:pointer; text-decoration:underline;>" + "已通过" + "</span>";
                        break;
                    case "Edit":
                        var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='windowOpen(\"" + record.get("Id") + "\")'>" + "问卷预览" + "</span>";
                        rtn = str;
                        break;
                    case "IsNoName":
                        if (value == "no") {
                            rtn = "否";
                        } else {
                            rtn = "是";
                        }
                        break;
                    case "State":
                        if (value == "1") {
                            rtn = "启用";
                        } else if (value == "2") {
                            rtn = "停用";
                        }
                        break;
                }
                return rtn;
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
    <input type="hidden" id="GrantCorpName" name="GrantCorpName" />
    <input type="hidden" id="GrantCorpId" name="GrantCorpId" />
</asp:Content>
