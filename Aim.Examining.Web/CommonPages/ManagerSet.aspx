<%@ Page Title="集团管理层" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="ManagerSet.aspx.cs" Inherits="Aim.Examining.Web.Modules.SysApp.SysMag.ManagerSet" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'MGroupId' },
			{ name: 'MName' },
			{ name: 'MCode' },
			{ name: 'GroupsSet' },
			{ name: 'GroupsName' },
			{ name: 'SortIndex' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' }
			]
            });

            // 分页栏
            pgBar = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });

            // 搜索栏
            schBar = new Ext.ux.AimSchPanel({
                store: store,
                collapsed: false,
                columns: 1,
                items: [
                { fieldLabel: '职位名称', id: 'MName', schopts: { qryopts: "{ mode: 'Like', field: 'MName' }"}}]
            });

            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        var recType = store.recordType;
                        var resc = grid.getStore().getRange();
                        var index = 0;
                        $.each(resc, function() {
                            if (parseInt(this.get("SortIndex")) > index)
                                index = parseInt(this.get("SortIndex"));
                        });
                        var rec = new recType({ SortIndex: index + 1 });
                        store.insert(store.data.length, rec);
                        var top = $(".x-grid3-body").innerHeight() - $(".x-grid3-scroller").innerHeight();
                        $(".x-grid3-scroller").scrollTop(top);
                    }
                },
               {
                   text: '保存',
                   iconCls: 'aim-icon-save',
                   handler: function() {
                       // 保存修改的数据
                       var recs = store.getModifiedRecords();
                       if (recs && recs.length > 0) {
                           var dt = store.getModifiedDataStringArr(recs) || [];
                           jQuery.ajaxExec('batchsave', { "data": dt }, function() {
                               store.commitChanges();
                               store.reload();
                               AimDlg.show("保存成功！");
                               frameContent.location.href = "ManagerDetail.aspx?PId=" + store.getAt(0).get("Id");
                           });
                       }
                   }
               },

                {
                    text: '删除',
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }

                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
}]
                });
                // 工具标题栏
                titPanel = new Ext.ux.AimPanel({
                    tbar: tlBar,
                    items: [schBar]
                });

                // 表格面板
                grid = new Ext.ux.grid.AimEditorGridPanel({
                    store: store,
                    split: true,
                    region: 'west',
                    clicksToEdit: 2,
                    width: 350,
                    autoExpandColumn: 'MName',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                     new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'SortIndex', dataIndex: 'SortIndex', header: '序号', width: 50, sortable: true, editor: { xtype: 'textfield'} },
					{ id: 'MName', dataIndex: 'MName', header: '职位名称', width: 130, sortable: true, editor: { xtype: 'textfield'} }
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                });

                //                grid.on("afteredit", function(e) {
                //                    if (e.record.get("MName")) {
                //                        var SortIndex = e.record.get("SortIndex");
                //                        var MName = e.record.get("MName");
                //                        var Id = e.record.get("Id");
                //                        $.ajaxExec("save", { Id: Id, SortIndex: SortIndex, MName: MName }, function(rtn) {
                //                            if (!e.record.get("Id")) e.record.set("Id", rtn.data.Id);
                //                            e.record.commit();
                //                        })
                //                    }
                //                });


                grid.on("rowclick", function(grid, rowIndex, e) {
                    var Element = document.getElementById("frameContent");
                    if (Element) {
                        var rec = grid.getStore().getAt(rowIndex);
                        if (rec.get("MName")) {
                            var url = "ManagerDetail.aspx?PId=" + rec.get("Id");
                            frameContent.location.href = url;
                        }
                    }
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid, {
                        region: 'center',
                        margins: '-2 0 0 0',
                        cls: 'empty',
                        bodyStyle: 'background:#f1f1f1',
                        html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
}]
                    });
                }

                window.setTimeout(function() {
                    var Element = document.getElementById("frameContent");
                    if (Element) {
                        frameContent.location.href = "ManagerDetail.aspx?PId=" + store.getAt(0).get("Id");
                    }
                }, 100);

                // 提交数据成功后
                function onExecuted() {
                    store.reload();
                }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
