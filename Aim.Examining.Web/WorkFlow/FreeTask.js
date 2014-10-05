var actionPanel;
var viewport;
var panel;
var mask;
var usersText;

function onPgLoad() {
    setPgUI();
    /*if (AimState["InstanceId"]) {
    renderProcTrack({ flowId: AimState["InstanceId"], track: 1 });
    }*/
}

function setPgUI() {
    mask = new Ext.LoadMask(Ext.getBody(), { msg: "处理中..." });
    mask.show();
    //InitTraceBar();
    var titlelabel = "<table width=100%><tr width=100%><td style='font-size:12px;font-weight:bold;'>" + AimState["Task"].WorkFlowName + "->" + AimState["Task"].ApprovalNodeName + "</td><td  style='font-size:12px;font-weight:bold;text-align:right;cursor:hand;display:none;' onclick='printpreview();'>打印</td></tr></table>";
    var tlBarTitle = new Ext.Panel({
        region: 'north',
        contentEl: 'divNorth',
        cls: 'app-header',
        title: titlelabel, //AimState["Task"].WorkFlowName + "->" + AimState["Task"].ApprovalNodeName
        html: ''
    });
    formUrl += formUrl.indexOf("?") > 0 ? "&InFlow=T" : formUrl + "?InFlow=T";
    viewport = new Ext.Viewport({
        layout: 'border',
        items: [tlBarTitle, /*actionPanel,*/
                    {
                    region: 'center',
                    margins: '0 0 0 0',
                    layout: 'border',
                    bodyStyle: 'background:#f1f1f1',
                    border: false, 
                    buttonAlign: 'left',
                    fbar: [{id:'btnReceive',
                        text: '<span style=font-size:12px>签收</span>',
                        iconCls: 'aim-icon-save',
                        handler: SaveTask
                    }, '-'],
                    items: [{
                        region: 'center',
                        border: false,
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src = "' + formUrl + '"></iframe>'
}]
}]
    });
    //ToolBarToggle();
    //window.setTimeout("ToolBarToggle();actionPanel.toggleCollapse(false);", 4000);
    mask.hide();
    if (AimState["Task"].Status != "0") {
        Ext.getCmp("btnReceive").hide();
    }
    if (op == "r") {
        Ext.getCmp("btnReceive").hide();
    }
}
function ToolBarToggle() {
    panel.toggleCollapse(false);
    panel.collapsed ? panel.el.dom.parentNode.style.display = 'none' : panel.el.dom.parentNode.style.display = '';
    setTimeout("viewport.doLayout()", 100);
}

function InitTraceBar() {
    var tasks = eval(AimState["Tasks"]);
    var items = [];
    var item;
    var i = 1;
    var tempName = "";
    $.each(tasks, function() {
        var finishT = this.FinishTime == null ? "[未处理]" : this.FinishTime;
        if (tempName == this.ApprovalNodeName) {
            item.html = item.html.replace("<ul><li>执行人:", "<ul><li>执行人:" + this.Owner + ",");
        }
        else {
            item = new Ext.Panel({
                frame: true,
                title: '第' + i + '步 ' + this.ApprovalNodeName,
                bodyStyle: i == tasks.length ? "background-color:yellow;" : "",
                collapsible: true,
                titleCollapse: true,
                iconCls: 'task',
                html: '<ul><li>执行人: ' + this.Owner + '</li><li>收到时间: ' + this.CreatedTime + '</li><li>处理时间: ' + finishT + '</li><li>备注: ' + this.Description + '</li></ul>'
            });
        }
        items.push(item);
        tempName = this.ApprovalNodeName;
        i++;
    });
    actionPanel = new Ext.Panel({
        id: 'panelTrace',
        region: 'west',
        iconCls: 'flow',
        title: '任务跟踪',
        contentEl: 'west',
        split: true,
        collapsible: true,
        collapsed: false,
        width: 200,
        autoScroll: true,
        minWidth: 150,
        maxWidth: 300,
        border: true,
        items: items
    });
    return actionPanel;
}
function ShowMask() {
    mask.show();
}
function HideMask() {
    mask.hide();
}

function printpreview() {
    // 打印页面预览
    try {
        document.getElementById("WebBrowser").ExecWB(7, 1);
    }
    catch (e) {
        window.print();
    }
}