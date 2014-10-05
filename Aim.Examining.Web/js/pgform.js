
//------------------------Aim 参数 开始------------------------//

var DEFAULT_EDIT_WIN_STYLE = CenterWin("width=650,height=600,scrollbars=yes");

var FIELD_REQUIRED_CLSNAME = "aim-ui-required";
var FIELD_REQUIRED_BGCOLOR = "#FEFFBB";

var UPLOAD_PAGE_URL = "../CommonPages/File/Upload.aspx";

var DOWNLOAD_PAGE_URL = "../CommonPages/File/DownLoad.aspx";
var DOWNLOAD_Sign_URL = "../CommonPages/File/DownLoadSign.aspx";
var IMPORT_PAGE_URL = "../CommonPages/Data/DataImport.aspx";
var FLOT_CHART_PAGE_URL = "../CommonPages/Chart/FlotChart.aspx";

var USER_SELECT_URL = "../CommonPages/Select/UsrSelect/MUsrSelect.aspx";
var SHARED_ICON_BASEPATH = "../images/shared/"
//var FCK_EDITOR_BASEPATH = "fckeditor/"
var FCK_EDITOR_BASEPATH = "/js/fckeditor/";
//------------------------Aim 参数 结束------------------------//

//------------------------Aim 公共方法 开始------------------------//

/**<doc type="function" name="Global.OpenModelWin">
<desc>打开模态窗口</desc>
<input>
<param name="params">参数</param>
<param name="onProcessFinish" type="function">数据导入完成后执行方法</param>
</input>
</doc>**/
function OpenModelWin(url, params, style, onProcessFinish) {
    var ModelStyle = "dialogWidth:750px; dialogHeight:550px; scroll:yes; center:yes; status:no; resizable:yes;";

    params.rtntype = params.rtntype || "array";
    style = style || ModelStyle;
    url = $.combineQueryUrl(url, params);

    rtn = window.showModalDialog(url, window, style);

    if (rtn) {
        if (typeof (onProcessFinish) == "function") {
            onProcessFinish.call(rtn, params);
        }
    }
}

/**<doc type="function" name="Global.OpenUploadWin">
<desc>打开模态文件上传窗口</desc>
<input>
<param name="params">参数</param>
<param name="style">样式</param>
<param name="onProcessFinish" type="function">数据导入完成后执行方法</param>
</input>
</doc>**/
function OpenUploadWin(params, onProcessFinish) {
    var url = UPLOAD_PAGE_URL;
    var style = style || "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;"; // 上传文件页面弹出样式
    if (params) {
        url = $.combineQueryUrl(url, params);
    }

    OpenModelWin(url, {}, style, onProcessFinish);
}

/**<doc type="function" name="Global.OpenChartWin">
<desc>打开图表页面</desc>
<input>
<param name="gdata" type="object">图表数据</param>
</input>
</doc>**/
function OpenChartWin(gdata, config) {
    config = config || {};
    var target = config.target || "_blank";
    var style = config.style || CenterWin("width=650,height=600,scrollbars=yes");
    var url = config.url || FLOT_CHART_PAGE_URL;
    var listeners = config.listeners || {};

    var win = OpenWin(url, target, style);

    $.execOnWinReady(win, function() {
        if (win.loadChart) {
            win.loadChart.call(this, gdata, config);
        }
    });
}

/**<doc type="function" name="Global.DownloadTemplate">
<desc>打开模板下载页面</desc>
<input>
<param name="code" type="string">模版编码</param>
<param name="type" type="function">模板类型</param>
</input>
</doc>**/
function DownloadTemplate(code, type) {
    type = type || "import";
    if (code) {
        $.ajaxExec('gettmplid', { code: code }, function(args) {
            if (args.status == 'success') {
                //args.data.id
                var url = $.combineQueryUrl(DOWNLOAD_PAGE_URL, "id=" + args.data.id);
                OpenWin(url);
            }
        }, null, IMPORT_PAGE_URL);
    }
}

/**<doc type="function" name="Global.OpenImportWin">
<desc>打开数据导入页面</desc>
<input>
<param name="code" type="string">数据模版编码</param>
<param name="onProcessFinish" type="function">数据导入完成后执行方法</param>
</input>
</doc>**/
function OpenImportWin(code, onProcessFinish) {
    style = CenterWin("width=650,height=220,scrollbars=yes");
    var ImportPageUrl = IMPORT_PAGE_URL + "?code=" + code;

    win = OpenWin(ImportPageUrl, "_blank", style);

    if (typeof (onProcessFinish) == "function") {
        win.onProcessFinish = onProcessFinish;
    }
}

/**<doc type="function" name="Global.OpenImportWin">
<desc>打开人员选择页面</desc>
<input>
<param name="params">参数</param>
<param name="onProcessFinish" type="function">数据导入完成后执行方法</param>
</input>
</doc>**/
function OpenUserWin(params, onProcessFinish) {
    var MultiStyle = "dialogWidth:750px; dialogHeight:550px; scroll:yes; center:yes; status:no; resizable:yes;";
    var SingleStyle = "dialogWidth:450px; dialogHeight:450px";

    var style = MultiStyle;

    if (params.seltype == "single") {
        style = SingleStyle;
    } else {
        style = MultiStyle;
    }
    params.rtntype = params.rtntype || "array";

    OpenModelWin(USER_SELECT_URL, params, style, onProcessFinish);
}

/**<doc type="function" name="Global.OpenWin">
<desc>链接到一个应用系统的一个页面</desc>
<input>
<param name="url" type="string">链接的目标地址，相对地址</param>
<param name="target" type="empty/object/string">链接到的目标窗口,可以是本窗口、Frame、IFrame或是新窗口</param>
<param name="style"  type="empty/string">新窗口的样式</param>
</input>
</doc>**/
function OpenWin(url, target, style) {
    var desurl = url;
    var win = null;
    if (desurl == null || desurl == "") {
        return false;
    }
    if (desurl.indexOf("{") != -1) {
        var param = returnUrl.substring(desurl.indexOf("{") + 1, desurl.indexOf("}"));
        var value = AppServer[param];
        desurl = desurl.replace("{" + param + "}", value);
    }
    try { var target = eval(target); } catch (e) { }
    if (!target || target == "null") {
        window.location.href = desurl;
    } else if (typeof (target) == "object") {
        target.location.href = desurl;
        win = target;
    } else if (typeof (target) == "string") {
        if (!style) style = "compact";
        else {
            if (style.indexOf('resizable') < 0) {
                style += ",resizable=yes";
            }
        }
        if (target == "")
            target = "_SELF";
        if (target.toUpperCase() == "_BLANK") {
            win = window.open(desurl, "", style);
        }
        else {
            win = window.open(desurl, target, style);
        }
        if (!win) alert("弹出窗口被阻止！");
        //}		
        //win = window.open(desurl,target,style);
    }
    if (win) return win;
}

/**<doc type="function" name="Global.CenterWin">
<desc>得到居中样式字符串</desc>
<input>
<param name="linkStyle"  type="string">连接样式</param>
<param name="isDialog"  type="bool">是否为对话框</param>
</input>
</doc>**/
function CenterWin(linkStyle, isDialog) {
    if (!linkStyle) return "";
    if (isDialog)
        var sp = new StringParam(linkStyle.toLowerCase());
    else
        var sp = new StringParam(linkStyle.toLowerCase(), ",", "=");
    if (sp.Get("left") || sp.Get("top")) {
        return linkStyle;
    }
    else {
        var widthC = sp.Get("width").replace("px", "");
        if (widthC == null)
            widthC = window.screen.width / 2;
        else
            sp.Remove("width");
        var heightC = sp.Get("height").replace("px", "");
        if (heightC == null)
            heightC = window.screen.height / 2;
        else
            sp.Remove("height");
        var left = (window.screen.width - widthC) / 2;
        var top = (window.screen.height - heightC) / 2 - 30;
        return "left=" + left + ",top=" + top + ",width=" + widthC + ",height=" + heightC + "," + sp.ToString();
        // alert("left=" + left + ",top=" + top + ",width=" + widthC + ",height=" + heightC + "," + sp.ToString());
    }
}

//动态引用JsCss
function LoadJsCssFile(filename, filetype) {
    var fileref;

    if (filetype == "js") { // js文件
        fileref = '<script type="text/javascript" src="' + filename + '">'
    }
    else if (filetype == "css") { // 样式文件
        fileref = '<link rel="stylesheet" type="text/css" href="' + filename + '" />'
    }

    if (typeof fileref != "undefined") {
        $(filer).appendTo('head');
    }
}

//------------------------Aim 公共方法 结束------------------------//


//------------------------Aim 事件 开始------------------------//

(function() {
    /***
    * A simple observer pattern implementation.
    */
    function AimEventHelper() {
        this.handlers = [];

        this.subscribe = function(fn) {
            var hdls = this.handlers;
            $.each(hdls, function(i) {
                if (hdls[i] == fn) {
                    return;
                }
            });

            this.handlers.push(fn);
        };

        this.notify = function(args) {
            for (var i = 0; i < this.handlers.length; i++) {
                this.handlers[i].call(this, args);
            }
        };

        this.hasHandler = function() {
            return (this.handlers && this.handlers.length > 0);
        }

        return this;
    }

    // Slick.Data.RemoteModel
    $.extend(true, window, { Aim: { EventHelper: AimEventHelper} });

} ());

//------------------------Aim 事件 结束------------------------//

//------------------------Aim 数据加载框 开始------------------------//

(function() {
    function AimLoadingIndicator(htmele) {
        var DLG_TMPL = "<span class='loading-indicator' style='display:none; color:white; z-index:10000' align='center'><div class='loading-indicator-text'><nobr>加载中...</nobr></div></span>)";
        var loadingIndicator = null;
        var htmlele = htmlele || document.body;

        init();

        function init() {
            if (!loadingIndicator) {
                loadingIndicator = $(DLG_TMPL).appendTo(document.body);
            }
        }

        function show(loadhtml) {
            var $g = $(htmlele);

            loadingIndicator
						.css("position", "absolute")
            //.css("top", $g.position().top + $g.height() / 2 - loadingIndicator.height() / 2)
            //.css("left", $g.position().left + $g.width() / 2 - loadingIndicator.width() / 2)
						.css("top", 0)
						.css("left", 0)
						.css("width", $g.width())
						.css("height", $g.height())
						.css("opacity", 0.6);

            var ldtext = loadingIndicator.find(".loading-indicator-text");
            ldtext.css("padding", $g.position().top + $g.height() / 2 - ldtext.height() / 2);

            if (loadhtml) { ldtext.html(loadhtml); }

            loadingIndicator.show();
        }

        function hide() {
            loadingIndicator.fadeOut();
        }

        // Public API
        $.extend(this, {
            // Properties
            "html": loadingIndicator,

            // Methods
            "show": show,   // 显示
            "hide": hide
        });

    }

    // Aim.LoadingIndicator
    $.extend(true, window, { Aim: { LoadingIndicator: AimLoadingIndicator} });
} ());

