<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="UsrVoiceDataView.aspx.cs" Inherits="Aim.Examining.Web.EmpUserVoice.UsrVoiceDataView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var typeName = unescape($.getQueryString({ ID: "nodeName" }) || "");
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
            { name: "ViewCount" },
            { name: 'WorkNo' },
            { name: 'Org' },
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
                collapsed: false,
                columns: 5,
                items: [
                { fieldLabel: '标题', id: 'Title', schopts: { qryopts: "{ mode: 'Like', field: 'Title' }"} },
                { fieldLabel: '内容', id: 'Contents', schopts: { qryopts: "{ mode: 'Like', field: 'Contents' }"} },
                { fieldLabel: '姓名', id: 'CreateName', schopts: { qryopts: "{ mode: 'Like', field: 'CreateName' }"} },
                { fieldLabel: '查询', xtype: 'button', iconCls: 'aim-icon-search', width: 60, text: '查询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("Contents"));
                }
                }
                ]
            });

            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                items: [schBar]
            });

            // 表格面板
            grid = new Ext.ux.grid.AimEditorGridPanel({
                store: store,
                //title: '等待您来回答',
                region: 'center',
                margins: '0 10 10 0',
                viewConfig: { forceFit: true, scrollOffset: 10 },
                autoExpandColumn: 'Org',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                // { id: 'Category', dataIndex: 'Category', header: '分类', width: 100, sortable: true },
					{id: 'Title', dataIndex: 'Title', header: '标题', width: 120, sortable: true, renderer: RowRender },
					{ id: 'Contents', dataIndex: 'Contents', header: '内容', width: 200, renderer: RowRender },
					{ id: 'CreateName', dataIndex: 'CreateName', header: '姓名', width: 70, sortable: true },
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 70, sortable: true },
					{ id: 'Org', dataIndex: 'Org', header: '所属组织', width: 250, sortable: true, renderer: RowRender },
                //{ id: 'AwardScore', dataIndex: 'AwardScore', header: '悬赏分值', width: 80, sortable: true },
                //	{id: 'ViewCount', dataIndex: 'ViewCount', header: '浏览次数', width: 80, sortable: true },
                    {id: 'AnswerCount', dataIndex: 'AnswerCount', header: '回复次数', width: 60, sortable: true },
					{ id: 'CreateTime', dataIndex: 'CreateTime', header: '发布时间', width: 80, renderer: ExtGridDateOnlyRender, sortable: true }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });

            grid.on("rowdblclick", function(gird, rowIndex, e) {
                var id = store.getAt(rowIndex).get("Id");
                windowOpen(id);
            })

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [grid]
            });
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "Title":
                    var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;' onclick='windowOpen(\"" + record.get("Id") + "\")'>" + value + "</span>";
                    rtn = str;
                    break;
                case "Anonymity":
                    if (value == "1") {
                        rtn = "是";
                    } else {
                        rtn = "否";
                    }
                    break;
                case "AnswerCount":
                    var str = "<span style='color:Blue; cursor:pointer; text-decoration:underline;'  onclick='openComment(\"" + record.get("Id") + "\")'>" + value + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + "查看回复" + '"';
                    rtn = str;
                    break;
                case "Contents":
                    value = value || "";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = value;
                    break;
                case "Org":
                    value = value || "";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = value;
                    break;
            }
            return rtn;
        }

        //打开评论回复页
        function openComment(id) {

            var task = new Ext.util.DelayedTask();

            var url = "UsrProblemSolve.aspx?QuestionId=" + id;
            task.delay(100, function() {
                openterwin(url, "", 780, 560);
            });
        }

        function windowOpen(id) {
            var task = new Ext.util.DelayedTask();      //UsrProblemSolve
            var url = "UsrProblemSolve.aspx?id=" + id + "&type=reply";
            //var url = "AskQuestionEdit.aspx?id=" + id + "&type=reply";
            task.delay(100, function() {
                opencenterwin(url, "", 780, 560);
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
</asp:Content>
