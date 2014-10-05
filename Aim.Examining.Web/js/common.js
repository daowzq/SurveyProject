/// <reference path="jquery-1.4.1-vsdoc2.js" />

//
//---------------------------------JQuery扩展开始--------------------------------------------------------------
//
try {
    if (Ext && Ext.util && Ext.util.CSS.swapStyleSheet)
        Ext.util.CSS.swapStyleSheet('theme', '/App_Themes/Ext/css/xtheme-gray.css'); //动态设置Ext主题CSS样式
}
catch (e) { }
$.extend({
    getJsonObj: function(jsonstr) {
        ///	<summary>
        /// 获取由Json字符串获取Json对象
        ///	</summary>
        ///	<param name="jsonstr" type="String">
        /// jsont字符串
        ///	</param>
        ///	<returns type="Object" />
        try {
            return eval("(" + jsonstr + ")");
        } catch (e) {
            return null;
        }
    },

    // 转换对象为Json字符串
    getJsonString: function(obj, escapedflag) {
        ///	<summary>
        /// 获取指定对象的Json字符串
        ///	</summary>
        ///	<param name="jsonstr" type="Object">
        /// 对象
        ///	</param>
        ///	<returns type="Object">jsont字符串<returns>
        var type = typeof (obj);

        switch (type.toLowerCase()) {
            case 'string':
                var objstr = obj.toString();
                if (escapedflag == true) {
                    objstr = escape(obj.toString());
                } else if (escapedflag == false) {
                    objstr = unescape(obj.toString());
                }
                return "\"" + $.encodeJsonString(objstr) + "\"";
                //return "\"" + obj.toString() + "\"";
            case 'boolean':
            case 'number':
                return obj.toString();
            case 'object':
                if (obj.constructor == Array) {
                    var strArray = '[';
                    for (var i = 0; i < obj.length; ++i) {
                        var value = '';
                        if (obj[i]) {
                            value = $.getJsonString(obj[i]);
                        }
                        strArray += value + ',';
                    }
                    if (strArray.charAt(strArray.length - 1) == ',') {
                        strArray = strArray.substr(0, strArray.length - 1);
                    }
                    strArray += ']';
                    return strArray;
                } else if (obj.constructor == Date) {
                    return "\"" + $.encodeJsonString($.getAdjustedDate(obj)) + "\"";
                }
            default:
                {
                    var serialize = '{';
                    for (var key in obj) {
                        if (obj[key] != undefined && typeof (obj[key]) != "function") {
                            var subserialize = 'null';
                            subserialize = $.getJsonString(obj[key]);
                            serialize += '' + key + ' : ' + subserialize + ',';
                        }
                    }
                    if (serialize.charAt(serialize.length - 1) == ',') {
                        serialize = serialize.substr(0, serialize.length - 1);
                    }
                    serialize += '}';
                    return serialize;
                }
        }
    },

    // 对对象进行编码
    getEscapedData: function(obj, flag) {
        ///	<summary>
        /// 获取指定对象escape编码后对象
        ///	</summary>
        ///	<param name="obj" type="Object/String">
        /// 对象
        ///	</param>
        ///	<returns type="Object">Object/String<returns>
        var type = typeof (obj);

        switch (type) {
            case 'string':
                if (flag) {
                    return escape(obj);
                } else {
                    return unescape(obj);
                }
                break;
            case 'object':
                var cobj;
                if (obj.constructor == Array) {
                    cobj = [];
                    $.each(obj, function() {
                        cobj[i] = $.getEscapedData(this, flag);
                    });
                } else if (obj) {
                    cobj = {};
                    for (var key in obj) {
                        cobj[key] = $.getEscapedData(obj[key], flag);
                    }
                }
                return cobj;
                break;
            default:
                return obj;
        }
    },

    htmlEncode: function(input) {
        var converter = document.createElement("DIV");
        converter.innerText = input;
        var output = converter.innerHTML;
        converter = null;
        return output;
    },

    htmlDecode: function(input) {
        var converter = document.createElement("DIV");
        converter.innerHTML = input;
        var output = converter.innerText;
        converter = null;
        return output;
    },

    encodeJsonString: function(jstr) {
        ///	<summary>
        /// 格式化JsonString(转换特殊字符)
        ///	</summary>
        ///	<param name="jstr" type="String">
        /// 普通字符串
        ///	</param>
        ///	<returns type="jstr">jsont字符串<returns>
        jstr = jstr.toString().replace(/(\\)/g, "\\$1")
            .replace(/(\/)/g, "\\$1")
            .replace(new RegExp('(["\"])', 'g'), "\\\"");

        return jstr;
    },

    mergeJson: function(obj1, obj2) {
        ///	<summary>
        ///	合并json属性
        ///	</summary>
        for (var z in obj2) {
            if (obj2.hasOwnProperty(z)) {
                obj1[z] = obj2[z];
            }
        }
        return obj1;
    },

    getEval: function(evalstr) {
        ///	<summary>
        ///	得到eval后的返回值,若执行出错则返回null
        ///	</summary>
        ///	<param name="jsonstr" type="String">
        /// 要执行的语句
        ///	</param>
        try {
            return eval(evalstr);
        } catch (e) {
            return null;
        }
    },

    cloneObj: function(obj) {
        ///	<summary>
        ///	克隆对象
        ///	</summary>
        ///	<param name="jsonstr" type="String">
        /// 要克隆对象
        ///	</param>
        if (typeof (obj) != 'object') return obj;
        if (obj == null) return obj;

        var newObj = new Object();

        for (var i in obj) {
            newObj[i] = $.cloneObj(obj[i]);
        }

        return newObj;
    },

    isSetted: function(obj) {
        ///	<summary>
        ///	判断某对象是否已被设置值
        ///	</summary>
        ///	<param name="obj" type="Object">
        /// 要判断的对象
        ///	</param>
        return typeof (obj) != "undefined" && obj != null;
    },

    getCssRule: function() {
        ///	<summary>
        ///	用 javascript 获取页面上有选择符的 CSS 规则 包括'内部样式块'和'外部样式表文件' 
        ///	</summary>
        var styleSheetLen = document.styleSheets.length; // 样式总数 

        if (!styleSheetLen) return;

        // 样式规则名称，IE 和 FireFox 不同 
        var ruleName = (document.styleSheets[0].cssRules) ? 'cssRules' : 'rules'; //FireFox:cssRules || IE:rules 

        // 初始结果 
        var result = {};
        var totalRuleLen = 0;
        var totalSelectorLen = 0;
        var totalProperty = 0;
        for (var i = 0; i < styleSheetLen; i++) {
            // 获取每个样式表定义 
            var styleSheet = document.styleSheets[i];
            // 每个样式表的规则数 
            var ruleLen = styleSheet[ruleName].length;
            totalRuleLen += ruleLen;
            for (var j = 0; j < ruleLen; j++) {
                // 获取当前规则的选择符 
                // 传入选择符转换为小写 
                var selectors = styleSheet[ruleName][j].selectorText.toLowerCase().split(",");
                var selectorLen = selectors.length;
                totalSelectorLen += selectorLen;
                for (var s = 0; s < selectorLen; s++) {
                    // 去除选择符左右的空格
                    selector = selectors[s].replace(/(^\s*)|(\s*$)/g, "");
                    // 初始化当前选择符
                    result[selector] = {};
                    // 获取当前样式 
                    var styleSet = styleSheet[ruleName][j].style;
                    for (property in styleSet) {
                        // 获取规则 
                        if (styleSet[property] && property != 'cssText') {
                            //alert(selector +'=>'+ property +':'+ styleSet[property]) 
                            result[selector][property] = styleSet[property];
                            totalProperty += 1;
                        }
                    }
                }
            }
        }
        // 统计数据 
        result.totalSheet = styleSheetLen;    //样式块 
        result.totalRule = totalRuleLen;    //规则数 
        result.totalSelector = totalSelectorLen;    //选择符 
        result.totalProperty = totalProperty;    //属性 
        return result;
    },

    //------------------------类型转换扩展开始-------------------------//

    toBool: function(value) {
        ///	<summary>
        ///	将字符串转化为bool类型
        ///	</summary>
        ///	<param name="str" type="String">
        /// 输入字符串
        ///	</param>
        ///	<returns type="Bool" />
        if (typeof (value) == "boolean") {
            return value;
        }
        if (!value) {
            return false;
        }
        value = (value + "").toLowerCase();
        if (value == "true" || value == "t" || value == "yes" || value == "on" || value == "ok") {
            return true;
        }
        else {
            return false;
        }
    },

    toInt: function(value) {
        ///	<summary>
        ///	将字符串转化为Int类型
        ///	</summary>
        ///	<param name="str" type="String">
        /// 输入字符串
        ///	</param>
        ///	<returns type="Integer" />
        return parseInt(value);
    },

    toFloat: function(value, sb) {
        ///	<summary>
        ///	转换为浮点数
        ///	</summary>
        ///	<param name="sb" type="Integer">
        /// 保留小数位数
        ///	</param>
        if (!sb || typeof (sb) != "number") {
            return parseFloat(value.toString());
        } else {
            var powInt = Math.pow(10, sb);
            return (parseInt(parseFloat(value.toString()) * powInt) / powInt);
        }
    },

    toDate: function(str, divChar) {
        ///	<summary>
        ///	将指定格式的字符串转化为日期对象
        ///	</summary>
        ///	<param name="str" type="String">
        /// 输入字符串,格式为（yyyy-mm-dd hh:mm:ss）
        ///	</param>
        ///	<returns type="Date"></returns>
        try {
            var divChar = divChar || "-";
            if (str.indexOf(divChar) < 0) {
                divChar = "/";
            }

            var parts = str.split(" ");
            var dp = parts[0].split(divChar);
            //var dt = new Date(); //parseInt("09")等有BUG
            //dt.setFullYear(parseInt(parseFloat(dp[0])),parseInt(parseFloat((dp[1])-1)),parseInt(parseFloat(dp[2])));
            var dt = new Date(dp[0], dp[1] - 1, dp[2]);
            if (parts.length > 1) {
                var tt = parts[1].split(":");
                dt.setHours(parseInt(tt[0]), parseInt(tt[1]), parseInt(tt[2]));
            }
            else
                dt.setHours(0, 0, 0, 0);
            return dt;
        } catch (e) {
            return null;
        }
    },

    //------------------------类型转换扩展结束-------------------------

    setDisabled: function(id, st) {
        ///	<summary>
        ///	将HTML元素设置为不可控/可控状态
        ///	</summary>
        ///	<param name="id" type="String">元素的ID</param>
        ///<param name="st" type="Boolean">状态</param>
        document.getElementById(id).disabled = st;
        $("#" + id).attr("disabled", st);
    },

    setReadonly: function(id, st) {
        ///	<summary>
        ///	将HTML元素设置为不可编辑/可编辑状态
        ///	</summary>
        ///	<param name="id" type="String">元素的ID</param>
        ///<param name="st" type="Boolean">状态</param>
        document.getElementById(id).disabled = st;
        $("#" + id).attr("readOnly", st);
    },

    ensureExec: function(func, interval, times) {
        ///	<summary>
        ///	确保执行某方法(当func返回true时停止执行，返回false则继续尝试)
        ///	</summary>
        ///	<param name="func" type="Function">执行方法</param>
        ///	<param name="interval" type="Integer">检查间隔</param>
        ///	<param name="times" type="Integer">尝试次数</param>
        interval = interval || 100;
        times = times || 10;

        var execed = false; // 是否已执行
        var triedtimes = 0; // 已尝试次数

        if (typeof (func) == "function") {
            var intervalID = setInterval(function() {
                try {
                    if (execed || triedtimes > times) {
                        clearInterval(intervalID);
                    }

                    if (func.call(this)) {
                        execed = true;
                        clearInterval(intervalID);
                    }
                } catch (ex) { }

                triedtimes++;
            }, interval);
        }
    },

    execOnWinReady: function(win, func, interval) {
        ///	<summary>
        ///	当目标窗口执行完毕时触发
        ///	</summary>
        ///	<param name="win" type="Object">目标窗口</param>
        ///	<param name="func" type="Function">执行方法</param>
        ///	<param name="interval" type="Integer">检查间隔</param>
        if (typeof (win) == "object" && typeof (func) == "function") {
            interval = interval || 100;

            var intervalID = setInterval(function() {
                try {
                    if (win.document.readyState == "complete") {
                        clearInterval(intervalID);

                        func.call(win);
                    }
                } catch (ex) { }
            }, 100);
        }
    },

    centerWin: function(linkStyle, isDialog) {
        ///	<summary>
        ///	得到居中样式字符串
        ///	</summary>
        ///	<param name="linkStyle"  type="String">连接样式</param>
        ///	<param name="isDialog"  type="Boolean">是否为对话框</param>
        if (!linkStyle) return "";
        if (isDialog)
            var sp = new StringParam(linkStyle.toLowerCase());
        else
            var sp = new StringParam(linkStyle.toLowerCase(), ",", "=");
        if (sp.Get("left") || sp.Get("top")) {
            return linkStyle;
        }
        else {
            var width = sp.Get("width");
            if (width == null)
                width = window.screen.width / 2;
            else
                sp.Remove("width");
            var height = sp.Get("height");
            if (height == null)
                height = window.screen.height / 2;
            else
                sp.Remove("height");
            var left = (window.screen.width - width) / 2;
            var top = (window.screen.height - height) / 2;
            return "left=" + left + ",top=" + top + ",width=" + width + ",height=" + height + "," + sp.ToString();
        }
    },

    includeScript: function(file, type) {
        ///	<summary>
        ///	加载Script文件
        ///	</summary>
        ///	<param name="file"  type="String">文件地址</param>
        ///	<param name="type"  type="String">文件类型，默认(text/javascript)</param>
        var head = document.getElementsByTagName('head');
        var script = document.createElement('script');
        script.src = file;
        script.type = type || 'text/javascript';

        if (head) {
            head[0].appendChild(script);
        }
    },

    includeCss: function(file, type) {
        ///	<summary>
        ///	加载Css文件
        ///	</summary>
        ///	<param name="file"  type="String">文件地址</param>
    ///	<param name="type"  type="String">文件类型，默认(text/css)</param>
        var head = document.getElementsByTagName('head');
        var lnk = document.createElement('link');
        lnk.href = file;
        lnk.type = type || 'text/css';
        lnk.rel = 'stylesheet';

        if (head) {
            head[0].appendChild(lnk);
        }
    },

    //------------------------字符串操作开始-------------------------

    getTab: function(len) {
        ///	<summary>
        ///	获得指定数目Tab字符
        ///	</summary>
        ///	<param name="len" type="Integer">Tab串长度</param>
        ///	<returns type="String">返回Tab串</returns>
        if (len == 0) return "";
        var str = "";
        for (var i = 0; i < len; i++)
            str += "\t";
        return str;
    },

    getSpace: function(len, ch) {
        ///	<summary>
        ///	获得指定数目Tab字符
        ///	</summary>
        ///	<param name="len" type="Integer">空字符串长度</param>
        ///	<param name="ch" type="String">填充字符</param>
        ///	<returns type="String">返回空字符串</returns>
        if (len == 0) return "";
        var str = "";
        if (!ch) ch = " ";
        for (var i = 0; i < len; i++) {
            str += ch;
        }
        return str;
    },

    stringLen: function(valuestr) {
        ///	<summary>
        ///	获取字符串长度（Unicode每个字符两个长度）
        ///	</summary>
        var strInput = valuestr;
        var count = strInput.length;
        var len = 0;
        if (count != 0)
            for (var i = 0; i < count; i++) {
            if (strInput.charCodeAt(i) >= 128)
                len += 2;
            else
                len += 1;
        }
        return len;
    },

    isDate: function IsDate(value, fm) {
        ///	<summary>
        ///	判断制定值是否符合制定日期格式
        ///	</summary>
        ///	<param name="value" type="String">给定用于判断的值</param>
        ///	<param name="fm" type="String">日期格式"YYYY-MM-DD","YY-MM-DD",默认"YYYY-MM-DD"</param>
        if (!fm) {
            fm = "YYYY-MM-DD";
        }
        if (fm == "YYYY-MM-DD") {
            var re = /^\d{4}-\d{1,2}-\d{1,2}$/;
            var r = value.match(re);
            if (r == null)
                return false;
            else {
                var s = value.split("-");
                if (s[0].substring(0, 2) < 19 || s[0].substring(0, 2) > 21 || s[1] > 12 || s[1] < 1 || s[2] > 31 || s[2] < 1)
                    return false;
            }
            return true;
        } else if (fm == "YY-MM-DD") {
            var re = /^\d{1,2}-\d{1,2}-\d{1,2}$/;
            var r = value.match(re);
            if (r == null)
                return false;
            else {
                var s = value.split("-");
                if (s[1] > 12 || s[1] < 1 || s[2] > 31 || s[2] < 1)
                    return false;
            }
            return true;
        }

    },

    isDateTime: function(value, minYear, maxYear, hassec) {
        ///	<summary>
        ///	判断制定值是否符合制定日期时间格式
        ///	</summary>
        ///<param name="value" type="String">给定用于判断的值</param>
        ///<param name="minYear" type="Integer">最小年份，默认0</param>
        ///<param name="maxYear" type="Integer">最大年份，默认9999</param>
        ///<param name="hassec" type="Boolean">是否验证秒，默认false</param>
        if (!maxYear) {
            maxYear = 9999;
        }
        if (!minYear) {
            maxYear = 0;
        }
        var reg;
        if (hassec)
            reg = /^(\d+)-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})$/;
        else
            reg = /^(\d+)-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{1,2})$/;
        var r = value.match(reg);
        //如果不验证秒,则将秒默认设置为0
        if (r == null) return false;
        if (!r[6])
            r[6] = 0;
        r[2] = r[2] - 1;
        var d = new Date(r[1], r[2], r[3], r[4], r[5], r[6]);
        if (d.getFullYear() != r[1] || r[1] < minYear || r[1] > maxYear) return false;
        if (d.getMonth() != r[2]) return false;
        if (d.getDate() != r[3]) return false;
        if (d.getHours() != r[4]) return false;
        if (d.getMinutes() != r[5]) return false;
        if (d.getSeconds() != r[6]) return false;
        return true;
    },

    isTime: function(value, hassec) {
        ///	<summary>
        ///	判断指定值是否符合时间格式
        ///	</summary>
        ///<param name="value" type="String">给定用于判断的值</param>
        ///<param name="hassec" type="Boolean">是否验证秒，默认false</param>
        if (typeof (hassec) == "undefined")
            var hassec = false;
        if (hassec) //需要判断秒
        {
            var re = /^\d{1,2}:\d{1,2}:\d{1,2}$/;
            var r = value.match(re);
            if (r == null)
                return false;
            else {
                var s = value.split(":");
                if (s[0] < 0 || s[0] > 23 || s[1] < 0 || s[1] > 59 || s[2] < 0 || s[2] > 59)
                    return false;
            }
            return true;
        } else {
            var re = /^\d{1,2}:\d{1,2}$/;
            var r = value.match(re);
            if (r == null)
                return false;
            else {
                var s = value.split(":");
                if (s[0] < 0 || s[0] > 23 || s[1] < 0 || s[1] > 59)
                    return false;
            }
            return true;

        }
    },

    isFloat: function(value) {
        ///	<summary>
        ///	判断指定值是否符合浮点数格式
        ///	</summary>
        var re = /^\d{1,}$|^\d{1,}\.\d{1,}$/;
        var r = value.match(re);
        if (r == null)
            return false;
        else
            return true;
    },

    isInt: function(value) {
        ///	<summary>
        ///	判断指定值是否符合时间格式
        ///	</summary>
        var re = /^\d{0,}$/;
        var r = value.match(re);
        if (r == null)
            return false;
        else
            return true;
    },

    isEmail: function(value) {
        ///	<summary>
        ///	判断指定值是否符合Email地址格式
        ///	</summary>
        var re = /^\w+@\w+\.\w{2,3}/;
        var r = value.match(re);
        if (r == null)
            return false
        else
            return true;

    },

    isPhone: function(value) {
        ///	<summary>
        ///	判断指定值是否符合电话号码格式
        ///	</summary>
        var re = /^(([0-9]+)-)?\d{7,11}$/;
        var r = value.match(re);
        if (r == null)
            return false
        else
            return true;
    },

    isIDCard: function(value) {
        ///	<summary>
        ///	判断是否合法居民身份证号（中国）
        ///	</summary>
        var _re15 = /^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$/; // 15位
        var _re18 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{4}$/; // 18位

        return (IsValueMatch(value, _re15) || IsValueMatch(value, _re18))
    },

    isValueMatch: function(value, re) {
        ///	<summary>
        ///	验证指定值是否符合指定正则表达式
        ///	</summary>
        var r = value.match(re)
        if (r == null)
            return false
        else
            return true;
    },

    getFileSize: function(fname) {
        ///	<summary>
        ///	得到指定文件的大小,以kb为单位
        ///	</summary>
        ///<param name="fname" type="string">指定文件</param>
        try {
            var FSO = new ActiveXObject("Scripting.FileSystemObject");
            var file = FSO.GetFile(fname);
            var fileSize = Math.ceil(file.Size / 1024);
            return fileSize;
        } catch (e) {
            return -1;
        }
    },

    matchExp: function(value, exp) {
        ///	<summary>
        ///	判断指定文本是否符合制定正则表达式
        ///	</summary>
        ///<param name="value" type="String">指定文本</param>
        ///<param name="exp" type="ExpStr">正则表达式</param>
        var expobj = new RegExp(exp, "i");
        var r = value.match(expobj);
        if (r == null)
            return false;
        else
            return true;
    },

    dateOnly: function(date) {
        ///	<summary>
        ///	获取指定字符串或Date类型的时间部分
        ///	</summary>
        ///<param name="date" type="String/Object">指定字符串</param>
        if (typeof date == 'string')
            return date.split(" ")[0];
        else if (typeof date == 'object')
            return $.getDatePart(date);
    },

    //------------------------字符串操作结束-------------------------

    //------------------------日期类型操作结束-------------------------



    isDateObj: function(obj) {
        if (typeof (obj) != "object") {
            return false;
        } else {
            return obj.constructor == Date;
        }
    },

    /**<doc type="classext" name="Date.getTime">
    <desc>取得当前日期的字符串（hh:mm:ss）</desc>
    <output>返回日期字符串</output>
    </doc>**/
    getTime: function() {
        var dt = new Date();
        return dt.getTimePart();
    },

    /**<doc type="classext" name="Date.getFullDate">
    <desc>取得当前日期的字符串（yyyy-mm-dd hh:mm:ss）</desc>
    <output>返回日期字符串</output>
    </doc>**/
    getFullDate: function(date) {
        date = date || new Date();
        return $.getDatePart(date) + " " + $.getTimePart(date);
    },

    /**<doc type="classext" name="Date.differ">
    <desc>取得两个日期的差值</desc>
    <input>
    <param name="dfrom" type="date">起始日期</param>
    <param name="dto" type="date">结束日期</param>
    <param name="type" type="enum">差值类型</param>
    </input>
    <output type="number">返回差值</output>
    <enum name="type">
    <item text="s">秒</item>
    <item text="n">分</item>
    <item text="h">小时</item>
    <item text="d">天</item>
    <item text="w">周</item>
    </enum>
    </doc>**/
    dateDiff: function(dfrom, dto, type) {
        var dtfrom, dtto;

        if (!type) {
            type = 'd';
        }

        if (typeof (dfrom) == "string" && typeof (dto) == "string") {
            dtfrom = Date.parseDate(dfrom);
            dtto = Date.parseDate(dto);
        }
        else {
            dtfrom = dfrom;
            dtto = dto;
        }

        switch (type) {
            case 's': return Math.floor((dtto - dtfrom) / (1000));
            case 'n': return Math.floor((dtto - dtfrom) / (1000 * 60));
            case 'h': return Math.floor((dtto - dtfrom) / (1000 * 60 * 60));
            case 'd': return Math.floor((dtto - dtfrom) / (1000 * 60 * 60 * 24));
            case 'w': return Math.floor((dtto - dtfrom) / (1000 * 60 * 60 * 24 * 7));
        }
    },

    /**<doc type="classext" name="Date.getTime">
    <desc>取得时间的字符串（ hh:mm:ss）</desc>
    <output>返回时间字符串</output>
    </doc>**/
    getTimePart: function(date) {
        date = date || new Date();
        var hour = date.getHours().toString();
        var minute = date.getMinutes().toString();
        var second = date.getSeconds().toString();
        if (hour.length == 1) hour = "0" + hour;
        if (minute.length == 1) minute = "0" + minute;
        if (second.length == 1) second = "0" + second;
        return (hour + ":" + minute + ":" + second);
    },

    /**<doc type="classext" name="Date.getDate">
    <desc>取得当前日期的字符串（yyyy-mm-dd）</desc>
    <output>返回日期字符串</output>
    </doc>**/
    getDatePart: function(date) {
        date = date || new Date();
        var month = (parseInt(date.getMonth()) + 1).toString();
        var day = date.getDate().toString();
        if (month.length == 1) month = "0" + month;
        if (day.length == 1) day = "0" + day;
        return (date.getFullYear() + "/" + month + "/" + day);
    },

    /**<doc type="classext" name="Date.getAdjustedDate">
    <desc>获取调整时间（若存在时分秒则返回长fullDate否则只返回普通时间段）</desc>
    <output>返回日期字符串</output>
    </doc>**/
    getAdjustedDate: function(date) {
        date = date || new Date();
        if (!date.getHours() && !date.getMinutes() && !date.getSeconds()) {
            return $.getDatePart(date);
        } else {
            return $.getFullDate(date);
        }
    },

    /**<doc type="classext" name="Date.DateAdd">
    <desc>将当前时间加上差值返回日期对象</desc>
    <input>
    <param name="strInterval" type="enum">差值类型</param>
    <param name="Number" type="integer">差值</param>
    </input>
    <enum name="strInterval">
    <item text="s">秒</item>
    <item text="m">分</item>
    <item text="h">小时</item>
    <item text="d">天</item>
    </enum>
    </doc>**/
    dateAdd: function(date, strInterval, Number) {
        var dtTmp = date || new Date();
        switch (strInterval) {
            case 's': return new Date(Date.parse(dtTmp) + (1000 * Number));
            case 'n': return new Date(Date.parse(dtTmp) + (60000 * Number));
            case 'h': return new Date(Date.parse(dtTmp) + (3600000 * Number));
            case 'd': return new Date(Date.parse(dtTmp) + (86400000 * Number));
            case 'w': return new Date(Date.parse(dtTmp) + ((86400000 * 7) * Number));
            case 'q': return new Date(dtTmp.getFullYear(), (dtTmp.getMonth()) + Number * 3, dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
            case 'm': return new Date(dtTmp.getFullYear(), (dtTmp.getMonth()) + Number, dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
            case 'y': return new Date((dtTmp.getFullYear() + Number), dtTmp.getMonth(), dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
        }
    },

    /**<doc type="classext" name="Date.getFrom">
    <desc>获得当前日期在指定类型区间的开始日期对象</desc>
    <input>
    <param name="type" type="enum">区间类型</param>
    </input>
    <enum name="type">
    <item text="h">小时</item>
    <item text="d">天</item>
    <item text="w">周</item>
    <item text="m">月</item>
    <item text="y">年</item>
    </enum>
    <output>返回开始日期对象</output>
    </doc>**/
    getDateFrom: function(type, date)//type=day,week,month,year
    {
        date = date || new Date();
        switch (type.toLowerCase()) {
            case "year":
                return new Date(date.getFullYear(), 0, 1);
            case "quarter":
                return new Date(date.getFullYear(), ((Math.ceil((date.getMonth() + 1) / 3) - 1) * 3), 1);
            case "month":
                return new Date(date.getFullYear(), date.getMonth(), 1);
            case "week":
                return new Date(date.getFullYear(), date.getMonth(), date.getDate() - ((date.getDay() + 6) % 7));
            case "preyear":
                return new Date(date.getFullYear() - 1, 0, 1);
            case "prequarter":
                return new Date(date.getFullYear(), ((Math.ceil((date.getMonth() + 1) / 3) - 1) * 3) - 3, 1);
            case "premonth":
                return new Date(date.getFullYear(), date.getMonth() - 1, 1);
            case "preweek":
                return new Date(date.getFullYear(), date.getMonth(), date.getDate() - ((date.getDay() + 6) % 7) - 7);
            case "nextyear":
                return new Date(date.getFullYear() + 1, 0, 1);
            case "nextquarter":
                return new Date(date.getFullYear(), ((Math.ceil((date.getMonth() + 1) / 3) - 1) * 3) + 3, 1);
            case "nextmonth":
                return new Date(date.getFullYear(), date.getMonth() + 1, 1);
            case "nextweek":
                return new Date(date.getFullYear(), date.getMonth(), date.getDate() - ((date.getDay() + 6) % 7) + 7);
            case "uphalfyear":
                return new Date(date.getFullYear(), 0, 1);
            case "downhalfyear":
                return new Date(date.getFullYear(), 6, 1);
            default:
                return date;
        }
    },

    /**<doc type="classext" name="Date.getTo">
    <desc>获得当前日期在指定类型区间的结束日期对象</desc>
    <input>
    <param name="type" type="enum">区间类型</param>
    </input>
    <enum name="type">
    <item text="h">小时</item>
    <item text="d">天</item>
    <item text="w">周</item>
    <item text="m">月</item>
    <item text="y">年</item>
    </enum>
    <output>返回结束日期对象</output>
    </doc>**/
    getDateTo: function(type, date) {
        date = date || new Date();
        switch (type.toLowerCase()) {
            case "year":
                return new Date(date.getFullYear(), 11, 31);
            case "quarter":
                return new Date(date.getFullYear(), ((Math.ceil((date.getMonth() + 1) / 3) - 1) * 3) + 3, 0);
            case "month":
                return new Date(date.getFullYear(), date.getMonth() + 1, 0);
            case "week":
                return new Date(date.getFullYear(), date.getMonth(), date.getDate() + (7 - date.getDay()));
            case "preyear":
                return new Date(date.getFullYear() - 1, 11, 31);
            case "prequarter":
                return new Date(date.getFullYear(), ((Math.ceil((date.getMonth() + 1) / 3) - 1) * 3), 0);
            case "premonth":
                return new Date(date.getFullYear(), date.getMonth(), 0);
            case "preweek":
                return new Date(date.getFullYear(), date.getMonth(), date.getDate() - date.getDay());
            case "nextyear":
                return new Date(date.getFullYear() + 1, 11, 31);
            case "nextquarter":
                return new Date(date.getFullYear(), ((Math.ceil((date.getMonth() + 1) / 3) - 1) * 3) + 6, 0);
            case "nextmonth":
                return new Date(date.getFullYear(), date.getMonth() + 2, 0);
            case "nextweek":
                return new Date(date.getFullYear(), date.getMonth(), date.getDate() + (14 - date.getDay()));
            case "uphalfyear":
                return new Date(date.getFullYear(), 5, 30);
            case "downhalfyear":
                return new Date(date.getFullYear(), 11, 30);
            default:
                return date;
        }
    }

    //------------------------日期类型操作结束-------------------------
});

/**
* base64 encode / decode
* 
* @location     http://www.webtoolkit.info/
*
*/

var Base64 = {

    // private property
    _keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",

    // public method for encoding
    encode: function(input) {
        var output = "";
        var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
        var i = 0;

        input = Base64._utf8_encode(input);

        while (i < input.length) {

            chr1 = input.charCodeAt(i++);
            chr2 = input.charCodeAt(i++);
            chr3 = input.charCodeAt(i++);

            enc1 = chr1 >> 2;
            enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            enc4 = chr3 & 63;

            if (isNaN(chr2)) {
                enc3 = enc4 = 64;
            } else if (isNaN(chr3)) {
                enc4 = 64;
            }

            output = output +
            this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
            this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);

        }

        return output;
    },

    // public method for decoding
    decode: function(input) {
        var output = "";
        var chr1, chr2, chr3;
        var enc1, enc2, enc3, enc4;
        var i = 0;

        input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

        while (i < input.length) {

            enc1 = this._keyStr.indexOf(input.charAt(i++));
            enc2 = this._keyStr.indexOf(input.charAt(i++));
            enc3 = this._keyStr.indexOf(input.charAt(i++));
            enc4 = this._keyStr.indexOf(input.charAt(i++));

            chr1 = (enc1 << 2) | (enc2 >> 4);
            chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
            chr3 = ((enc3 & 3) << 6) | enc4;

            output = output + String.fromCharCode(chr1);

            if (enc3 != 64) {
                output = output + String.fromCharCode(chr2);
            }
            if (enc4 != 64) {
                output = output + String.fromCharCode(chr3);
            }

        }

        output = Base64._utf8_decode(output);

        return output;

    },

    // private method for UTF-8 encoding
    _utf8_encode: function(string) {
        string = string.replace(/\r\n/g, "\n");
        var utftext = "";

        for (var n = 0; n < string.length; n++) {

            var c = string.charCodeAt(n);

            if (c < 128) {
                utftext += String.fromCharCode(c);
            }
            else if ((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }

        }

        return utftext;
    },

    // private method for UTF-8 decoding
    _utf8_decode: function(utftext) {
        var string = "";
        var i = 0;
        var c = c1 = c2 = 0;

        while (i < utftext.length) {

            c = utftext.charCodeAt(i);

            if (c < 128) {
                string += String.fromCharCode(c);
                i++;
            }
            else if ((c > 191) && (c < 224)) {
                c2 = utftext.charCodeAt(i + 1);
                string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
                i += 2;
            }
            else {
                c2 = utftext.charCodeAt(i + 1);
                c3 = utftext.charCodeAt(i + 2);
                string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
                i += 3;
            }

        }

        return string;
    }

}

//
//---------------------------------全局函数定义结束--------------------------------------------------------------
//

//
//---------------------------------系统对象增强开始--------------------------------------------------------------
//

/**<doc type="classext" name="Array.Find">
<desc>查找数组中指定值位置</desc>
<output>返回数组中指定值位置，没有则返回-1</output>
</doc>**/
Array.prototype.Find = function(value) {
    for (var i = 0; i < this.length; i++)
        if (this[i] == value) return i;
    return -1;
}

/**<doc type="classext" name="Array.Remove">
<desc>删除数组中指定值</desc>
<output>删除成功返回true，不存在此值没有则返回false</output>
</doc>**/
Array.prototype.Remove = function(value) {
    var exists = false;
    for (var i = 0, n = 0; i < this.length; i++) {
        if (this[i] != value) {
            this[n++] = this[i];
        } else {
            exists = true;
        }
    }
    if (exists) {
        this.length -= 1
        return true;
    }

    return false;
}

/**<doc type="classext" name="String.fromNull">
<desc>字符串过滤</desc>
<output>如果为null或null串，返回空，否则返回原字符串</output>
</doc>**/
String.prototype.filterNull = function() {
    if (this.toLowerCase() == "null") return "";
    return "" + this;
}

/**<doc type="protofunc" name="String.trim">
<desc>字符串对象定义修剪功能扩展</desc>
<output>返回去除前后空格的字符串</output>
</doc>**/
String.prototype.trim = function() {
    return this.replace(/(^\s*)|(\s*$)/g, "");
}

/**<doc type="protofunc" name="String.trimStart">
<desc>字符串对象定义修剪功能扩展</desc>
<output>返回去除前指定字符串</output>
</doc>**/
String.prototype.trimStart = function(str) {
    if (this.indexOf(str) == 0) {
        return this.substr(str.length, this.length);
    }
    
    return "" + this;
}

/**<doc type="protofunc" name="String.trimEnd">
<desc>字符串对象定义修剪功能扩展</desc>
<output>返回去除后指定字符串</output>
</doc>**/
String.prototype.trimEnd = function(str) {
    if ((this.lastIndexOf(str) + str.length) == this.length) {
        return this.substring(0, this.lastIndexOf(str));
    }
    return "" + this;
}

/**<doc type="protofunc" name="String.bytelen">
<desc>返回字节长度，中文字符长度为2，英文长度为1</desc>
<output>返回字节长度</output>
</doc>**/
String.prototype.bytelen = function() {
    var count = this.length;
    var len = 0;
    if (count != 0)
        for (var i = 0; i < count; i++) {
        if (this.charCodeAt(i) >= 128)
            len += 2;
        else
            len += 1;
    }
    return len;
}

/**<doc type="protofunc" name="String.bytelen">
<desc>替换指定字符串</desc>
<output>返回替换后的字符串</output>
</doc>**/
String.prototype.replaceAll = function(search, replace) {
    var tmp = str = this;
    do {
        str = tmp;
        tmp = str.replace(search, replace);
    } while (str != tmp);
    return str;
}

/**<doc type="protofunc" name="String.bytelen">
<desc>判断String是否以指定字符串开始</desc>
<output>Boolean</output>
</doc>**/
String.prototype.startWith = function(str) {
    return this.indexOf(str) == 0;
}

/**<doc type="protofunc" name="String.bytelen">
<desc>判断String是否以指定字符串结尾</desc>
<output>Boolean</output>
</doc>**/
String.prototype.endWith = function(str){
    var reg=new RegExp(str+"$");
    return reg.test(this);
}

/**<doc type="protofunc" name="String.bytelen">
<desc>判断String是否相等</desc>
<output>Boolean</output>
</doc>**/
String.prototype.equals = function(str, ignoreCase) {
    ignoreCase = !(ignoreCase == false);    // 默认为true
    if (this == str) {
        return true;
    } else {
        if (ignoreCase && str) {
            return this.toLowerCase() == str.toLowerCase();
        }
    }

    return false;
}

/**<doc type="protofunc" name="String.bytelen">
<desc>判断String是否包含指定字符</desc>
<output>Boolean</output>
</doc>**/
String.prototype.contains = function(str, ignoreCase) {
    if (!str) {
        return false;
    } else {
        if (ignoreCase) {
            return this.toLowerCase().indexOf(str.toLowerCase()) >= 0;
        }

        return this.indexOf(str) >= 0;
    }
}

/**<doc type="objdefine" name="Currency">
<desc>Currency定义, 货币类型</desc>	
</doc>**/
function Currency() { }

/**<doc type="protofunc" name="Currency.Format">
<desc>将数值四舍五入(保留2位小数)后格式化成金额形式</desc>
<output>金额格式的字符串,如'1,234,567.45'</output>
</doc>**/
Currency.Format = function(num) {
    var num = num.toString().replace(/\$|\,/g, '');
    if (isNaN(num)) num = "0";

    sign = (num == (num = Math.abs(num)));
    num = Math.floor(num * 100 + 0.50000000001);
    cents = num % 100;
    num = Math.floor(num / 100).toString();

    if (cents < 10)
        cents = "0" + cents;

    for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++)
        num = num.substring(0, num.length - (4 * i + 3)) + ',' +
        num.substring(num.length - (4 * i + 3));

    return (((sign) ? '' : '-') + num + '.' + cents);
}

