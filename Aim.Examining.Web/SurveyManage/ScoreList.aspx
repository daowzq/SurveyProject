<%@ Page Title="问卷积分" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="ScoreList.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.ScoreList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "SurveyScoreEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }
        var Sort = "";
        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'UserID',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'UserID' },
		    { name: 'UserName' },
			{ name: 'CropName' },
			{ name: 'Score' },
			{ name: 'DeptName' }
			],
                aimbeforeload: function(proxy, options) {
                    options.data = options.data || {};
                    options.data.sort = Sort;
                }
            });

            if (!store.getRange().length && AimState["Power"] != "1") {
                window.setTimeout(function() {
                    AimDlg.show("你暂无积分或查看权限不足！");
                }, 200)
            }
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
                { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
               { fieldLabel: '公司', id: 'CropName', schopts: { qryopts: "{ mode: 'Like', field: 'CropName' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("UserName"));
                }
                }
                ]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    hidden: AimState["Power"] == "1" ? false : true,
                    text: '<font size=2em>模板下载</font>',
                    iconCls: 'aim-icon-download',
                    handler: function() {
                        var url = "/CommonPages/File/DownLoad.aspx?FileName=UserScoreImp.xlsx";
                        $("body").append("<iframe src=" + url + "></iframe>");
                    }
                },
                {
                    hidden: AimState["Power"] == "1" ? false : true,
                    text: '<font size=2em>导入积分</font>',
                    iconCls: 'aim-icon-trans',
                    handler: function() {
                        ImpUser(function() {
                            Ext.getBody().unmask();
                            AimDlg.show("导入成功！");
                            store.reload();
                        }, function() {
                            AimDlg.show("导出异常！");
                            return
                        });
                    }
                }, {
                    hidden: AimState["Power"] == "1" ? false : true,
                    text: '清除分值',
                    iconCls: 'aim-icon-undo',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要清除的记录！");
                            return;
                        }

                        if (confirm("确定清除所选记录的分值？")) {
                            idList = [];
                            $.each(recs, function() {
                                idList.push(this.get("UserID"));
                            });

                            $.ajaxExec('doBatchClear', { IdList: idList }, function() {
                                AimDlg.show("清除成功！");
                                store.reload();
                                return;
                            })
                        }
                    }
                },
                {
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '问卷积分' });
                    }
                }
                //                , {
                //                    text: '查看排名',
                //                    iconCls: 'aim-icon-xls',
                //                    handler: function() {
                //                        Sort = "corp";
                //                        store.reload();
                //                    }
                //                }

]
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
                // autoExpandColumn: 'Name',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 100, sortable: true },
					{ id: 'CropName', dataIndex: 'CropName', header: '公司', width: 200, sortable: true },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 150, sortable: true },
					{ id: 'Score', dataIndex: 'Score', header: '积分', width: 100, sortable: true }
                // { id: 'ScoreSource', dataIndex: 'ScoreSource', header: '积分来源', width: 150, renderer: RowRender }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [grid]
            });
        }

        //导入人员
        function ImpUser(doSuccess, doError) {

            var mode = 'single'                 //单个文件上传
            var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;";
            var uploadurl = '/CommonPages/File/Upload.aspx?IsSingle=true&Filter=(*.xls;*.xlsx)|*.xls;*.xlsx';
            var rtn = window.showModalDialog(uploadurl, window, UploadStyle);

            Ext.getBody().mask("积分导入中，请稍后！");
            rtn && $.ajaxExec("DoImpScore", { FileId: rtn }, function(rtn) {
                if (rtn.data.State == "1") {
                    doSuccess();
                }
                else {
                    doError();
                }
            }, null, "Comman.aspx");
            !rtn && Ext.getBody().unmask();
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "ScoreSource":
                    if (value) {
                        value = value || "";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        rtn = value;
                    }
                    break;
            }
            return rtn;
        }
        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
