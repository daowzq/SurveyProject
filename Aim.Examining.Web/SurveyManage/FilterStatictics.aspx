<%@ Page Title="筛选统计" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FilterStatictics.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.FilterStatictics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/FusionChart32/FusionCharts.js" type="text/javascript"></script>

    <style type="text/css">
        .col
        {
            background-color: #F1A754;
        }
        .x-grid3-cell-inner .x-grid3-hd-inner
        {
            white-space: normal !important;
        }
        .grid-row-span .x-grid3-row
        {
            border-bottom: 0;
        }
        .grid-row-span .x-grid3-col
        {
            border-bottom: 1px solid gray;
        }
        .grid-row-span .row-span
        {
            border-bottom: 1px solid #fff;
        }
        .grid-row-span .row-span-first
        {
            position: relative;
        }
        .grid-row-span .row-span-first .x-grid3-cell-inner
        {
            position: absolute;
            border-right: 1px solid gray;
        }
        .grid-row-span .row-span-last
        {
            border-bottom: 1px solid gray;
        }
    </style>

    <script type="text/javascript">
        var row = 0;
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;
        var screenType = $.getQueryString({ ID: "screenType" }) || "";
        var SurveyId = $.getQueryString({ ID: "SurveyId" }) || "";
        var Count_choise = $.getQueryString({ ID: "Count" }) || 0;
        var title = $.getQueryString({ ID: "title" }) || "";
        var arrdate = new Array();
        //查询参数
        var QueryParm = {
            year: "",
            sex: "",
            cropId: "",
            detpId: "",
            age: ""
        }
        function onPgLoad() {
//            if (screenType != "allscreen")
//                window.parent.expandPanel(); //展开父面板
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
                fields: [{ name: 'Id' },
                        { name: 'Content' },
                        { name: 'ParentID' },
                        { name: 'IsLeaf' },
                        { name: 'Item' },
                        { name: 'Value' },
                        { name: 'QuestionType' },
                        { name: 'Index' },
                        { name: 'Qty' },
                        { name: 'Scount'}],
                aimbeforeload: function(proxy, options) {
                    options.data = options.data || {};
                    options.data.cropId = QueryParm.cropId;
                    options.data.deptId = QueryParm.detpId;
                    options.data.SurveyId = SurveyId;
                    options.data.year = QueryParm.year;
                    options.data.sex = QueryParm.sex;
                    options.data.age = QueryParm.age;
                    options.data.ation = "query";
                }
            });


            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                region: 'north',
                //margins: '0 0 10 0',
                height: 30,
                items: [{ xtype: 'tbtext',
                    text: '<p style="font-size:12px; ">&nbsp;&nbsp;公司: </p>'
                },
           	    new Ext.ux.form.AimComboBox({
           	        id: 'cropBar',
           	        width: 220,
           	        // enumdata: { "单选项": "单选项", "多选项": "多选项", "填写项": "填写项" },
           	        enumdata: AimState["CropEnum"] || {},
           	        lazyRender: false,
           	        allowBlank: false,
           	        autoLoad: true,
           	        forceSelection: true,
           	        triggerAction: 'all',
           	        mode: 'local',
           	        listeners: {
           	            blur: function(obj) {
           	                if (obj.value) {
           	                    $.ajaxExec("GetDept", { CropId: obj.value, SurveyId: SurveyId }, function(rtn) {
           	                        var deptDic = rtn.data.detpDic;
           	                        var Extcomb = Ext.getCmp("deptBar");

           	                        Extcomb.getStore().removeAll(); //先删除
           	                        var EntRecord = Extcomb.getStore().recordType;
           	                        var frist = new EntRecord({ value: "", text: "请选择..." });
           	                        Extcomb.getStore().insert(Extcomb.getStore().data.length, frist);

           	                        for (var i = 0; i < deptDic.length; i++) {
           	                            var rec = new EntRecord({ value: deptDic[i]["GroupID"], text: deptDic[i]["Name"] });
           	                            Extcomb.getStore().insert(Extcomb.getStore().data.length, rec);
           	                        }
           	                        QueryParm.cropId = obj.value; //公司ID
           	                    });
           	                } else {
           	                    QueryParm.cropId = ""; //公司ID 
           	                }
           	            }
           	        }
           	    }), { xtype: 'tbtext', text: '<p style="font-size:12px; ">&nbsp;&nbsp;部门: </p>' },
           	    new Ext.ux.form.AimComboBox({
           	        width: 180,
           	        id: 'deptBar',
           	        enumdata: {},
           	        lazyRender: false,
           	        allowBlank: false,
           	        autoLoad: true,
           	        forceSelection: true,
           	        triggerAction: 'all',
           	        mode: 'local',
           	        listeners: {
           	            blur: function(obj) {
           	                if (obj.value) {
           	                    QueryParm.detpId = obj.value;
           	                } else {
           	                    QueryParm.detpId = obj.value;
           	                }
           	            }
           	        }
           	    }),
           	    { xtype: 'tbtext', text: '<p style="font-size:12px; ">&nbsp;&nbsp;入职年限: </p>' },
           	    new Ext.ux.form.AimComboBox({
           	        id: 'yeartBar',
           	        width: 100,
           	        enumdata: { "<1": "<1", "1-3": "1-3", "3-5": "3-5", "5-8": "5-8", "5-10": "5-10", ">8": ">8", ">10": ">10" },
           	        lazyRender: false,
           	        allowBlank: false,
           	        autoLoad: true,
           	        forceSelection: true,
           	        triggerAction: 'all',
           	        mode: 'local',
           	        listeners: {
           	            blur: function(obj) {
           	                if (obj.value) {
           	                    QueryParm.year = obj.value;
           	                } else {
           	                    QueryParm.year = obj.value;
           	                }
           	            }
           	        }
           	    }),
           	    { xtype: 'tbtext', text: '<p style="font-size:12px; ">&nbsp;&nbsp;性别: </p>' },
           	    new Ext.ux.form.AimComboBox({
           	        width: 80,
           	        id: 'sextBar',
           	        enumdata: { "男": "男", "女": "女" },
           	        lazyRender: false,
           	        allowBlank: false,
           	        autoLoad: true,
           	        forceSelection: true,
           	        triggerAction: 'all',
           	        mode: 'local',
           	        listeners: {
           	            blur: function(obj) {
           	                if (obj.value) {
           	                    QueryParm.sex = obj.value;
           	                } else {
           	                    QueryParm.sex = obj.value;
           	                }
           	            }
           	        }
           	    }),
           	    { xtype: 'tbtext', text: '<p style="font-size:12px; ">&nbsp;&nbsp;年龄范围: </p>' },
           	    new Ext.ux.form.AimComboBox({
           	        width: 120,
           	        id: 'sltAge',
           	        enumdata: { "<20": "<20", "<30": "<30", "20-30": "20-30", "30-40": "30-40", ">40": ">40", ">50": ">50" },
           	        lazyRender: false,
           	        allowBlank: false,
           	        autoLoad: true,
           	        forceSelection: true,
           	        triggerAction: 'all',
           	        mode: 'local',
           	        listeners: {
           	            blur: function(obj) {
           	                if (obj.value) {
           	                    QueryParm.age = obj.value;
           	                } else {
           	                    QueryParm.age = obj.value;
           	                }
           	            }
           	        }
           	    }), {
           	        text: '查询',
           	        style: { marginLeft: '8px' },
           	        iconCls: 'aim-icon-search',
           	        handler: function() {

           	            //  if (QueryParm.cropId == "" && QueryParm.detpId == "" && QueryParm.year == "" && QueryParm.sex == "") {
           	            //      AimDlg.show("请选择查询条件!");
           	            //      return;
           	            //   }
           	            //store.reload();
           	            $.ajaxExec("QueryData", {
           	                ationType: 'GetCount', SurveyId: SurveyId, cropId: QueryParm.cropId,
           	                deptId: QueryParm.detpId, year: QueryParm.year, sex: QueryParm.sex,
           	                age: QueryParm.age
           	            }, function(rtn) {
           	                var total = rtn.data.Total;
           	                Count_choise = total;
           	                store.reload();
           	            });
           	        }
           	    }, '->',
                    {
                        text: '导出Excel',
                        iconCls: 'aim-icon-xls',
                        handler: function() {
                            ExtGridExportExcel(grid, { store: null, title: '问卷选项统计' });
                        }
}]
            });

            // 表格面板
            grid = new Ext.ux.grid.AimGridPanel({
                store: store,
                region: 'west',
                split: true,
                width: "60%",
                collapsible: true,
                forceFit: true,
                //viewConfig: { forceFit: true, scrollOffset: 0 },
                //autoExpandColumn: 'Content',
                cls: 'grid-row-span',
                columns: [
                 { id: 'Id', header: '编号', dataIndex: 'Id', hidden: true },
                 { id: "Index", header: "序列", dataIndex: 'Index', width: 60 },

                 { id: 'Content', header: "问题", width: 420, dataIndex: 'Content', renderer: renderRow },
                 { id: 'Item', header: "选项", width: 180, dataIndex: 'Item', renderer: RowRender },

                 { id: 'Scount', header: "选择人次", width: 60, dataIndex: 'Scount', renderer: RowRender },
                 { id: 'Value', dataIndex: 'Value', header: '百分率', width: 60, sortable: true }
                 ]

            });

            chartInfo = {
                Title: "",
                SurveyId: SurveyId,
                arrContent: [],
                arrCount: [],
                arrValue: []
            };

            grid.on("afterrender", function(ctrl) {
                var rowIndex = 1;
                var rec = grid.getStore().getAt(rowIndex);
                if ($.isEmptyObject(rec)) return;
                var task = new Ext.util.DelayedTask();

                task.delay(250, function() {
                    chartInfo.Title = rec.get("Content"); //Title

                    if (!rec.data.Item) {
                        var istrue = true;
                        while (istrue) {
                            rowIndex += 1;
                            var thisData = grid.getStore().getAt(rowIndex);
                            if (thisData) {
                                var thisIndex = thisData.data.Index;
                                if (thisIndex.split('_').length != 1) {
                                    //   var tempObj = {
                                    //       content: thisData.get("Item"),
                                    //       count: getValue(thisData.get("Value")),
                                    //       value: thisData.get("Value")
                                    //    }
                                    // chartInfo["arrContent"].push(thisData.get("Item"));
                                    chartInfo["arrCount"].push(getValue(thisData.get("Qty"), thisData.get("Value")));
                                    chartInfo["arrValue"].push(thisData.get("Value"));
                                } else {
                                    istrue = false;
                                }
                            } else {
                                istrue = false;
                            }
                        }
                    }

                    frameContent.location.href = "FilterSatictics_graph.aspx?" + Ext.urlEncode(chartInfo);
                });

            })


            grid.on("rowclick", function(grid, rowIndex, e) {
                chartInfo = {
                    SurveyId: SurveyId,
                    Title: "",
                    arrContent: [],
                    arrCount: [],
                    arrValue: []
                }; //清空

                var rec = grid.getStore().getAt(rowIndex);
                if (rowIndex == 0) return;
                if ($.isEmptyObject(rec)) return;
                if ((rec.get("Index") + "").indexOf("_") > -1) return; //子项

                var task = new Ext.util.DelayedTask();
                task.delay(250, function() {
                    chartInfo.Title = rec.get("Content"); //Title

                    var rec_Index = rec.data.Index;
                    if (!rec.data.Item) {
                        if (rowIndex != 0) {
                            var istrue = true;
                            while (istrue) {
                                rowIndex += 1;
                                var thisData = grid.getStore().getAt(rowIndex);
                                if (thisData) {
                                    var thisIndex = thisData.data.Index;
                                    if (thisIndex.split('_').length != 1) {
                                        // chartInfo["arrContent"].push(thisData.get("Item"));
                                        chartInfo["arrCount"].push(getValue(thisData.get("Qty"), thisData.get("Value")));
                                        chartInfo["arrValue"].push(thisData.get("Value"));
                                    } else {
                                        istrue = false;
                                    }
                                } else {
                                    istrue = false;
                                }
                            }
                        }
                    }
                    frameContent.location.href = "FilterSatictics_graph.aspx?" + Ext.urlEncode(chartInfo);
                });

            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [tlBar, grid, {
                    id: 'detail',
                    title: '&nbsp;',
                    split: true,
                    collapsible: false,
                    collapseDirection: 'right',
                    region: 'center',
                    width: "40%",
                    height: "100%",
                    border: true,
                    draggable: true,
                    autoScroll: true,
                    // html: html
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
                }
 ]
            });

            if (document.getElementById("frameContent")) {
                frameContent.location.href = "FilterSatictics_graph.aspx?Index=0";
            }
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }

        var seq = { "1": "A", "2": "B", "3": "C", "4": "D", "5": "E", "6": "F", "7": "J",
            "8": "H", "9": "I", "10": "G", "11": "K", "12": "L",
            "13": "M", "14": "N", "15": "O", "16": "P", "17": "Q", "18": "R", "19": "S",
            "20": "T", "21": "U", "22": "V", "23": "W", "24": "X", "25": "Y", "26": "Z",
            "27": "ZA", "28": "ZB", "29": "ZC", "30": "ZD", "31": "ZF", "32": "ZG", "33": "ZH", "34": "ZI",
            "35": "ZJ", "36": "ZK", "37": "ZL", "38": "ZM", "39": "ZN", "40": "ZO"
        };
        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {

            var rtn = "";
            switch (this.id) {
                case "Scount":
                    if (rowIndex == 0) {
                        rtn = Count_choise;
                    }
                    else if (record.get("Value")) {
                        var choiseCount = record.get("Qty") || 0;
                        rtn = parseInt(choiseCount) * parseFloat(parseFloat(record.get("Value") || 0) / 100);
                        rtn = Math.round(rtn);
                    }
                    else {
                        rtn = !record.get("Item") ? "" : 0;
                    }
                    break;
                case "Content":
                    break;
                case 'Item':
                    var thisnum = record.get('Index').split('_');
                    if (thisnum.length == 2) {
                        rtn = seq[thisnum[1]] + " " + value;
                    }
                    break;
            }
            return rtn;
        }

        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }

        //合并列
        function renderRow(value, meta, record, rowIndex, colIndex, store) {

            if (value) {
                row = rowIndex;
                if (rowIndex == 0) {
                    return rtn = "<b>" + unescape(title) + "_[" + value + "]" + "</b>";
                } else {
                    meta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
                    rtn = value + (record.get("QuestionType") ? " 【" + record.get("QuestionType") + "】" : "");
                }
            }

            if (rowIndex != 0) {
                // if (value) {
                //  var first = !rowIndex || value !== store.getAt(rowIndex - 1).get('Content'), last = rowIndex >= store.getCount() - 1 || value !== store.getAt(rowIndex + 1).get('Content');
                var first = !rowIndex || value != null, last = rowIndex >= store.getCount() - 1 || value != null;
                meta.css += 'row-span' + (first ? ' row-span-first' : '') + (last ? ' row-span-last' : '');
                if (first) {
                    var i = rowIndex + 1;
                    while (i < store.getCount() && (store.getAt(i).get('Content') == null || store.getAt(i).get('Content').length == 0)) {
                        i++;
                    }
                    var rowHeight = 25, padding = 3, height = (rowHeight * (i - rowIndex) - padding) + 'px';
                    //  meta.attr = 'style="height:' + height + ';line-height:' + height + ';"';
                    meta.attr = 'style="height:' + height + ';"';
                }

            }
            //            if (value) {
            //                meta.attr = 'ext:qtitle =""' + ' ext:qtip ="' + value + '"';
            //            }
            return first ? '<b>' + value + (record.get("QuestionType") ? " 【" + record.get("QuestionType") + "】" : "") + '</b>' : '';

        }

        //
        function getValue(Qty, rate) {
            var choiseCount = Qty || 0;
            rtn = parseInt(choiseCount) * parseFloat(parseFloat(rate || 0) / 100);
            rtn = Math.round(rtn);
            return rtn;
        }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
