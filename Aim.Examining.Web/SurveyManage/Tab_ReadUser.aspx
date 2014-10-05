<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="Tab_ReadUser.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Tab_ReadUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background-color: #F2F2F2;
        }
        fieldset
        {
            margin: 15px;
            width: 100%;
            padding: 5px;
        }
        fieldset legend
        {
            font-size: 12px;
            font-weight: bold;
        }
        .underline
        {
            border: 0;
            border-bottom: 1 solid black;
            background: #F2F2F2;
            color: black;
        }
    </style>

    <script type="text/javascript">
        var store = "";
        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';
        var op = $.getQueryString({ ID: 'op' }) || '';
        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {

            myData2 = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList2"] || []
            };
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList2',
                idProperty: 'Id',
                data: myData2,
                fields: [
			{ name: 'Id' },
			{ name: 'SurveyId' },
			{ name: 'SurveyTitle' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'WorkNo' },
			{ name: 'CreateWay' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'CreateTime' }
			      ],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};
                        options.data.SurveyId = SurveyId;
                    }
                }
            });


            // 分页栏
            pgBar2 = new Ext.ux.AimPagingToolbar({

                displayMsg: '{0} - {1} 共:{2}条',
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            // 搜索栏
            schBar2 = new Ext.ux.AimSchPanel({
                store: store,
                collapsed: false,
                columns: 3,
                items: [
                   { fieldLabel: '姓名', id: 'Name2', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                    { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                   { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询',
                       handler: function() {
                           Ext.ux.AimDoSearch(Ext.getCmp("Name2"));   //Number 为任意
                       }
                   }
                ]
            });

            tlBar2 = new Ext.Toolbar({

                items: [
                {
                    hidden: (op == "r" || op == "v") ? true : false,
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openUsrWin(gridReader);
                    }
                },
               {
                   hidden: (op == "r" || op == "v") ? true : false,
                   text: '删除',
                   iconCls: 'aim-icon-delete',
                   handler: function() {
                       var recs = gridReader.getSelectionModel().getSelections();
                       if (!recs || recs.length <= 0) {
                           AimDlg.show("请先选择要删除的记录！");
                           return;
                       }
                       if (confirm("确定删除所选记录？")) {
                           ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                       }
                   }
               },

                //               {
                //                   hidden: (op == "r" || op == "v") ? true : false,
                //                   text: '保存',
                //                   iconCls: 'aim-icon-save',
                //                   handler: function() {
                //                       if (gridReader.getStore().getRange().length < 1) {
                //                           AimDlg.show("没有要保存的数据");
                //                           return;
                //                       }
                //                       var recs = gridReader.getStore().getRange();
                //                       recs = gridReader.getStore().getModifiedDataStringArr(recs);
                //                       $.ajaxExec("Save", { Record: recs, SurveyId: SurveyId }, function(rtn) {
                //                           AimDlg.show("保存成功");
                //                       });
                //                   }
                //               },

                '-',
                {
                    text: '<font size=2em>导出人员</font>',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        ExtGridExportExcel(gridReader, { store: null, title: '标题' });
                    }
                },
                {
                    hidden: (op == "r" || op == "v") ? true : false,
                    text: '<font size=2em>导入人员</font>',
                    iconCls: 'aim-icon-trans',
                    handler: function() {
                        ImpUser("Reader", SurveyId, function() {
                            //store.reload();
                            AimDlg.show("导入成功！");
                            window.location.reload();
                        });

                    }
                }, '->',
                 {
                     hidden: (op == "r" || op == "v") ? true : false,
                     text: '收起',
                     iconCls: 'aim-icon-arrow-down',
                     handler: function() {
                         schBar2.toggleCollapse(false);
                         if (this.getText() == "收起") {
                             this.setText("展开");
                             this.setIconClass("aim-icon-arrow-up")
                         }
                         else {
                             this.setText("收起");
                             this.setIconClass("aim-icon-arrow-down")
                         }
                     }
                 }
]
            });

            // 工具标题栏
            titPanel2 = new Ext.ux.AimPanel({
                // renderTo: 'addUsrTool',
                tbar: tlBar2,
                items: [schBar2]
            });

            // 表格面板
            gridReader = new Ext.ux.grid.AimGridPanel({
                region: 'center',
                store: store,
                tbar: titPanel2,
                bbar: pgBar2,

                autoExpandColumn: 'DeptName',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    { id: 'UserId', dataIndex: 'UserId', header: 'UserId', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 80, sortable: true },
					   { id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 100 },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '组织名称', width: 220, sortable: true },
                //{ id: 'CreateWay', dataIndex: 'CreateWay', header: '创建标识', width: 80, sortable: true, renderer: RowRender }
                    ]
            });
            viewport = new Ext.ux.AimViewport({
                items: [gridReader]
            });
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }

        //人员选择
        function openUsrWin(gridSg) {
            var style = "dialogWidth:720px; dialogHeight:430px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "/CommonPages/Select/UsrSelect/MUsrSelect.aspx?seltype=multi&rtntype=array";
            OpenModelWin(url, {}, style, function() {
                if (this.data == null || this.data.length == 0 || !this.data.length) return;
                // var gird = Ext.getCmp(gridSg);
                var gird = gridSg
                var EntRecord = gird.getStore().recordType;
                for (var i = 0; i < this.data.length; i++) {
                    if (gird.store.find("Id", this.data[i]["UserID"]) != -1) continue;
                    var UserId = this.data[i]["UserID"];
                    var UserName = this.data[i]["Name"];

                    $.ajaxExecSync("GetOrgs", { UserId: UserId }, function(rtn) {
                        var OrgName = rtn.data.OrgName.split('|');
                        var rec = new EntRecord({
                            UserId: UserId,
                            WorkNo: OrgName[0],
                            UserName: UserName,
                            DeptName: OrgName[1] || ""
                        });
                        gird.getStore().insert(gird.getStore().data.length, rec);

                    }, null, "Comman.aspx");
                }

                var recs = gird.getStore().getRange();
                recs = gird.getStore().getModifiedDataStringArr(recs);

                $.ajaxExec("Save", { Record: recs, SurveyId: SurveyId }, function(rtn) {
                    if ($(".x-grid3-body").innerHeight() > $(".x-grid3-scroller").innerHeight()) {
                        var top = $(".x-grid3-body").innerHeight() - $(".x-grid3-scroller").innerHeight();
                        $(".x-grid3-scroller").scrollTop(top);
                    }
                });
            })
        }

        //导入人员
        function ImpUser(surObj, surveyId, doSuccess) {

            var mode = 'single' //当个文件上传
            var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;";
            var uploadurl = '/CommonPages/File/Upload.aspx?IsSingle=true&Filter=(*.xls;*.xlsx)|*.xls;*.xlsx';
            var rtn = window.showModalDialog(uploadurl, window, UploadStyle);

            Ext.getBody().mask("人员导入中，请稍后！");
            rtn && $.ajaxExec("ImpUser", { FileId: rtn, SurveyId: surveyId, Sign: surObj }, function(rtn) {
                Ext.getBody().unmask();
                if (rtn.data.State == "1")
                    doSuccess();
                else
                    AimDlg.show("导入异常！");
            }, null, "Comman.aspx");
            !rtn && Ext.getBody().unmask();
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "CreateWay":
                    rtn = value == "0" ? "导入" : "创建";
                    break;
            }
            return rtn;
        }

       
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
