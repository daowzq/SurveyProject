
(function($) {
    $.fn.toUrlPara = function(separator) {
        if (!(e instanceof jQuery)) return alert("不能转化为地址变量，参数必须为jQuery对象。");
        separator = separator == undefined ? "," : separator;
        var s = [],
            a = e.serializeArray(),
			        add = function(key, value) {
			            value = $.isFunction(value) ? value() : value;
			            s[key] = s[key] == undefined ? encodeURIComponent(value) : s[key] + separator + encodeURIComponent(value);
			        },
            toStr = function(s) {
                var url = "";
                for (var key in s) {
                    url += key + "=" + s[key] + "&";
                }
                if (url.length > 1)
                    url = url.substring(0, url.length - 1);
                return url;
            };

        if ($.isArray(a))
            $.each(a, function() {
                add(this.name, this.value);
            });
        return toStr(s);
    }
})(jQuery);