//------------------------Aim 数据加载框 结束------------------------//

//------------------------Aim 数据加载模型 开始------------------------//

(function() {
    /***
    * A sample AJAX data store implementation.
    * Right now, it's hooked up to load all Apple-related Digg stories, but can
    * easily be extended to support and JSONP-compatible backend that accepts paging parameters.
    */
    function RemoteModel(opts) {
        var options = opts || {}; // 查询选项
        var data = { length: 0 };
        var h_request = null;
        var req = null; // ajax request
        var req_page;
        var stopped = false;
        var loadingIndicator = null;   // 异步加载蒙板

        // events
        var onDataLoading = new Aim.EventHelper();
        var onDataLoaded = new Aim.EventHelper();
        var onError = new Aim.EventHelper();
        var onProcessException = new Aim.EventHelper();

        var maskmsg = options["maskmsg"] || null;

        function init() {
            if (maskmsg) {
                if (typeof (maskmsg != "string")) {
                    maskmsg = "加载中...";
                }

                if (typeof (Ext) == 'object' && Ext.LoadMask) {
                    loadingIndicator = new Ext.LoadMask(document.body, { msg: maskmsg });
                } else {
                    loadingIndicator = new Aim.LoadingIndicator();
                }
            }
        }

        function isDataLoaded(from, to) {
            return true;
        }

        function clear() {
            for (var key in data) {
                delete data[key];
            }
            data.length = 0;
        }

        function ensureData(opts) {
            opts = opts || options || {};

            var postType = opts["posttype"] || 'POST';

            options = opts;
            if (req) { req.abort(); }
            var url = opts["url"] || $.getQueryUrl();
            url = url.trimEnd("#").replace(/#\?/g, "?");
            opts["asyncreq"] = true;
            var dt = opts["data"] || {};
            var qrycrit = opts["qrycrit"] || dt["qrycrit"] || {};

            var postdata = { "asyncreq": true };
            postdata["SearchCriterion"] = $.getJsonString(qrycrit);
            if ($.isSetted(opts["reqaction"])) { postdata["reqaction"] = opts["reqaction"]; }

            if (!opts["frmdata"] && dt["frmdata"]) {
                var frmdata = dt["frmdata"];
                delete (dt["frmdata"]);
            } else {
                var frmdata = opts["frmdata"];
            }

            if (typeof (frmdata) == "string") {
                postdata["frmdata"] = frmdata;
            } else if (typeof (frmdata) == "object") {
                postdata["frmdata"] = $.getJsonString(frmdata, true);
            }

            if (postdata["frmdata"]) {// 由于可能存在textarea编辑回车，需要两次转换
                postdata["frmdata"] = postdata["frmdata"];
            }

            // 提交的数据
            postdata["reqdata"] = $.getJsonString(dt, true);

            if (postdata["reqdata"]) {
                postdata["reqdata"] = postdata["reqdata"];
            }

            if (h_request != null)
                clearTimeout(h_request);

            if (loadingIndicator) {
                loadingIndicator.show();
            }
            for (var key in postdata) {
                if (typeof (postdata[key]) == 'string') {
                    var tpdt = postdata[key];
                    /*tpdt = tpdt.replace(/\xB7/g, "%B7"); //由于服务器端Request处理中点，解码时会变成问号
                    tpdt = tpdt.replace(/\xD7/g, "%D7"); //×
                    tpdt = tpdt.replace(/\xF7/g, "%F7"); //÷
                    tpdt = tpdt.replace(/\xB1/g, "%B1"); //±
                    tpdt = tpdt.replace(/\xB0/g, "%B0"); //°*/
                    tpdt = tpdt.replace(/\+/g, "%2B")//由于服务器端Request处理"+"解码时会变成空格
                    postdata[key] = tpdt;
                }
            }
            h_request = setTimeout(function() {
                onDataLoading.notify(opts);

                req = $.ajax({
                    type: postType,
                    url: url,
                    data: postdata,
                    success: onSuccess,
                    error: function(resp) {
                        if (loadingIndicator) {
                            loadingIndicator.hide();
                        }

                        if (stopped) {
                            stopped = false;
                        } else {
                            onError.notify(opts);
                        }
                    }
                });
            }, 50);
        }

        function onSuccess(resp) {
            if (loadingIndicator) {
                loadingIndicator.hide();
            }
            if (stopped) {
                stopped = false;
                return;
            }
            data = $.getJsonObj(resp) || data;
            req = null;

            if (data && data["__SEXCEPTION"]) {
                // 安全异常处理
                // AimDlg.show(data["__SEXCEPTION"]["Content"], "安全异常", "alert");
                alert(data["__SEXCEPTION"]["Content"]);

                window.location.reload();
            }

            showMsg(data);
        }

        // 停止
        function stopLoading() {
            if (loadingIndicator) {
                loadingIndicator.hide();
            }

            stopped = true;
        }

        function showMsg(dt) {
            var dt = dt || data;
            if (!dt) return;
            var fdt = [];

            if (dt["__EXCEPTION"]) {
                if (onProcessException.hasHandler()) {
                    onProcessException.notify({ data: dt, options: options, status: "except", msg: dt["__EXCEPTION"]["Content"] });
                } else {
                    AimDlg.show(dt["__EXCEPTION"]["Content"], "异常", "alert");
                }
            } else if (dt["__WEB"]) {
                if (onDataLoaded.hasHandler()) {
                    onDataLoaded.notify({ data: dt, options: options, status: "success", msg: dt["__WEB"]["Content"] });
                } else {
                    AimDlg.show(dt["__WEB"]["Content"], "消息", "info");
                }
            } else {
                onDataLoaded.notify({ data: dt, options: options, status: "success" });
            }
        }

        function reloadData(from, to) {
            this.clear();
            ensureData(options);
        }

        function setSort(column, dir) {
            sortcol = column;
            sortdir = dir;
            clear();
        }

        function setSearch(str) {
            searchstr = str;
            clear();
        }

        init();

        return {
            // properties
            "data": data,

            // methods
            "clear": clear,
            "isDataLoaded": isDataLoaded,
            "ensureData": ensureData,
            "reloadData": reloadData,
            "setSort": setSort,
            "setSearch": setSearch,

            // events
            "onDataLoading": onDataLoading,
            "onDataLoaded": onDataLoaded,
            "onError": onError,
            "onProcessException": onProcessException
        };
    }

    // Slick.Data.RemoteModel
    $.extend(true, window, { Aim: { Data: { RemoteModel: RemoteModel}} });
})();

//------------------------Aim 数据加载模型 结束------------------------//


//------------------------Aim 格式化方法 开始------------------------//

// 枚举格式化
AimEnumFormatter = function(val, dtenumstr) {
    return formatAimEnum(val, dtenumstr);
}

function formatAimEnum(val, dtenumstr) {
    var dtenum = null;
    if (dtenumstr) {
        dtenum = $.getEval(dtenumstr) || AimState[dtenumstr];
    }

    if (dtenum) { return (dtenum[val] || val) }
    return val;
}

// 枚举格式化
AimLinkFormatter = function(val, dtenumstr) {
}

function formatAimLink(val, dtenumstr) {
}


function FormValidationBind(controlId, funcSuccess, funcfail) {
    if ($("[class*=validate]").length > 0) {
        $("[class*=validate]").validationEngine({
            success: funcSuccess,
            failure: funcfail,
            controlid: controlId
        })
    } else {
        $("#" + controlId).bind("click", funcSuccess);
    }
}
//------------------------Aim 格式化方法 结束------------------------//


//------------------------Aim Form控件 开始------------------------//

(function() {
    function AimForm(htmele) {
        var id = htmele.id;
        var htmlele = htmele;
        var dsname = "frmdata";
        var async = false;
        var data = [];
        var frmdata = {};
        var loader = null;
        var loadingIndicator = null;   // 异步加载蒙板

        var optype = "";    //操作类型

        // events
        var onDataLoading = new Aim.EventHelper();
        var onDataLoaded = new Aim.EventHelper();

        var onSubmitting = new Aim.EventHelper();
        var onSubmitFail = new Aim.EventHelper();
        var onSubmitted = new Aim.EventHelper();
        var onProcessException = new Aim.EventHelper();
        var onProcessFinished = new Aim.EventHelper();  // 所有操作以结束

        init();
        render();

        function init() {
            dsname = $(htmlele).attr("dsname") || dsname;
            async = $(htmlele).attr("async");
        }

        function render() {
            if (pgOperationType == 'c') {
                clientRender();
            } else {
                serverRender();
            }
        }

        function clientRender() {
            // 客户端加载时
            if (typeof (dialogArguments) != "undefined" && dialogArguments) {
                frmdata = dialogArguments['frmdata'] || "";
            } else {
                var frmdatastr = $.getQueryString({ ID: 'frmdata' }) || "";
                if (frmdatastr) {
                    frmdata = $.getJsonObj(unescape(frmdatastr));
                }
            }

            dataBind();
        }

        function serverRender() {
            if (typeof (Ext) == 'object' && Ext.LoadMask) {
                loadingIndicator = new Ext.LoadMask(id, { msg: "数据处理中..." });
            } else {
                loadingIndicator = new Aim.LoadingIndicator(htmlele);
            }

            loader = new Aim.Data.RemoteModel({});

            loader.onDataLoading.subscribe(function() {
                onDataLoading.notify(data);
            });

            loader.onDataLoaded.subscribe(function(args) {
                data = args.data || data;
                frmdata = data[dsname] || data || frmdata;

                loadingIndicator.hide();

                onDataLoaded.notify(args);

                dataBind(); // 绑定数据

                onProcessFinished.notify(args);

                if (optype == "submit") {
                    onSubmitted.notify(args);
                }
                optype = "";
            });

            loader.onError.subscribe(function(opts) {
                loadingIndicator.hide();

                onSubmitFail.notify(opts);
            });

            loader.onProcessException.subscribe(function(dt) {
                loadingIndicator.hide();

                if (dt || dt["__EXCEPTION"] || dt.data["__EXCEPTION"]) {
                    var ex = dt["__EXCEPTION"] || dt.data["__EXCEPTION"];

                    if (onProcessException.hasHandler()) {
                        onProcessException.notify(dt);
                    } else {
                        AimDlg.show(ex["Content"], "异常", "alert");
                    }
                }
            });

            if (!async) {
                data = AimState;

                // 没有loader(同步加载时)
                frmdata = AimState[dsname] || frmdata;

                dataBind();
            } else {
                loadingIndicator.show();
                loader.ensureData();
            }
        }

        function submit(action, dt, url, onProcFinished, onProcExcept, onSubFail) {
            if (pgOperationType == 'c') {
                clientSubmit(action, dt, url, onProcFinished);
            } else {
                serverSubmit(action, dt, url, onProcFinished, onProcExcept, onSubFail);
            }
        }

        // 提交客户端表单
        function clientSubmit(action, dt, url, onProcFinished) {
            var rtnval = { action: action, url: url, data: dt };
            rtnval[dsname] = getJsonString();

            if (onProcFinished) {
                onProcFinished.call(this, { url: url, data: dt, action: action });
            }
        }

        // 提交表单（需要在此加验证）
        function serverSubmit(action, dt, url, onProcFinished, onProcExcept, onSubFail) {
            optype = "submit";
            if (onProcFinished) onProcessFinished.subscribe(onProcFinished);
            if (onProcExcept) onProcessException.subscribe(onProcExcept);
            if (onSubFail) onSubmitFail.subscribe(onSubFail);

            var isAsync = !(async == false);
            loadingIndicator.show("数据处理中...");
            onSubmitting.notify({ url: url, data: dt, action: action });
            url = url || location.href;
            action = action || "default";

            var postdata = { url: url, reqaction: action, data: dt, asyncreq: true };
            var jsonstr = getJsonString();
            postdata[dsname] = escape(jsonstr);

            if (isAsync) {
                loader.ensureData(postdata);
            } else {
                // 同步提交表单
                //$(htmlele).submitForm();
                $(htmlele).submit();
            }
        }

        function getJson() {
            if (typeof FCKeditorAPI != "undefined") {
                //超文本编辑控件的特殊处理 jnpadd2010-7-16
                $("[aimctrl=editor]").each(function(i) {
                    var editor = FCKeditorAPI.GetInstance(this.id);
                    $(this).val(editor.GetXHTML(true));
                });
            }

            return $(htmlele).getJson();
        }

        // 获取数据
        function getJsonString() {
            if (typeof FCKeditorAPI != "undefined") {
                //超文本编辑控件的特殊处理 jnpadd2010-7-16
                $("[aimctrl=editor]").each(function(i) {
                    var editor = FCKeditorAPI.GetInstance(this.id);
                    $(this).val(editor.GetXHTML(true));
                });
            }

            return $(htmlele).getJsonString();
        }

        // 绑定数据
        function dataBind(dt) {
            dt = dt || frmdata || data;
            if (dt) {
                var fdt = dt[(dsname || "frmdata")] || dt;

                var mode = "";
                if ($.getQueryString && $.getQueryString({ ID: "op" }) != 'undefined') {
                    mode = $.getQueryString({ ID: "op" });

                    if (mode == "r") {
                        $("[class*=aim-ui-button submit]").hide();
                    }
                }

                $(":input").each(function() {
                    var cname = $(this).attr("id");
                    if (cname == "") {
                        return;
                    }

                    var defVal = "";
                    // 设置新创建时默认值
                    if (mode == "c" || mode == "cs") {
                        defVal = $("#" + cname).val() || defVal;
                    }

                    var val = fdt[cname];
                    if (val != 0) {
                        val = val || defVal;
                    }

                    $("#" + cname).dataBind(val, id, mode);
                });

                return this;
            }
        }

        // 加载数据
        function reload(schopts, url) {
            optype = "load";

            schopts = schopts || {};
            loadingIndicator.show("数据加载中...");
            url = url || location.href;

            // var postdata = { "frmdata": schopts };

            var postdata = { url: url, reqaction: "query", data: schopts, asyncreq: true };
            loader.ensureData(postdata);
        }

        // 停止加载
        function stopLoading() {
            optype = "";
            loader.stopLoading();

            loadingIndicator.hide();
        }

        // 设置表单状态
        function setStatus(name, status) {
            if (!name) return;
            status = !(status == false);
            $(htmlele).find(":input").attr(name, status);
        }

        // 清空表单
        function clear() {
            $(htmlele).find(":input").val("");
        }

        // 清空验证提示
        function clearValidatePrompt() {
            $(htmlele).find("[class^=validate]").each(function() {
                closingPrompt = $(this).attr("name")

                $("." + closingPrompt).fadeTo("fast", 0, function() {
                    $("." + closingPrompt).remove()
                });
            });
        }

        // Public API
        $.extend(this, {
            // Events
            "onDataLoading": onDataLoading, // 异步数据加载中触发
            "onDataLoaded": onDataLoaded, // 异步数据加载完成触发
            "onSubmitting": onSubmitting, // 提交表单时触发
            "onSubmitFail": onSubmitFail, // 提交表单失败后触发
            "onSubmitted": onSubmitted,
            "onProcessException": onProcessException, // 处理页面出现异常时触发
            "onProcessFinished": onProcessFinished, // 处理页面出现异常时触发

            // Methods
            "submit": submit,   // 提交表单
            "dataBind": dataBind,    // 绑定表单
            "reload": reload,    // 加载数据
            "setStatus": setStatus,  // 设置表单状态,
            "clear": clear,   // 清空表单
            "getJson": getJson,    // 获取Json
            "getJsonString": getJsonString,    // 获取Json字符串
            "clearValidatePrompt": clearValidatePrompt
        });
    }

    // Aim.Form
    $.extend(true, window, { Aim: { Form: AimForm} });

    // 提交数据
    $.submitData = $.extend(true, Aim.Form, { submitData: function(frmdata, action, dt, url, onProcFinished, onProcExcept) {
        var ldr = new Aim.Data.RemoteModel({});
        if (onProcFinished) ldr.onDataLoaded.subscribe(onProcFinished);
        if (onProcExcept) ldr.onProcessException.subscribe(onProcExcept);

        url = url || location.href;
        action = action || "default";

        var postdata = { url: url, reqaction: action, data: dt, asyncreq: true };
        if (typeof (frmdata) == "string") {
            postdata["frmdata"] = frmdata;
        } else if (frmdata) {
            postdata["frmdata"] = $.getJsonString(frmdata);
        }

        ldr.ensureData(postdata);
    }
    });
} ());



//使用方法：$("#controlId").dataBind(value);
$.fn.dataBind = function(value, formId, mode) {
    if (value) {
        if (mode == "View") this.attr("readonly", true);

        if (value == undefined) {
            return this;
        }

        value = unescape(value.toString());
        formId = formId || "";
        if (formId != "") {
            formId = "#" + formId + " ";
        }
        switch (this.attr("type")) {
            case "select-one":
                //DropDownList
                //this[0].selectedIndex = 0;
                //$("option[value='" + value + "']", this).attr("selected");
                var isSelected = false;
                $("option", this).each(function() {
                    if (this.value == value) {
                        this.selected = true;
                        isSelected = true;
                        return;
                    }
                });
                if (!isSelected)
                    this[0].selectedIndex = 0;
                break;
            case "select-multiple": //ListBox
                this.children().each(function() {
                    var arr = value.split(',');
                    for (var i = 0; i < arr.length; i++) {
                        if (this.value == arr) {
                            this.selected = true;
                        }
                    }
                });
                break;
            case "checkbox": //CheckboxList
                //单选
                if (value.indexOf(',') == -1) {
                    $(formId + "input[name='" + this.attr("name") + "']").each(function() {
                        if (this.value == value) {
                            $(this).attr("checked", true);
                            return;
                        }
                        else {
                            $(this).attr("checked", false);
                            return;
                        }
                    });
                }
                //多选
                else if (this.attr("type") == 'checkbox') {
                    var arr = value.split(',');
                    for (var i = 0; i < arr.length; i++) {
                        $(formId + "input[name='" + this.attr("name") + "']").each(function() {
                            if (this.value == arr) {
                                this.checked = true;
                            }
                        });
                    }
                }
                break;
            case "radio": //RadioButtonList
                //            $(formId + " input[name='" + this.attr("name") + "']").each(function() {
                //                if (this.value == value) {
                //                    this.checked = true;
                //                    return;
                //                }
                //            });
                break;
            default: //Normal
                this.val(value);
                this.change();
                break;
        }
    }

    if (this.attr("aimctrl") && this.attr("aimctrl").toString().toLowerCase() == "editor") {
        try {
            if (typeof (FCKeditorAPI) != 'undefined') {
                var oEditor = FCKeditorAPI.GetInstance(this.attr("id"));
                oEditor.ReplaceTextarea();
            }
        } catch (e) { }
    }

    return this;
}

//注册form的ajaxForm 此方法需要调用jquery.ajaxwindow.js的方法
//一般form里有action，所以参数有可能只需要传一个callback，
//如果一个表单有多个提交按钮，那么则需要 提交不同的url
// 这个方法是用来注册form提交，如果有多个提交按钮时，最好默认注册一个，否则验证方法就不起到作用
$.fn.submitForm = function(args) {
    var url, id, callback, before;
    id = this.attr("id");

    if (typeof (args) == "string") {//只传一个url
        url = args;
        before = undefined;
        callback = undefined;
    }
    else {
        args = args || new Object();
        url = args.url || this.attr("action");
        if (typeof (args) == "function") {//只传一个callback
            callback = args;
        }
        else {
            before = args.before;
            callback = args.callback;
        }
    }

    //输入验证
    this.ajaxSubmit({ //这里调用jquery.form.js表单注册方法。
        url: url,
        type: "post",
        beforeSubmit: function(a, f, o) {//提交前的处理
            //提交验证
            //if ($("#" + id).submitValidate() == false)//这里我们需要实现的“提交时的验证”。
            //return false;
            if (before != undefined && before() == false) {
                return false;
            }
            o.dataType = "jason"; //指定返回的数据为json格式。
        },

        success: function(data) {//提交后反馈信息处理
            if (data == "" || data == null) {
                return false;
            }
            //var msg = new ajaxMsg(data);//这个ajaxMsg便是我们需要实现的Lightbox
            //msg.show(callback);//show这个反馈的结果。
            if (callback)
                callback(data);
            return false;
        }
    });
    return this;
}

// 提交Ajax表单
/*$.ajaxForm = function(action, dt, url, onProcFinished, onProcExcept, onSubFail) {
if (!el) {
if ($("form").length > 0) {
el = $("form")[0];
} else {
return;
}
}

var sbForm = new Aim.Form(el);
sbForm.submit(action, dt, url, onProcFinished, onProcExcept, onSubFail);
}*/


// 提交Ajax操作
/*$.ajaxExec = function(action, params, onExecuted, onError, url, maskmsg) {
var loader = new Aim.Data.RemoteModel({ 'maskmsg': maskmsg });

if (onExecuted) { loader.onDataLoaded.subscribe(onExecuted); }
if (onError) { loader.onError.subscribe(onError); }
action = action || "default";

loader.ensureData({ url: url, reqaction: action, data: params });
}*/

$.ajaxExec = function(action, params, onExecuted, onError, url, maskmsg) {
    var loader = new Aim.Data.RemoteModel({ 'maskmsg': maskmsg });

    if (onExecuted) { loader.onDataLoaded.subscribe(onExecuted); }
    if (onError) { loader.onError.subscribe(onError); }
    if (onError) { loader.onProcessException.subscribe(onError); }
    action = action || "default";

    loader.ensureData({ url: url, reqaction: action, data: params });
}

$.ajaxExecSync = function(action, params, onExecuted, onError, url, maskmsg) {
    var postdata = { reqaction: action, data: params, "asyncreq": true };

    // 提交的数据
    postdata["reqdata"] = $.getJsonString(params, true);

    if (postdata["reqdata"]) {
        postdata["reqdata"] = postdata["reqdata"];
    }
    $.ajax({
        async: false,
        type: "POST",
        url: url || $.getQueryUrl(),
        data: postdata,
        success: function(rtn) {
            onExecuted({ data: $.getJsonObj(rtn) }, params);
        },
        failure: function(result, request) {
            onError({ data: $.getJsonObj(rtn) }, params);
        }
    });
}

// 刷新并关闭打开页
function RefreshClose() {
    try {
        if (window.opener && window.opener.location) {
            window.opener.location.reload();
        }
    }
    catch (e) { }
    window.close();
}

// 返回值
function ReturnClose(rtns) {
    Aim.PopUp.ReturnValue(rtns);
}

// 获取服务器端数据
function GetAjaxData(url, action, data, onDataLoaded, onError) {
    var loader = new Aim.Data.RemoteModel();

    if (onDataLoaded) { loader.onDataLoaded.subscribe(onDataLoaded); }
    if (onError) { loader.onError.subscribe(onError); }
    action = action || "default";

    loader.ensureData({ url: url, reqaction: action, data: data });
}

//------------------------Aim Form控件 结束------------------------//

//------------------------Aim Window控件 开始------------------------//

(function() {
    function AimWindow(htmele) {
        var WIN_TMPL = '<div class="aim-window-titlebar" style="cursor: move; padding:1px; height:23px; display:none;"><span style="height:22px;padding:1px;" class="aim-window-titletext"></span>'
                        + '<a style="float:right; cursor:hand; padding:2px; height:22px;" class="aim-window-close"><span class="ui-icon ui-icon-closethick aim-window-close"></span></a></div>'

        var id = htmele.id;
        var htmlele = htmele;
        var options = {};
        var resoptions = {};

        // events
        var onDataLoading = new Aim.EventHelper();
        var onDataLoaded = new Aim.EventHelper();
        var onShow = new Aim.EventHelper();
        var onClose = new Aim.EventHelper();

        init();
        render();

        function init() {
            var optstr = $(htmlele).attr("options") || {};
            options = $.getJsonObj(optstr) || {};

            resoptions["minWidth"] = parseInt(options["minWidth"] || $(htmlele).css("width") || 1);
            //resoptions["minHeight"] = parseInt(options["minHeight"] || $(htmlele).css("width") || 1);
            resoptions["maxWidth"] = options["maxWidth"] || document.documentElement.offsetWidth;
            resoptions["maxHeight"] = options["maxHeight"] || document.documentElement.offsetHeight;
        }

        function render() {
            // 添加标题栏
            $(htmlele).find(".aim-window-body").before(WIN_TMPL);
            $(htmlele).addClass("jqmWindow");
            $(htmlele).find(".aim-window-titlebar").addClass("ui-widget-header ui-helper-clearfix");
            $(htmlele).find('.aim-window-body').addClass("ui-jqdialog-content ui-widget-content")
            $(htmlele).find(".aim-icon aim-window-close").addClass("ui-state-hover ui-jqdialog-titlebar-close ui-corner-all").css("CURSOR: move; padding:1px;");
            $(htmlele).find(".aim-window-content").attr("border", 0).attr("cellSpacing", 0).attr("cellpading", 0).css("width", "100%");
            $(htmlele).find('.aim-window-close').bind("click", close);
            $(htmlele).find('td').addClass("CaptionTD ui-widget-content");
            $(htmlele).find('.aim-window-bottom').css("padding", 10).attr("align", "right");
            $(htmlele).find(':input').addClass("text ui-widget-content ui-corner-all");
            $(htmlele).draggable({ handle: ".aim-window-titlebar" }).resizable(resoptions);

            $(htmlele).jqm(options);
            $(htmlele).jqmAddClose('.aim-window-close');
        }

        // 设置表单状态
        function setStatus(name, status) {
            if (!name) return;
            status = !(status == false);
            $(htmlele).find(":input").attr(name, status);
        }

        // 显示
        function show(opts) {
            onShow.notify(opts);
            if (typeof (opts) == "string") {
                opts = { title: opts };
            }

            opts = opts || {};
            $(htmlele).find(".aim-window-titletext").text(opts["title"] || " ");
            $(htmlele).jqmShow(opts);
            $(htmlele).attr("width", opts["width"] || $(htmlele).css("width"));
            $(htmlele).attr("height", opts["height"] || $(htmlele).css("height"));
        }

        function close() {
            onClose.notify(options);

            // 清空提示信息
            if (AimFrm) AimFrm.clearValidatePrompt();

            $(htmlele).jqmHide();
        }

        // Public API
        $.extend(this, {// Events
            "onDataLoading": onDataLoading,
            "onDataLoaded": onDataLoaded,
            "onShow": onShow,
            "onClose": onClose,

            "setStatus": setStatus,  // 设置窗体状态
            "show": show,
            "close": close
        });
    }

    // Aim.Window
    $.extend(true, window, { Aim: { Window: AimWindow} });
} ());

//------------------------Aim Window控件 结束------------------------//

//------------------------Aim 控件基类 开始------------------------//

(function() {
    function AimControl(htmele) {
        var htmlele = htmlele;
        var enumKey = {};
        var formatter = null;

        init();

        function init() {

        }

        function getValue() {
        }

        function setValue() {
        }

        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue
        });

    }

    // Aim.Control
    $.extend(true, window, { Aim: { Control: AimControl} });
} ());

