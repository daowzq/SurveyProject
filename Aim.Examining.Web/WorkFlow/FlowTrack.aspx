<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/formpage.master" AutoEventWireup="true"
    CodeBehind="FlowTrack.aspx.cs" Inherits="Aim.Examining.Web.WorkFlow.FlowTrack" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/js/plug-ins/jquery.corner.js" type="text/javascript"></script>

    <style type="text/css">
        .thumb
        {
            background-color: #dddddd;
            padding: 4px;
            text-align: center;
            height: 40px;
        }
        .thumb-activated
        {
            background-color: #33dd33;
            padding: 4px;
            text-align: center;
            border: 2px;
            border-style: dashed;
            border-color: Red;
            height: 40px;
        }
        .thumb-activateded
        {
            background-color: blue;
            padding: 4px;
            text-align: center;
            border: 2px;
            border-style: dashed;
            border-color: Red;
            height: 40px;
        }
        .thumb-separater
        {
            float: left;
            padding: 2px;
            margin-left: 5px;
            margin-right: 5px;
            vertical-align: middle;
        }
        .thumb-wrap-out
        {
            float: left;
            width: 80px;
            margin-right: 0;
            padding: 0px; /*background-color:#8DB2E3;*/
        }
        .thumb-wrap
        {
            font-size: 13px;
            font-weight: bold;
        }
        .span_track_link
        {
            cursor: hand;
        }
        .messagelabel
        {
            cursor: hand;
            font-size: 12px;
            color: Red;
            text-decoration: underline;
        }
    </style>

    <script type="text/javascript">
        var phase, tracktype, PhaseData = {};
        var store, trackPanel, dataView, SubPortalWin;
        var PhaseData;
        var flowId = $.getQueryString({ ID: 'flowId', DefaultValue: "" });

        function onPgLoad() {
            PhaseData = AimState["FlowEnum"];
            phase = $.getQueryString({ ID: 'phase', DefaultValue: AimState["FlowEnum"][0].Value });
            phase = AimState["SysWorkFlowTaskList"][0].ApprovalNodeName;
            if (AimState["SysWorkFlowTaskList"][0].Status != "0") {
                phase = "结束";
            }
            SubPortalWin = window
            /*while (SubPortalWin.parent) {
            SubPortalWin = SubPortalWin.parent;
            if (SubPortalWin.parent.FireItemMenuClk) {
            SubPortalWin = SubPortalWin.parent;
            break;
            }
            }*/

            setPgUI();

            $('.span_track_link').mouseover(function() {
                $(this.parentNode).attr('orgbgcolor', $(this.parentNode).css('background-color'));
                $(this.parentNode).css('background-color', 'green');
            });

            $('.span_track_link').mouseout(function() {
                $(this.parentNode).css('background-color', $(this.parentNode).attr('orgbgcolor'));
            });

            $('.span_track_link').click(function() {
                var code = $(this).attr('code');

                if (SubPortalWin && SubPortalWin.FireItemMenuClk) {
                    SubPortalWin.FireItemMenuClk(code);
                }
            });
        }

        function OnTrackLinkClick() {

        }

        function setPgUI() {
            Ext.QuickTips.init();
            myData = {
                total: AimState["FlowEnum"].length,
                records: AimState["FlowEnum"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'FlowEnum',
                idProperty: 'EnumerationID',
                data: myData,
                fields: [
			{ name: 'EnumerationID' },
			{ name: 'TaskName' },
			{ name: 'UserName' },
			{ name: 'Value' }
			]
            });

            var dtCount = store.getRange().length;

            var tpl = new Ext.XTemplate(
		'<tpl for=".">',
		    '<div class="thumb-wrap-out">',
            '<div class="thumb-wrap">',
            '<tpl if="this.isActivated(Value)">',
		        '<div class="thumb-activated">',
		    '</tpl>',
            '<tpl if="!this.isActivated(Value)">',
		        '<div class="thumb">',
		    '</tpl>',
		    '<span class="span_track_link" code="{Value}" ext:qtip="{UserName}"  data-qtip="{UserName}">{#}.{TaskName}</span>',
		    '</div>',
		    '</div>',
		    '</div>',
            '<tpl if="!this.isLast([xindex][0])">',
		        '<div class="thumb-separater"><img src="/images/shared/arrow_right1.png" /></div>',
		    '</tpl>',
        '</tpl>',
        '<div class="x-clear"></div>', {
            isActivated: function(val) {
                return phase.equals(val);
            },
            isLast: function(idx) {
                return idx >= dtCount;
            },
            isActivatedNotEnd: function(val) {
                return phase.equals(val) && val != "结束";
            }
        }
	);
            dataView = new Ext.DataView({
                id: 'my-data-view',
                store: store,
                tpl: tpl,
                autoHeight: true,
                trackOver: true,
                width: PhaseData.length * 110,
                overClass: 'x-view-over',
                itemSelector: 'div.thumb-wrap'
            });

            trackPanel = new Ext.ux.AimPanel({
                region: 'center',
                border: false,
                autoScroll: true,
                bodyStyle: 'background-color: #DFE8F6; margin:5px;',
                items: dataView
            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, trackPanel]
            });
            store.on('load', function(options) {
                var image_width = 110;
                Ext.getCmp('my-data-view').setWidth(this.data.items.length * image_width);
            })
            //$('.thumb-wrap').corner("round 5px");
            $('.thumb-wrap-out').corner("round 8px");
            for (var i = 0; i < dataView.getNodes().length; i++) {
                if (dataView.getNode(i).childNodes(0).className != "thumb-activated") {
                    dataView.getNode(i).childNodes(0).className = "thumb-activateded";
                }
                else
                    return;
            }
        }
        function SendMessage(taskName) {
            if (confirm("您将要给[" + taskName + "]环节审批人发送短信,确定要发送短信催办吗?")) {
                jQuery.ajaxExec('sendMessage', { "flowId": flowId, "TaskName": taskName }, function(rtn) {
                    if (rtn.data.Message) {
                        alert(rtn.data.Message);
                    }
                    else
                        alert("短信已发送!");
                });
            }
        }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            流程跟踪</h1>
    </div>
</asp:Content>
