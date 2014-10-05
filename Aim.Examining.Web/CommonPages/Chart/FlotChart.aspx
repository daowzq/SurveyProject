<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FlotChart.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.FlotChart" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>图表</title>
    
    <link href="/js/flot/layout.css" rel="stylesheet" type="text/css" />

    <!--[if IE]><script language="javascript" type="text/javascript" src="/js/flot/excanvas.min.js"></script><![endif]-->

    <!--<script src="/js/lib/jquery-1.4.2.min.js" type="text/javascript"></script>-->
    
    <script src="/js/lib/jquery-1.4.1-vsdoc.js" type="text/javascript"></script>
    <script src="/js/plug-ins/jquery.plug-ins.js" type="text/javascript"></script>
    <script src="/js/common.js" type="text/javascript"></script>

    <script src="/js/flot/jquery.flot.js" type="text/javascript"></script>
    <script src="/js/flot/jquery.flot.multi.js" type="text/javascript"></script>
    <script src="/js/flot/jquery.flot.pie.js" type="text/javascript"></script>
    
    <script type="text/javascript" language="javascript">
        var Chart, data, params;
    
        // 页面初始化
        $().ready(function() {
        });

        function loadChart(gdata, config) {
            config = config || {};
            
            data = gdata["data"] || [];
            params = gdata["params"] || {};

            Chart = $.plot($("#placeholder"), data, params);

            var listeners = config.listeners || {};
            for (var key in listeners) {
                if (listeners[key] && listeners[key].call) {
                    $("#placeholder").bind(key, function(event, pos, obj) { listeners[key].call(window, event, pos, obj, window) });
                }
            }

            return Chart;
        }
        
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="placeholder" style="width:650px;height:500px;margin:0 auto;"></div>
    </form>
</body>
</html>
