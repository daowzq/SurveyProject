<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="TravelMoneyConfigList.aspx.cs" Inherits="Aim.Examining.Web.TravelMoneyConfigList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <script src="../js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>
    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=530,height=240,scrollbars=no");
        var EditPageUrl = "TravelMoneyConfigEdit.aspx";
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
                records: AimState["TravelMoneyConfigList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'TravelMoneyConfigList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'WorkNo' },
			{ name: 'Indutydate' },
			{ name: 'HaveUsed' },
			{ name: 'Money' },
			{ name: 'BaseMoney' },
			{ name: 'Ext1' },
			{ name: 'Corp' },
			{ name: 'CorpName' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
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
                collapsed: false,
                store: store,
                columns: 6,
                items: [{ fieldLabel: '年度', id: 'Year', xtype: 'aimcombo', required: true,
                    enumdata: YearEnum,
                    schopts: { qryopts: "{ mode: 'Equal', field: 'CreateTime' }" },
                    listeners: { "collapse": function (e) { Ext.ux.AimDoSearch(Ext.getCmp("Year")); } }
                },
                { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                { fieldLabel: '公司', id: 'CorpName', schopts: { qryopts: "{ mode: 'Like', field: 'CorpName' }"} },
                {
                    fieldLabel: '是否使用',
                    id: 'HaveUsed',
                    xtype: 'aimcombo',
                    // required: true,
                    enumdata: { "Y": "是", "N": "否" },
                    schopts: {
                        qryopts: "{ mode: 'Like', field: 'HaveUsed' }"
                    },
                    listeners: {
                        "collapse": function (e) {
                            if (e.value)
                                Ext.ux.AimDoSearch(Ext.getCmp("UserName"));
                        }
                    }
                },
                 {
                     fieldLabel: '按钮',
                     xtype: 'button',
                     iconCls: 'aim-icon-search',
                     width: 60,
                     margins: '2 30 0 0',
                     text: '查 询',
                     handler: function () {
                         Ext.ux.AimDoSearch(Ext.getCmp("UserName"));
                     }
                 }
]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '生成默认旅游金额',
                    iconCls: 'aim-icon-add',
                    handler: function () {
                        if (confirm("一旦生成,则旅游津贴以该数据为准,确定生成吗?")) {
                            $.ajaxExecSync("CreateCheck", {}, function (rtn) {
                                if (rtn.data.staus == "1") {
                                    Ext.getBody().mask("旅游金额生成中...");
                                    $.ajaxExec("CreateMoney", {}, function (rtn) {
                                        Ext.getBody().unmask();
                                        if (rtn.data.State == "1") {
                                            store.reload();
                                            AimDlg.show("旅游金额生成成功!");
                                        } else {
                                            AimDlg.show("旅游金额生成异常!");
                                        }
                                    });
                                } else {
                                    AimDlg.show("旅游金额已生成,无需再次生成!");
                                }

                            });


                        }

                    }
                }, {
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function () {
                        ExtOpenGridEditWin(grid, EditPageUrl, "c", EditWinStyle);
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function () {
                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function () {
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
                    text: '<font size=2em>导入数据</font>',
                    iconCls: 'aim-icon-trans',
                    handler: function () {
                        if (confirm("请确保导入的文件符合模板规范！确定导入吗？")) {
                            ImpUser(function () {
                                store.reload();
                                AimDlg.show("导入成功！");
                            });
                        }
                    }
                }, {
                    text: '<font size=2em>服务年限奖励金额修正</font>',
                    iconCls: 'aim-icon-edit',
                    handler: function () {
                        if (confirm("请确保导入的文件符合模板规范！确定导入吗？")) {
                            EditMoney(function () {
                                store.reload();
                                AimDlg.show("导入成功！");
                            });
                        }
                    }
                }, {
                    text: '<font size=2em>模板下载</font>',
                    iconCls: 'aim-icon-download',
                    handler: function () {
                        var url = "../CommonPages/File/DownLoad.aspx?FileName=TravelMoneyTpl.xlsx";
                        $("body").append("<iframe style='display:none;' src=" + url + "></iframe>");
                    }
                }, '-', {
                    text: '<span>导出Excel</span>',
                    iconCls: 'aim-icon-xls',
                    handler: function () {
                        ExtGridExportExcel(grid, { store: null, title: '标题' });
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
                viewConfig: {
                    forceFit: true,
                    scrollOffset: 10
                },
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'Year', dataIndex: 'CreateTime', header: '年份', width: 80, sortable: true, renderer: RowRender },
                    { id: 'CorpName', dataIndex: 'CorpName', header: '公司', width: 180, sortable: true },
                    { id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 120, sortable: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 80, sortable: true },
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 80, sortable: true },

					{ id: 'Indutydate', dataIndex: 'Indutydate', header: '入职日期', width: 100, sortable: true },
					{ id: 'BaseMoney', dataIndex: 'BaseMoney', header: '旅游基本津贴（￥）', width: 100, sortable: true },
					{ id: 'Money', dataIndex: 'Money', header: '服务年限奖励金（￥）', width: 100, sortable: true },
					{ id: 'HaveUsed', dataIndex: 'HaveUsed', header: '<font color=red><b>是否使用</b></font>', width: 80, sortable: true, renderer: RowRender },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '创建日期', width: 80, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });
            grid.on("rowdblclick", function (Grid, rowIndex, e) {
                ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
            });


            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [grid]
            });
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "HaveUsed":
                    if (value == "Y")
                        rtn = "<font color='red'>是</font>";
                    else if (value == "N") {
                        rtn = "否";
                    }
                    break;
                case "Year":
                    var tm = record.get("CreateTime");
                    rtn = $.toDate(tm).getYear() || new Date().getYear();
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
            if (!rtn) return;
            Ext.getBody().mask("人员导入中，请稍后！");
            rtn && $.ajaxExec("ImpUser", { FileId: (rtn + "").replace(",", "") }, function (rtn) {
                Ext.getBody().unmask();
                if (rtn.data.State == "1") doSuccessFun();
                else AimDlg.show("导入异常！");

            });
        }

        //服务年限奖励金额修正
        function EditMoney(doSuccessFun) {
            var mode = 'single' //单个文件上传
            var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;";
            var uploadurl = '../CommonPages/File/Upload.aspx?IsSingle=true&Filter=(*.xls;*.xlsx)|*.xls;*.xlsx';
            var rtn = window.showModalDialog(uploadurl, window, UploadStyle);
            if (!rtn) return;
            Ext.getBody().mask("人员导入中，请稍后！");
            rtn && $.ajaxExec("EditMoney", { FileId: (rtn + "").replace(",", "") }, function (rtn) {
                Ext.getBody().unmask();
                if (rtn.data.State == "1") doSuccessFun();
                else AimDlg.show("导入异常！");
            });
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
    
    </script>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
