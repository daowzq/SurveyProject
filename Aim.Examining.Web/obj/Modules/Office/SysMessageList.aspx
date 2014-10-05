
<%@ Page Title="内部邮件" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="SysMessageList.aspx.cs" Inherits="Aim.Portal.Web.SysMessageList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var StatusEnum = { '1': '有效', '0': '无效' };
    
    var viewport;
    var store, myData;
    var pgBar, schBar, tlBar, titPanel, grid;
    var typeId;

    function onPgLoad() {
        typeId = $.getQueryString({"ID":"TypeId"});
    
        setPgUI();
    }

    function setPgUI() {

        // 表格数据
        myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["SysMessageList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'SysMessageList',
            idProperty: 'Id',
            data: myData,
            fields: [
			{ name: 'Id' },
			{ name: 'SenderName' },
			{ name: 'ReceiverName' },
			{ name: 'Title' },
			{ name: 'SendTime' }
			]
			 , listeners: { "aimbeforeload": function(proxy, options) {
			    options.data = options.data || {};
			    options.data.TypeId  ='<%=this.Request["TypeId"] %>';
            }
            }
        });

        // 分页栏
        pgBar = new Ext.ux.AimPagingToolbar({
            pageSize: AimSearchCrit["PageSize"],
            store: store
        });

        // 搜索栏
        schBar = new Ext.ux.AimSchPanel({
            items: [
				{ layout: 'form', unstyled: true, columnWidth: .33,
				    items: [new Ext.app.AimSearchField({ fieldLabel: '标题', anchor: '90%', name: 'Title', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Title' }" })]}, 
                { layout: 'form', unstyled: true, columnWidth: .33,
                    items: [new Ext.app.AimSearchField({ fieldLabel: '发送人', anchor: '90%', name: 'Field12', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'SenderName' }" })]}]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    hidden: typeId != "Send",
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        openEditWin("SysMessageEdit.aspx", "c");
                    }
                }, {
                    text: '修改',
                    hidden: typeId != "Send",
                    iconCls: 'aim-icon-edit',
                    handler: function() {
                        openEditWin("SysMessageEdit.aspx", "u");
                    }
                }, {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        if(confirm("确定删除所选记录？")){
                            batchOperate('batchdelete', {"TypeId": typeId});
                        }
                    }
                }, '-', {
                    text: '其他',
                    iconCls: 'aim-icon-cog',
                    menu: [{ text: '导出Excel', iconCls: 'aim-icon-xls', handler: function() {
                        ExtGridExportExcel(grid, { store: null, title: '内部邮件' });
                    }}]
                }, '->', { text: '查询&nbsp;:&nbsp; ', xtype:'tbtext' },
                new Ext.app.AimSearchField({ store: store, schbutton: true, qryopts: "{ type: 'fulltext' }" }),
                '-',
                {
                    text: '复杂查询',
                    iconCls: 'aim-icon-search',
                    handler: function() {
                        schBar.toggleCollapse(false);

                        setTimeout("viewport.doLayout()", 50);
                    }
}]
                });

                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.grid.AimGridPanel({
                    store: store,
                    region: 'center',
                    columns: [
                    { id: 'Id', header: '标识', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Title', header: '标题', width: 100, sortable: true, renderer: linkRender, dataIndex: 'Title' },
					{ id: 'SenderName', header: '发送人', width: 100,  sortable: true, dataIndex: 'SenderName' },
					{ id: 'ReceiverName', header: '接收人', width: 100,  sortable: true, dataIndex: 'ReceiverName' },
					{ id: 'SendTime', header: '发送时间', width: 100,  sortable: true, dataIndex: 'SendTime' }
                    ],
                    bbar: pgBar,
                    tbar: titPanel,
                    autoExpandColumn: 'Title'
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                });
            }

            // 链接渲染
            function linkRender(val, p, rec) {
                var rtn = val;
                switch (this.dataIndex) {
                    case "Title":
                        rtn = "<a class='aim-ui-link' onclick='openEditWin(\"SysMessageEdit.aspx?id=" + rec.data.Id + "\")'>" + val + "</a>";
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
                style = style || CenterWin("width=650,height=450,scrollbars=auto");

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
            
            function batchOperate(action, params, url){
                if(!url) url = null;
                var recs = grid.getSelectionModel().getSelections();
                if (!recs || recs.length <= 0) {
                    AimDlg.show("请先选择要删除的记录！");
                    return;
                }
                
                ids = [];
                
                if (recs != null) {
                    $.each(recs, function() {
                        ids.push(this.json["Id"]);
                    })
                }
                
                params = params || {};
                params["Ids"] = ids;
                
                $.ajaxExec(action, params, onExecuted);
            }
            
            // 提交数据成功后
            function onExecuted(){
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>内部邮件</h1></div>
</asp:Content>


