
//------------------------Aim Grid控件（对JqGrid的包装）开始------------------------//

(function() {
    function AimGrid(htmlele) {
        if (!$.jgrid) {
            throw "请先导入JqGrid库";
        }

        var id = htmlele.id;
        var htmlele = htmlele;
        var grid = $(htmlele);
        var gridbox = null;

        var tolpanel = null;
        var hdpanel = null;
        var dtoptions = {};
        var options = {};
        var treeoptions = {};
        var columns = [];

        var pgpanel = null;
        var pgoptions = {};
        var pgcommands = [];

        var isgridloaded = false;   // 是否网格已加载, ensureData区分是否第一次加载
        var cursubmitoptions = null;    // 当前提交选项

        var data = {};
        var loader = null;
        var loadingIndicator = null;   // 异步加载蒙板

        // events
        var onDataLoading = new Aim.EventHelper();
        var onDataLoaded = new Aim.EventHelper();
        var onProcessException = new Aim.EventHelper();
        var onInitializing = new Aim.EventHelper();
        var onInitialized = new Aim.EventHelper();
        var onRendering = new Aim.EventHelper();
        var onRendered = new Aim.EventHelper();

        var orgRowNum = 0;  // 原始单页行数

        init();
        render();

        function init() {
            var evtoptstr = (grid.children("evt") || {}).attr("val");
            var evtoptions = $.getJsonObj(evtoptstr) || {};
            if (typeof (evtoptions["onInitializing"]) == "function") { onInitializing.subscribe(evtoptions["onInitializing"]); }
            if (typeof (evtoptions["onInitialized"]) == "function") { onInitialized.subscribe(evtoptions["onInitialized"]); }
            if (typeof (evtoptions["onRendering"]) == "function") { onRendering.subscribe(evtoptions["onRendering"]); }
            if (typeof (evtoptions["onRendered"]) == "function") { onRendered.subscribe(evtoptions["onRendered"]); }
            if (typeof (evtoptions["dataLoading"]) == "function") { onDataLoading.subscribe(evtoptions["dataLoading"]); }
            if (typeof (evtoptions["dataLoaded"]) == "function") { onDataLoading.subscribe(evtoptions["dataLoaded"]); }

            var optstr = (grid.children("opts") || {}).attr("val");
            options = $.getJsonObj(optstr) || options;

            var dtoptstr = (grid.children("data") || {}).attr("val");
            dtoptions = $.getJsonObj(dtoptstr) || dtoptions;

            var treeoptstr = (grid.children("tree") || {}).attr("val");
            treeoptions = $.getJsonObj(treeoptstr) || treeoptions;

            onInitializing.notify({ options: options, dtoptions: dtoptions, data: data, grid: grid });

            loadingIndicator = new Aim.LoadingIndicator(htmlele);
            loader = new Aim.Data.RemoteModel(dtoptions);

            //options["autowidth"] = !(options["autowidth"] == false);
            options["datatype"] = options["datatype"] || "jsonstring";
            options["dynautowidth"] = !(options["dynautowidth"] == false);
            options["dynautoheight"] = !(options["dynautoheight"] == false);
            options["autoheight"] = !(options["autoheight"] == false);
            options["autowidth"] = !(options["autowidth"] == false);
            options["viewrecords"] = !(options["viewrecords"] == false);
            options["altRows"] = !(options["altRows"] == false);
            options["rowList"] = options["rowList"] || [10, 20, 50];
            options["toolbar"] = options["toolbar"] || [true, "top"];
            options["tolPanelHeight"] = options["tolPanelHeight"] || 30;
            options["onPaging"] = options["onPaging"] || onPaging;
            options["onSortCol"] = options["onSortCol"] || onSortCol;

            options["height"] = options["height"] || "350";
            options["width"] = options["width"] || "500";
            var colMods = [];   // 列表模型
            var colNames = [];  // 列表名

            grid.children("add").each(function(i) {
                columns[i] = $.getJsonObj($(this).attr("val")) || {};
                colNames[i] = columns[i]["title"] || " ";
                if (columns[i]["dtenum"]) {
                    columns[i]["formatter"] = AimGridEnumFormatter;
                }

                // 若为treeGrid, 则sortable默认为flase;
                if (treeoptions["treeGrid"]) {
                    columns[i]["sortable"] = (columns[i]["sortable"] == true);
                }
            });

            options["colNames"] = options["colNames"] || colNames;
            options["colModel"] = options["colModel"] || columns;

            dtoptions["async"] = !(dtoptions["async"] == false);
            dtoptions["qrycrit"] = AimSearchCrit || dtoptions["qrycrit"];
            dtoptions["idfield"] = dtoptions["idfield"];
            data = AimState[dtoptions["dsname"]] || [];

            treeoptions["treeGridModel"] = treeoptions["treeGridModel"] || "adjacency";

            onInitialized.notify({ options: options, dtoptions: dtoptions, data: data, grid: grid });

            options = $.mergeJson(options, treeoptions); // 融合选项

            resetQryCrit(dtoptions["qrycrit"]); // 重设查询规则

            // 重设数据
            if (!dtoptions["async"]) { resetData(data); }

            pgpanel = $(options["pager"]);
            pgoptions = $.getJsonObj(pgpanel.children("opts").attr("val")) || {}
            pgpanel.children("cmd").each(function(i) {
                pgcommands[i] = $.getJsonObj($(this).attr("val"));
            });

            hdpanel = $(options["header"]);
            tolpanel = $(options["tolpanel"]);
        }

        function render() {
            onRendering.notify({ options: options, dtoptions: dtoptions, data: data, grid: grid });

            loader.onDataLoading.subscribe(function() {
                onDataLoading.notify(options);

                loadingIndicator.show();
            });

            loader.onDataLoaded.subscribe(function(req) {
                resetQryCrit(req["data"]["SearchCriterion"]);

                if (!isgridloaded) {
                    resetData(req["data"][dtoptions["dsname"]]);

                    // 初始化JqGrid
                    renderGrid(options);
                } else {
                    if (req["data"]) {
                        if (req["data"]["__EXCEPTION"]) {
                            onProcessException.notify(req);
                        } else if (req["data"][dtoptions["dsname"]]) {
                            data = req["data"][dtoptions["dsname"]];

                            refreshData(data);
                        }

                        dtoptions["qrycrit"] = req.data["SearchCriterion"] || dtoptions["qrycrit"];
                        grid.setGridParam({ records: dtoptions["qrycrit"]["RecordCount"], page: dtoptions["qrycrit"]["CurrentPageIndex"] });
                        grid.updatePager(true, true);

                        onDataLoaded.notify(req);
                    }
                }

                loadingIndicator.hide();
            });

            loader.onProcessException.subscribe(function(args) {
                if (args && args["data"] && args["data"]["__EXCEPTION"]) {
                    AimDlg.show(dt["__EXCEPTION"]["Content"], "异常", "alert");
                }

                loadingIndicator.hide();
            });

            if (dtoptions["async"]) {
                loader.ensureData(dtoptions);
            } else {
                renderGrid(options);
            }

            onRendered.notify({ options: options, dtoptions: dtoptions, data: data, grid: grid });
        }

        function renderGrid(opts) {
            opts = opts || options;

            grid.jqGrid(options);
            gridbox = $("#gbox_" + id);

            isgridloaded = true;

            // 初始化pager
            if (options["pager"]) {
                grid.jqGrid('navGrid', options["pager"], pgoptions);
                $.each(pgcommands, function(i) {
                    grid.jqGrid('navButtonAdd', ('#' + id), this);
                });
            }

            // 设置工具栏
            tolpanel.appendTo($("#t_" + id));
            $("#t_" + id).height(options["tolPanelHeight"]);

            // 设置标题栏
            hdpanel.appendTo(gridbox.find(".ui-jqgrid-titlebar"));

            // 显示过滤查询栏
            if (options["showfilter"]) {
                grid.jqGrid('filterToolbar');
            }

            // 调整列表宽度
            /*if (options["dynautowidth"]) {
                grid.setGridWidth(document.documentElement.clientWidth - 10);

                $(window).bind("resize", {}, function(e) {
                    grid.setGridWidth(document.documentElement.clientWidth - 10);
                });
            }

            // 调整列表高度
            if (options["dynautoheight"]) {
                grid.setGridHeight(document.documentElement.clientHeight - 120);

                $(window).bind("resize", {}, function(e) {
                    grid.setGridHeight(document.documentElement.clientHeight - 120);
                });
            }*/
        }

        // 翻页
        function onPaging() {
            dtoptions["qrycrit"]["CurrentPageIndex"] = grid.getGridParam("page");
            dtoptions["qrycrit"]["PageSize"] = grid.getGridParam("rowNum");
            doQuery();

            orgRowNum = grid.getGridParam("rowNum");
        }

        // 排序
        function onSortCol(index, colindex, sortorder) {
            var orders = dtoptions["qrycrit"]["Orders"] || [];
            if (orders.length <= 0 || orders[0]["PropertyName"] != index) {
                dtoptions["qrycrit"]["Orders"] = [{ "PropertyName": index, "Ascending": (sortorder == "asc")}];
            } else {
                dtoptions["qrycrit"]["Orders"] = [{ "PropertyName": index, "Ascending": !orders[0]["Ascending"]}];
            }

            doQuery();

            return false;
        }

        // 查询
        function query(schCrit, ftschCrit) {
            dtoptions["qrycrit"]["CurrentPageIndex"] = 1;
            dtoptions["qrycrit"]["Searches"] = schCrit || dtoptions["qrycrit"]["Searches"] || [];
            dtoptions["qrycrit"]["FTSearches"] = ftschCrit || dtoptions["qrycrit"]["FTSearches"] || [];

            doQuery();
        }

        function doQuery() {
            if (dtoptions["async"]) {
                delete (dtoptions["rows"]);
                loader.ensureData(dtoptions);
            } else {
                var qrycritstr = $.getJsonString(dtoptions["qrycrit"]);
                location.href = $.getQueryUrl() + "?SearchCriterion=" + qrycritstr;
            }
        }

        // 刷新数据
        function refreshData(dt) {
            data = dt || data;

            grid.clearGridData(false, true);

            $.each(data, function(i) {
                var rid = getRowID(this, i);
                grid.jqGrid('addRowData', rid, this, null, null, true);
            });

            grid.setGridParam({ records: data["records"] });
        }

        function resetQryCrit(crit) {
            dtoptions["qrycrit"] = crit || dtoptions["qrycrit"];

            // 重设rowNum
            orgRowNum = options["rowNum"] = options["rowNum"] || dtoptions["qrycrit"]["PageSize"] || 20;
            if ($.inArray(options["rowNum"], options["rowList"]) < 0) {
                options["rowList"][options["rowList"].length] = options["rowNum"];
                options["rowList"] = options["rowList"].sort();
            }

            // 重设data
            dtoptions["page"] = dtoptions["page"] || dtoptions["qrycrit"]["CurrentPageIndex"] || 1;
            dtoptions["total"] = dtoptions["qrycrit"]["PageCount"];
            dtoptions["records"] = dtoptions["qrycrit"]["RecordCount"];
        }

        function resetData(dt) {
            data = dt || data;
            var dtrows = [];

            $.each(data, function(i) {
                dtrows[dtrows.length] = formatGridRowData(this, i);
            });

            dtoptions["rows"] = dtrows;
            options["datastr"] = dtoptions;
        }

        // 格式化表格数据
        function formatGridRowData(dtitem, i) {
            var tdt = {};
            tdt["id"] = getRowID(dtitem, i);

            var tdtcell = [];

            $.each(options["colModel"], function(j) {
                tdtcell[tdtcell.length] = dtitem[this["name"]];
            });

            if (treeoptions["treeGrid"]) {
                var trReader = treeoptions["treeReader"] || {};
                var lvlfld = trReader["level_field"] || "level";
                var pidfld = trReader["parent_id_field"] || "parent";
                var lffld = trReader["leaf_field"] || "isLeaf";
                var expfld = trReader["expanded_field"] || "expanded";

                tdtcell[tdtcell.length] = dtitem[lvlfld];
                tdtcell[tdtcell.length] = dtitem[pidfld];
                tdtcell[tdtcell.length] = dtitem[lffld];

                if ($.isSetted(dtitem[expfld])) {
                    tdtcell[tdtcell.length] = dtitem[expfld];
                } else if ($.isSetted(treeoptions["expanded"])) {
                    tdtcell[tdtcell.length] = treeoptions["expanded"];
                }
            }

            tdt["cell"] = tdtcell;

            return tdt;
        }

        function getRowID(dtitem, i) {
            return !dtoptions["idfield"] ? i : dtitem[dtoptions["idfield"]];
        }

        // 添加数据
        function newGridRow(opt) {
            opt = procRowOption(opt, "new");

            grid.jqGrid('editGridRow', "new", opt);
        }

        // 编辑数据
        function editGridRow(opt) {
            opt = procRowOption(opt, "edit");

            var gr = grid.jqGrid('getGridParam', 'selrow');

            if (gr == null) {
                if (opt["eptmsg"]) {
                    AimDlg.show(opt["eptmsg"]);
                } else {
                    AimDlg.show("请选择要编辑的记录!");
                }
            } else {
                grid.jqGrid('editGridRow', gr, opt);
            }
        }

        // 编辑数据
        function delGridRow(opt) {
            opt = procRowOption(opt, "delete");

            var gr = grid.jqGrid('getGridParam', 'selrow');
            if (gr == null) {
                if (opt["eptmsg"]) {
                    AimDlg.show(opt["eptmsg"]);
                } else {
                    AimDlg.show("请选择要删除的记录!");
                }
            } else {
                grid.jqGrid('delGridRow', gr, opt);
            }
        }

        // 预处理行选项
        function procRowOption(opt, act) {
            cursubmitoptions = opt;
            cursubmitoptions["reqaction"] = act;   // 保存当前操作选项

            act = act || "default";
            opt = opt || {};

            opt["url"] = $.formatQueryUrl(opt["url"] || options["editurl"]);
            opt["cusReloadAfterSubmit"] = !(opt["reloadAfterSubmit"] == false);
            opt["reloadAfterSubmit"] = false;
            opt["closeAfterAdd"] = !(opt["reloadAfterSubmit"] == false);
            opt["closeAfterEdit"] = !(opt["closeAfterEdit"] == false);
            opt["cusBeforeSubmit"] = opt["beforeSubmit"];   // 保存beforeSubmit
            opt["beforeSubmit"] = befGridSubmit;
            opt["cusAfterComplete"] = opt["afterComplete"];   // 保存beforeSubmit
            opt["afterComplete"] = aftGridSubmitComplete;

            var action = "Default";
            switch (act) {
                case "new":
                    action = "Insert";
                    break;
                case "edit":
                    action = "Update";
                    break;
                case "delete":
                    action = "Delete";
                    break;
            }

            opt["url"] = $.combineQueryUrl(opt["url"], ("reqaction=" + action));

            return opt;
        }

        // 表单操作提交前触发方法
        function befGridSubmit(ptdata) {
            var contflag = true;    // 继续标识
            var gr = grid.jqGrid('getGridParam', 'selrow');

            if (typeof (cursubmitoptions["cusBeforeSubmit"]) == "function") {
                contflag = cursubmitoptions["cusBeforeSubmit"].call(this, ptdata, gr);
            }

            if (!(contflag == false)) {
                if (cursubmitoptions && cursubmitoptions["reqaction"] == "delete") {
                    if ($.isSetted(gr)) {
                        var rd = grid.jqGrid('getRowData', gr);
                        for (var key in rd) {
                            if (rd[key]) {
                                rd[key] = encodeURI(rd[key]);
                            }
                        }

                        ptdata["frmdata"] = $.getJsonString(rd);
                        return [true, "", ""];
                    } else {
                        return [false, "没有找到要删除的行", ""];
                    }
                } else {
                    var pkdata = $.cloneObj(ptdata);
                    delete (pkdata[id + "_id"]);

                    for (var key in ptdata) {
                        delete (ptdata[key]);
                    }

                    ptdata["frmdata"] = $.getJsonString(pkdata);

                    return [true, "", ""];
                }
            } else {
                return [true, "", ""];
            }
        }

        // 表单操作完全结束后触发
        function aftGridSubmitComplete(copydata, postdata, frmmgr) {
            var contflag = true;    // 继续标识
            var gr = grid.jqGrid('getGridParam', 'selrow');

            if (typeof (cursubmitoptions["cusAfterComplete"]) == "function") {
                contflag = cursubmitoptions["cusAfterComplete"].call(this, ptdata, gr);
            }

            if (!(contflag == false)) {
                if (cursubmitoptions["cusReloadAfterSubmit"]) {
                    onPaging();
                }
            }
        }

        // Public API
        $.extend(this, {
            // Properties
            "grid": grid,
            "gridbox": gridbox,
            "tolpanel": tolpanel,

            // Methods
            "query": query,
            "resetData": resetData,
            "newGridRow": newGridRow,
            "editGridRow": editGridRow,
            "delGridRow": delGridRow,

            // Events
            "onDataLoading": onDataLoading,
            "onProcessException": onProcessException,
            "onDataLoaded": onDataLoaded
        });
    }

    // Aim.Form
    $.extend(true, window, { Aim: { Grid: AimGrid} });

} ());

(function() {
    function AimTree(htmlele) {
        if (!$.tree) {
            throw "请先导入JsTree库";
        }

        var id = htmlele.id;
        var htmlele = htmlele;
        var tree = $(htmlele);

        var data = {};
        var loader = null;

        init();
        render();

        function init() {
            var evtoptstr = (grid.children("evt") || {}).attr("val");
            var evtoptions = $.getJsonObj(evtoptstr) || {};

            var optstr = (grid.children("opts") || {}).attr("val");
            options = $.getJsonObj(optstr) || options;

            var dtoptstr = (grid.children("data") || {}).attr("val");
            dtoptions = $.getJsonObj(dtoptstr) || dtoptions;
        }

        function render() {
        }

        // Public API
        $.extend(this, {
            // Properties
            "tree": tree
        });
    }

    // Aim.Form
    $.extend(true, window, { Aim: { Tree: AimTree} });

} ());

// 枚举格式化
AimGridEnumFormatter = function(el, val, opts) {
    var dtenumstr = val.colModel["dtenum"];
    return formatAimEnum(el, dtenumstr) || " ";
}


//------------------------Aim Grid控件（对JqGrid的包装）结束------------------------//