//------------------------Aim 控件基类 开始------------------------//

//------------------------Aim Select 开始------------------------//

(function() {
    function AimSelect(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        var enumKey = htmlele.attr("enumdata") || htmlele.attr("enum");
        var formatter = null;
        var isSelected = false;
        var Readonly = htmlele.attr("readonly");
        var Required = htmlele.attr("required");
        var emptyText = htmlele.attr("emptyText") || "请选择...";

        var _OldIndex = null;
        var _OldHandle = null;

        function init() {
            if (Required && Required.toString().toLowerCase() == "true") {
                Required = true;
            } else {
                Required = false;
            }

            htmlele.empty();
            if (enumKey) {
                if (AimState[enumKey]) {
                    bindData(AimState[enumKey]);
                } else {
                    bindData(eval(enumKey));
                }
            }
        }

        init();

        function getValue() {
            return this.htmlele.val();
        }

        function setValue(val) {
            this.htmlele.children().each(function() {
                if (this.value == val) {
                    this.selected = true;
                    isSelected = true;
                    return;
                }
            });
            if (!isSelected)
                this.htmlele[0].selectedIndex = 0;
        }
        function bindData(jsonVal) {
            htmlele.empty();
            if (!Required) {
                var option = new Option(emptyText, '');
                htmlele[0].options.add(option);
            }

            for (var key in jsonVal) {
                var option = new Option(jsonVal[key], key);
                if ($.browser.msie) {
                    htmlele[0].options.add(option);
                }
                else {
                    htmlele[0].options.add(option);
                }
            }
        }
        function setReadOnly(bool) {
            this.Readonly = bool;
            this._OldIndex = null;
            this._OldHandle = null;
            if (bool) {
                this._OldIndex = this.htmlele.selectedIndex;
                this._OldHandle = this.htmlele.onchange;
                this.htmlele.onchange = function() { this.selectedIndex = this.htmlele._OldIndex; };
            } else {
                this.htmlele.onchange = this._OldHandle;
            }
        }
        function setDisabled(bool) {
            this.htmlele.disabled = bool;
        }
        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue,
            "bindData": bindData,
            "setReadOnly": setReadOnly,
            "setDisabled": setDisabled
        });

    }

    // Aim.Select
    $.extend(true, window, { Aim: { Select: AimSelect} });
} ());

