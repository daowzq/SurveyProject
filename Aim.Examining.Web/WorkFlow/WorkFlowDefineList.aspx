<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="WorkFlowDefineList.aspx.cs" Inherits="Aim.Portal.Web.WorkFlow.TaskDefineList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var EnumType = { 0:"Developing",1:"Testing",2:"Deployed",3:"Offline",4:"Online"};
    var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
    var EditPageUrl = "WorkFlowDefineEdit.aspx";
    
    var store, myData;
    var pgBar, schBar, tlBar, titPanel, grid, viewport;

    function onPgLoad() {
        setPgUI();
    }

    function setPgUI() {
        // 表格数据
        myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["SysWorkFlowDefineList"] || []
        };
        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'SysWorkFlowDefineList',
            idProperty: 'ID',
            data: myData,
            fields: [
			{ name: 'ID' },
			{ name: 'Category' },
			{ name: 'Code' },
			{ name: 'TemplateName' },
			{ name: 'DllSource' },
			{ name: 'AssemblyName' },
			{ name: 'Status' },
			{ name: 'Version' },
			{ name: 'Description' },
			{ name: 'CreateId' },
			{ name: 'Creator' },
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
            items: [
                { fieldLabel: '名称', id: 'Name', schopts: { qryopts: "{ mode: 'Like', field: 'Name' }"} }]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
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
						
                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, '-', {
                    text: '其他',
                    iconCls: 'aim-icon-cog',
                    menu: [{ text: '导出Excel', iconCls: 'aim-icon-xls', handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
                    } }]
                }, {
                    text: '提交审批',
                    iconCls: 'aim-icon-execute',
                    handler: SubmitFlow
                }, {
                    text: '流程跟踪',
                    iconCls: 'aim-icon-execute',
                    handler: FlowTrace
                }, '->', { text: '查询:' },
                new Ext.app.AimSearchField({ store: store, schbutton: true, qryopts: "{ type: 'fulltext' }" }),
                '-',
                {
                    text: '复杂查询',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        schBar.toggleCollapse(false);

                        setTimeout("viewport.doLayout()", 50);
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
                    region: 'center',
                    //autoExpandColumn: 'Name',
                    columns: [
                    { id: 'ID', header: '标识', dataIndex: 'ID', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'Code', dataIndex: 'Code', header: '标识', width: 100, sortable: true },
					{ id: 'TemplateName', dataIndex: 'TemplateName', header: '流程名称', width: 200, linkparams: { url: EditPageUrl, style: EditWinStyle }, sortable: true },
					{ id: 'Status', dataIndex: 'Status', header: '状态', width: 100, sortable: true, enumdata: EnumType },
					{ id: 'Version', dataIndex: 'Version', header: '版本', width: 100,  sortable: true },
					{ id: 'Description', dataIndex: 'Description', header: '描述', width: 200,  sortable: true },
					{ id: 'Creator', dataIndex: 'Creator', header: '创建人', width: 100, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建时间', width: 100, sortable: true }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }



            ///流程执行代码
            function SubmitFlow() {
                var smask = new Ext.LoadMask(document.body, { msg: "处理中..." });
                var recs = grid.getSelectionModel().getSelections();
                if (!recs || recs.length <= 0) {
                    AimDlg.show("请先选择要提交审批的记录！");
                }
                else {
                    if (recs[0].data.State == "1") {
                        AimDlg.show("已审批,无需再提交!");
                        return;
                    }
                    smask.show();
                    $.ajaxExec('startflow', { Id: recs[0].data.ID, tid: "2" },
                    function(args) {
                        AimDlg.show(args.data.message);
                        onExecuted();
                        smask.hide();
                    });
                }
            }

            function FlowTrace() {
                var recs = grid.getSelectionModel().getSelections();
                if (!recs || recs.length <= 0) {
                    AimDlg.show("请先选择要跟踪的记录！");
                }
                else {
                    OpenWin("/WorkFlow/FlowTrace.aspx?FormId=" + recs[0].data.ID, "_blank", EditWinStyle);
                }
            }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>标题</h1></div>
</asp:Content>