//
//--------------------------------StringParam 对象定义开始---------------------------------------------------
//

/**<doc type="objdefine" name="StringParam" inhert="Collection">
<desc>串参数集合对象定义</desc>
<input>
<param name="spstr" type="string">初始化参数串</param>
<param name="type" type="enum">参数串类型</param>
</input>
<enum name="type">
<item value="style" isdefault="true">Key:Value;Key1:Value0;Key1:Value1;</item>
<item value="query" >Key=Value&Key1=Value0&Key1=Value1</item>
</enum>
</doc>**/
function StringParam(spstr, divchar, gapchar) {
    this.Keys = new Array();
    this.Values = new Array();
    this.DivChar = ";";
    this.GapChar = ":";
    if (divchar && gapchar) {
        this.DivChar = divchar;
        this.GapChar = gapchar;
    }
    if (spstr) {
        var ary = spstr.split(this.DivChar);
        for (var i = 0; i < ary.length; i++) {
            var subary = ary[i].split(this.GapChar);
            if (subary[0] != "") {
                this.Values.push(subary[1]);
                this.Keys.push(subary[0]);
            }
        }
    }
}
/**<doc type="protofunc" name="StringParam.GetCount">
<desc>获得元素个数</desc>
<output type="number">元素的个数</output>
</doc>**/
StringParam.prototype.GetCount = function() {
    return this.Keys.length;
}