//------------------------Aim Select 结束------------------------//

//------------------------Aim Date 开始------------------------//

(function() {
    function AimDate(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        var formatter = null;
        var isSelected = false;
        var Readonly = htmlele.attr("readonly");
        function init() {
            $.datepicker.regional['zh-CN'] = {
                closeText: '关闭',
                prevText: '&#x3c;上月',
                nextText: '下月&#x3e;',
                currentText: '今天',
                monthNames: ['一月', '二月', '三月', '四月', '五月', '六月',
		'七月', '八月', '九月', '十月', '十一月', '十二月'],
                monthNamesShort: ['一', '二', '三', '四', '五', '六',
		'七', '八', '九', '十', '十一', '十二'],
                dayNames: ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'],
                dayNamesShort: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
                dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
                weekHeader: '周',
                dateFormat: 'yy-mm-dd',
                firstDay: 1,
                isRTL: false,
                showMonthAfterYear: true,
                yearSuffix: '年'
            };
            $.datepicker.setDefaults($.datepicker.regional['zh-CN']);
            if ($.getQueryString({ ID: "op" }) != 'r') {
                htmlele.datepicker();
            }
        }
        init();

        function getValue() {
            return this.htmlele.val();
        }

        function setValue(val) {

        }
        function setReadOnly(bool) {

        }
        function setDisabled(bool) {
            this.htmlele.disabled = bool;
        }

        htmlele.attr("readonly", true);

        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue,
            "setReadOnly": setReadOnly,
            "setDisabled": setDisabled
        });

    }

    $.extend(true, window, { Aim: { Date: AimDate} });
} ());

//------------------------Aim Date 结束------------------------//

