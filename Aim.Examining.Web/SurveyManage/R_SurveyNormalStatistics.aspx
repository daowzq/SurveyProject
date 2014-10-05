<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="R_SurveyNormalStatistics.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.R_SurveyNormalStatistics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">

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
            { name: "SummitCount" },
			{ name: 'UrgencyDegree' },
			{ name: 'SetTimeout' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
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
                store: store,
                columns: 5,
                collapsed: false,
                items: [
                { fieldLabel: '问卷标题', id: 'SurveyTitile', schopts: { qryopts: "{ mode: 'Like', field: 'SurveyTitile' }"} },
               { fieldLabel: '发起机构', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CompanyName' }"} },
       { fieldLabel: '起始时间', id: 'StartTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', endDateField: 'EndTime', schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'StartTime' }"} },
                { fieldLabel: '截至时间', id: 'EndTime', format: 'Y-m-d', xtype: 'datefield', vtype: 'daterange', startDateField: 'StartTime', schopts: { qryopts: "{ mode: 'LessThan', datatype:'Date', field: 'EndTime' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
                    Ext.ux.AimDoSearch(Ext.getCmp("SurveyTitile"));   //Number 为任意
                }
                }
      ]
            });

            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                //tbar: tlBar,
                items: [schBar]
            });


            // 表格面板
            grid = new Ext.ux.grid.AimGridPanel({
                store: store,
                region: 'center',
                margins: '0 10 0 0',
                //viewConfig: { forceFit: true, scrollOffset: 10 },
                autoExpandColumn: 'SurveyTitile',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'SurveyTitile', dataIndex: 'SurveyTitile', header: '问卷标题', width: 150, sortable: true, renderer: RowRender },
                     { id: 'SurveyTypeName', dataIndex: 'SurveyTypeName', header: '问卷类型', width: 120, sortable: true },

                    //{ id: 'Description', dataIndex: 'Description', header: '问卷描述', width: 230, renderer: RowRender },
					{ id: 'SummitCount', dataIndex: 'SummitCount', header: '提交数量', width: 80 },
                //{ id: 'State', dataIndex: 'State', header: '启用状态', width: 80, sortable: true, renderer: RowRender },
                //{ id: 'State', dataIndex: 'State', header: '问卷状态', width: 80, renderer: RowRender },
                     // {id: 'CompanyName', dataIndex: 'CompanyName', header: '发起机构', width: 150, renderer: RowRender },
                    { id: 'CreateTime', dataIndex: 'CreateTime', header: '创建时间', width: 100, renderer: ExtGridDateOnlyRender },
                // { id: 'CreateName', dataIndex: 'CreateName', header: '创建人', width: 80 },
			        {id: 'Edit', dataIndex: 'Edit', header: '操作', width: 220, renderer: RowRender },
			        { id: 'DataSource', dataIndex: 'DataSource', header: '数据源', width: 120, renderer: RowRender }
                    ],
                bbar: pgBar,
                // tbar: AimState["Audit"] == 'admin' ? titPanel : ''
                tbar: titPanel
                //tbar: titPanel
            });

            grid.on("rowclick", function(grid, rowIndex, e) {
                var Element = document.getElementById("frameContent");
                if (Element) {
                    var rec = grid.getStore().getAt(rowIndex);
                    var url = "FilterStatictics.aspx?op=r&SurveyId=" + rec.get("Id") + "&Count=" + (rec.get("SummitCount") || 0);
                    frameContent.location.href = url;
                }
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
                case "DataSource":
                    var str = "";
                    var url = "FStaticticsDetail.aspx?screenType=allscreen&SurveyId=" + record.get("Id") + "&title=" + (escape(record.get("SurveyTitile") || ""));
                    str += "<span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='opencenterwin(\"" + url + "\", \"allscreen\", window.screen.availWidth, window.screen.availHeight);'>" + "题目维度" + "</span>";
                    var url1 = "FStaticticsDetailTwo.aspx?screenType=allscreen&SurveyId=" + record.get("Id") + "&title=" + (escape(record.get("SurveyTitile") || ""));
                    str += "<span>&nbsp;&nbsp;</span><span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='opencenterwin(\"" + url1 + "\", \"allscreen\", window.screen.availWidth, window.screen.availHeight);'>" + "人员维度" + "</span>";
                    rtn = str;
                    break;
                case "SurveyTitile":
                    if (value) {
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + "标题:" + value + "</br>内容:" + record.get("Description").substring(0, 30) + "..." + '"';
                        rtn = value;
                    }
                    break;
                case "Description":
                    if (value) {
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        rtn = value.length > 120 ? value.substring(0, 120) + "..." : value;
                    }
                    break;

                case "Edit":

                    var str = "<span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='statitcsWin(\"" + record.get("Id") + "\")'>" + "查看统计" + "</span>";
                    var url = "FilterStatictics.aspx?screenType=allscreen&SurveyId=" + record.get("Id") + "&Count=" + record.get("SummitCount") + "&title=" + (escape(record.get("SurveyTitile") || ""));
                    var url2 = "../ReportSheet/LeaveReasonFrame.aspx";
                    str += "<span>&nbsp;&nbsp;&nbsp;&nbsp;</span><span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='opencenterwin(\"" + url + "\", \"allscreen\", window.screen.availWidth, window.screen.availHeight);'>" + "统计分析" + "</span>";

                    if (record.get("SurveyTitile") == "员工离职调查问卷") {
                        str += "<span>&nbsp;&nbsp;&nbsp;&nbsp;</span><span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='opencenterwin(\"" + url2 + "\", \"allscreen\", 900, 470);'>" + "离职原因" + "</span>";
                    }
                    if (record.get("IsNoName") != "1") {
                        str += "<span>&nbsp;&nbsp;&nbsp;&nbsp;</span><span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='UsrChoiceWin(\"" + record.get("Id") + "\")'>" + "详细" + "</span>";
                    } else {
                        str += "<span>&nbsp;&nbsp;&nbsp;&nbsp;</span><span style='color:gray; cursor:pointer; text-decoration:underline;' >" + "详细" + "</span>";
                    }
                    rtn = str;
                    break;
                case "DeptName":
                    value = value || "";
                    cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = value;
                    break;
            }
            return rtn;
        }


        function UsrChoiceWin(val) {
            var ModelStyle = "dialogWidth:1000px; dialogHeight:600px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "SurveyCommitHistoryList.aspx?surveyId=" + val;
            //OpenModelWin(url, "", ModelStyle, function() { })
            opencenterwin(url, "", 1000, 600);
            //OpenModelWin
        }

        //查看统计
        function statitcsWin(surveyId) {
            var task = new Ext.util.DelayedTask();
            task.delay(100, function() {
                var url = "T_SurveyStatisticTab.aspx?SurveyId=" + surveyId + "&rand=" + Math.random();
                opencenterwin(url, "", 1000, 600);
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
