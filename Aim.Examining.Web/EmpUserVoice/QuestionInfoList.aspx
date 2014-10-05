<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="QuestionInfoList.aspx.cs" Inherits="Aim.Examining.Web.QuestionInfoList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=800,height=530,scrollbars=yes");
        var EditPageUrl = "AskQuestionEdit.aspx";
        var ContentUrl = "UsrProblemSolve.aspx";

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
			{ name: 'Title' },
			{ name: 'Contents' },
			{ name: 'Anonymity' },
			{ name: 'Category' },
			{ name: 'AwardScore' },
			{ name: 'AnswerCount' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'ViewCount' },
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
                collapsed: false,
                columns: 5,
                items: [
                { fieldLabel: '标题', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                { fieldLabel: '类型', id: 'Category', xtype: 'aimcombo', required: true, enumdata: AimState["QuestionEnum"], schopts: { qryopts: "{ mode: 'Like', field: 'Category' }" }, listeners: { "collapse": function(e) { Ext.ux.AimDoSearch(Ext.getCmp("Category")); } } },
                { fieldLabel: '内容', id: 'Contents', schopts: { qryopts: "{ mode: 'Like', field: 'Contents' }"} },
                { fieldLabel: '查询', xtype: 'button', iconCls: 'aim-icon-search', width: 60, text: '查询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Contents"));
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
                    autoExpandColumn: 'Contents',
                    margins: '0 10 10 0',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Title', dataIndex: 'Title', header: '标题', width: 150, sortable: true },
					{ id: 'Category', dataIndex: 'Category', header: '问题类型', width: 100, sortable: true },
                    //{ id: 'Anonymity', dataIndex: 'Anonymity', header: '是否匿名', width: 80, sortable: true, renderer: RowRender },
                    //{ id: 'AwardScore', dataIndex: 'AwardScore', header: '悬赏分值', width: 80, sortable: true },
					{id: 'AnswerCount', dataIndex: 'AnswerCount', header: '回复次数', width: 80, sortable: true },
					{ id: 'Contents', dataIndex: 'Contents', header: '内容', width: 100, renderer: RowRender },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '发布时间', width: 100, renderer: ExtGridDateOnlyRender, sortable: true },
					{ id: 'huifu', dataIndex: 'Id', header: '查看回复', width: 100, renderer: RowRender }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid]
                });
            }

            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
                    case "Anonymity":
                        if (value == "1") {
                            rtn = "是";
                        } else {
                            rtn = "否";
                        }
                        break;
                    case "Contents":
                        value = (value + "").replaceAll("<br/>", "").replaceAll("<p>", "").replaceAll("</p>", "").replaceAll("<br />", "");
                        value = value.substring(0, 100);
                        var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;'  onclick='openComment(\"" + record.get("Id") + "\")'>" + value + "&nbsp;&nbsp;</span>";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + "查看回复" + '"';
                        rtn = str;
                        break;
                    case "huifu":
                        var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;'  onclick='openhui(\"" + record.get("Id") + "\")'> 查看回复&nbsp;&nbsp;</span>";
                        //  cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + "查看回复" + '"';
                        rtn = str;
                        break;

                }
                return rtn;
            }




            function openhui(id) {
                var task = new Ext.util.DelayedTask();      //UsrProblemSolve
                var url = "UsrProblemSolve.aspx?id=" + id + "&type=reply";
                //var url = "AskQuestionEdit.aspx?id=" + id + "&type=reply";
                task.delay(100, function() {
                    openterwin(url, "", 780, 560);
                });
            }



            //打开评论回复页
            function openComment(id) {
                var task = new Ext.util.DelayedTask();
                var url = EditPageUrl + "?id=" + id;
                var style = "dialogWidth:780px; dialogHeight:540px; scroll:yes; center:yes; status:fasdfasfds; resizable:yes;";

                task.delay(100, function() {
                    rtn = window.showModalDialog(url, window, style);
                    //openterwin(EditPageUrl + "?id=" + id + "&op=v", "", 780, 540);
                });
            }


            function openterwin(url, name, iWidth, iHeight) {
                var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
                var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
                window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