//------------------------Aim PopUp 开始------------------------//
(function() {
    function AimPopUp(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        var eleButton = null;
        var AllowEmpty = htmlele.attr("allowempty");
        var Readonly = htmlele.attr("readonly");
        var PopUrl = htmlele.attr("PopUrl");
        var PopParam = htmlele.attr("PopParam");
        var PopStyle = htmlele.attr("PopStyle");
        var AfterPopUp = htmlele.attr("AfterPopUp");
        var PopMode = htmlele.attr("PopMode") || "window";  //Change By WGM

        function init() {
            eleButton = "<a class='aim-ui-button' style='padding-left:4px; width:20px; padding-right:4px; margin-left:5px;'>...</a>";
            htmlele.after(eleButton);
            eleButton = htmlele.next();

            eleButton.css({ cursor: "hand" });
            //PopUrl = PopUrl.indexOf("?") == -1 ? PopUrl + "?PopParam=" + PopParam : PopUrl + "&PopParam=" + PopParam;

            PopUrl = $.combineQueryUrl(PopUrl, { "PopParam": PopParam, "AfterPopUp": AfterPopUp });

            eleButton.click(function() {
                if (PopMode.toString().toLowerCase() == "window") {
                    OpenWin(PopUrl, "_blank", CenterWin(PopStyle));
                }
                else if (PopMode.toString().toLowerCase() == "mypop") {
                    window.showModalDialog(PopUrl, window, PopStyle);
                }
                else {
                    window.showModalDialog(PopUrl, window, CenterWin(PopStyle, true));
                }
            });
        }

        init();

        function getValue() {
            return this.htmlele.val();
        }

        function setValue(val) {
            this.htmlele.val(val);
        }

        function setReadOnly(bool) {
            this.Readonly = bool;
            if (bool) {
                htmlele.attr("readonly", true);
                eleButton.attr('disabled', true);
            } else {
                htmlele.attr("readonly", false);
                eleButton.attr('disabled', false);
            }
        }

        function setDisabled(bool) {
            if (bool) {
                htmlele.attr("disabled", bool);
                eleButton.attr('disabled', bool);
            }
            else {
                htmlele.removeAttr("disabled");
                eleButton.removeAttr("disabled");
            }
        }

        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue,
            "setReadOnly": setReadOnly,
            "setDisabled": setDisabled
        });

    }

    // Aim.PopUp
    $.extend(true, window, { Aim: { PopUp: AimPopUp} });

    // 提交数据
    $.ReturnValue = $.extend(true, Aim.PopUp, { ReturnValue: function(rtns) {
        var rtnData = rtns || {};
        var param, strs;
        var onAfterPopUp;

        if (typeof (dialogArguments) != "undefined" && dialogArguments) {
            param = dialogArguments.PopParam || "";
        } else {
            param = $.getQueryString({ ID: "PopParam" }) || "";
            onAfterPopUp = $.getQueryString({ ID: "AfterPopUp", DefaultValue: null });
        }

        //-----Change  By WGM-----11/12---------
        var popmode = "";
        if (!param || !onAfterPopUp) {
            param = $.getQueryString({ ID: "PopParam" }) || "";
            onAfterPopUp = $.getQueryString({ ID: "AfterPopUp", DefaultValue: null });
            popmode = $.getQueryString({ ID: 'popmode' });
        }

        strs = param.split(";");
        if (typeof (dialogArguments) != "undefined" && dialogArguments) {
            //Change By WGM
            if (popmode == "myPop") {
                if (typeof dialogArguments[onAfterPopUp] == "function") {
                    dialogArguments[onAfterPopUp](rtns);
                    window.returnValue = { result: "success" };
                }
            } else {
                window.returnValue = { result: "success", data: rtns || {} };
            }
        } else if (window.opener) {
            var tstr = [];
            var openDoc = window.opener.document;
            $.each(strs, function() {
                tstr = this.split(":");
                if (openDoc.getElementById(tstr[0]) && tstr[1]) {
                    $(openDoc.getElementById(tstr[0])).val(rtnData[tstr[1]] || "");
                }
            });

            if (typeof (onAfterPopUp) == "string" && onAfterPopUp != "") {
                eval("window.opener." + onAfterPopUp + "(rtns)");
            }
        }

        window.close();
    }
    });

    $.GetPopParamValue = $.extend(true, Aim.PopUp, { GetPopParamValue: function() {
        var param, strs;
        var pval = {};
        if (typeof (dialogArguments) != "undefined" && dialogArguments) {
            param = dialogArguments.PopParam || "";
        } else {
            param = $.getQueryString({ ID: "PopParam" }) || "";
        }

        if (!param) {
            param = $.getQueryString({ ID: "PopParam" }) || "";
        }
        if (!param) strs = "";
        else
            strs = param.split(";");


        if (window.opener) {
            var tstr = [];
            var openDoc = window.opener.document;
            $.each(strs, function() {
                tstr = this.split(":");

                if (openDoc.getElementById(tstr[0]) && tstr[1]) {
                    pval[tstr[1]] = $(openDoc.getElementById(tstr[0])).val();
                }
            });
        }
        else {     //Change By WGM
            if ((function(obj) {//是否为window对象
                return /Window|global/.test({}.toString.call(obj)) || obj == obj.document && obj.document != obj;
            })(dialogArguments)) {
                var tstr = [];
                var openDoc = dialogArguments.document.body;
                $.each(strs, function() {
                    tstr = this.split(":");
                    if ($("#" + tstr[0], openDoc) && tstr[1]) {
                        pval[tstr[1]] = $("#" + tstr[0], openDoc).val();
                    }
                });
            }
        }

        return pval;
    }
    });

} ());

//------------------------Aim PopUp 结束------------------------//


//------------------------Aim File 开始------------------------//
(function() {
    function AimFile(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        htmlele.css("float", "left");
        var eleSpan, fileLinkSpan, fileBtnSpan, fileInputField, btnFileAdd, btnFileDel, btnFileClr, btnFileOpn;


        var readOnly = htmlele.attr("readonly");
        var disabled = htmlele.attr("disabled");
        var mode = htmlele.attr("mode") || "multi";

        var IsLog = htmlele.attr("IsLog") || ""; // 上传是否写日志
        var Filter = htmlele.attr("Filter") || ""; // 上传文件过滤字符
        var MaximumUpload = ""; // 最大单个上传文件大小(MB)
        var MaxNumberToUpload = ""; // 最大上传文件数
        var AllowThumbnail = false; // 是否允许显示缩略图
        var DoCheck = htmlele.attr("DoCheck") || null; // 上传前检查方法
        var UploadPage = htmlele.attr("UploadPage") || UPLOAD_PAGE_URL;
        var DownloadPage = htmlele.attr("DownloadPage") || DOWNLOAD_PAGE_URL;

        var BtnFileAddID = "btnFileAdd_" + htmele.id;
        var BtnFileClrID = "btnFileClr_" + htmele.id;
        var BtnFileDelID = "btnFileDel_" + htmele.id;
        var BtnFileOpnID = "btnFileOpn_" + htmele.id;
        var FileLinkSpanID = "spanFileLink_" + htmele.id;
        var FileInputFieldID = "spanFileInput_" + htmele.id;
        var FileBtnSpanID = "spanFileBtn_" + htmele.id;
        var TDButtonId = "tdbutton" + htmele.id;

        //        var SingleFileBlock = "<div class='aim-ctrl-file-link' linkfile='{filefullname}' style='float:left; width:100%; border:0px;'>"
        //            + "<a href='javascript:void(0)' style='margin:5px;' title='{filename}' "
        //            + " onclick=OpenWin('" + DownloadPage + "?Id={fileid}','_blank','width=1,height=1')>{filename}</a></div>";

        //        var FileBlock = "<div class='aim-ctrl-file-link' linkfile='{filefullname}' style='float:left; width:120; height: 20; margin:2px; border:0px;'>"
        //            + "<input type='checkbox'style='border:0px' />"
        //            + "<a href='javascript:void(0)' style='margin:5px;' title='{filename}' "
        //            + " onclick=OpenWin('" + DownloadPage + "?Id={fileid}','_blank','width=1,height=1')>{filename}</a></div>";

        var SingleFileBlock = "<div class='aim-ctrl-file-link' linkfile='{filefullname}' style='float:left; width:100%; border:0px;'>"
            + "<a href='" + DownloadPage + "?Id={fileid}' style='margin:5px;' title='{filename}' "
            + " >{filename}</a></div>";

        var FileBlock = "<div class='aim-ctrl-file-link' linkfile='{filefullname}' style='float:left; width:120; height: 20; margin:2px; border:0px;'>"
            + "<input type='checkbox'style='border:0px' />"
            + "<a href='" + DownloadPage + "?Id={fileid}' style='margin:5px;' title='{filename}' "
            + " >{filename}</a></div>";

        var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;"; // 上传文件页面弹出样式

        var SingleStructure = "<table style='border:0px; width:100%; font-size:12px;'><tr>"
            + "<td style='width:*; vertical-align:top; border-color:#8FAACF; padding:2px;' class='aim-ctrl-file'><span id='" + FileInputFieldID + "' style='width:100%' /></td>"
            + "<td style='width:100px; border:0px; padding:0px;' align='center'><span id='" + FileBtnSpanID + "' class='aim-ctrl-file-button-span'>"
            + "<a id='" + BtnFileAddID + "' class='aim-ctrl-file-button'>上传</a>"
            + "<a id='" + BtnFileClrID + "' class='aim-ctrl-file-button'>清空</a>"
        // + "<a id='" + BtnFileOpnID + "' class='aim-ctrl-file-button'>打开</a>"
            + "</span></td></tr></table>";

        var MultiStructure = "<table style='border:0px; width:100%; font-size:12px;'><tr>"
            + "<td style='width:*; vertical-align:top; border-color:#8FAACF' class='aim-ctrl-file'><span id='" + FileLinkSpanID + "' style='width:100%;'></span></td>"
            + "<td id='" + TDButtonId + "' style='width:50px; border:0px;' align='center'><span id='" + FileBtnSpanID + "' class='aim-ctrl-file-button-span'>"
            + "<a id='" + BtnFileAddID + "' class='aim-ctrl-file-button'>上传</a><br><br>"
            + "<a id='" + BtnFileDelID + "' class='aim-ctrl-file-button'>删除</a><br><br>"
            + "<a id='" + BtnFileClrID + "' class='aim-ctrl-file-button'>清空</a>"
            + "</span></td></tr></table>";

        init();

        function init() {
            // 如果父元素不是span，则创建一个span
            //if (htmlele.parent().attr("tagname").toLowerCase() == "span") {
            if (htmlele.parent().attr("tagname") && htmlele.parent().attr("tagname").toString().toLowerCase() == "span") {
                eleSpan = htmlele.parent();
            } else {
                htmlele.wrap("<span></span>");
                eleSpan = htmlele.parent();

                eleSpan.attr("height", htmlele.attr("height"));
                eleSpan.css("height", htmlele.css("height"));

                eleSpan.attr("width", htmlele.attr("width"));
                eleSpan.css("width", htmlele.css("width"));
            }

            if (!eleSpan.css("height") || eleSpan.css("height") == "auto") {
                if (mode != "single") {
                    eleSpan.css("height", 60);
                }
            }

            eleSpan.attr("className", "aim-ctrl");

            var structure;

            if (mode == "single") {
                structure = $(SingleStructure);
                htmlele.css("display", "none");
            } else {
                structure = $(MultiStructure);
                htmlele.css("visibility", "hidden");
                htmlele.css("width", "15");
            }
            eleSpan.append(structure);

            fileLinkSpan = $("#" + FileLinkSpanID);
            fileLinkSpan.css("height", parseInt(eleSpan.css("height").replace("px", "")) + 20);
            fileLinkSpan.css("overflow-y", "auto");
            fileInputField = $("#" + FileInputFieldID);
            fileBtnSpan = $("#" + FileBtnSpanID);
            btnFileAdd = $("#" + BtnFileAddID);
            btnFileDel = $("#" + BtnFileDelID);
            btnFileClr = $("#" + BtnFileClrID);
            btnFileOpn = $("#" + BtnFileOpnID);

            fileLinkSpan.append(htmlele);

            if (htmlele.attr("Required")) {
                structure.find(".aim-ctrl-file").css("background", FIELD_REQUIRED_BGCOLOR)

                if (mode == "single") {
                    fileInputField.css("background", FIELD_REQUIRED_BGCOLOR);
                    htmlele.removeClass("validate[required]");
                    fileInputField.addClass("validate[required]");
                }
            }

            btnFileAdd.click(function() {
                var uploadurl = getUploadUrl();
                var rtn = window.showModalDialog(uploadurl, window, UploadStyle);

                if (rtn) {
                    if (mode == "single") {
                        htmlele.val(rtn);
                    } else {
                        htmlele.val(htmlele.val() + rtn);
                    }

                    refreshFileView();
                }
            });

            btnFileDel.click(function() {
                $.each(fileLinkSpan.find("input[type='checkbox']"), function() {
                    if (this.checked) {
                        var ffname = $(this.parentNode).attr("linkfile");
                        removeFile(ffname);
                    }
                });
            });

            btnFileClr.click(function() {
                htmlele.val('');
                clearFileView();
            });

            btnFileOpn.click(function() {
                if (htmlele.val()) {
                    var tflid = htmlele.val().substring(0, htmlele.val().indexOf("_"));
                    OpenWin(DownloadPage + '?Id=' + tflid, '_blank', 'width=1,height=1');
                }
            });

            htmlele.change(function() {
                refreshFileView();
            });

            refreshFileView();

            if (readOnly) {
                setReadOnly(readOnly);
            } else if (disabled) {
                setDisabled(disabled);
            }
        }

        // 刷新文件按视图
        function refreshFileView() {
            clearFileView();

            var fileval = htmlele.val();
            if (!fileval) return;

            if (mode == "single") {
                fileval = fileval.trimEnd(',');
                var tflname = fileval.substring(fileval.indexOf("_") + 1);
                var tflid = fileval.substring(0, fileval.indexOf("_"));

                var linkFile = $(SingleFileBlock.replace(/{filefullname}/g, fileval).replace(/{filename}/g, tflname).replace(/{fileid}/g, tflid));
                fileInputField.html(linkFile);
            } else {
                var ctrl = this;
                var fileVals = fileval.split(",");

                $.each(fileVals, function() {
                    if (this != "") {
                        var tflname = this.substring(this.indexOf("_") + 1);
                        var tflid = this.substring(0, this.indexOf("_"));

                        var linkFile = $(FileBlock.replace(/{filefullname}/g, this).replace(/{filename}/g, tflname).replace(/{fileid}/g, tflid));

                        if (readOnly || disabled) {
                            linkFile.find("input").css("display", "none");
                        }

                        if (mode == "single") {
                            linkFile.css("display", "none");
                        }

                        linkFile.insertBefore(htmlele);
                    }
                }
                );
            }
        }

        // 移除文件
        function removeFile(filefullname) {
            var fstr = filefullname + ","
            var val = htmlele.val().replace(fstr, "");

            fileLinkSpan.find("[linkfile=" + filefullname + "]").remove();
            htmlele.val(val);
        }

        // 清空文件视图
        function clearFileView() {
            if (mode == "single") {
                fileInputField.html("");
            } else {
                fileLinkSpan.find(".aim-ctrl-file-link").remove();
            }
        }

        function getValue() {
            return this.htmlele.val();
        }

        function setValue(val) {
            this.htmlele.val(val);
        }

        function setReadOnly(bool) {
            this.readOnly = bool;
            if (bool) {
                //$("#" + TDButtonId).hide(); 不显示上传等按钮
                //eleSpan.find("input").attr("readonly", true);
                //fileBtnSpan.css("visibility", "hidden");
            } else {
                $("#" + TDButtonId).show();
                eleSpan.find("input").attr("readonly", false);
                fileBtnSpan.css("visibility", "visible");
            }
        }

        function setDisabled(bool) {
            if (bool) {
                //$("#" + TDButtonId).hide();
                //eleSpan.find("input").attr("disabled", true);
                //fileBtnSpan.css("visibility", "hidden");
            } else {
                $("#" + TDButtonId).show();
                eleSpan.find("input").attr("disabled", false);
                fileBtnSpan.css("visibility", "visible");
            }
        }

        // 获取上传文件路径
        function getUploadUrl() {
            var qrystr = "&IsLog=" + IsLog + "&Filter=" + escape(Filter)
                + "&MaximumUpload=" + MaximumUpload + "&MaxNumberToUpload=" + MaxNumberToUpload
                + "&AllowThumbnail=" + AllowThumbnail;

            if (mode == "single") {
                qrystr += "&IsSingle=true";
            }

            if (this.DoCheck) {
                qrystr += "&DoCheck=" + DoCheck;
            }

            var uploadurl = UploadPage + "?" + qrystr;
            return uploadurl;
        }


        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue,
            "setReadOnly": setReadOnly,
            "setDisabled": setDisabled
        });

    }

    // Aim.File
    $.extend(true, window, { Aim: { File: AimFile} });
} ());

