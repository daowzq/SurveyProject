<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SearchQusetionKey.aspx.cs" Inherits="Aim.Examining.Web.SearchQusetionKey" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        *
        {
            font-size: 12px;
            color: #000000;
            text-decoration: none;
            margin: 0px;
            padding: 0px;
            line-height: 1.5;
        }
        .body
        {
            border: 1px dashed #CCCCCC;
            width: 700px;
            margin-right: auto;
            margin-left: auto;
        }
        .sum
        {
            text-align: right;
        }
        .title
        {
            font-size: 14px;
            line-height: 2em;
            text-decoration: none;
            text-align: center;
            cursor: pointer;
        }
        .date
        {
            padding-left: 20px;
        }
        .Answer
        {
            text-indent: 24px;
        }
    </style>

    <script type="text/javascript">
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, dataview, tip, viewport;
        var authState;

        var EditWinStyle = "width=650,height=600,scrollbars==0";
        function onPgLoad() {

            setPgUI();
        }
        function setPgUI() {
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
             { name: 'Id' },
			{ name: 'Title' },
			{ name: 'Contents' },
			{ name: 'Anonymity' },
			{ name: 'Category' },
			{ name: 'AwardScore' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },
			{ name: 'AcceptAnswerId' },
			{ name: 'AnswerCount' },
			{ name: 'ViewCount' },
			{ name: 'NikeName' },
			{ name: 'IsCheck' },
			{ name: 'CheckOpinion' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' },
			{ name: 'Answer' }
                ],
                listeners: {
                    aimbeforeload: function(proxy, options) {
                        options.data = options.data || {};

                    }
                }
            });
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            tpl = new Ext.XTemplate(
                '<tpl for=".">',
'<div class="body">',
'<div class="title" thisid={Id}>{Contents}</div>',
'<div class="sum"><span>浏览[{ViewCount}]次</span><span class="date">[{CreateTime}]</span></div>',
'<div class="Answer">{Answer}</div>',
'</div>',
               '</tpl>'
           );

            dataview = new Ext.DataView({
                id: 'my-data-view',
                store: store,
                tpl: tpl,
                region: 'center',
                autoScroll: true,
                // autoHeight: true,
                singleSelect: true,
                multiSelect: false,
                simpleSelect: true,
                overClass: 'x-view-over',
                selectedClass: 'x-view-selected',
                itemSelector: 'div.radioItem'
            });

            viewport = new Ext.ux.AimViewport({
                items: [dataview]
            });
        }


        function openPalyerWin(val, name) {
            var FileUrl = val + "_" + name;
            var task = new Ext.util.DelayedTask();
            task.delay(50, function() {
                opencenterwin("SearchQusetionKeyEdit.aspx" + "?op=r&FileUrl=" + FileUrl, "", 1000, 650);
            });

        }


        $(function() {
            $(".title").bind("click", function() {
                var id = $(this).attr("thisid");
                opencenterwin("SearchQusetionKeyEdit.aspx?QuestionId=" + id, "", 780, 500);
            })
        })


        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',,innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }


        function onExecuted() {
            store.reload();
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