ArrayFind = function(ary, value) {
    for (var i = 0; i < ary.length; i++)
        if (ary[i] == value) return i;
    return -1;
}

/**<doc type="protofunc" name="StringParam.Add">
<desc>添加元素</desc>
<input>
<param name="key" type="string">元素key</param>
<param name="value" type="string">元素value</param>
<param name="notescape" type="bool">是否不对对value进行编码</param>
</input>
</doc>**/
StringParam.prototype.Add = function(key, value, notescape) {
    var pos = ArrayFind(this.Keys, key);
    if (pos >= 0) {
        var ary = this.Values[pos].split(",");
        if (ArrayFind(ary, escape(value)) < 0 && !notescape) {
            if (notescape) {
                this.Values[pos] = this.Values[pos] + "," + escape(value);
            } else {
                this.Values[pos] = this.Values[pos] + "," + value;
            }
        }
        else
            throw new Error(0, "(" + key + " , " + value + ") has exist!");
    } else {
        if (notescape) {
            this.Values.push(value);
        } else {
            this.Values.push(escape(value));
        }
        this.Keys.push(key);
    }
}

/**<doc type="protofunc" name="StringParam.Set">
<desc>设置元素值</desc>
<input>
<param name="key" type="string">元素key</param>
<param name="value" type="string">元素value</param>
<param name="notclear" type="bool">为true时查询原Values中是否包含指定值，不包含则加入</param>
</input>
</doc>**/
StringParam.prototype.Set = function(key, value, notclear) {
    if (typeof (key) == "string") {
        var pos = ArrayFind(this.Keys, key);
        if (pos >= 0) {
            if (notclear) {
                var ary = this.Values[pos].split(",");
                if (ArrayFind(ary, escape(value)) < 0)
                    this.Values[pos] = this.Values[pos] + "," + escape(value);
            } else
                this.Values[pos] = escape(value);
        } else {
            this.Values.push(escape(value));
            this.Keys.push(key);
        }
    }
    else if (typeof (key) == "number") {
        if ((key < 0 || key >= this.Keys.length))
            throw new Error(0, key + " not in scope!");
        if (notclear) {
            var ary = this.Values[key].split(",");
            if (ArrayFind(ary, escape(value)) < 0)
                this.Values[key] = this.Values[key] + "," + escape(value);
        } else
            this.Values[key] = escape(value);
    }
}