//------------------------Aim File 结束------------------------//

//------------------------Aim Editor 开始------------------------//

(function() {
    function AimEditor(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        var editor;

        function init() {
            editor = new FCKeditor(htmele.id);
            editor.BasePath = FCK_EDITOR_BASEPATH;
            editor.Width = htmlele.attr("width") || htmlele.css("width") || '100%';
            editor.Height = htmlele.attr("height") || htmlele.css("height") || '300';
            editor.Value = htmlele.val();
            editor.ToolbarSet = htmlele.attr("ToolbarSet") || 'Default';
            //editor.Create();
            editor.ReplaceTextarea();
        }

        init();

        function getValue() {
            var oEditor = FCKeditorAPI.GetInstance(htmele.id);
            return oEditor.GetXHTML(true);
        }

        function setValue(val) {
            var editor = FCKeditorAPI.GetInstance(htmele.id);
            if (editor)
                editor.SetHTML(val);
        }
        function setReadOnly(bool) {
            var editor = FCKeditorAPI.GetInstance(htmele.id);
            if (editor != null) {
                if (editor.EditorDocument != null && editor.EditorDocument.body != null)
                    editor.EditorDocument.body.readonly = true;
            }
        }
        function setDisabled(bool) {
            this.htmlele.disabled = bool;
            var editor = FCKeditorAPI.GetInstance(htmele.id);
            if (editor != null) {
                if (editor.EditorDocument != null && editor.EditorDocument.body != null)
                    editor.EditorDocument.body.disabled = bool;
            }
        }

        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue,
            "setReadOnly": setReadOnly,
            "setDisabled": setDisabled
        });

    }

    $.extend(true, window, { Aim: { Editor: AimEditor} });
} ());

//------------------------Aim Date 结束------------------------//

//------------------------Aim User 开始------------------------//

(function() {
    function AimUser(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        var usersel;
        var seltype = "single";
        var relateId = "";
        var popafter = null;
        var rendering = true;
        var width = null;
        function init() {

            relateId = htmele.getAttribute("RelateId");
            popafter = htmele.getAttribute("popafter");
            var extendParam = htmele.getAttribute("extparams") || "";    //Modify by WGM 8/22

            width = htmele.style && htmele.style.width ? htmele.style.width.replace("px", "") : 180;
            seltype = htmele.getAttribute("seltype") == "multi" ? "multi" : "single";
            usersel = new Ext.ux.form.AimUser({ allowBlank: htmele.getAttribute("required") == "true" ? false : true,
                id: htmele.id + 'usersel',
                extParams: extendParam,
                renderTo: htmele.parentNode,
                removeValuesFromStore: false,
                width: width,
                emptyText: '姓名拼音首字母或工号',
                seltype: seltype,
                popAfter: function(rtn) {
                    if (rtn && rtn.data) {
                        if (popafter && typeof (eval(popafter)) == "function") {
                            if (rendering) {
                                rendering = false;
                                if ($("#" + relateId).val() != "")
                                    return;
                            }
                            eval(popafter).call(this, rtn, true);
                        }
                        if (seltype == "single") {
                            $("#" + htmele.id).val(rtn.data.Name);
                            $("#" + relateId).val(rtn.data.UserID);
                        }
                        else {
                            var ids = "";
                            var names = "";
                            $.each(rtn.data, function(i) {
                                ids += rtn.data[i].UserID + ",";
                                names += rtn.data[i].Name + ",";
                            });
                            if (ids.length > 0) {
                                ids = ids.substring(0, ids.length - 1);
                                names = names.substring(0, names.length - 1);
                            }
                            $("#" + htmele.id).val(names);
                            $("#" + relateId).val(ids);
                        }
                    }
                },
                removeItem: function(bs, v, rec) {
                    if (v) {
                        if (seltype == "single") {
                            $("#" + htmele.id).val("");
                            $("#" + relateId).val("");
                            if (popafter && typeof (eval(popafter)) == "function") {
                                if (rendering) {
                                    rendering = false;
                                    return;
                                }
                                eval(popafter).call(this, { data: { WorkNo: "", UserID: "", Name: ""} }, true);
                            }
                        }
                        else {
                            if (v.data && v.data.UserID) {
                                $("#" + htmele.id).val("");
                                $("#" + relateId).val("");
                                if (this.getValueEx().length > 0) {
                                    var ids = "";
                                    var names = "";
                                    var vals = this.getValueEx();
                                    $.each(vals, function(i) {
                                        ids += vals[i].UserID + ",";
                                        names += vals[i].Name + ",";
                                    });
                                    if (ids.length > 0) {
                                        ids = ids.substring(0, ids.length - 1);
                                        names = names.substring(0, names.length - 1);
                                    }
                                    $("#" + htmele.id).val(names);
                                    $("#" + relateId).val(ids);
                                }
                                else {
                                    this.reset();
                                    $("#" + htmele.id).val("");
                                    $("#" + relateId).val("");
                                }
                            }
                        }
                    }
                }
            });
            htmlele.hide();
            htmlele.change(function() {
                setValue(htmlele.val());
            });
        }

        init();

        function getValue() {
            htmlele.val();
        }

        function setValue(val) {
            if (val && val != undefined && val != "undefined") {
                if ($("#" + relateId).val() || AimState["frmdata"]) {
                    if (seltype == "single") {
                        usersel.setValueEx({ UserID: $("#" + relateId).val() || AimState["frmdata"][relateId], Name: val });
                    }
                    else {
                        var ids = $("#" + relateId).val() || AimState["frmdata"][relateId];
                        var names = val;
                        if (ids && ids != "") {
                            ids = ids.split(",");
                            names = names.split(",");
                            var arr = [];
                            $.each(ids, function(i) {
                                if (ids[i]) {
                                    arr.push({ UserID: ids[i], Name: names[i] });
                                }
                            });
                            usersel.setValueEx(arr);
                        }
                    }
                }
            }
        }
        function setReadOnly(bool) {
            if (bool)
                usersel.disable();
            else
                usersel.enable();
        }
        function setDisabled(bool) {
            this.setReadOnly(bool);
        }

        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue,
            "setReadOnly": setReadOnly,
            "setDisabled": setDisabled
        });

    }

    $.extend(true, window, { Aim: { User: AimUser} });
} ());

