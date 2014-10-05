<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="EmpVoiceAnswerInfoList.aspx.cs" Inherits="Aim.Examining.Web.EmpVoiceAnswerInfoList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "EmpVoiceAnswerInfoEdit.aspx";
        var questionId = $.getQueryString("Id") || "";
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["EmpVoiceAnswerInfoList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'EmpVoiceAnswerInfoList',
                idProperty: 'Id',
                data: myData,
                fields: [
            { name: 'Id' },
			{ name: 'QuestionId' },
			{ name: 'QuestionTitle' },
			{ name: 'QuestionContent' },
			{ name: 'Answer' },
			{ name: 'Anonymity' },
			{ name: 'ParentId' },
			{ name: 'IsLeaf' },
			{ name: 'IsCheck' },
			{ name: 'CheckOpinion' },
			{ name: 'NikeName' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' }
			],
                listeners: { "aimbeforeload": function(proxy, options) {
                    options.data.Id = questionId;
                }
                }

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
                { fieldLabel: '回复内容', id: 'Answer', schopts: { qryopts: "{ mode: 'Like', field: 'Answer' }"} },
                { fieldLabel: '昵称', id: 'NikeName', schopts: { qryopts: "{ mode: 'Like', field: 'NikeName' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Answer"));   //Number 为任意
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
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
                    }
}]
                });

                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    //   tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    autoExpandColumn: 'Answer',
                    singleSelect: true,
                    margins: '0 10 10 0',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Answer', dataIndex: 'Answer', header: '回复内容', width: 100, sortable: true },
					{ id: 'NikeName', dataIndex: 'NikeName', header: '回复人昵称', width: 100, sortable: true, renderer: RowRender },
					{ id: 'IsCheck', dataIndex: 'IsCheck', header: '状态', width: 80, renderer: RowRender },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建日期', width: 100, renderer: ExtGridDateOnlyRender, sortable: true },
					{ id: 'Ischeck', dataIndex: 'Id', header: '审核', renderer: RowRender }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }


            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn;

                switch (this.id) {
                    case "IsCheck":
                        if ($.trim(value + "") == '0') {
                            rtn = "审核未通过";
                        } else if ($.trim(value + "") == '1') {
                            rtn = "审核通过";
                        } else {
                            rtn = "未审核";
                        }
                        break;
                    case "NikeName":

                        if (value) {
                            rtn = value;
                        } else {
                            rtn = "匿名";
                        }
                        break
                    case "Ischeck":

                        rtn = "<a class='aim-ui-link' onclick=\"ischeck(this)\" typ='1' thisid=" + record.id + " >通过</a>&nbsp;<a class='aim-ui-link' onclick=\"ischeck(this)\" typ='0' thisid=" + record.id + "  >不通过</a>";
                        break;
                }
                return rtn;
            }

            function ischeck(thi) {
                var this_id = $(thi).attr("thisid");
                var this_typ = $(thi).attr("typ");
                var rec = grid.getSelectionModel().getSelected();

                rec.set("IsCheck", this_typ);

                $.ajaxExec("ischeck", { thisid: this_id, typ: this_typ }, function() {

                });
            }
    
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