/**<doc type="protofunc" name="StringParam.Insert">
<desc>在StringParam的制定位置插入值</desc>
<input>
<param name="key" type="string">元素key</param>
<param name="value" type="string">元素value</param>
<param name="before" type="number/string">制定位置或值得位置,默认为末位</param>
</input>
</doc>**/
StringParam.prototype.Insert = function(key, value, before) {
    if (ArrayFind(this.Keys, key) >= 0) {
        throw new Error(0, key + " has exist!");
        return;
    }
    if (typeof (before) == "undefined") {
        this.Add(key, escape(value));
        return;
    }
    if (typeof (before) == "number") {
        if ((before < 0 || before >= this.Keys.length))
            this.Add(key, value);
        else {
            this.Keys.splice(before, 0, key);
            this.Values.splice(before, 0, escape(value));
        }
    }
    if (typeof (before) == "string") {
        var bpos = ArrayFind(this.Keys, before);
        if (bpos < 0)
            this.Add(key, escape(value)); //这里有错误?
        else {
            this.Keys.splice(bpos, 0, key);
            this.Values.splice(bpos, 0, escape(value));
        }
    }

}

/**<doc type="protofunc" name="StringParam.Get">
<desc>得到指定位置的值</desc>
<input>
<param name="key" type="string/number">元素key或位置</param>
</input>
</doc>**/
StringParam.prototype.Get = function(key) {
    if (typeof (key) == "string") {
        var pos = ArrayFind(this.Keys, key);
        if (pos < 0) return null;
        return unescape(this.Values[pos]);
    }
    if (typeof (key) == "number") {
        if ((key < 0 || key >= this.Keys.length)) return null;
        return unescape(this.Values[key]);
    }
}