//------------------------Aim User 结束------------------------//

//------------------------Aim Sign 开始------------------------//

(function() {
    function AimSign(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        var usersel;
        var seltype = "single";
        var relateId = "";
        var signPic;
        var width = 70;
        var height = 25;
        function init() {
            signPic = "<image width='" + width + "' height='" + height + "' src='" + DOWNLOAD_Sign_URL + "?UserId=" + htmlele.val() + "'/>";
            htmlele.after(signPic);
            signPic = htmlele.next();
            //signPic.css({ cursor: "hand" });
            htmlele.hide();
            htmlele.change(function() {
                setValue(htmlele.val());
            });
        }

        init();

        function getValue() {
            htmlele.val();
        }

        function setValue(val) {
            if (htmlele.val() || AimState["frmdata"]) {
                if (seltype == "single") {
                    signPic.attr("src", DOWNLOAD_Sign_URL + "?UserId=" + val);
                    if (val == "" || val == null) {
                        signPic.css({ display: "none" });
                    }
                    else {
                        signPic.css({ display: "" });
                    }
                }
                else {
                    var ids = val;
                    if (ids) {
                        ids = ids.split(",");
                        var arr = [];
                        $.each(ids, function(i) {
                            if (ids[i]) {
                                signPic.src = DOWNLOAD_Sign_URL + "?UserId=" + val;
                            }
                        });
                    }
                }
            }
        }

        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue
        });

    }

    $.extend(true, window, { Aim: { Sign: AimSign} });
} ());

//------------------------Aim Sign 结束------------------------//


//------------------------Aim 消息框控件 开始------------------------//

(function() {
    function AimDialog(htmele) {
        var DLG_TMPL = '<div id="__maindlg" title="提示" style="display:none;"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span><span name="__content"></span></p></div>';

        var htmlele = htmlele;
        var mode = "";  // 消息框模式

        init();

        function init() {
            if (typeof (Ext) == "object" && typeof (Ext.MessageBox) == "object") {
                mode = "ext";
            } else if (jQuery.ui && $(htmlele).dialog) {
                mode = "jqui";
            }

            switch (mode) {
                case "ext":
                    extInit();
                    break;
                case "jqui":
                default:
                    jquiInit();
                    break;
            }
        }

        // jQuery UI模式的初始化
        function jquiInit() {
            if (!htmlele) {
                $("body").append(DLG_TMPL);

                htmlele = $("#__maindlg")[0];
                dialog({ autoOpen: false })
            } else {
                var autoOpen = $(htmlele).attr("autoOpen");
                dialog({ autoOpen: autoOpen });
            }

            $(htmlele).css("z-index", 10002);
        }

        // ext js模式的初始化
        function extInit() { }

        // 显示对话框
        function dialog(opts) {
            if (mode === "jqui") {
                $(htmlele).dialog(opts);
            } else if (mode === "ext") {
                Ext.MessageBox.show(opts);
            }
        }

        // 显示消息框类型
        function show(msg, title, type, width) {
            title = title || "提示";
            if (mode === "jqui") {
                resetContent(title, msg, type);

                dialog({
                    modal: true,
                    buttons: {
                        Ok: function() {
                            $(this).dialog('close');
                        }
                    }
                });
            } else if (mode === "ext") {
                var msgWidth = width || 300;
                Ext.MessageBox.show({
                    title: title, msg: msg, icon: getExtIcon(type),
                    width: msgWidth, buttons: Ext.MessageBox.OK
                });
            }
        }

        // 提示
        function confirm(msg, title, type, width) {
            title = title || "提示";
            if (mode === "ext") {
                var msgWidth = width || 300;

                Ext.MessageBox.confirm(title, msg, function(btn) {
                    if (btn == "yes") {
                        return true;
                    } else {
                        return false;
                    }
                }
                    );
            } else {
                return confirm(msg);
            }
        }

        function getExtIcon(type) {
            var type = type || "info";
            var rtn = Ext.MessageBox.INFO;

            switch (type.toString().toLowerCase()) {
                case "alert":
                case "warning":
                    rtn = Ext.MessageBox.WARNING;
                    break;
                case "error":
                    rtn = Ext.MessageBox.ERROR;
                    break;
                case "info":
                case "notice":
                    rtn = Ext.MessageBox.INFO;
                    break;
                case "question":
                    rtn = Ext.MessageBox.QUESTION;
                    break;
            }

            return rtn;
        }

        function resetContent(title, msg, type) {
            if ($(htmlele).dialog) { $(htmlele).dialog("destroy"); }
            if (title) { $(htmlele).attr("title", title); }
            if (msg) { $(htmlele).find("[name='__content']").html(msg) }
            if (type) { $(htmlele).find(".ui_icon").attr("style", "ui-icon  ui-icon-" + type); }
        }

        // Public API
        $.extend(this, {
            // Methods
            "show": show,   // 提交表单
            "confirm": confirm   // 提交表单
        });

    }

    // Aim.Dialog
    $.extend(true, window, { Aim: { Dialog: AimDialog} });
} ());

//------------------------Aim 消息框控件 结束------------------------//

