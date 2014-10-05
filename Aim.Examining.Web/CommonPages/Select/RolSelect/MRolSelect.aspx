<%@ Page Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="MRolSelect.aspx.cs" Inherits="Aim.Portal.Web.CommonPages.MRolSelect" %>
<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script src="/CommonPages/Select/js/m-sel.js" type="text/javascript"></script>

    <script type="text/javascript">

        var store, DataRecord;

        function onSelPgLoad() {
            TitleString = '角色选择';
            SelCatalogUrl = 'RolCatalog.aspx';
            SelSelViewUrl = "RolSelView.aspx";

            setPgUI();
        }

        function setPgUI() {
            DataRecord = Ext.data.Record.create([
            { name: 'RoleID', type: 'string' },
            { name: 'Name', type: 'string' }
        ]);

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                reader: new Ext.ux.data.AimJsonReader({ id: 'RoleID' }, DataRecord)
            });

            store.on('load', function() {
                InitSelections();
            });

            // 表格面板
            SelGrid = new Ext.grid.GridPanel({
                store: store,
                region: 'center',
                width: 180,
                minSize: 100,
                maxSize: 200,
                columns: [
                new Ext.grid.CheckboxSelectionModel({ singleSelect: false }),
                { id: 'Name', header: "角色名", width: 160, sortable: true, dataIndex: 'Name' }
      ],
                autoExpandColumn: 'Name'
            });
        }

        function InitSelections(pval) {
            var pval = AimPopParamValue || {};
            var ids = (pval["RoleID"] || "").split(",");
            var names = (pval["Name"] || "").split(",");

            var rtndata = [];
            for (var i = 0; i < ids.length; i++) {
                if (ids[i]) {
                    rtndata.push({ "RoleID": ids[i], "Name": names[i] });
                }
            }

            $.each(rtndata, function() {
                if (this) {
                    var rec = new DataRecord(this, this["RoleID"]);
                    store.add(rec);
                }
            });
        }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
        </h1>
    </div>
</asp:Content>