/**<doc type="protofunc" name="StringParam.GetArray">
<desc>返回指定Key对应的Value并转化为数组</desc>
<output type="object">由指定Key对应的Value转化的数组</output>
</doc>**/
StringParam.prototype.GetArray = function(key) {
    var value;
    if (typeof (key) == "string") {
        var pos = ArrayFind(this.Keys, key);
        if (pos < 0) return null;
        value = this.Values[pos];
    }
    if (typeof (key) == "number") {
        if ((key < 0 || key >= this.Keys.length)) return null;
        value = this.Values[key];
    }
    var ary = value.split(",");
    for (var i = 0; i < ary.length; i++)
        ary[i] = unescape(ary[i]);
    return ary;
}
/**<doc type="protofunc" name="StringParam.Remove">
<desc>删除一个元素</desc>
<input>
<param name="keyindex" type="string/number">键值或索引</param>
</input>
</doc>**/
StringParam.prototype.Remove = function(key) {
    if (typeof (key) == "number") {
        if (key < 0 || key >= this.Keys.length)
            return false;
        this.Keys.splice(key, 1);
        this.Values.splice(key, 1);
        return true;
    } else if (typeof (key) == "string") {
        var pos = ArrayFind(this.Keys, key);
        if (pos < 0)
            return false;
        this.Keys.splice(pos, 1);
        this.Values.splice(pos, 1);
        return true;
    }
}


