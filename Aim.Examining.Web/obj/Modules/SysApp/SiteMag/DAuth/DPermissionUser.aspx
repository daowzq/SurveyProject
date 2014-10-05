<%@ Page Title="动态人员权限" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true" CodeBehind="DPermissionUser.aspx.cs" Inherits="Aim.Portal.Web.Modules.SysApp.SiteMag.DPermissionUser" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

<script type="text/javascript">
    var StatusEnum = { '1': '有效', '0': '无效' };
    var usrEditStyle = "dialogWidth:450px; dialogHeight:300px; scroll:yes; center:yes; status:no; resizable:yes;";
    var AllowOps = [];
    var OpDivChar = ',';
    
    var store, EntRecord, fields;
    var viewport, grid;
    var type, op, id;

    function onPgLoad() {
        type = $.getQueryString({ "ID": "type" });
        op = $.getQueryString({ "ID": "op" });
        id = $.getQueryString({ "ID": "id" });
        AllowOps = AimState["AllowOperation"] || [];
        OpDivChar = AimState["OpDivChar"] || ',';   // 操作分割符
        
        setPgUI();
    }

    function OPColumnName(code) {
        return "OP_" + code;
    }

    function FormatOpData(data) {
        var opstr = "";
        $.each(AllowOps, function() {
            if (data[OPColumnName(this.Code)] == true) {
                opstr += this.Code + OpDivChar;
            }
            delete (data[OPColumnName(this.Code)]);
        });

        opstr = opstr.trimEnd(OpDivChar);

        data.Operation = opstr;
        
        return data;
    }

    // 数据适配
    function adjustData(jdata) {
        if ($.isArray(jdata)) {
            $.each(jdata, function() {
                var tjdata = this;
                $.each(AllowOps, function() {
                    tjdata[OPColumnName(this.Code)] = tjdata.Operation.indexOf(this.Code) >= 0;
                });
            });
            
            return jdata;
        } else {
            return [];
        }
    }

    function setPgUI() {
        // 表格数据
        var data = adjustData(AimState["EntList"] || []);
        data.total = AimSearchCrit["RecordCount"];

        fields = [
			{ name: 'DynamicPermissionID' },
			{ name: 'Name' },
			{ name: 'CatalogCode' },
			{ name: 'AuthID' },
			{ name: 'AuthCatalogCode' },
			{ name: 'Operation' },
			{ name: 'Data' },
			{ name: 'Tag' },
			{ name: 'SortIndex' },
			{ name: 'EditStatus' },
			{ name: 'CreaterID' },
			{ name: 'CreaterName' },
			{ name: 'LastModifiedDate' },
			{ name: 'CreatedDate' }
];

			$.each(AllowOps, function() {
			    fields.push({ name: (OPColumnName(this.Code)), defaultValue: true });
			});

			EntRecord = Ext.data.Record.create(fields);
         
        // 表格数据源
        store = new Ext.ux.data.AimJsonStore({
            data: data,
            reader: new Ext.ux.data.AimJsonReader({ id: 'DynamicPermissionID', dsname: 'EntList', aimread: function(rd, resp, dt) { 
                if (dt) {
                    dt = adjustData(dt);
                    dt.total = resp.data.SearchCriterion["RecordCount"];
                }
            }
            }, EntRecord),
            proxy: new Ext.ux.data.AimRemotingProxy({
                aimbeforeload: function(proxy, options) {
                    options.data = { type: type, id: id, op: op };
                }
            })
        });
        
        grid = buildGrid();

        // 页面视图
        viewport = new Ext.ux.AimViewport({
            layout: 'border',
            items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
        });
    }

    function buildGrid() {
        var chkCols = [];

        if (AllowOps && $.isArray(AllowOps)) {
            $.each(AllowOps, function() {
                chkCols.push(new Ext.ux.grid.AimCheckColumn({ header: this["Name"], dataIndex: OPColumnName(this["Code"]), defaultValue: this["Deafult"], align: 'center' }));
            });
        };

        // 分页栏
        pgBar = new Ext.ux.AimPagingToolbar({
            pageSize: AimSearchCrit["PageSize"],
            store: store
        });

        // 搜索栏
        var schBar = new Ext.ux.AimSchPanel({
            items: []
        });

        // 工具栏
        var tlBar = new Ext.ux.AimToolbar({
            items: [{
                text: '保存',
                iconCls: 'aim-icon-save',
                handler: function() {
                    DoSave(onExecuted);
                }
            }, '-', { text: '添加人员', iconCls: 'aim-icon-user-add',
                handler: function() {
                    openMdlWin("/CommonPages/Select/UsrSelect/MUsrSelect.aspx?rtntype=array", "adduser");
                }
            }, { text: '移除人员', iconCls: 'aim-icon-user-delete',
                handler: function() {
                    UpdateGroupUser('delete');
                }
            }, '->', { text: '查询:' }, new Ext.app.AimSearchField({ store: store, pgbar: pgBar, schbutton: true, qryopts: "{ type: 'fulltext' }" })]
        });

        // 工具标题栏
        var titPanel = new Ext.ux.AimPanel({
            tbar: tlBar,
            items: [schBar]
        });

        grid = new Ext.ux.grid.AimEditorGridPanel({ 
            store: store,
            region: 'center',
            plugins: chkCols,
            columns: [
            { id: 'UserID', header: 'UserID', dataIndex: 'UserID', hidden: true },
            new Ext.ux.grid.AimRowNumberer(),
            new Ext.ux.grid.AimCheckboxSelectionModel(),
            { id: 'Name', header: '姓名', width: 100, renderer: linkRender, sortable: true, dataIndex: 'Name' }
            ],
            bbar: pgBar,
            tbar: titPanel,
            autoExpandColumn: 'Name'
        });

        $.each(chkCols, function() {
            grid.addColumn(this, null, null, false);
        });

        return grid;
    }

    // 链接渲染
    function linkRender(val, p, rec) {
        var rtn = val;
        switch (this.dataIndex) {
            case "Name":
                rtn = "<a class='aim-ui-link' onclick='openMdlWin(\"/Modules/SysApp/OrgMag/UsrEdit.aspx?id=" + rec.json.Data + "\", null, usrEditStyle)'>" + val + "</a>";
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
                if (op == 'adduser') {
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
            $.ajaxExec("adduser", { "id": id, UserIDs: uids }, onExecuted);
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
                        uids.push(this.json.Data);
                    })
                }
            }

            $.ajaxExec("deluser", { "id": id, UserIDs: uids }, onExecuted);
        }
    }

    function DoSave(onSaveFinish) {
        var dt = [];
        var recs = store.getModifiedRecords();

        $.each(recs, function() {
            dt[dt.length] = $.getJsonString(FormatOpData(this.data));
        });

        $.ajaxExec('update', { "id": id, "data": dt }, onSaveFinish);
    }

    // 提交数据成功后
    function onExecuted() {
        store.commitChanges();
        store.removeAll();
        store.load();
    }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display:none;"><h1>动态人员权限列表</h1></div>
</asp:Content>
