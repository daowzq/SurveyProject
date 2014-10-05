<%@ Page Title="维度筛选" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FDimension.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.FDimension" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        .noborer
        {
            border: none;
        }
        #right
        {
            top: 50%;
            width: 31px;
            right: 0px;
            position: fixed;
            _position: absolute;
            _right: 0;
            _top: 40%;
        }
        .report-error
        {
            padding: 100px;
            text-align: center;
            color: rgb(170, 170, 170);
            font-size: 14px;
        }
        .help-tool
        {
            width: 31px;
            height: 31px;
            margin-top: 1px;
            display: block;
            cursor: pointer;
            background-image: url("img/help-tool.png");
        }
        .help-tool2
        {
            width: 31px;
            height: 31px;
            margin-top: 1px;
            display: block;
            cursor: pointer;
            background-image: url("img/help-tool2.png");
        }
        #allscreen
        {
            background-position: 0px 0px;
        }
        #allscreen:hover
        {
            background-position: 0px -82px;
        }
        #toTop
        {
            background-position: 0px -324px;
        }
        #toTop:hover
        {
            background-position: 0px -243px;
        }
        .toobarBtn
        {
            margin-top: 5px;
            margin-right: 5px;
        }
        .tbar_group
        {
            border: none;
        }
    </style>
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />
    <!-- <script src="js/jquery.scrollto.js" type="text/javascript"></script>-->
    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>
    <script src="/FusionChart32/FusionCharts.js" type="text/javascript"></script>
    <!-- <script src="js/AdvanceStatistics.js" type="text/javascript"></script>-->
    <script type="text/javascript">

        var SurveyId = $.getQueryString({ ID: "SurveyId" });
        var title = unescape($.getQueryString({ ID: "title" })) || "";
        var voteCount = $.getQueryString({ ID: 'Count' }); //提交人数
        var qtRecordClns = "", qstTreeStore = "";
        var voteInfo = "";

        var queryConfig = { //统计模式object
            pType: 'usr',
            groupType: 'Corp',
            QuestionId: '',
            QuestionItemId: ''
        }
        window.onerror = function (sMessage, sUrl, sLine) {
            return true
        };
        function onPgLoad() {
            voteInfo = AimState["VoteInfo"] || {};

            Ext.getBody().mask("数据正在努力加载中...");
            window.setTimeout(function () {
                setPgUI();
                complementCtrl(queryConfig);
            }, 100);
        }

        function setPgUI() {

            //--------------------------------------------筛选模式----------------------------------
            var toolbar = new Ext.Panel({
                // title: title,
                height: 70,
                flex: 3,
                //anchor: '99%',
                layout: 'column',
                cls: 'tbar_group',
                border: false,
                items: [
              new Ext.FormPanel({
                  frame: true,
                  border: false,
                  // width: '40%',
                  //columnWidth: 0.5,
                  //width: 500,
                  height: 70,
                  items: [{
                      xtype: 'radiogroup',
                      fieldLabel: '筛选模式',
                      unstyled: true,
                      columns: 2,
                      items: [
                        { boxLabel: '人员', checked: true, name: 'splittype', value: 'usr' },
                        { boxLabel: '题目', name: 'splittype', value: 'qst' }
                        ],
                      listeners: { "change": function (cmp, checkedRdo) {
                          if (checkedRdo.value == "qst") {
                              queryConfig.pType = "qst";
                              complementCtrl(queryConfig);
                          }
                          if (checkedRdo.value == "usr") {
                              queryConfig.pType = "usr";
                              complementCtrl(queryConfig);
                              //概要统计图
                              //---公司
                              window.setTimeout(function () {

                                  var title = "";
                                  switch (queryConfig.groupType) {
                                      case "Corp":
                                          title = "公司";
                                          break;
                                      case "WorkAge":
                                          title = "工龄";
                                          break;
                                      case "Sex":
                                          title = "性别";
                                          break;
                                      case "AgeSeg":
                                          title = "年龄段";
                                          break;
                                  }


                                  Ext.getCmp("groupTree").setTitle("【" + title + "】分组统计");

                                  //概要Chart
                                  $.ajaxExec("SummaryChart", {
                                      SurveyId: SurveyId,
                                      QuestionId: queryConfig.QuestionId,
                                      QuestionItemId: queryConfig.QuestionItemId,
                                      pType: queryConfig.pType,
                                      GroupType: queryConfig.groupType
                                  }, function (rtn) {
                                      var chartInfo = rtn.data.SummaryChart;
                                      if (chartInfo.length <= 0) return;
                                      summaryChart(chartInfo, queryConfig.groupType);
                                  });

                              }, 50);
                          }
                      }
                      }

                  }
            ]

              })

                //              , new Ext.Toolbar({
                //                  //width: '50%',
                //                  columnWidth: 0.5,
                //                  height: 30,
                //                  border: false,
                //                  cls: 'tbar_group',
                //                  frame: true,
                //                  items: []
                //              })
]
            });


            //------------------------------------查询区域-----------------------------------
            var fsf = new Ext.FormPanel({
                frame: true,
                //title: '分组维度',
                //bodyStyle: 'padding:5px 5px 0',
                flex: 7,
                height: 70,
                items: [{
                    xtype: 'radiogroup',
                    fieldLabel: '维度',
                    width: 250,
                    columns: 2,
                    items: [
                        { boxLabel: '公司', checked: true, name: 'groupby', value: 'Corp' },
                        { boxLabel: '工龄', name: 'groupby', value: 'WorkAge' },
                        { boxLabel: '性别', name: 'groupby', value: 'Sex' },
                        { boxLabel: '年龄段', name: 'groupby', value: 'AgeSeg'}],
                    listeners: { "change": function (cmp, Rdo) {
                        groupCompleteCtrl();

                        if (Rdo.value == "Sex") {
                            queryConfig.groupType = "Sex";
                            Ext.getCmp("groupTree").setTitle("【性别】分组统计");

                            //概要Chart
                            $.ajaxExec("SummaryChart", {
                                SurveyId: SurveyId,
                                QuestionId: queryConfig.QuestionId,
                                QuestionItemId: queryConfig.QuestionItemId,
                                pType: queryConfig.pType,
                                GroupType: queryConfig.groupType
                            }, function (rtn) {
                                var chartInfo = rtn.data.SummaryChart;
                                if (chartInfo.length <= 0) return;
                                summaryChart(chartInfo, "Sex");
                            });

                            var task = new Ext.util.DelayedTask();
                            task.delay(50, function () {
                                $.ajaxExec("GroupDetial", {
                                    SurveyId: SurveyId,
                                    QuestionId: queryConfig.QuestionId,
                                    QuestionItemId: queryConfig.QuestionItemId,
                                    pType: queryConfig.pType,
                                    GroupType: queryConfig.groupType
                                }, function (rtn) {
                                    var dicList = rtn.data.QstDetail;
                                    AimState["CorpUsr"] = rtn.data.CorpUsr;

                                    dicList = AdapterData(dicList);
                                    var cm = Ext.getCmp("groupTree").getColumnModel();
                                    var index = cm.getIndexById("Corp");
                                    cm.setColumnHeader(index, "性别");
                                    cm.setColumnWidth(index, 80);

                                    record = Ext.data.Record.create(qtRecordClns);
                                    qstTreeStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                                        parent_id_field_name: 'ParentID',
                                        leaf_field_name: 'IsLeaf',
                                        data: dicList,
                                        reader: new Ext.ux.data.AimJsonReader({ id: 'ID' }, record)
                                    });
                                    // qstTreeGrid.reconfigure(qstTreeStore, cm);
                                    window.setTimeout(function () {
                                        qstTreeGrid.reconfigure(qstTreeStore, cm);
                                    }, 50);
                                });
                            });

                        }
                        //---公司
                        if (Rdo.value == "Corp") {
                            queryConfig.groupType = "Corp";
                            Ext.getCmp("groupTree").setTitle("【公司】分组统计");

                            //概要Chart
                            $.ajaxExec("SummaryChart", {
                                SurveyId: SurveyId,
                                QuestionId: queryConfig.QuestionId,
                                QuestionItemId: queryConfig.QuestionItemId,
                                pType: queryConfig.pType,
                                GroupType: queryConfig.groupType
                            }, function (rtn) {
                                var chartInfo = rtn.data.SummaryChart;
                                if (chartInfo.length <= 0) return;
                                summaryChart(chartInfo, queryConfig.groupType);
                            });

                            var task = new Ext.util.DelayedTask();
                            task.delay(50, function () {
                                $.ajaxExec("GroupDetial", {
                                    SurveyId: SurveyId,
                                    QuestionId: queryConfig.QuestionId,
                                    QuestionItemId: queryConfig.QuestionItemId,
                                    pType: queryConfig.pType,
                                    GroupType: queryConfig.groupType
                                }, function (rtn) {
                                    var dicList = rtn.data.QstDetail;
                                    AimState["CorpUsr"] = rtn.data.CorpUsr;

                                    dicList = AdapterData(dicList);
                                    var cm = Ext.getCmp("groupTree").getColumnModel();
                                    var index = cm.getIndexById("Corp");
                                    cm.setColumnHeader(index, "公司");
                                    cm.setColumnWidth(index, 260);

                                    record = Ext.data.Record.create(qtRecordClns);
                                    qstTreeStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                                        parent_id_field_name: 'ParentID',
                                        leaf_field_name: 'IsLeaf',
                                        data: dicList,
                                        reader: new Ext.ux.data.AimJsonReader({ id: 'ID' }, record)
                                    });
                                    window.setTimeout(function () {
                                        qstTreeGrid.reconfigure(qstTreeStore, cm);
                                    }, 50);
                                    // qstTreeGrid.reconfigure(qstTreeStore, cm);
                                });
                            });

                        }

                        //--工龄
                        if (Rdo.value == "WorkAge") {
                            queryConfig.groupType = "WorkAge";
                            Ext.getCmp("groupTree").setTitle("【工龄】分组统计");

                            //概要Chart
                            $.ajaxExec("SummaryChart", {
                                SurveyId: SurveyId,
                                QuestionId: queryConfig.QuestionId,
                                QuestionItemId: queryConfig.QuestionItemId,
                                pType: queryConfig.pType,
                                GroupType: queryConfig.groupType
                            }, function (rtn) {
                                var chartInfo = rtn.data.SummaryChart;
                                if (chartInfo.length <= 0) return;

                                summaryChart(chartInfo, queryConfig.groupType);
                            });

                            var task = new Ext.util.DelayedTask();
                            task.delay(50, function () {
                                $.ajaxExec("GroupDetial", {
                                    SurveyId: SurveyId,
                                    QuestionId: queryConfig.QuestionId,
                                    QuestionItemId: queryConfig.QuestionItemId,
                                    pType: queryConfig.pType,
                                    GroupType: queryConfig.groupType
                                }, function (rtn) {
                                    var dicList = rtn.data.QstDetail;
                                    AimState["CorpUsr"] = rtn.data.CorpUsr;

                                    dicList = AdapterData(dicList);
                                    var cm = Ext.getCmp("groupTree").getColumnModel();
                                    var index = cm.getIndexById("Corp");
                                    cm.setColumnHeader(index, "工龄(年)");
                                    cm.setColumnWidth(index, 100);

                                    record = Ext.data.Record.create(qtRecordClns);
                                    qstTreeStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                                        parent_id_field_name: 'ParentID',
                                        leaf_field_name: 'IsLeaf',
                                        data: dicList,
                                        reader: new Ext.ux.data.AimJsonReader({ id: 'ID' }, record)
                                    });

                                    window.setTimeout(function () {
                                        qstTreeGrid.reconfigure(qstTreeStore, cm);
                                    }, 50);

                                });
                            });

                        }
                        //--年龄段
                        if (Rdo.value == "AgeSeg") {
                            queryConfig.groupType = "AgeSeg";
                            Ext.getCmp("groupTree").setTitle("【年龄段】分组统计");

                            //概要Chart
                            $.ajaxExec("SummaryChart", {
                                SurveyId: SurveyId,
                                QuestionId: queryConfig.QuestionId,
                                QuestionItemId: queryConfig.QuestionItemId,
                                pType: queryConfig.pType,
                                GroupType: queryConfig.groupType
                            }, function (rtn) {
                                var chartInfo = rtn.data.SummaryChart;
                                if (chartInfo.length <= 0) return;
                                summaryChart(chartInfo, queryConfig.groupType);
                            });

                            var task = new Ext.util.DelayedTask();
                            task.delay(50, function () {
                                $.ajaxExec("GroupDetial", {
                                    SurveyId: SurveyId,
                                    QuestionId: queryConfig.QuestionId,
                                    QuestionItemId: queryConfig.QuestionItemId,
                                    pType: queryConfig.pType,
                                    GroupType: queryConfig.groupType
                                }, function (rtn) {
                                    var dicList = rtn.data.QstDetail;
                                    AimState["CorpUsr"] = rtn.data.CorpUsr;

                                    dicList = AdapterData(dicList);
                                    var cm = Ext.getCmp("groupTree").getColumnModel();
                                    var index = cm.getIndexById("Corp");
                                    cm.setColumnHeader(index, "年龄段");
                                    cm.setColumnWidth(index, 110);

                                    record = Ext.data.Record.create(qtRecordClns);
                                    qstTreeStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                                        parent_id_field_name: 'ParentID',
                                        leaf_field_name: 'IsLeaf',
                                        data: dicList,
                                        reader: new Ext.ux.data.AimJsonReader({ id: 'ID' }, record)
                                    });

                                    window.setTimeout(function () {
                                        qstTreeGrid.reconfigure(qstTreeStore, cm);
                                    }, 50);

                                });
                            });

                        }
                        ////去除MASK 
                        //Ext.getBody().unmask();
                        //--
                    }
                    }

                }
            ]

            });

            //            var field = new Ext.Panel({
            //                layout: { type: 'hbox', align: 'stretch' },
            //                defaults: { margins: '0 0 0 0' },
            //                unstyled: true,
            //                border: false,
            //                hidden: true,
            //                cls: 'noborer',
            //                height: 26,
            //                items: [{
            //                    flex: 1,
            //                    layout: 'form',
            //                    unstyled: true,
            //                    items: [{
            //                        fieldLabel: "公司",
            //                        xtype: 'textfield',
            //                        name: "birthday",
            //                        width: 100
            //}]
            //                    }, {
            //                        flex: 1,
            //                        layout: 'form',
            //                        unstyled: true,
            //                        items: [{
            //                            fieldLabel: "工龄",
            //                            xtype: 'textfield',
            //                            name: "birthday",
            //                            width: 100
            //}]
            //                        },
            //                                {
            //                                    flex: 1,
            //                                    layout: 'form',
            //                                    border: false,
            //                                    unstyled: true,
            //                                    items: [{
            //                                        fieldLabel: "岗位",
            //                                        xtype: 'textfield',
            //                                        name: "birthday",
            //                                        width: 100
            //}]
            //                                    }
            //]
            //                    },
            //                                {
            //                                    defaults: { margins: '0 0 0 0' },
            //                                    layout: { type: 'hbox', align: 'stretch' },
            //                                    border: false,
            //                                    hidden: true,
            //                                    height: 26,
            //                                    items: [{
            //                                        flex: 1,
            //                                        layout: 'form',
            //                                        unstyled: true,
            //                                        items: [{
            //                                            fieldLabel: "性别",
            //                                            xtype: 'textfield',
            //                                            name: "birthday",
            //                                            width: 100
            //}]
            //                                        }, {
            //                                            flex: 1,
            //                                            layout: 'form',
            //                                            unstyled: true,
            //                                            items: [{
            //                                                fieldLabel: "年龄段",
            //                                                xtype: 'textfield',
            //                                                name: "birthday",
            //                                                width: 100
            //}]
            //                                            },
            //                                {
            //                                    flex: 1,
            //                                    layout: 'form',
            //                                    border: false,
            //                                    unstyled: true,
            //                                    items: [
            //                                    { xtype: 'button',
            //                                        iconCls: 'aim-icon-search',
            //                                        width: 60,
            //                                        margins: '2 30 0 0',
            //                                        text: '查 询',
            //                                        handler: function() {

            //                                        }
            //}]
            //}]
            //                                        });
            //                    var field = new Ext.Panel({
            //                        frame: true,
            //                        //title: '查询条件',
            //                        layout: 'form',
            //                        border: false,
            //                        flex: 7,
            //                        cls: 'noborer',
            //                        height: 100,
            //                        items: [field]
            //                    });

            //查询栏
            schpanel = new Ext.Panel({
                layout: {
                    type: 'hbox',
                    align: 'stretch'
                },
                anchor: '99%',
                height: 70,
                border: false,
                autoScroll: true,
                items: [toolbar, fsf]
            });

            //----------------------------题项treegrid--------------------------------
            var treedata = AimState["QstDataList"] || [];
            var treeData = [];

            $.each(treedata, function () {
                if ((this.QuestionType + "").indexOf("单选") > -1 || (this.QuestionType + "").indexOf("多选") > -1) {
                    var tmpObj = {
                        ParentID: null,
                        IsLeaf: false,
                        Rate: 100,
                        AnswerItem: '',
                        QuestionItemId: '',
                        TolCount: voteInfo[this.QuestionId],
                        CurrCount: voteInfo[this.QuestionId],
                        ID: this.QuestionId,
                        Question: this.Content || "",
                        QuestionType: this.QuestionType || ""
                    }
                    //frist root node
                    var parentID = this.QuestionId;
                    var tolCount = voteInfo[this.QuestionId];
                    treeData.push(tmpObj);

                    //child node 同意|53.19|否|1692deec-b642-4510-8d14-e45bcb0f4149
                    var itemArr = this.ItemSet.split('$'); //// [2]该问题项是否说明
                    $.each(itemArr, function () {
                        var arr = this.split("|");
                        treeData.push({ Question: '', QuestionType: '', QuestionItemId: arr[3], CurrCount: voteInfo[arr[3]], ParentID: parentID, IsLeaf: true, AnswerItem: arr[0], Rate: arr[1] });
                    })
                }
            })


            AppMdlRecord = Ext.data.Record.create([
                { name: 'ID', type: 'string' },
                { name: 'ParentID', type: 'string' },
                { name: 'IsLeaf', type: 'bool' },
                { name: 'Question' },
                { name: 'QuestionItemId' },
                { name: 'QuestionType' },
                { name: 'AnswerItem' },
                { name: 'TolCount' },
                { name: 'CurrCount' },
                { name: 'Rate'}]);

            treeStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                parent_id_field_name: 'ParentID',
                leaf_field_name: 'IsLeaf',
                data: treeData,
                reader: new Ext.ux.data.AimJsonReader({
                    id: 'ID',
                    dsname: 'Mdls',
                    aimread: function (rd, resp, dt) { }
                }, AppMdlRecord),
                proxy: new Ext.ux.data.AimRemotingProxy({
                    aimbeforeload: function (proxy, options) {
                    }
                })
            });


            // 表格面板
            treegrid = new Ext.ux.maximgb.tg.GridPanel({
                id: 'qstTree',
                store: treeStore,
                stripeRows: true,
                hidden: true,
                title: '问卷问题统计',
                viewConfig: { forceFit: true, scrollOffset: 5 },
                border: true,
                master_column_id: 'Question',
                height: 280,
                anchor: '99%',
                //autoExpandColumn: 'Name',
                columns: [
                    { id: 'Question', header: "题目", dataIndex: 'Question', width: 400, sortable: true },
                    { id: 'QuestionType', header: "题目类型", dataIndex: 'QuestionType', width: 80, sortable: true },
                    { id: 'AnswerItem', header: "答案选项", dataIndex: 'AnswerItem', width: 300, align: 'center', renderer: RowRender },
                //{ id: 'TolCount', header: "总票数", dataIndex: 'TolCount', width: 100, sortable: true },
                    {id: 'CurrCount', header: "票数", dataIndex: 'CurrCount', width: 100, sortable: true },
                    { id: 'Rate', header: "占比（%）", dataIndex: 'Rate', width: 100, sortable: true }
                ]
            });

            //treegrid.on("afterrender", function() {
            //    //Ext.getBody().unmask();
            // });

            treegrid.on("rowclick", function (Grid, rowIndex, e) {
                var rec = treeStore.getAt(rowIndex);
                var questionId = rec.get("ParentID") + "";
                var questionItemId = rec.get("QuestionItemId") || "";
                if (rec.get("AnswerItem")) {
                    queryConfig.QuestionId = questionId;
                    queryConfig.QuestionItemId = questionItemId;

                    Ext.getCmp("qstTreeTwoGrid").show();
                    Ext.getCmp("qstTreeTwoGrid").setTitle("【" + rec.get("AnswerItem") + "】选项" + "_问卷问题统计");
                    //Ext.getCmp("qstTreeTwoGrid").mask("数据加载中...");

                    $.ajaxExec("RBackQst", {
                        SurveyId: SurveyId,
                        QuestionId: questionId,
                        QuestionItemId: questionItemId
                    }, function (rtn) {
                        var DList = rtn.data.DList;
                        DList = qstDataAdapter(DList);

                        var cm = Ext.getCmp("qstTreeTwoGrid").getColumnModel();
                        var qSTTreeRecord = Ext.data.Record.create([
                                                { name: 'ID', type: 'string' },
                                                { name: 'ParentID', type: 'string' },
                                                { name: 'IsLeaf', type: 'bool' },
                                                { name: 'Question' },
                                                { name: 'QuestionType' },
                                                { name: 'AnswerItem' },
                                                { name: 'TolCount' },
                                                { name: 'CurrCount' },
                                                { name: 'Rate'}]);

                        qstTwoStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                            parent_id_field_name: 'ParentID',
                            leaf_field_name: 'IsLeaf',
                            data: DList,
                            reader: new Ext.ux.data.AimJsonReader({ id: 'ID' }, qSTTreeRecord)
                        });

                        window.setTimeout(function () {
                            qstTreeTwoGrid.reconfigure(qstTwoStore, cm);
                            //Ext.getCmp("qstTreeTwoGrid").unmask("数据加载中...");

                            //                            //概要图表
                            //                            $.ajaxExec("SummaryChart", {
                            //                                SurveyId: SurveyId,
                            //                                QuestionId: queryConfig.QuestionId,
                            //                                QuestionItemId: queryConfig.QuestionItemId,
                            //                                pType: queryConfig.pType,
                            //                                GroupType: queryConfig.groupType
                            //                            }, function(rtn) {
                            //                                var chartInfo = rtn.data.SummaryChart;
                            //                                if (chartInfo) {
                            //                                    Ext.getCmp("guidSheet").show();
                            //                                    if (chartInfo.length <= 0) return;
                            //                                    summaryChart(chartInfo, queryConfig.groupType);
                            //                                }
                            //                            });

                            //                            //分组
                            //                            $.ajaxExec("GroupDetial", {
                            //                                SurveyId: SurveyId,
                            //                                QuestionId: queryConfig.QuestionId,
                            //                                QuestionItemId: queryConfig.QuestionItemId,
                            //                                pType: queryConfig.pType,
                            //                                GroupType: queryConfig.groupType
                            //                            }, function(rtn) {
                            //                                var dicList = rtn.data.QstDetail;
                            //                                if (!!dicList || dicList.length <= 0) return;

                            //                                AimState["CorpUsr"] = rtn.data.CorpUsr;
                            //                                Ext.getCmp("groupTree").show();

                            //                                dicList = AdapterData(dicList);
                            //                                var cm = Ext.getCmp("groupTree").getColumnModel();
                            //                                var index = cm.getIndexById("Corp");

                            //                                //
                            //                                if (queryConfig.groupType == "Corp") {
                            //                                    cm.setColumnHeader(index, "公司");
                            //                                    cm.setColumnWidth(index, 260);
                            //                                } else if (queryConfig.groupType == "Sex") {
                            //                                    cm.setColumnHeader(index, "性别");
                            //                                    cm.setColumnWidth(index, 80);
                            //                                } else if (queryConfig.groupType = "WorkAge") {
                            //                                    cm.setColumnHeader(index, "工龄(年)");
                            //                                    cm.setColumnWidth(index, 100);
                            //                                } else if (queryConfig.groupType == "AgeSeg") {
                            //                                    cm.setColumnHeader(index, "年龄段");
                            //                                    cm.setColumnWidth(index, 110);
                            //                                }

                            //                                record = Ext.data.Record.create(qtRecordClns);
                            //                                qstTreeStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                            //                                    parent_id_field_name: 'ParentID',
                            //                                    leaf_field_name: 'IsLeaf',
                            //                                    data: dicList,
                            //                                    reader: new Ext.ux.data.AimJsonReader({ id: 'ID' }, record)
                            //                                });
                            //                                window.setTimeout(function() {
                            //                                    qstTreeGrid.reconfigure(qstTreeStore, cm);
                            //                                }, 50);
                            //                            });


                        }, 50);
                    });
                }

            });

            //------------------- two--------------------------------
            function qstDataAdapter(record) {

                var splitArr = [];
                var splitObj = {
                    NodePID: '',
                    ChildNodePID: '',
                    Content: '',
                    QuestionId: '',
                    QuestionItemId: ''
                }

                for (var i = 0; i < record.length; i++) {
                    if (record[i]["Content"] == splitObj["Content"]) {//child
                        var tmpObj = {
                            ID: record[i]["QuestionId"] + "|" + Math.random(),
                            ParentID: splitObj["NodePID"],
                            IsLeaf: true,
                            Question: '',
                            QuestionType: '',
                            AnswerItem: record[i]["Answer"],
                            TolCount: '',
                            CurrCount: record[i]["STotal"],
                            Rate: new Number(parseFloat(record[i]["STotal"]) / parseFloat(record[i]["ZTotal"]) * 100).toFixed(2)
                        }
                        splitArr.push(tmpObj)

                    } else { //root
                        var tmpObj = {
                            ID: record[i]["QuestionId"],
                            ParentID: '',
                            IsLeaf: false,
                            Question: record[i]["Content"],
                            QuestionType: record[i]["QuestionType"],
                            AnswerItem: '',
                            TolCount: '',
                            CurrCount: record[i]["ZTotal"],
                            Rate: '100'
                        }
                        splitObj.Content = record[i]["Content"];
                        splitObj.NodePID = record[i]["QuestionId"];

                        splitArr.push(tmpObj)
                        i--;
                    }
                }

                return splitArr;
            }

            var treedataTwo = [];
            var treeDataTwo = [];

            qSTTreeRecord = Ext.data.Record.create([
                { name: 'ID', type: 'string' },
                { name: 'ParentID', type: 'string' },
                { name: 'IsLeaf', type: 'bool' },
                { name: 'Question' },
                { name: 'QuestionType' },
                { name: 'AnswerItem' },
                { name: 'TolCount' },
                { name: 'CurrCount' },
                { name: 'Rate'}]);

            qstTwoStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                parent_id_field_name: 'ParentID',
                leaf_field_name: 'IsLeaf',
                data: treeDataTwo,
                reader: new Ext.ux.data.AimJsonReader({
                    id: 'ID',
                    dsname: 'Mdls',
                    aimread: function (rd, resp, dt) { }
                }, qSTTreeRecord)
            });


            // two
            qstTreeTwoGrid = new Ext.ux.maximgb.tg.GridPanel({
                id: 'qstTreeTwoGrid',
                store: qstTwoStore,
                stripeRows: true,
                hidden: true,
                title: '问题统计',
                viewConfig: { forceFit: true, scrollOffset: 0 },
                border: false,
                master_column_id: 'Question',
                height: 280,
                anchor: '99%',
                //autoExpandColumn: 'Name',
                columns: [
                    { id: 'Question', header: "题目", dataIndex: 'Question', width: 400, sortable: true },
                    { id: 'QuestionType', header: "题目类型", dataIndex: 'QuestionType', width: 80, sortable: true },
                    { id: 'AnswerItem', header: "答案选项", dataIndex: 'AnswerItem', width: 300, align: 'center' },
                //{ id: 'TolCount', header: "总票数", dataIndex: 'TolCount', width: 100, sortable: true },
                    {id: 'CurrCount', header: "票数", dataIndex: 'CurrCount', width: 100, sortable: true },
                    { id: 'Rate', header: "占比（%）", dataIndex: 'Rate', width: 100, sortable: true }
                ]
            });

            qstTreeTwoGrid.on("rowclick", function (Grid, rowIndex, e) {

                var rec = qstTwoStore.getAt(rowIndex);
                var questionId = (rec.get("ID") + "").split("|")[0];
                var corp = rec.get("hiddenQty") || "";

                if (rec.get("Question")) { //调用
                    $.ajaxExec("GetQstInfo", {
                        SurveyId: SurveyId,
                        QuestionId: questionId,
                        QstQuestionId: queryConfig.QuestionId,
                        QstQuestionItemId: queryConfig.QuestionItemId,
                        pType: queryConfig.pType,
                        GroupType: "no"
                    }, function (rtn) {
                        var arrDic = rtn.data.QstInfo;
                        if (arrDic.length <= 0) return;

                        var charInfo = {
                            Title: arrDic[0]["Content"],
                            SurveyId: arrDic[0]["QuestionId"],
                            arrContent: [],
                            arrCount: [],
                            arrValue: []
                        }

                        $.each(arrDic, function () {
                            charInfo.arrContent.push(this.Answer);
                            charInfo.arrCount.push(this.Total);
                            var val = new Number(parseFloat(parseFloat(this.Total) / parseFloat(AimState["SubmitTol"] || 0) * 100)).toFixed(2)
                            charInfo.arrValue.push(val);
                        });
                        //----
                        Ext.getCmp("qstReportSheet").show();
                        var tle = (charInfo.Title + "").length > 34 ? (charInfo.Title + "").substring(0, 30) + "..." : charInfo.Title;
                        Ext.getCmp("zzt").setTitle("柱状图" + "【" + tle + "】");
                        Ext.getCmp("bzt").setTitle("饼状图" + "【" + tle + "】");
                        setChart(charInfo);
                    });
                }

            });
            //treeStore.expandAll();

            //-----------------------------概要图表------------------------------------

            var chartPanel = new Ext.Panel({
                anchor: '99%',
                height: 400,
                id: "guidSheet",
                border: false,
                autoScroll: true,
                items: [
                {
                    title: '概要图表',
                    //bodyStyle: 'padding:0px 5px 0',
                    html: "<div id='summaryChart' style='display:inline' ></div><div id='summaryChart1' style='display:inline' ></div>"
                }]
            });

            var chart = window.setInterval(function () {
                Ext.getBody().unmask();
                var dom = document.getElementById("summaryChart");
                if (dom) {
                    clearInterval(chart);
                    $.ajaxExec("SummaryChart", {
                        SurveyId: SurveyId,
                        QuestionId: queryConfig.QuestionId,
                        QuestionItemId: queryConfig.QuestionItemId,
                        pType: queryConfig.pType
                    }, function (rtn) {
                        if (rtn.data.SummaryChart.length > 0) {
                            var ChartDt = rtn.data.SummaryChart;
                            summaryChart(ChartDt, "Corp");
                        }
                    })
                }

            }, 50);

            //----------------------------QuestionGrid 问题grid------------------------

            function AdapterData(record) {
                var splitArr = [];
                var splitObj = {
                    NodePID: '',
                    ChildNodePID: '',
                    Corp: '',
                    QuestionId: '',
                    QuestionItemId: ''
                }

                for (var i = 0; i < record.length; i++) {
                    if (record[i]["Corp"] == splitObj["Corp"]) {
                        if (record[i]["QuestionId"] == splitObj["QuestionId"]) { //创建一个孙节点
                            var tmpObj = {
                                ID: record[i]["QuestionItemId"] + Math.random(),
                                ParentID: splitObj["ChildNodePID"],
                                IsLeaf: true,
                                Corp: "",
                                Question: "",
                                hiddenQty: record[i]["Corp"],
                                hiddenQstID: record[i]["QuestionId"],
                                Answer: record[i]["Answer"] + "",
                                JoinCount: "",
                                ItemCount: record[i]["ItemTotal"] + "",
                                QuestionCount: "",
                                CurrRate: record[i]["CurrRate"] + "",
                                TotalRate: record[i]["TotalRate"] + "",
                                TotalCount: ""
                            }
                            splitArr.push(tmpObj)

                        } else {  //问题不同创建一个子节点
                            var tmpObj = {
                                ID: record[i]["QuestionId"] + "|" + Math.random(),
                                ParentID: splitObj["NodePID"],
                                IsLeaf: false,
                                Corp: "",
                                hiddenQty: record[i]["Corp"],
                                Question: record[i]["Content"],
                                Answer: "",
                                JoinCount: "",
                                ItemCount: record[i]["QstTotal"],
                                CurrRate: "100",
                                TotalRate: new Number(parseFloat(parseInt(record[i]["QstTotal"]) / parseInt(record[i]["Total"]) * 100)).toFixed(2),
                                TotalCount: record[i]["Total"]
                            }

                            splitObj.QuestionId = record[i]["QuestionId"];
                            splitObj.ChildNodePID = tmpObj["ID"];

                            splitArr.push(tmpObj)
                            i--;
                        }
                    } else {//公司不同,创建一个根节点
                        var tmpObj = {
                            ID: record[i]["Id"],
                            IsLeaf: false,
                            ParentID: null,
                            Corp: record[i]["Corp"],
                            Question: "",
                            Answer: "",
                            JoinCount: AimState["CorpUsr"][record[i]["Corp"]],
                            ItemCount: "",
                            QuestionCount: "",
                            CurrRate: "",
                            TotalRate: "",
                            TotalCount: ""
                        }
                        splitObj.Corp = record[i]["Corp"];
                        splitObj.NodePID = record[i]["Id"];
                        splitObj.ChildNodePID = "";

                        splitArr.push(tmpObj)
                        i--;
                    }
                }

                return splitArr;
            }

            var qstdata = AimState["QstDetail"] || [];
            qstdata = AdapterData(qstdata);
            //qstdata = testArr;
            qtRecordClns = [
                    { name: 'ID' },
                    { name: 'ParentID' },
                    { name: 'IsLeaf' },
                    { name: 'Corp' },
                    { name: 'Question' },
                    { name: 'hiddenQty' },
                    { name: 'Answer' },
                    { name: 'JoinCount' },
                    { name: 'ItemCount' },
                    { name: 'hiddenQstID' },
                    { name: 'QuestionCount' },
                    { name: 'CurrRate' },
                    { name: 'TotalRate' },
                    { name: 'TotalCount' }
                ]
            qtRecord = Ext.data.Record.create(qtRecordClns);

            qstTreeStore = new Ext.ux.maximgb.tg.AdjacencyListStore({
                autoLoad: true,
                parent_id_field_name: 'ParentID',
                leaf_field_name: 'IsLeaf',
                data: qstdata,
                reader: new Ext.ux.data.AimJsonReader({
                    id: 'ID',
                    dsname: 'QstDetail',
                    aimread: function (rd, resp, dt) { /* dt = AdapterData(dt); */ }
                }, qtRecord),
                proxy: new Ext.ux.data.AimRemotingProxy({
                    aimbeforeload: function (proxy, options) {
                        // var rec = treeStore.getById(options.anode);
                        options.reqaction = "getAllNode";
                        options.data.SurveyId = SurveyId;
                        options.data.GroupType = queryConfig.groupType;
                    }
                })
            });
            //底部工具栏
            bottom = new Ext.ux.AimPanel({
                items: [
                     new Ext.Panel({
                         id: 'mony',
                         border: false,
                         height: 24,
                         html: "<span style='font-size:12px;font-weight:bold; margin-right: 60px; float:right'>合计人数:<span id='money'>" + (AimState["SubmitTol"] || 0) + "</span>&nbsp;人</span>"
                     })]
            });

            var qstColumns = [
                    { id: 'Corp', header: "公司", dataIndex: 'Corp', width: 260, sortable: true },
                    { id: 'Question', header: "题目", dataIndex: 'Question', width: 310 },
                    { id: 'Answer', header: "选项", dataIndex: 'Answer', width: 200 },
                    { id: 'JoinCount', header: "提交人数", dataIndex: 'JoinCount', width: 80, sortable: true },

                    { id: 'ItemCount', header: "选项票数", dataIndex: 'ItemCount', width: 80 },
            //{ id: 'QuestionCount', header: "票数", dataIndex: 'QuestionCount', width: 80 },
                    {id: 'CurrRate', header: "当前比", dataIndex: 'CurrRate', width: 80 },
                    { id: 'TotalRate', header: "总比", dataIndex: 'TotalRate', width: 60 },
                    { id: 'TotalCount', header: "总票数", dataIndex: 'TotalCount', width: 60 }
                    ]

            // 表格面板
            qstTreeGrid = new Ext.ux.maximgb.tg.GridPanel({
                id: 'groupTree',
                title: '【公司】分组统计',
                stripeRows: true,
                store: qstTreeStore,
                viewConfig: { forceFit: true, scrollOffset: 5 },
                border: true,
                master_column_id: 'Corp',
                height: 320,
                anchor: '99%',
                //autoExpandColumn: 'Corp',
                bbar: bottom,
                columns: qstColumns
            });
            qstTreeGrid.on("rowclick", function (Grid, rowIndex, e) {
                var rec = qstTreeStore.getAt(rowIndex);
                var questionId = (rec.get("ID") + "").split("|")[0];
                var corp = rec.get("hiddenQty") || "";
                var QtyType = "Corp";

                if (rec.get("Question")) { //调用

                    $.ajaxExec("GetQstInfo", {
                        SurveyId: SurveyId,
                        QuestionId: questionId,
                        QtyOpt: corp,
                        QstQuestionId: queryConfig.QuestionId,
                        QstQuestionItemId: queryConfig.QuestionItemId,
                        pType: queryConfig.pType,
                        GroupType: queryConfig.groupType
                    }, function (rtn) {
                        var arrDic = rtn.data.QstInfo;
                        if (arrDic.length <= 0) return;

                        var charInfo = {
                            Title: arrDic[0]["Content"],
                            SurveyId: arrDic[0]["QuestionId"],
                            arrContent: [],
                            arrCount: [],
                            arrValue: []
                        }

                        $.each(arrDic, function () {
                            charInfo.arrContent.push(this.Answer);
                            charInfo.arrCount.push(this.Total);
                            var val = new Number(parseFloat(parseFloat(this.Total) / parseFloat(AimState["SubmitTol"] || 0) * 100)).toFixed(2)
                            charInfo.arrValue.push(val);
                        });
                        //----
                        Ext.getCmp("qstReportSheet").show();
                        var tle = (charInfo.Title + "").length > 34 ? (charInfo.Title + "").substring(0, 30) + "..." : charInfo.Title;
                        Ext.getCmp("zzt").setTitle("柱状图" + "【" + tle + "】");
                        Ext.getCmp("bzt").setTitle("饼状图" + "【" + tle + "】");
                        setChart(charInfo);
                    });
                }
                if (rec.get("Corp")) {
                    Ext.getCmp("usrFrame").show();

                    //                                QuestionId: queryConfig.QuestionId,
                    //       QuestionItemId: queryConfig.QuestionItemId,
                    var hiddenBtn = "Corp";
                    var url = "FStaticticsDetailTwo.aspx?SurveyId=" + SurveyId + "&GroupType=" + queryConfig.groupType + " &type=iframe&hiddenBtn=" + hiddenBtn + "&Qty=" + escape(rec.get("Corp") || "");
                    url += "&QuestionId=" + queryConfig.QuestionId;
                    url += "&QuestionItemId=" + queryConfig.QuestionItemId;
                    subFrameContent.location.href = url;
                    //设置滚动条
                    //var scrollTop = $("#bottom").offset().top;
                    //$("html").scrollLeft(scrollTop);
                }

                return;
            });


            //----------------------------ReprotSheet 报表-----------------------------
            var reportPanel = new Ext.Panel({
                id: 'qstReportSheet',
                layout: {
                    type: 'hbox',
                    align: 'stretch'
                },
                anchor: '99%',
                height: 350,
                hidden: true,
                border: false,
                autoScroll: true,
                items: [
                {
                    id: 'zzt',
                    title: '柱状图',
                    autoScroll: true,
                    bodyStyle: 'padding:5px 5px 0',
                    flex: 4,
                    html: "<div id='but1Chg' style=\"display: inline-block; display: inline; width: 50px; height: 25px;\
                           color: Blue; text-decoration: underline; cursor: pointer\
                           border: solid 1 red\">占比</div>\
                           <div id='div2-chart-part1' style='display:none;' ></div><div id='div2-chart-part3'  ></div>"
                }, {
                    id: 'bzt',
                    title: '饼状图',
                    autoScroll: true,
                    bodyStyle: 'padding:5px 5px 0',
                    flex: 3,
                    html: "<div id='div2-chart-part2'></div>"
                }]
            });

            var charInfo = {
                Title: "",
                SurveyId: "",
                arrContent: [],
                arrCount: ["100"],
                arrValue: []
            }
            var chartInterval = window.setInterval(function () {
                var dom = document.getElementById("div2-chart-part1");
                if (dom) {

                    clearInterval(chartInterval);
                    $("#but1Chg").toggle(function () {
                        $(this).html("占比");
                        $("#div2-chart-part3").show();
                        $("#div2-chart-part1").hide();
                    }, function () {
                        $(this).html("票数");
                        $("#div2-chart-part1").show();
                        $("#div2-chart-part3").hide();
                    });
                    setChart(charInfo);
                }

            }, 50);

            //                  var titlePanel = new Ext.Panel({
            //                    frame: true,
            //                    title: title,
            //                     anchor: '99%',
            //                    //layout: 'form',
            //                    border: false,
            //                    cls: 'noborer'
            //                    height: 25,
            //                });

            //----------页面视图--------------------
            viewport = new Ext.ux.AimViewport({
                id: 'viewport',
                items: [{
                    id: "panelSet",
                    region: 'center',
                    title: title,
                    border: false,
                    layout: 'anchor',
                    autoScroll: true,
                    items: [schpanel, treegrid, qstTreeTwoGrid, chartPanel, qstTreeGrid, {
                        title: '人员信息',
                        id: 'usrFrame',
                        region: 'center',
                        hidden: true,
                        border: true,
                        anchor: '99%',
                        height: 400,
                        margins: '0 0 0 0',
                        cls: 'empty',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="subFrameContent" name="subFrameContent" frameborder="0" src=""></iframe><div id="bottom" ></div>'
                    }, reportPanel]
                }]
            });

            //Ext.getBody().unmask();
            $(".x-form-item-label").css({ width: 60 });
            $(".x-box-layout-ct").css({ border: 'none' });
            if (document.getElementById("subFrameContent")) {
                //  //WGM 2013-12-26 优化
                //  var hiddenBtn = "Corp";
                //  var url = "FStaticticsDetailTwo.aspx?SurveyId=" + SurveyId + "&type=iframe&hiddenBtn=" + hiddenBtn;
                //  subFrameContent.location.href = url;
            }
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "Content":
                    if (value) {
                        value = value || "";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                        rtn = value;
                    }
                    break;
                case "Crux":
                    if (value) {
                        if (value == "N") rtn = "否";
                        if (value == "Y") rtn = "是";
                        cellmeta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    }
                    break;
            }
            return rtn;
        }


        //概要图表
        function summaryChart(chartData, type) {
            if (type == "Corp") { //Corp
                $("#summaryChart").hide().children().remove();
                $("#summaryChart1").hide().children().remove();
                //1000 300
                var chartTpl = "<chart yAxisName='人数'  numDivLines='5' animation='0' showYAxisValues='1'  maxLabelWidthPercent='10' yAxisMaxValue='{max}' labelDisplay='ROTATE' canvasLeftMargin='150' numberSuffix='人' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
                var ItemTpl = "<set label='{item}'  value='{val}' />";

                var tempItems = "", TotalCount = 0, valArr = [];
                for (var i = 0; i < chartData.length; i++) {
                    if (i == 0) TotalCount = chartData[0]["Total"];
                    var temp = ItemTpl.replace('{item}', chartData[i]["Corp"]);   //标题
                    temp = temp.replace('{val}', chartData[i]["ItemTotal"]);       //高度值
                    valArr.push(chartData[i]["ItemTotal"])
                    tempItems += temp;
                }

                //------------图形自适应------
                var width = 1000, heigth = 370;
                if (chartData.length > 15) {
                    width += (chartData.length - 15) * 10;
                }
                //------------------------------

                var maxVal = getMaxVal(valArr) + 10;
                var chart = chartTpl.replaceAll('{items}', tempItems).replace("{max}", maxVal);
                var chartdiv2 = new FusionCharts('/FusionChart32/Column3D.swf', '', width, heigth, '0', '1');
                chartdiv2.setXMLData(chart);
                $("#summaryChart").show();
                chartdiv2.render("summaryChart");

            } else if (type == "Sex") {
                $("#summaryChart").hide().children().remove();
                $("#summaryChart1").hide().children().remove();

                var chartTpl = "<chart yAxisName='人数'  numDivLines='5' animation='0' showYAxisValues='1'  maxLabelWidthPercent='10' yAxisMaxValue='{max}' labelDisplay='WRAP' canvasLeftMargin='150' numberSuffix='人' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
                var ItemTpl = "<set label='{item}'  value='{val}' />";

                var tempItems = "";
                for (var i = 0; i < chartData.length; i++) {
                    var temp = ItemTpl.replace('{item}', chartData[i]["Sex"]);     //label标题
                    temp = temp.replace('{val}', chartData[i]["ItemTotal"]);       //高度值
                    tempItems += temp;
                }

                var tempItems1 = "";
                for (var i = 0; i < chartData.length; i++) {
                    var temp = ItemTpl.replace('{item}', chartData[i]["Sex"]);     //label标题
                    var val = parseFloat(chartData[i]["ItemTotal"]) / parseFloat(chartData[i]["Total"]) * 100;
                    temp = temp.replace('{val}', new Number(val).toFixed(2));       //高度值
                    tempItems1 += temp;
                }

                var width = 1000, heigth = 365;
                var chart = chartTpl.replaceAll('{items}', tempItems).replace("{max}", 0);
                var chartdiv2 = new FusionCharts('/FusionChart32/Column3D.swf', '', width, heigth, '0', '1');
                chartdiv2.setXMLData(chart);
                $("#summaryChart").show();
                chartdiv2.render("summaryChart");

                // var chartTpl = "<chart yAxisName='人数'  numDivLines='5' animation='0' showYAxisValues='1'  maxLabelWidthPercent='10' yAxisMaxValue='{max}' numDivLines='0' labelDisplay='ROTATE' canvasLeftMargin='150' numberSuffix='%' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
                // var chart = chartTpl.replaceAll('{items}', tempItems1).replace("{max}", 0);
                // chartdiv = new FusionCharts('/FusionChart32/Pie3D.swf', '', width, heigth, '0', '1');
                // chartdiv.setXMLData(chart);
                // $("#summaryChart1").css({ "margin-left": "20%" }).show();
                // chartdiv.render("summaryChart1");

            } else if (type == "WorkAge") {

                $("#summaryChart").hide().children().remove();
                $("#summaryChart1").hide().children().remove();
                var chartTpl = "<chart yAxisName='人数' animation='0' xAxisName='工龄(年)' numDivLines='5' showYAxisValues='1' maxLabelWidthPercent='10' yAxisMaxValue='{max}'  labelDisplay='WRAP' canvasLeftMargin='150' numberSuffix='人' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
                var ItemTpl = "<set label='{item}'  value='{val}' />";

                var tempItems = "", TotalCount = 0, valArr = [];
                for (var i = 0; i < chartData.length; i++) {
                    if (i == 0) TotalCount = chartData[0]["Total"];
                    var temp = ItemTpl.replace('{item}', chartData[i]["WorkAge"]);   //标题
                    temp = temp.replace('{val}', chartData[i]["ItemTotal"]);       //高度值
                    valArr.push(chartData[i]["ItemTotal"])
                    tempItems += temp;
                }

                //------------图形自适应------
                var width = 1000, heigth = 370;
                if (chartData.length > 15) {
                    width += (chartData.length - 15) * 10;
                }
                //------------------------------

                var maxVal = getMaxVal(valArr) + 10;
                var chart = chartTpl.replaceAll('{items}', tempItems).replace("{max}", maxVal);
                var chartdiv2 = new FusionCharts('/FusionChart32/Column3D.swf', '', width, heigth, '0', '1');
                chartdiv2.setXMLData(chart);
                $("#summaryChart").show();
                chartdiv2.render("summaryChart");

            } else if (type == "AgeSeg") { //年龄段

                $("#summaryChart").hide().children().remove();
                $("#summaryChart1").hide().children().remove();
                var chartTpl = "<chart yAxisName='人数' animation='0' xAxisName='年龄段' showYAxisValues='1' maxLabelWidthPercent='10' yAxisMaxValue='{max}' numdivLines='2' labelDisplay='WRAP' canvasLeftMargin='150' numberSuffix='人' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
                var ItemTpl = "<set label='{item}'  value='{val}' />";

                var tempItems = "", valArr = [];
                for (var i = 0; i < chartData.length; i++) {
                    var temp = ItemTpl.replace('{item}', chartData[i]["Corp"].replace(">", "大于").replace("<", "小于") + "岁");    //标题
                    temp = temp.replace('{val}', chartData[i]["ItemTotal"]);       //高度值
                    tempItems += temp;
                    valArr.push(chartData[i]["ItemTotal"])
                }

                //------------图形自适应------
                var width = 1000, heigth = 370;
                if (chartData.length > 15) {
                    width += (chartData.length - 15) * 10;
                }
                //------------------------------

                var maxVal = getMaxVal(valArr) + 10;
                var chart = chartTpl.replaceAll('{items}', tempItems).replace("{max}", maxVal);

                var chartdiv2 = new FusionCharts('/FusionChart32/Column3D.swf', '', width, heigth, '0', '1');
                chartdiv2.setXMLData(chart);
                $("#summaryChart").show();
                chartdiv2.render("summaryChart");

            }

        }

        //设置Chart
        function setChart(chartInfo) {

            var chartTpl = "<chart yAxisName='百分比' animation='0' subCaption='选项比例统计图' xAxisName='选项' numDivLines='5' showYAxisValues='1'  maxLabelWidthPercent='20' yAxisMaxValue='100' labelDisplay='WRAP' canvasLeftMargin='150' numberSuffix='%' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
            var ItemTpl = "<set label='{item}' value='{val}' />";
            var tempItems = "", TotalCount = 0;
            for (var i = 0; i < chartInfo["arrContent"].length; i++) {
                var temp = ItemTpl.replace('{item}', chartInfo["arrContent"][i]);   //标题
                temp = temp.replace('{val}', chartInfo["arrValue"][i]);           //条形高度值
                // temp = temp.replace('{count}', chartInfo["arrCount"][i] + " 票");           //条形高度值
                TotalCount = (parseInt(chartInfo["arrCount"][i]) > TotalCount) && parseInt(chartInfo["arrCount"][i]);
                tempItems += temp;
            }

            $("#div2-chart-part2,#div2-chart-part1").children().remove();
            //------------图形自适应------
            var width = 550, heigth = 300;
            if (chartInfo["arrContent"].length > 6) {
                width += (chartInfo["arrContent"].length - 6) * 28;
            }
            //------------------------------
            var chart = chartTpl.replaceAll('{items}', tempItems);
            var chartdiv2 = new FusionCharts('/FusionChart32/Pie3D.swf', '', width, heigth, '0', '1');
            chartdiv2.setXMLData(chart);
            chartdiv2.render("div2-chart-part2");

            var chartdiv = new FusionCharts('/FusionChart32/Column3D.swf', '', width, heigth, '0', '1');
            chartdiv.setXMLData(chart);
            chartdiv.render("div2-chart-part1");

            var chartdiv2 = new FusionCharts('/FusionChart32/Pie3D.swf', '', width, heigth, '0', '1');
            chartdiv2.setXMLData(chart);
            chartdiv2.render("div2-chart-part2");
            //-----------------------------------------

            //票数
            chartTpl = "<chart yAxisName='票数' animation='0' subCaption='选项票数统计图' xAxisName='选项' numDivLines='5' showYAxisValues='1'  maxLabelWidthPercent='20' yAxisMaxValue='{max}' labelDisplay='ROTATE' canvasLeftMargin='150' numberSuffix=' 票' outCnvbaseFontSize='12' borderAlpha='100' bgColor='#FFFFFF' formatNumberScale='0' showBorder='0' canvasBorderThickness='1'  canvasBorderColor='#CCCCCC'>{items}<styles><definition><style name='myLabel' type='font' width='100' align='right'/><style name='myCaptionFont' type='font' align='left'/></definition><application><apply toObject='Caption' styles='myCaptionFont' /><apply toObject='DataLabels' styles='myLabel' /></application></styles></chart>";
            chartTpl = chartTpl.replace("{max}", Math.round(TotalCount + 5));

            tempItems = "";
            for (var i = 0; i < chartInfo["arrContent"].length; i++) {
                var temp = ItemTpl.replace('{item}', chartInfo["arrContent"][i]);   //标题
                temp = temp.replace('{val}', chartInfo["arrCount"][i]);           //条形高度值
                TotalCount += parseInt(chartInfo["arrCount"][i]);
                tempItems += temp;
            }

            var chart = chartTpl.replaceAll('{items}', tempItems);
            var chartdiv2 = new FusionCharts('/FusionChart32/Column3D.swf', '', width, heigth, '0', '1');
            chartdiv2.setXMLData(chart);
            chartdiv2.render("div2-chart-part3");
        }

        //页面组件控制
        function complementCtrl(obj) {
            if (obj.pType == "usr") { //人员

                Ext.getCmp("guidSheet").show();
                Ext.getCmp("groupTree").show();
                Ext.getCmp("qstTree").hide();
                Ext.getCmp("qstTreeTwoGrid").hide();
                Ext.getCmp("qstReportSheet").hide();
            }
            if (obj.pType == "qst") {//题模式
                Ext.getCmp("qstTree").show();
                Ext.getCmp("guidSheet").hide();
                Ext.getCmp("groupTree").hide();
                Ext.getCmp("usrFrame").hide();
                Ext.getCmp("qstReportSheet").hide();
            }
        }
        //group CompleteCtrl
        function groupCompleteCtrl() {
            if (queryConfig.pType == "qst") {
                Ext.getCmp("usrFrame").hide();
                Ext.getCmp("qstReportSheet").hide();
            }
            if (queryConfig.pType == "qst") {
                Ext.getCmp("usrFrame").hide();
                Ext.getCmp("qstReportSheet").hide();
            }
        }


        //获取最大值
        function getMaxVal(arr) {
            var val = 0;
            $.each(arr, function () { this > val && (val = this) });
            return val;
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "AnswerItem":
                    rtn = (value + "").length > 500 ? (value.substring(0, 500) + "...") : value;
                    break;
            }
            return rtn;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