/**<doc type="protofunc" name="StringParam.Clear">
<desc>清除所有元素</desc>
</doc>**/
StringParam.prototype.Clear = function() {
    this.Keys.splice(0, this.Keys.length);
    this.Values.splice(0, this.Values.length);
}

/**<doc type="protofunc" name="StringParam.Clone">
<desc>复制本集合</desc>
<output type="object">StringParam对象</output>
</doc>**/
StringParam.prototype.Clone = function() {
    var newsp = new StringParam();
    var count = this.Keys.length;
    for (var i = 0; i < count; i++) {
        newsp.Keys[i] = this.Keys[i];
        newsp.Values[i] = this.Values[i];
    }
    return newsp;
}

/**<doc type="protofunc" name="StringParam.ToString">
<desc>返回StringParam的字符串形式格式为 "Key+GapChar+Value"</desc>
<input>
<param name="noescape" type="bool">是否用unescape编码Value</param>
</input>
</doc>**/
StringParam.prototype.ToString = function(noescape) {
    var str = "", value;
    var count = this.Keys.length;
    for (var i = 0; i < count; i++) {
        if (noescape)
            value = unescape(this.Values[i]);
        else
            value = this.Values[i];
        str += this.Keys[i] + this.GapChar + value + this.DivChar;
    }
    if (str.length > 0)
        return str.substr(0, str.length - 1);
    return "";
}

