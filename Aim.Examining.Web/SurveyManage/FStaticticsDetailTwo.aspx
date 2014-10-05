<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="FStaticticsDetailTwo.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.FStaticticsDetailTwo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "UsrChildWelfareEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var SurveyId = $.getQueryString({ ID: "SurveyId" });
        var title = unescape($.getQueryString({ ID: "title" }));

        var iframe = $.getQueryString({ ID: "type" }) || "";   //维度统计iframe 页
        var hiddenBtn = $.getQueryString({ ID: "hiddenBtn" }); //隐藏的按钮
        var Qty = unescape($.getQueryString({ ID: 'Qty' })) || "";       //查询条件
        var GroupType = $.getQueryString({ ID: 'GroupType' }) || ""; //分组维度
        var QuestionId = $.getQueryString({ ID: 'QuestionId' }) || "";
        var QuestionId = $.getQueryString({ ID: 'QuestionId' }) || "";
        var QuestionItemId = $.getQueryString({ ID: 'QuestionItemId' }) || "";

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };

            var fields = [
			{ name: 'Id' },
			{ name: 'SurveyId' },
			{ name: 'WorkNo' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'Sex' },
			{ name: 'Corp' },
			{ name: 'Dept' },
			{ name: 'Indutydate' },
			{ name: 'WorkAge' },
			{ name: 'Crux' },
			{ name: 'BornDate' },
			{ name: 'Age' },
			{ name: 'JobName' },
			{ name: 'JobDegree' },
			{ name: 'JobSeq' },
			{ name: 'Skill' },
			{ name: 'Content' },
			{ name: 'QuestionType' },
			{ name: 'Answer' },
			{ name: 'Explanation'}]

            var skillFiledIndex = 17; //固定字段的最后索引
            if (AimState["ClnList"].length > 0) {
                for (var i = skillFiledIndex; i < AimState["ClnList"].length; i++) {
                    fields.push(AimState["ClnList"][i]);
                }
            }

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: fields,
                aimbeforeload: function(proxy, options) {
                    options.data = options.data || {};
                    options.data.SurveyId = SurveyId;
                    options.data.GroupType = GroupType;
                    options.data.type = iframe;
                    options.data.Qty = Qty;
                    options.data.QuestionId = QuestionId;
                    options.data.QuestionItemId = QuestionItemId;

                }
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            //	----------------------------列表页面-----------------------------------
            tlBar = new Ext.ux.AimToolbar({
                id: 'tlBar',
                hidden: iframe == "iframe" ? true : false,
                items: ['->', {
                    text: '刷新数据源',
                    iconCls: 'aim-icon-refresh',
                    handler: function() {
                        Ext.getBody().mask("数据刷新中...");
                        $.ajaxExecSync("RefData", { SurveyId: SurveyId }, function(rtn) {
                            Ext.getBody().unmask();
                            if (rtn.data.State == "1") {
                                store.reload();
                                AimDlg.show("数据刷新成功!");
                            } else {
                                AimDlg.show("数据刷新失败!");
                            }
                        }, null, "Comman.aspx");
                    }
                }, {
                    text: '导出Excel',
                    iconCls: 'aim-icon-xls',
                    handler: function() {
                        //ExtGridExportExcel(grid, { store: null, title: title });
                        if (store.getRange().length <= 0) {
                            AimDlg.show("暂无数据,无须导出!");
                            return;
                        }
                        var Corp = "", WorkNo = "", UserName = "", JobName = "", WorkAge = "";
                        Corp = Ext.getCmp("CorpBtn").getValue();
                        WorkNo = Ext.getCmp("WorkNo").getValue();
                        UserName = Ext.getCmp("UserName").getValue();
                        JobName = Ext.getCmp("JobName").getValue();
                        WorkAge = Ext.getCmp("WorkAge").getValue();

                        Ext.getBody().mask("正在导出请稍后...");
                        $.ajaxExec("ImpExcel", {
                            SurveyId: SurveyId,
                            title: unescape($.getQueryString({ ID: "title" })) || "",
                            Corp: Corp,
                            WorkNo: WorkNo,
                            UserName: UserName,
                            JobName: JobName,
                            WorkAge: WorkAge
                        }, function(rtn) {
                            if (rtn.data.fileName) {
                                Ext.getBody().unmask();
                                $("body").append("<iframe style='display:none' src=" + rtn.data.fileName + "></iframe>");
                            }
                        });
                    }
}]
                })

                var columns = [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'SurveyId', dataIndex: 'SurveyId', header: 'SurveyId', width: 100, sortable: true, hidden: true },
					{ id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 100, sortable: true },
					{ id: 'UserId', dataIndex: 'UserId', header: 'UserId', width: 100, sortable: true, hidden: true },
					{ id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 80, sortable: true, renderer: RowRender },
					{ id: 'Sex', dataIndex: 'Sex', header: '性别', width: 60, sortable: true },
					{ id: 'Corp', dataIndex: 'Corp', header: '公司', width: 200, sortable: true },
					{ id: 'Dept', dataIndex: 'Dept', header: '部门', width: 150, sortable: true },
					{ id: 'Indutydate', dataIndex: 'Indutydate', header: '入职日期', renderer: ExtGridDateOnlyRender, width: 100, sortable: true },
					{ id: 'WorkAge', dataIndex: 'WorkAge', header: '工龄', width: 50, sortable: true },
					{ id: 'Crux', dataIndex: 'Crux', header: '关键岗位', width: 80, sortable: true, renderer: RowRender },
					{ id: 'BornDate', dataIndex: 'BornDate', header: '出生日期', renderer: ExtGridDateOnlyRender, width: 100, sortable: true },
					{ id: 'Age', dataIndex: 'Age', header: '年龄', width: 50, sortable: true },
					{ id: 'JobName', dataIndex: 'JobName', header: '岗位', width: 100, sortable: true },
					{ id: 'JobDegree', dataIndex: 'JobDegree', header: '岗位等级', width: 60, sortable: true },
					{ id: 'JobSeq', dataIndex: 'JobSeq', header: '岗位序列', width: 100, sortable: true },
					{ id: 'Skill', dataIndex: 'Skill', header: '技能等级', width: 100, sortable: true}];

                if (AimState["ClnList"].length > 0) {
                    for (var i = skillFiledIndex; i < AimState["ClnList"].length; i++) {
                        var cmTpl = {
                            id: "dynamic_" + i,
                            dataIndex: AimState["ClnList"][i],
                            header: "<b>" + AimState["ClnList"][i] + "</b>",
                            width: (AimState["ClnList"][i] + "").length * 12 + 80,
                            renderer: RowRender
                        };
                        columns.push(cmTpl);
                    }
                }

                var cln1 = [
                { fieldLabel: '公司', id: 'CorpBtn', schopts: { qryopts: "{ mode: 'Like', field: 'Corp' }"} },
                { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                { fieldLabel: '岗位', id: 'JobName', schopts: { qryopts: "{ mode: 'Like', field: 'JobName' }"} },
                { fieldLabel: '工龄', id: 'WorkAge', schopts: { qryopts: "{ mode: 'Like', field: 'WorkAge' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询',
                    handler: function() {
                        Ext.ux.AimDoSearch(Ext.getCmp("WorkNo"));
                    }
                }
                 ];
                var cln2 = [
                { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'WorkNo' }"} },
                { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'UserName' }"} },
                { fieldLabel: '岗位', id: 'JobName', schopts: { qryopts: "{ mode: 'Like', field: 'JobName' }"} },
                { fieldLabel: '工龄', id: 'WorkAge', schopts: { qryopts: "{ mode: 'Like', field: 'WorkAge' }"} },
                { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询',
                    handler: function() {
                        Ext.ux.AimDoSearch(Ext.getCmp("WorkNo"));
                    }
                }
                 ];
                // 搜索栏
                schBar = new Ext.ux.AimSchPanel({
                    store: store,
                    collapsed: false,
                    columns: 6,
                    items: !!iframe ? cln2 : cln1
                });

                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });
                //隐藏查询组件
                switch (hiddenBtn) {
                    case "Corp":
                        //schBar.remove("Corp");
                        // Ext.getCmp("CorpBtn").hide();
                        break;
                }

                // 表格面板
                grid = new Ext.ux.grid.AimGridPanel({
                    title: title,
                    store: store,
                    region: 'center',
                    heigth: 500,
                    // autoExpandColumn: 'Name',
                    columns: columns,
                    tbar: titPanel,
                    bbar: pgBar
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid]
                });

            }

            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn = "";
                switch (this.id) {
                    case "Crux":
                        if (value) {
                            if (value == "N") rtn = "否";
                            if (value == "Y") rtn = "是";
                            cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        }
                        break;
                    case "UserName":
                        if (value) {
                            rtn = "<span style='color:blue; cursor:pointer; text-decoration:underline;' \
                            onclick='openSubmitPg(\"" + record.get("UserId") + "\")'>" + value + "</span>";
                        }
                        break;
                    default:
                        if (columnIndex > 18) {
                            value = value || "";
                            cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                            rtn = value;
                        }
                        break;
                }
                return rtn;
            }

            function openSubmitPg(userid) {
                var url = "SurveyedHistory_1.aspx?SurveyId=" + SurveyId + "&UserId=" + userid + "&op=r";
                opencenterwin(url, "", 900, 620);
            }
            function opencenterwin(url, name, iWidth, iHeight) {
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
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
