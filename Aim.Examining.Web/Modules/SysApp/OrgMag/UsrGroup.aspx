<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="UsrGroup.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.OrgMag.UsrGroup" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGrid.css" rel="stylesheet" type="text/css" />
    <link href="/App_Themes/Ext/ux/TreeGrid/TreeGridLevels.css" rel="stylesheet" type="text/css" />

    <script src="/js/ext/ux/TreeGrid.js" type="text/javascript"></script>

    <script type="text/javascript">
        var StatusEnum = { 1: "启用", 0: "停用" };

        var viewport;
        var authStore, usrStore;
        var authGrid, usrGrid, pgBar;
        var authSchField, usrSchField;
        
        var DataRecord;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            usrStore = new Ext.ux.data.AimJsonStore({
                dsname: 'UsrList',
                idProperty: 'UserID',
                data: { records: AimState["UsrList"] || [], total: AimSearchCrit["RecordCount"] || 0 },
                fields: [{ name: 'UserID' }, { name: 'Name' }, { name: 'LoginName'}]
            });

            usrSchField = new Ext.app.AimSearchField({ fieldLabel: '', anchor: '90%', name: 'UserID', hidden: true, hideLable: true, store: usrStore, aimgrp: "grp", qryopts: "{ mode: 'Equal', field: 'UserID' }" });

            usrTlBar = new Ext.Toolbar({ items: ['<label style="font-size:12px;" title="姓名拼音首字母">姓名:</label>',
                new Ext.app.AimSearchField({ store: usrStore, id: "sname", width: 90, schbutton: true, qryopts: "{ mode: 'Equal', field: 'Name'}" }),
                '<label style="font-size:12px;">工号:</label>',
                new Ext.app.AimSearchField({ store: usrStore, id: "sworkno", width: 90, schbutton: true, qryopts: "{ mode: 'Like', field: 'WorkNo' }" })]
            });

            // 分页栏
            pgBar = new Ext.PagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: usrStore,
                displayInfo: true,
                displayMsg: '总条目 {2}',
                emptyMsg: "无条目显示",
                items: ['-']
            });

            usrGrid = new Ext.grid.GridPanel({
                id: 'usrPanel',
                store: usrStore,
                region: 'west',
                split: true,
                width: 300,
                minSize: 250,
                maxSize: 500,
                margins: '0 0 5 5',
                cmargins: '0 5 5 5',
                columns: [{ id: 'UserID', header: 'UserID', dataIndex: 'UserID', hidden: true },
                { id: 'Name', header: '姓名', width: 100, renderer: usrRender, sortable: true, dataIndex: 'Name' },
                { id: 'LoginName', header: '登录名', width: 100, sortable: true, dataIndex: 'LoginName'}],
                autoExpandColumn: 'Name',
                bbar: pgBar,
                tbar: usrTlBar
            });

            usrGrid.getSelectionModel().on('rowselect', function(sm, rowIdx, r) {
                frameContent.location.href = "GrpTree.aspx?type=user&op=r&id=" + r.data.UserID;
            });

            // 页面视图
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, usrGrid, {
                    region: 'center',
                    margins: '0 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0" src=""></iframe>'}/*, tree, authGrid*/]
                });

                usrGrid.getSelectionModel().selectFirstRow();
            }

            // 链接渲染
        function usrRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Name":
                    rtn = "<a class='aim-ui-link'>" + val + "</a>";
                    break;
            }

            return rtn;
        }

            // 链接渲染
        function linkRender(val, p, rec) {
            var rtn = val;
            switch (this.dataIndex) {
                case "Name":
                    rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"UsrEdit.aspx?id=" + p.value + "\")'>" + val + "</a>";
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
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>组列表</h1></div>
</asp:Content>
