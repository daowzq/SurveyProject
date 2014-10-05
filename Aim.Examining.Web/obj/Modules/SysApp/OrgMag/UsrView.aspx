<%@ Page Title="人员列表" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="UsrView.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.OrgMag.UsrView" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var StatusEnum = { '1': '有效', '0': '无效' };
    var usrEditStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";
    
    var viewport;
    var store;
    var grid, pgBar;
    var qtype, op, id;

    function onPgLoad() {
        setPgUI();
        qtype = $.getQueryString({ "ID": "type" });
        op = $.getQueryString({ "ID": "op" });
        id = $.getQueryString({ "ID": "id" });
    }

    function setPgUI() {
        // 表格数据
        var myData = {
            total: AimSearchCrit["RecordCount"],
            records: AimState["UsrList"] || []
        };

        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            dsname: 'UsrList',
            idProperty: 'UserID',
            data: myData,
            fields: [{ name: 'UserID' }, { name: 'Name' }, { name: 'LoginName' }, { name: 'Status' }, { name: 'Email' }, { name: 'Remark' }, { name: 'CreateDate', type: 'date'}],
            proxy: new Ext.ux.data.AimRemotingProxy({
                aimbeforeload: function(proxy, options) {
                    options.data = { type: qtype, id: id, op: op };
                }
            })
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
        var schBar = new Ext.Panel({
            collapsed: true,
            unstyled: true,
            padding: 5,
            layout: 'column',
            items: [/*{ layout: 'form', unstyled: true, columnWidth: .33,
                items: [new Ext.app.AimSearchField({ fieldLabel: '姓名', anchor: '90%', name: 'Name', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'Name' }" })]
            }, { layout: 'form', unstyled: true, columnWidth: .33,
            items: [new Ext.app.AimSearchField({ fieldLabel: '登录名', anchor: '90%', name: 'LoginName', store: store, aimgrp: "usrgrp", qryopts: "{ mode: 'Like', field: 'LoginName' }" })]
}*/]
        });

        // 工具栏
        var tlBar = new Ext.Toolbar({
            items: [{ text: '添加人员', iconCls: 'aim-icon-user-add',
                handler: function() {
                    openMdlWin("/CommonPages/Select/UsrSelect/MUsrSelect.aspx?rtntype=array", "addgrpuser");
                }
            }, { text: '移除人员', iconCls: 'aim-icon-user-delete',
                handler: function() {
                    UpdateGroupUser('delete');
                }
            }, '->', { text: '查询:' }, new Ext.app.AimSearchField({ store: store, pgbar: pgBar, schbutton: true, qryopts: "{ type: 'fulltext' }" })]
        });

        // 工具标题栏
        var titPanel = new Ext.Panel({
            tbar: tlBar,
            items: [schBar]
        });

        // 表格面板
        grid = new Ext.grid.GridPanel({
            store: store,
            region: 'center',

            monitorResize: true,
            columns: [
            { id: 'UserID', header: 'UserID', dataIndex: 'UserID', hidden: true },
            new Ext.ux.grid.AimRowNumberer(),
            { id: 'Name', header: '姓名', width: 100, renderer: linkRender, sortable: true, dataIndex: 'Name' },
            { id: 'LoginName', header: '登录名', width: 100, sortable: true, dataIndex: 'LoginName' },
            { id: 'Status', header: '状态', width: 100, align: 'center', renderer: enumRender, sortable: true, dataIndex: 'Status' }
            ],
            bbar: pgBar,
            tbar: titPanel,
            frame: true,
            forceLayout: true,
            stripeRows: true,
            autoExpandColumn: 'Name',
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
                        rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"UsrEdit.aspx?id=" + rec.id + "\", null, usrEditStyle)'>" + val + "</a>";
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
            function openMdlWin(url, op, style) {
                op = op || "r";
                style = style || "dialogWidth:750px; dialogHeight:550px; scroll:yes; center:yes; status:no; resizable:yes;";

                var params = [];
                params[params.length] = "op=" + op;

                url = $.combineQueryUrl(url, params)
                rtn = window.showModalDialog(url, window, style);

                if (rtn && rtn.result) {
                    if (rtn.result === 'success') {
                        if (op == 'addgrpuser') {
                            var uids = [];
                            var usrs = rtn.data;
                            
                            $.each(usrs, function() {
                                if (this.UserID) {
                                    uids.push(this.UserID);
                                }
                            });

                            UpdateGroupUser('add', uids);
                        }
                    }
                }
            }

            // 添加用户到组
            function UpdateGroupUser(op, uids) {
                if (op == 'add' && uids) {
                    $.ajaxExec("addgrpuser", { id: id, UserIDs: uids }, onExecuted);
                } else if (op == "delete" || op == "remove") {
                    if (!uids) {
                        uids = [];
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的人员！");
                            return;
                        }
                        
                        if (recs != null) {
                            $.each(recs, function() {
                                uids.push(this.json.UserID);
                            })
                        }
                    }

                    $.ajaxExec("delgrpuser", { id: id, UserIDs: uids }, onExecuted);
                }
            }

            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>人员列表</h1></div>
</asp:Content>
