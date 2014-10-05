<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="WebPartList.aspx.cs" Inherits="Aim.Portal.Web.WebPartList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var StatusEnum = { '1': '有效', '0': '无效' };

        var viewport;
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["WebPartList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'WebPartList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'BlockName' },
			{ name: 'BlockKey' },
			{ name: 'BlockTitle' },
			{ name: 'BlockType' },
			{ name: 'BlockImage' },
			{ name: 'Remark' },
			{ name: 'HeadHtml' },
			{ name: 'ColorValue' },
			{ name: 'Color' },
			{ name: 'RepeatItemCount' },
			{ name: 'RepeatItemLength' },
			{ name: 'RepeatDataDataSql' }
			]
            });

            // 分页栏
            pgBar = new Ext.PagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store,
                displayInfo: true,
                displayMsg: '当前条目 {0} - {1}, 总条目 {2}',
                emptyMsg: "无条目显示",
                items: ['-']
            });

            // 搜索栏
            schBar = new Ext.Panel({
                collapsed: true,
                unstyled: true,
                padding: 5,
                layout: 'column',
                items: [
				{ layout: 'form', unstyled: true, columnWidth: .33,
				    items: [new Ext.app.AimSearchField({ fieldLabel: '名称', anchor: '90%', name: 'Name', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Name' }" })]
				}
				]
            });

            // 工具栏
            tlBar = new Ext.Toolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openEditWin("WebPartEdit.aspx", "c");
                    }
                }, {
                    text: '修改',
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openEditWin("WebPartEdit.aspx", "u");
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }

                        if (confirm("确定删除所选记录？")) {
                            batchOperate('batchdelete', recs);
                        }
                    }
                }, {
                    text: '复制',
                    iconCls: 'aim-icon-copy',
                    handler: function() {
                        openEditWin("WebPartEdit.aspx", "cp");
                    }
                }, '-', {
                    text: '其他',
                    iconCls: 'aim-icon-cog',
                    menu: [{ text: '其他操作', handler: function() { viewport.doLayout(); } }]
                }
                //                    , '->', 
                //                    {
                //                        text: '复杂查询',
                //                        iconCls: 'aim-icon-search',
                //                        handler: function() {
                //                            schBar.toggleCollapse(false);

                //                            setTimeout("viewport.doLayout()", 50);
                //                        }
                //                    }
                    ]
            });

            // 工具标题栏
            titPanel = new Ext.Panel({
                tbar: tlBar,
                items: [schBar]
            });

            // 表格面板
            grid = new Ext.grid.GridPanel({
                store: store,
                region: 'center',
                monitorResize: true,
                columns: [
                    { id: 'Id', header: '标识', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'BlockName', header: '名称', width: 100, sortable: true, dataIndex: 'BlockName' },
					{ id: 'BlockKey', header: 'Key', width: 100, sortable: true, dataIndex: 'BlockKey' },
					{ id: 'BlockTitle', header: '标题', width: 100, sortable: true, dataIndex: 'BlockTitle' },
					{ id: 'BlockType', header: '类型', width: 100, sortable: true, dataIndex: 'BlockType' },
					{ id: 'Color', header: '颜色', width: 100, sortable: true, dataIndex: 'Color' },
					{ id: 'RepeatItemCount', header: '显示条数', width: 100, sortable: true, dataIndex: 'RepeatItemCount' },
					{ id: 'RepeatDataDataSql', header: '取数据sql', width: 300, sortable: true, dataIndex: 'RepeatDataDataSql' }
                    ],
                bbar: pgBar,
                tbar: titPanel,
                frame: true,
                forceLayout: true,
                stripeRows: true,
                //autoExpandColumn: 'Name',
                stateful: true,
                stateId: 'grid'
            });

            // 页面视图
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
            });
        }

        // 链接渲染
        function linkRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Name":
                    rtn = "<a class='aim-ui-link' onclick='openEditWin(\"WebPartEdit.aspx?id=" + p.value + "\")'>" + val + "</a>";
                    break;
            }

            return rtn;
        }

        // 枚举渲染
        function enumRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Status":
                    rtn = StatusEnum[val];
                    break;
            }

            return rtn;
        }

        // 打开模态窗口
        function openEditWin(url, op, style) {
            op = op || "r";
            style = style || CenterWin("width=900,height=580,scrollbars=yes");

            var sels = grid.getSelectionModel().getSelections();
            var sel;
            if (sels.length > 0) sel = sels[0];

            var params = [];
            params[params.length] = "op=" + op;
            if (op !== "c") {
                if (sel) {
                    if (url.indexOf("id=") < 0) {
                        params[params.length] = "id=" + sel.json.Id;
                    }
                } else {
                    AimDlg.show('请选择需要操作的行。', '提示', 'alert');
                    return;
                }
            }

            url = jQuery.combineQueryUrl(url, params)
            rtn = OpenWin(url, "_blank", style);
            if (rtn && rtn.result) {
                if (rtn.result === 'success') {
                    store.reload();
                }
            }
        }

        function batchOperate(action, recs, params, url) {
            if (!url) url = null;

            idList = [];

            if (recs != null) {
                $.each(recs, function() {
                    idList.push(this.json["Id"]);
                })
            }

            params = params || {};
            params["IdList"] = idList;

            $.ajaxExec(action, params, onExecuted);
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            门户内容维护</h1>
    </div>
</asp:Content>
