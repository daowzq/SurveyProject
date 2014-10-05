<%@ Page Title="离职原因" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="LeaveReasonFrame.aspx.cs" Inherits="Aim.Examining.Web.ReportSheet.LeaveReasonFrame" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">
        var YearEnum = "";
        var url = "";
        function onPgLoad() {
            //----------设置年份----------------
            var evalStr = "";
            var year = new Date().getFullYear();
            evalStr += "{";
            evalStr += "\"\":'请选择...',";
            for (var i = 0; i < 4; i++) {
                if (i > 0) evalStr += ",";
                evalStr += (year - i) + ":" + (year - i);
            }
            evalStr += "}";
            YearEnum = eval("(" + evalStr + ")");
            //-- -- -- -- -- -- -- -- -- -- -- --  
            setPgUI();

        }
        function setPgUI() {

            cb_Year = new Ext.ux.form.AimComboBox({
                id: 'cb_Year',
                enumdata: YearEnum,
                lazyRender: false,
                allowBlank: false,
                width: 100,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function(obj) {
                        if (obj.value) {
                            var month = Ext.getCmp("cb_Month").getValue();
                            month = !!month ? month : new Date().getMonth() + 1;
                            var url = "LeaveReasonDetail.aspx?year=" + obj.value + "&month=" + month;
                        }
                    }
                }
            });

            cb_Month = new Ext.ux.form.AimComboBox({
                id: 'cb_Month',
                enumdata: {
                    "1": "1月",
                    "2": "2月",
                    "3": "3月",
                    "4": "4月",
                    "5": "5月",
                    "6": "6月",
                    "7": "7月", "8": "8月", "9": "9月",
                    "10": "10月",
                    "11": "11月",
                    "12": "12月"
                },
                lazyRender: false,
                allowBlank: false,
                width: 100,
                autoLoad: true,
                forceSelection: true,
                triggerAction: 'all',
                mode: 'local',
                listeners: {
                    blur: function(obj) {
                        if (obj.value) {
                            var year = Ext.getCmp("cb_Year").getValue();
                            year = !!year ? year : new Date().getFullYear();
                            url = "LeaveReasonDetail.aspx?year=" + year + "&month=" + obj.value;
                        }
                    }
                }
            });

            titPanel = new Ext.Toolbar({
                region: 'north',
                //title: '工作量负荷情况',
                //frame: true,
                buttonAlign: 'left',
                //tbar: tlBar,
                height: 30,
                items: [{ xtype: 'tbtext', style: { marginLeft: '30px' }, text: '<p style="font-size:12px;">&nbsp;&nbsp;<b>年份</b>: </p>' }, cb_Year, { xtype: 'tbtext', text: '<p style="font-size:12px;">&nbsp;&nbsp;<b>月份</b>: </p>' }, cb_Month,
                 {
                     xtype: 'button',
                     text: '查询',
                     id: 'btn_search',
                     iconCls: 'aim-icon-search',
                     style: { marginLeft: '8px' },
                     handler: function() {
                         frameContent.location.href = url;
                     }
                 }

 ]
            });


            var viewport = new Ext.ux.AimViewport({
                items: [titPanel, {
                    region: 'center',
                    autoScroll: true,
                    //width: 100,
                    cls: { " background-color": "red" },
                    margins: '-2 0 0 0',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" scrolling="auto" ></iframe>'}]
                });
                if (document.getElementById("frameContent")) {
                    frameContent.location.href = "LeaveReasonDetail.aspx?Index=0"
                }
            }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
