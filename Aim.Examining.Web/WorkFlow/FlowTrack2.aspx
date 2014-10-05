<%@ Page Title="流程图形跟踪" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master"
    AutoEventWireup="true" CodeBehind="FlowTrack2.aspx.cs" Inherits="Aim.Examining.Web.WorkFlow.FlowTrack2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        mxBasePath = '/workflow/src';
	</script>

    <!-- Loads and initializes the library -->

    <script type="text/javascript" src="/workflow/src/js/mxClient.js"></script>

    <script type="text/javascript">
        var flowId = $.getQueryString({ ID: 'flowId', DefaultValue: "" });
        var graph;
        var nodesArr = [];
        var GrphsArr = [];
        function onPgLoad() {
            main(document.getElementById('graphContainer'));

        }

        function main(container) {
            // Checks if the browser is supported
            if (!mxClient.isBrowserSupported()) {
                // Displays an error message if the browser is not supported.
                mxUtils.error('Browser is not supported!', 200, false);
            }
            else {
                mxGraphHandler.prototype.guidesEnabled = true;

                // Alt disables guides
                mxGraphHandler.prototype.useGuidesForEvent = function(me) {
                    return !mxEvent.isAltDown(me.getEvent());
                };
                mxEvent.disableContextMenu(container);
                // Enables crisp rendering of rectangles in SVG
                mxRectangleShape.prototype.crisp = true;
                graph = new mxGraph(container);
                // Creates the graph inside the given container
                var style = graph.getStylesheet().getDefaultEdgeStyle();
                style[mxConstants.STYLE_ROUNDED] = true;
                style[mxConstants.STYLE_EDGE] = mxEdgeStyle.ElbowConnector;
                graph.alternateEdgeStyle = 'elbow=vertical';

                var style = [];
                style[mxConstants.STYLE_SHAPE] = mxConstants.SHAPE_RECTANGLE;
                style[mxConstants.STYLE_PERIMETER] = mxPerimeter.RectanglePerimeter;
                style[mxConstants.STYLE_STROKECOLOR] = 'gray';
                style[mxConstants.STYLE_ROUNDED] = true;
                style[mxConstants.STYLE_FILLCOLOR] = 'blue';
                style[mxConstants.STYLE_GRADIENTCOLOR] = 'white';
                style[mxConstants.STYLE_FONTCOLOR] = 'black';
                style[mxConstants.STYLE_ALIGN] = mxConstants.ALIGN_CENTER;
                style[mxConstants.STYLE_VERTICAL_ALIGN] = mxConstants.ALIGN_MIDDLE;
                style[mxConstants.STYLE_FONTSIZE] = '12';
                style[mxConstants.STYLE_FONTSTYLE] = 1;
                graph.getStylesheet().putDefaultVertexStyle(style);

                var imgstyle = 'shape=image;verticalLabelPosition=bottom;verticalAlign=top;';
                // Enables rubberband selection
                new mxRubberband(graph);
                graph.setPanning(true);
                graph.setTooltips(true);
                graph.setEnabled(false);
                graph.setTooltips(true);
                var rubberband = new mxRubberband(graph);
                var keyHandler = new mxKeyHandler(graph);
                mxPopupMenu.prototype.useLeftButtonForPopup = true;
                graph.panningHandler.factoryMethod = function(menu, cell, evt) {
                    return createPopupMenu(graph, menu, cell, evt);
                };
                var parent = graph.getDefaultParent();
                graph.getModel().beginUpdate();
                try {
                    var xStart = -100;
                    var yStart = 10;
                    var tasks = AimState["FlowEnum"];
                    InsertNext(graph, imgstyle, xStart, yStart, tasks[0].TaskName);
                }
                finally {
                    graph.getModel().endUpdate();
                }
                graph.getTooltipForCell = function() {
                    if (GetTaskByName(arguments[0].value))
                        return GetTaskByName(arguments[0].value).ExecuteMessages;
                    else
                        return "";
                }
            }
            function InsertNext(graph, imgstyle, parentStartX, parentStartY, childName, parentNode, route, parentName, firstDraw) {
                var tasks = AimState["FlowEnum"];
                var currentX = parentStartX + 150;
                var currentY = parentStartY;
                var node = CheckExsitNode(childName)
                if (!node) {
                    node = graph.insertVertex(parent, null, childName, currentX, currentY, 48, 41, imgstyle + GetTaskBGColor(childName, parentNode, parentName, route));
                    GrphsArr.push(node);
                    nodesArr.push(childName);
                }
                if (parentNode) {
                    if (route)//switch
                    {
                        var parentTask = GetTaskByName(parentName);
                        var edge = null;
                        var targetLabel = null;
                        if (parentTask && parentTask.ExecuteRoute == route) {//走的当前路由
                            //edge = graph.insertEdge(parent, null, '', parentNode, node, 'strokeColor=red;strokeWidth=4');
                            edge = graph.insertEdge(parent, null, '', parentNode, node, 'strokeColor=green;');
                            targetLabel = new mxCell(route, new mxGeometry(1, 0, 0, 0), 'resizable=0;align=right;verticalAlign=bottom;fontColor=green;fontSize=11;');
                        }
                        else {
                            if (CheckExecuteTask(childName)) {
                                edge = graph.insertEdge(parent, null, '', parentNode, node, 'strokeColor=green;');
                            }
                            else
                                edge = graph.insertEdge(parent, null, '', parentNode, node, 'strokeColor=gray;');
                            //node.style = "shape=image;image=/workflow/src/images/audit.png;verticalLabelPosition=bottom;verticalAlign=top;"
                            targetLabel = new mxCell(route, new mxGeometry(1, 0, 0, 0), 'resizable=0;align=right;verticalAlign=bottom;fontColor=#774400;fontSize=11;');
                        }
                        targetLabel.geometry.relative = true;
                        targetLabel.setConnectable(false);
                        targetLabel.vertex = true;
                        edge.insert(targetLabel);
                    }
                    else {
                        var parentTask = GetTaskByName(parentName);
                        if (parentTask.ExecuteState == "2" && parentNode.style.indexOf("imageBackground") > 0) {
                            graph.insertEdge(parent, null, '', parentNode, node, 'strokeColor=green;strokeWidth=2');
                        }
                        else {
                            graph.insertEdge(parent, null, '', parentNode, node, 'strokeColor=gray;');
                        }
                    }
                }
                if (firstDraw) return;
                var next = GetTaskByName(childName).Child;
                if (next)
                    if (next.split(";;").length > 1) {
                    for (var j = 0; j < next.split(";;").length; j++) {
                        var next1 = next.split(";;")[j];
                        InsertNext(graph, imgstyle, currentX + 20, currentY + j * 60, next1.split(",,")[0], node, next1.split(",,")[1], childName, true);
                    }
                    for (var j = 0; j < next.split(";;").length; j++) {
                        var next1 = next.split(";;")[j];
                        InsertNext(graph, imgstyle, currentX + 20, currentY + j * 60, next1.split(",,")[0], node, next1.split(",,")[1], childName);
                    }
                }
                else {
                    InsertNext(graph, imgstyle, currentX, currentY, next.split(",,")[0], node, null, childName);
                }
            }
        };
        function CheckExsitNode(name) {
            for (var i = 0; i < nodesArr.length; i++) {
                if (nodesArr[i].toString() == name) {
                    return GrphsArr[i];
                }
            }
            return false;
        }
        function CheckExecuteTask(taskName) {
            var tasks = AimState["SysWorkFlowTaskList"] || [];
            for (var i = 0; i < tasks.length; i++) {
                if (tasks[i].ApprovalNodeName == taskName) {
                    return tasks[i];
                }
            }
        }
        function GetTaskByName(taskName) {
            var tasks = AimState["FlowEnum"];
            for (var i = 0; i < tasks.length; i++) {
                if (tasks[i].TaskName == taskName) {
                    return tasks[i];
                }
            }
        }
        function GetTaskState(taskName) {
            var tasks = AimState["FlowEnum"];
            for (var i = 0; i < tasks.length; i++) {
                if (tasks[i].TaskName == taskName) {
                    return tasks[i].ExecuteState;
                }
            }
        }
        function GetTaskBGColor(taskName, parentNode, parentName, route) {
            var tasks = AimState["FlowEnum"];
            for (var i = 0; i < tasks.length; i++) {
                if (taskName == "结束") {
                    return "image=/workflow/images/gameover.jpg;";
                }
                if (tasks[i].TaskName == taskName) {
                    switch (tasks[i].ExecuteState) {
                        case "0":
                            return "image=/workflow/images/wait.jpg;";
                            break;
                        case "1":
                            //if (parentNode && parentNode.style.indexOf("imageBackground") < 0)
                            //   return "image=/workflow/images/wait.jpg;";
                            if (tasks[i].ViewDate == "")
                                return "image=/workflow/images/undoing.jpg;fontColor=green"; //imageBackground=yellow;
                            else
                                return "image=/workflow/images/doing1.jpg;fontColor=green"; //imageBackground=yellow;
                            break;
                        case "2":
                            if (parentNode && parentNode.style.indexOf("imageBackground") < 0)
                                return "image=/workflow/images/done1.jpg;";
                            return "image=/workflow/images/done1.jpg;imageBackground=";
                            break;
                        default:
                            return "";
                    }
                }
            }
        }
        function createPopupMenu(graph, menu, cell, evt) {
            if (cell != null) {
                var task = CheckExecuteTask(cell.value);
                if (!task || task.Status != 0) return;
                menu.addItem('短信催办', '/images/shared/cellphone2.gif', function() {
                    if (confirm("您确定要发短信催办[" + cell.value + "]环节审批人吗?")) {
                        jQuery.ajaxExec('sendMessage', { "flowId": flowId, "TaskName": cell.value, "Method": "phone" }, function(rtn) {
                            if (rtn.data.Message) {
                                alert(rtn.data.Message);
                            }
                            else
                                alert("短信已发送!");
                        });
                    }
                });
                menu.addSeparator();
                menu.addItem('邮件催办', '/images/shared/email_go.png', function() {
                    if (confirm("您确定要发邮件催办[" + cell.value + "]环节审批人吗?")) {
                        jQuery.ajaxExec('sendMessage', { "flowId": flowId, "TaskName": cell.value, "Method": "mail" }, function(rtn) {
                            if (rtn.data.Message) {
                                alert(rtn.data.Message);
                            }
                            else
                                alert("邮件已发送!");
                        });
                    }
                });
            }
            else {
                /*menu.addItem('No-Cell Item', 'editors/images/image.gif', function() {
                mxUtils.alert('MenuItem2');
                });*/
            }
        };
	</script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <!-- Auto create tab 1 -->
    <div onclick="return;if(window.parent.ChangeTrackHeight)window.parent.ChangeTrackHeight()"
        id="graphContainer" style="width: 100%; height: 60px; background-image: url('editors/images/grid1.gif');">
    </div>
</asp:Content>