/*  创建fusionchart  start by Phg 20120616*/
function CreateFusionChart(obj) {
    var jsonarray = new Array();
    var mychart, chartconfig, fieldlabelname, fieldvalue, fieldvaluename, total;
    switch (obj.type) {
        case 'Column3D':
            mychart = new FusionCharts("/FusionChart32/Column3D.swf", "myChartId", obj.width, obj.height);
            for (var j = 0; j < obj.data.length; j++) {
                if (obj.valueField) {
                    jsonarray.push({ label: eval('obj.data[j].' + obj.labelField), value: eval("obj.data[j]." + obj.valueField),
                        link: obj.link ? obj.link + '\'' + eval('obj.data[j].' + obj.labelField) + '\')' : ''
                    });
                }
            }
            chartconfig = { caption: obj.caption, xAxisName: obj.xAxisName, yAxisName: obj.yAxisName, numberSuffix: obj.numberSuffix, unescapeLinks: '0',
                decimalPrecision: 2, chartTopMargin: obj.chartTopMargin, formatNumberScale: obj.formatNumberScale,
                showYAxisValues: obj.showYAxisValues ? obj.showYAxisValues : '1'
            };
            mychart.setJSONData({ chart: chartconfig, data: jsonarray });
            mychart.render(obj.renderTo);
            break;
        case 'Doughnut3D':
            mychart = new FusionCharts("/FusionChart32/Doughnut3D.swf", "myChartId", obj.width, obj.height);
            for (var j = 0; j < obj.data.length; j++) {
                if (obj.valueField) {
                    jsonarray.push({ label: eval('obj.data[j].' + obj.labelField), value: eval("obj.data[j]." + obj.valueField)
                    });
                }
            }
            chartconfig = { caption: obj.caption, xAxisName: obj.xAxisName, yAxisName: obj.yAxisName, decimalPrecision: 2,
                formatNumberScale: obj.formatNumberScale
            };
            mychart.setJSONData({ chart: chartconfig, data: jsonarray });
            mychart.render(obj.renderTo);
            break;
        case 'Pie3D':
            mychart = new FusionCharts("/FusionChart32/Pie3D.swf", "myChartId", obj.width, obj.height);
            for (var j = 0; j < obj.data.length; j++) {
                if (obj.valueField) {
                    jsonarray.push({ label: eval("obj.data[j]." + obj.labelField), value: eval('obj.data[j].' + obj.valueField), link: obj.link ? obj.link + '\'' + eval('obj.data[j].' + obj.labelField) + '\')' : ""
                    });
                }
            }
            chartconfig = { caption: obj.caption, numberPrefix: obj.numberPrefix, showPercentValues: '1', bgColor: obj.bgColor, unescapeLinks: '0',
                formatNumberScale: obj.formatNumberScale
            };
            mychart.setJSONData({ chart: chartconfig, data: jsonarray });
            mychart.render(obj.renderTo);
            break;
        case 'MSColumn3D':
            var categoryarray = new Array();
            for (var i = 0; i < obj.data.length; i++) {
                categoryarray.push({ label: eval("obj.data[i]." + obj.labelField) })
            }
            var datasetarray = new Array();
            for (var j = 0; j < obj.seriesarray.length; j++) {
                var dataarray = new Array();
                for (var k = 0; k < obj.data.length; k++) {
                    dataarray.push({ value: eval("obj.data[k]." + obj.fieldarray[j]), link: obj.link ? obj.link + '\'' + eval("obj.data[k]." + obj.labelField) + '\')' : "" });
                }
                datasetarray.push({ SeriesName: obj.seriesarray[j], data: dataarray });
            }
            var jsondata = { chart: { caption: obj.caption, decimalPrecision: obj.decimalPrecision, rotateValues: '1', unescapeLinks: '0',
                formatNumberScale: obj.formatNumberScale, yAxisName: obj.yAxisName, placeValuesInside: '1', showYAxisValues: obj.showYAxisValues,
                chartTopMargin: '0', chartBottomMargin: '10'
            },
                categories: { category: categoryarray },
                dataset: datasetarray
            };
            mychart = new FusionCharts("/FusionChart32/MSColumn3D.swf", "myChartId", obj.width, obj.height);
            mychart.setJSONData(jsondata);
            mychart.render(obj.renderTo);
            break;
        case 'ZomeLine':
            var categoryarray = new Array();
            for (var i = 0; i < obj.data.length; i++) {
                categoryarray.push({ label: eval("obj.data[i]." + obj.labelField) });
            }
            var datasetarray = new Array();
            for (var k = 0; k < obj.seriesarray.length; k++) {
                var dataarray = new Array();
                for (var j = 0; j < obj.data.length; j++) {
                    dataarray.push({ value: eval("obj.data[j]." + obj.seriesarray[k]) });
                }
                datasetarray.push({ Seriesname: obj.seriesarray[k], data: dataarray });
            }
            var jsondata = { chart: { caption: obj.caption, xaxisname: obj.xaxisname, yaxisname: obj.yaxisname, palette: "3",
                formatNumberScale: obj.formatNumberScale, slantLabels: '0', labelDisplay: 'None'
            },
                categories: { category: categoryarray }, dataset: datasetarray
            };
            mychart = new FusionCharts("/FusionChart32/ZoomLine.swf", "myChartId", obj.width, obj.height);
            mychart.setJSONData(jsondata);
            mychart.render(obj.renderTo);
            break
        case 'Area2D':
            var labelarray = new Array();
            mychart = new FusionCharts("/FusionChart32/Area2D.swf", "myChartId", "600", "400");
            for (var i = 0; i < obj.data.records.length; i++) {
                if (obj.config.labelfield) {
                    if (jQuery.inArray(eval("obj.data.records[i]." + obj.config.labelfield), labelarray) < 0) {
                        labelarray.push(eval("obj.data.records[i]." + obj.config.labelfield));
                    }
                }
                else {
                    AimDlg.show("请配置labelField字段！");
                    return;
                }
            }
            for (var j = 0; j < labelarray.length; j++) {
                total = 0;
                if (obj.config.valuefield) {
                    fieldvalue = 0;
                    fieldvaluename = obj.config.valuefield;
                }
                for (var k = 0; k < obj.data.records.length; k++) {
                    if (labelarray[j] == eval("obj.data.records[k]." + obj.config.labelfield)) {
                        total++;
                        if (obj.config.valuefield) {
                            fieldvalue = fieldvalue + eval("obj.data.records[k]." + obj.config.labelfield);
                        }
                    }
                }
                if (obj.config.valueField) {
                    jsonarray.push({ "label": labelarray[j], "value": fieldvalue, "color": obj.color[j] });
                }
                else {
                    jsonarray.push({ "label": labelarray[j], "value": total, "color": obj.color[j] });
                }
            }
            chartconfig = { "caption": obj.config.caption, "xAxisName": obj.config.xAxisName, "yAxisName": obj.config.yAxisName, "numberPrefix": obj.config.numberPrefix };
            mychart.setJSONData({ "chart": chartconfig, "data": jsonarray });
            mychart.render(obj.renderTo);
            break;
        case 'Line':
            mychart = new FusionCharts("/FusionChart32/Line.swf", "myChartId", obj.width, obj.height);
            for (var j = 0; j < obj.data.length; j++) {
                if (obj.valueField) {
                    jsonarray.push({ label: eval('obj.data[j].' + obj.labelField), value: eval("obj.data[j]." + obj.valueField),
                        link: obj.link + obj.params + eval('obj.data[j].' + obj.labelField), color: obj.colors[j]
                    });
                }
            }
            chartconfig = { caption: obj.caption, xAxisName: obj.xAxisName, yAxisName: obj.yAxisName, numberSuffix: obj.numberSuffix,
                decimalPrecision: 2, chartTopMargin: obj.chartTopMargin, aboutMenuItemLabel: 'HELLO', aboutMenuItemLink: "n-http://www.sina.com.cn"
            };
            mychart.setJSONData({ chart: chartconfig, data: jsonarray });
            mychart.render(obj.renderTo);
            break;
        case 'MSLine':
            var categoryarray = new Array();
            for (var i = 0; i < obj.data.length; i++) {
                categoryarray.push({ label: eval("obj.data[i]." + obj.labelField) })
            }
            var datasetarray = new Array();
            for (var j = 0; j < obj.seriesarray.length; j++) {
                var dataarray = new Array();
                for (var k = 0; k < obj.data.length; k++) {
                    dataarray.push({ value: eval("obj.data[k]." + obj.fieldarray[j]), link: obj.link ? obj.link + '\'' + eval("obj.data[k]." + obj.labelField) + '\')' : "" });
                }
                datasetarray.push({ SeriesName: obj.seriesarray[j], data: dataarray });
            }
            var jsondata = { chart: { caption: obj.caption, decimalPrecision: obj.decimalPrecision, unescapeLinks: '0',
                formatNumberScale: obj.formatNumberScale, yAxisName: obj.yAxisName, showYAxisValues: obj.showYAxisValues,
                chartTopMargin: '0', chartBottomMargin: '10'
            },
                categories: { category: categoryarray },
                dataset: datasetarray
            };
            mychart = new FusionCharts("/FusionChart32/MSLine.swf", "myChartId", obj.width, obj.height);
            mychart.setJSONData(jsondata);
            mychart.render(obj.renderTo);
            break;

        case 'StackedColumn3D':
            var labeljson = new Array();
            for (var i = 0; i < obj.data.records.length; i++) {
                labeljson.push({ "label": eval("obj.data.records[i]." + obj.labelfield) });
            }
            var datasetarray = new Array();
            for (var i = 0; i < obj.seriesfieldarray.length; i++) {
                var tempdata = new Array();
                for (var j = 0; j < labeljson.length; j++) {
                    for (var k = 0; k < obj.data.records.length; k++) {
                        if (eval("obj.data.records[k]." + obj.labelfield) == labeljson[j].label) {
                            tempdata.push({ "value": eval("obj.data.records[k]." + obj.seriesfieldarray[i]) });
                        }
                    }
                }
                datasetarray.push({ "seriesname": obj.seriesnamearray[i], "data": tempdata });
            }
            var jsoncolumn3D = { "chart": { "caption": obj.config.caption, "xAxisName": obj.config.xAxisName, "yAxisName": obj.config.yAxisName, "formatNumberScale": 0, "numberPrefix": '￥', "numdivlines": 1, "divlineThickness": 2, "divLineColor": "008E8E", "divLineValue": 4000, "yAxisMaxValue": 8000 },
                "categories": { "category": labeljson },
                "dataset": datasetarray
            };
            mychart = new FusionCharts("/FusionChart32/StackedBar3D.swf", "myChartId", "600", "400");
            mychart.setJSONData(jsoncolumn3D);
            mychart.render(obj.renderTo);
            break;
        case "AngularGauge":
            var chart = {
                caption: 'hello',
                bgColor: "FFFFFF", upperLimit: "100", lowerLimit: "0",
                showLimits: "1", baseFontColor: "666666", majorTMNumber: "11",
                majorTMColor: "666666", majorTMHeight: "8", minorTMNumber: "5",
                minorTMColor: "666666", minorTMHeight: "3", pivotRadius: "20",
                showGaugeBorder: "0", gaugeOuterRadius: "100", gaugeInnerRadius: "90",
                gaugeOriginX: "170", gaugeOriginY: "170", gaugeScaleAngle: "320",
                displayValueDistance: "10", placeValuesInside: "1", gaugeFillMix: "",
                pivotFillMix: "{F0EFEA}, {BEBCB0}", pivotBorderColor: "BEBCB0", pivotfillRatio: "80,20", showShadow: "0"
            };
            var color = [
            {
                minvalue: "0",
                "maxvalue": "80",
                "code": "00FF00",
                "alpha": "0"
            },
            {
                "minvalue": "80",
                "maxvalue": "100",
                "code": "FF0000",
                "alpha": "50"
            }
        ];
            var dial = [
            {
                value: obj.value,
                "bordercolor": "FFFFFF",
                "bgcolor": "bebcb0, f0efea, bebcb0",
                "borderalpha": "0",
                "basewidth": "10",
                "topwidth": "3"
            }
        ];
            var groups = [
            {
                "x": "170",
                "y": "170",
                "items": [
                    {
                        "type": "circle",
                        "x": "0",
                        "y": "0",
                        "radius": "150",
                        "bordercolor": "bebcb0",
                        "fillasgradient": "1",
                        "fillcolor": "f0efea, bebcb0",
                        "fillratio": "85,15"
                    },
                    {
                        "type": "circle",
                        "x": "0",
                        "y": "0",
                        "radius": "120",
                        "fillcolor": "bebcb0, f0efea",
                        "fillratio": "85,15"
                    },
                    {
                        "type": "circle",
                        "x": "0",
                        "color": "FFFFFF",
                        "y": "0",
                        "radius": "100",
                        "bordercolor": "f0efea"
                    }
                ]
            }
        ];
            var jsondata = { chart: chart, colorrange: { color: color }, dials: { dial: dial }, annotations: { groups: groups} };
            mychart = new FusionCharts("/FusionChart32/AngularGauge.swf", "myChartId", "620", "300");
            mychart.setJSONData(jsondata);
            mychart.render(obj.renderTo);
            break;
    }
}
/*  创建fusionchart  end by Phg 20120616*/


//------------------------Aim CustomerQuickSel by cc 开始------------------------//

(function() {
    function AimCustomerQuickSel(htmele) {
        var htmlele = typeof (htmele) == "object" ? $("#" + htmele.id) : $("#" + htmele);
        var customersel;
        var PopUrl;
        var mode = "single";
        var relateId = "";
        var seltype = "";
        var extParams = "";
        var popStyle = "";
        var width = 120;
        function init() {
            relateId = htmele.getAttribute("RelateId");
            seltype = htmele.getAttribute("seltype") || "single";
            popStyle = htmele.getAttribute("popstyle") || "";
            PopUrl = htmele.getAttribute("popurl");
            extParams = htmele.getAttribute("extparams") || "";
            width = htmele.style && htmele.style.width ? htmele.style.width.replace("px", "") : 180;
            mode = htmele.getAttribute("seltype");
            this.customersel = new Ext.ux.form.AimCustomerQuickSel({
                allowBlank: htmele.getAttribute("required") == "true" ? false : true,
                id: htmele.id + 'customersel',
                renderTo: htmele.parentNode,
                emptyText: '输入公司代码或点击后面放大镜',
                seltype: seltype,
                extParams: extParams,
                PopUrl: PopUrl,
                popStyle: popStyle,
                mode: mode,
                width: width,
                relateId: relateId,
                popAfter: function(rtn) {
                    if (rtn && rtn.data && (rtn.data.Id || rtn.data.ID)) {
                        $("#" + htmele.id).val(rtn.data.Name);
                        $("#" + relateId).val(rtn.data.Id || rtn.data.ID);
                    }
                }
            });
            htmlele.hide();
            htmlele.change(function() {
                setValue(htmlele.val());
            });
        }

        init();

        function getValue() {
            this.htmlele.val();
        }

        function setValue(val) {
            if ($("#" + relateId).val() || AimState["frmdata"]) {
                this.customersel.setValueEx({ Id: $("#" + relateId).val() || AimState["frmdata"][relateId], Name: val });
            }
        }
        function setReadOnly(bool) {
            if (bool)
                this.customersel.disable();
            else
                this.customersel.enable();
        }
        function setDisabled(bool) {
            this.setReadOnly(bool);
        }

        // Public API
        $.extend(this, {
            // Methods
            "getValue": getValue,
            "setValue": setValue,
            "setReadOnly": setReadOnly,
            "setDisabled": setDisabled
        });

    }

    $.extend(true, window, { Aim: { CustomerQuickSel: AimCustomerQuickSel} });
} ());

//------------------------Aim Customer 结束------------------------//