<%@ Page Title="集团管理层" Language="C#" MasterPageFile="~/Masters/Ext/formpage.Master"
    AutoEventWireup="true" CodeBehind="ManagementEdit.aspx.cs" Inherits="Aim.Examining.Web.ManagementGroupEdit" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var store, grid;
        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {
            initGrid();
            FormValidationBind('btnSubmit', SuccessSubmit);

            $("#btnCancel").click(function() {
                window.close();
            });
        }
        function SuccessSubmit() {
            var resc = grid.getStore().getRange();
            resc = store.getModifiedDataStringArr(resc);
            if (resc.length > 0) {
                resc = "[" + resc.join(",") + "]";
                AimFrm.submit(pgAction, { OrgEnts: resc }, null, SubFinish);
            } else {
                AimFrm.submit(pgAction, {}, null, SubFinish);
            }
        }

        //grid 初始化
        function initGrid() {

            //工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    xtype: 'tbtext',
                    text: '<font color=red ><b>组织结构</b><font/>'
                }, '-',
				{
				    text: '添加',
				    iconCls: 'aim-icon-add',
				    handler: function() {
				        openOrgWin("grid");
				    }
				},
				{
				    text: '删除',
				    iconCls: 'aim-icon-delete',
				    handler: function() {
				        var recs = grid.getSelectionModel().getSelections();
				        var dt = store.getModifiedDataStringArr(recs);
				        if (!recs || recs.length <= 0) {
				            AimDlg.show("请先选择要删除的记录！");
				            return;
				        }
				        if (confirm("确定删除所选记录？")) {
				            store.remove(recs);
				            ExtBatchOperate('girdBatchDel', recs, null, null);
				        }
				    }
				}
		    ]
            });

            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList',
                isclient: true,
                data: { records: eval("(" + AimState["DataList"] + ")") || [] },
                fields: [{ name: 'Id' }, { name: 'Name' }, { name: 'PathName'}]
            });

            grid = new Ext.ux.grid.AimGridPanel({
                id: 'grid',
                store: store,
                height: 300,
                renderTo: 'girdDiv',
                autoExpandColumn: 'PathName',
                columns: [
                    { id: 'Id', dataIndex: 'Id', hidden: true },
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'Name', dataIndex: 'Name', header: '职位名称', width: 100 },
					{ id: 'PathName', dataIndex: 'PathName', header: '组织路径', width: 200, renderer: RowRender }
					],
                tbar: pgOperation != "v" ? tlBar : "",
                tbar: tlBar
            });
        }
        //组织结构选择
        function openOrgWin(gridSg) {
            var style = "dialogWidth:720px; dialogHeight:400px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "/CommonPages/Select/CustomerSlt/OrgPathName.aspx?seltype=multi&rtntype=array";
            OpenModelWin(url, {}, style, function(rtn) {
                if (this.data == null || this.data.length == 0 || !this.data.length) return;
                var gird = Ext.getCmp(gridSg);
                var EntRecord = gird.getStore().recordType;
                for (var i = 0; i < this.data.length; i++) {
                    if (Ext.getCmp(gridSg).store.find("Id", this.data[i]["GroupID"]) != -1) continue; //筛选已经存在的部门
                    var rec = new EntRecord({ Id: this.data[i]["GroupID"], Name: this.data[i]["Name"], PathName: this.data[i]["FullPathName"] });
                    gird.getStore().insert(gird.getStore().data.length, rec);
                }
            })
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "PathName":
                    if (value)
                        rtn = value.toString().substring("3", value.length);
                    else
                        rtn = "";
                    break;
            }
            return rtn;
        }

        function SubFinish(args) {
            RefreshClose();
        }
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            集团管理层</h1>
    </div>
    <div id="editDiv" align="center">
        <table class="aim-ui-table-edit">
            <tbody>
                <tr style="display: none">
                    <td>
                        <input id="Id" name="Id" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        名称
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="MName" name="MName" class="validate[required]" />
                    </td>
                    <td class="aim-ui-td-caption">
                        编号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="MCode" name="MCode" class="validate[required]" />
                    </td>
                </tr>
                <tr>
                    <td class="aim-ui-td-caption">
                        序号
                    </td>
                    <td class="aim-ui-td-data">
                        <input id="SortIndex" name="SortIndex" />
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div id="girdDiv" style="width: 100%;">
    </div>
    <table class="aim-ui-table-edit" style="width: 100%; margin: 2 0">
        <tr>
            <td class="aim-ui-button-panel" colspan="4">
                <a id="btnSubmit" class="aim-ui-button submit">保存</a> <a id="btnCancel" class="aim-ui-button cancel">
                    取消</a>
            </td>
        </tr>
    </table>
</asp:Content>
