<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SurveyType.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.SurveyType" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=700,height=540,scrollbars=1");
        var EditPageUrl = "SurveyTypeEdit.aspx";
        var Modelstyle = "dialogWidth:700px; dialogHeight:540px; scroll:no; center:yes; status:no; resizable:no;";
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
			{ name: 'TypeCode' },
			{ name: 'TypeName' },
			{ name: 'TypeDescribe' },
			{ name: 'EnabledState' },
			{ name: 'AddFilesId' },
			{ name: 'AddFilesName' },
			{ name: "MustCheckFlow" },
			{ name: 'AccessPower' },
			{ name: 'SurveyedPower' },
			{ name: 'WorkFlowId' },
			{ name: 'WorkFlowName' },
			{ name: 'SortIndex' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
			{ name: 'CreateDeptId' },
			{ name: 'CreateDeptName' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
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
                columns: 4,
                collapsed: false,
                items: [
                { fieldLabel: '问卷类型', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'TypeName' }"} },
                { fieldLabel: '状态', id: 'State', xtype: 'aimcombo', required: true, enumdata: { '0': '停用', '1': '启用', '%%': '请选择...' }, schopts: { qryopts: "{ mode: 'Like', field: 'EnabledState' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("State")) } } },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Title"));
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
                        var recs = store.getRange();
                        var temp = 0;
                        for (var i = 0; i < recs.length; i++) {
                            var st = recs[i].get("SortIndex") || 0;
                            parseInt(st) > temp && (temp = parseInt(st));
                        }
                        var url = EditPageUrl + "?SortIndex=" + (temp + 1) + "&op=c";
                        // ExtOpenGridEditWin(grid, url, "c", EditWinStyle);

                        OpenModelWin(url, window, Modelstyle, function() {
                            store.reload();
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
                        var url = EditPageUrl + "?id=" + (recs[0].get("Id") || "") + "&op=u";
                        //ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
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

                        $.ajaxExec("IsRef", { TypeName: recs[0].get("TypeName") || "" }, function(rtn) {
                            if (rtn.data.State == "1") {
                                AimDlg.show("该问卷类型在使用中,暂不能删除!");
                                return;
                            } else {
                                if (confirm("确定删除所选记录？")) {
                                    ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                                }
                            }
                        });

                    }
                }, '-', {
                    text: '启用',
                    iconCls: 'aim-icon-run',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要启用的问卷类型！");
                            return;
                        }
                        if (recs[0].get("EnabledState") != "0") {
                            return;
                        }
                        ExtBatchOperate('StartType', null, { id: recs[0].get("Id") }, null, onExecuted);
                    }
                }, {
                    text: '停用',
                    iconCls: 'aim-icon-stop',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要停用的问卷类型！");
                            return;
                        } if (recs[0].get("EnabledState") != "1") {
                            AimDlg.show("该问卷类型已停用,无需停止");
                            return;
                        }
                        ExtBatchOperate('StopType', null, { id: recs[0].get("Id") }, null, onExecuted);

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
                //autoExpandColumn: 'TypeDescribe',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'TypeName', dataIndex: 'TypeName', header: '问卷类型', width: 200, sortable: true, renderer: RowRender },
					{ id: 'TypeDescribe', dataIndex: 'TypeDescribe', header: '类型描述', width: 300, renderer: RowRender },
					{ id: 'EnabledState', dataIndex: 'EnabledState', header: '状态', width: 80, sortable: true, renderer: RowRender },
					{ id: 'MustCheckFlow', dataIndex: 'MustCheckFlow', header: '流程审批', width: 80, renderer: RowRender },
                //{ id: 'WorkFlowName', dataIndex: 'WorkFlowName', header: '审批流程', width: 150, renderer: RowRender },
                //{id: 'SortIndex', dataIndex: 'SortIndex', header: '序号', width: 80, sortable: true },
					{id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 100, hidden: true }
                    ],
                bbar: pgBar,
                // tbar: AimState["Audit"] == 'admin' ? titPanel : ''
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
                case "TypeName":
                    var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='openWin(\"" + record.get("Id") + "\")'>" + ' <span style= "font-size: 13px;">' + value + '</span>' + "</span>";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = str;
                    break;
                case "EnabledState":
                    rtn = value == "0" ? "停用" : "启用";
                    break;
                case "TypeDescribe":
                    var tip = value.toString().length > 50 ? value.toString().substr(0, 50) + "..." : value;
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + tip + '"';
                    rtn = value;
                    break;
                case "WorkFlowName":
                    var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='openFlWin(\"" + record.get("WorkFlowId") + "\")'>" + ' <span style= "font-size: 13px;">' + value + '</span>' + "</span>";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = str;
                    break;
                case "MustCheckFlow":
                    if (value == "1") {
                        rtn = "是"
                    } else {
                        rtn = "否";
                    }
                    break;
            }
            return rtn;
        }

        //打开流程图视图
        function openFlWin(val) {
            return;
            var task = new Ext.util.DelayedTask();
            task.delay(50, function() {
                opencenterwin("/WorkFlow/TaskExecuteView.aspx" + "?op=r&id=" + val, "", 650, 550);
            });
        }

        function openWin(val) {
            var task = new Ext.util.DelayedTask();
            task.delay(50, function() {
                opencenterwin(EditPageUrl + "?op=r&id=" + val, "", 650, 510);
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
    <div id="header" style="display: none;">
        <h1>
            问卷类型</h1>
    </div>
</asp:Content>