function RMBMoney(v, dataIndex, record) {
    v = (Math.round((v - 0) / 100)) * 100;
    //v = (v == Math.floor(v)) ? v + ".00" : ((v*10 == Math.floor(v*10)) ? v + "0" : v);  
    v = String(v);
    //var ps = v.split('.');  
    var whole = v;
    //var sub = ps[1] ? '.'+ ps[1] : '.00';  
    var r = /(\d+)(\d{3})/;
    while (r.test(whole)) {
        whole = whole.replace(r, '$1' + ',' + '$2');
    }
    v = whole;
    if (v.charAt(0) == '-') {
        return '-' + v.substr(1);
    }
    return v;
}

function RMBMoneyWithTag(v, dataIndex, record) {
    v = (Math.round((v - 0) / 100)) * 100;
    //v = (v == Math.floor(v)) ? v + ".00" : ((v*10 == Math.floor(v*10)) ? v + "0" : v);  
    v = String(v);
    //var ps = v.split('.');  
    var whole = v;
    //var sub = ps[1] ? '.'+ ps[1] : '.00';  
    var r = /(\d+)(\d{3})/;
    while (r.test(whole)) {
        whole = whole.replace(r, '$1' + ',' + '$2');
    }
    v = whole;
    if (v.charAt(0) == '-') {
        return '-￥' + v.substr(1);
    }
    return "￥" + v;
}


//
//--------------------------------StringParam 对象定义结束---------------------------------------------------
//
