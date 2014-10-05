<%@ Page Title="授权管理" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="FrmMultiRoleSelect.aspx.cs" Inherits="Aim.Portal.Web.EPC.FrmMultiRoleSelect" %>

<%@ OutputCache Duration="1" VaryByParam="None" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var StatusEnum = { '1': '有效', '0': '无效' };
        var catalogtype = '';
        var seltype = 'multi';  // multi(多选), single(单选)
        var rtntype = 'string'; // string, json(json字符串), record(Ext DataRecord), array(数组)

        var store, grid, viewport, selPanel;
        var DataRecord;

        function onPgLoad() {
            rtntype = $.getQueryString({ ID: "rtntype", DefaultValue: "string" }).toLowerCase();
            seltype = $.getQueryString({ ID: "seltype", DefaultValue: "multi" }).toLowerCase();

            setPgUI();
        }

        function setPgUI() {

            DataRecord = Ext.data.Record.create([
            { name: 'RoleID', type: 'string' },
            { name: 'UserID', type: 'string' },
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
            grid = new Ext.ux.grid.AimGridPanel({
                store: store,
                region: 'center',
                width: 120,
                minSize: 100,
                maxSize: 200,
                columns: [
                new Ext.grid.MultiSelectionModel(),
                { id: 'RoleID', header: '标识', dataIndex: 'RoleID', hidden: true },
                { id: 'UserID', header: 'UserID', dataIndex: 'UserID', hidden: true },
				{ id: 'Name', header: "名称", width: 100, sortable: true, dataIndex: 'Name' }
      ],
                autoExpandColumn: 'Name'
            });

            grid.on("rowdblclick", function(grid, rowIndex, e) {
                var rec = grid.store.getAt(rowIndex);
                RemoveSelections([rec]);
            });

            selCmdPanel = new Ext.ux.AimPanel({
                region: 'west',
                layout: 'vbox',
                border: false,
                width: 50,
                layoutConfig: {
                    padding: '5',
                    pack: 'center',
                    align: 'middle'
                },
                defaults: { margins: '0 0 5 0' },
                items: [{ xtype: 'button', text: '选择', handler: function() {
                    var recs;

                    if (usrViewFrame.frames[0] && usrViewFrame.frames[0].GetSelections) {
                        recs = usrViewFrame.frames[0].GetSelections();
                    }
                    
                    if (recs) {
                        recs.push(usrViewFrame.frames[1].GetSelections());
                    } else {
                        recs = usrViewFrame.frames[1].GetSelections();
                    }

                    AddSelections(recs);
                }
                }, { xtype: 'button', text: '移除', handler: function() {
                    var recs = grid.getSelectionModel().getSelections();

                    RemoveSelections(recs);
                }
                }, { xtype: 'button', text: '清空', handler: function() {
                    store.each(function() {
                        store.remove(this);
                    })
                } }]
                });

                selPanel = new Ext.ux.AimPanel({
                    region: 'east',
                    split: true,
                    hidden: (seltype == "single"),
                    width: 200,
                    layout: 'border',
                    items: [selCmdPanel, grid]
                });

                cmdPanel = new Ext.ux.AimPanel({
                    region: 'south',
                    layout: 'hbox',
                    // hidden: (seltype == "single"),
                    layoutConfig: {
                        padding: '5',
                        pack: 'center',
                        align: 'middle'
                    },
                    height: 40,
                    items: [{ xtype: 'button', text: '确定',
                        handler: function() {
                            var usrs = GetUsers(rtntype);
                            if (!usrs || usrs == "" || usrs.length == 0) {
                                AimDlg.show("请选择人员!");
                                return;
                            }
                            Aim.PopUp.ReturnValue(usrs);
                        }
                    }, { xtype: 'button', text: '清空',
                        handler: function() {
                            Aim.PopUp.ReturnValue({});
                        }
                    },
            { xtype: 'button', text: '取消', handler: function() { window.close(); } }]
                });

                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    layout: 'border',
                    items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 },
                    //            {
                    //                region: 'west',
                    //                split: true,
                    //                margins: '0 0 0 0',
                    //                cls: 'empty',
                    //                width: 200,
                    //                bodyStyle: 'background:#f1f1f1',
                    //                html: '<iframe width="100%" height="100%" id="usrCatalogFrame" name="frameContent" frameborder="0" src="UsrCatalog.aspx"></iframe>'
                    //            },
            {
            region: 'center',
            split: true,
            margins: '0 0 0 0',
            cls: 'empty',
            bodyStyle: 'background:#f1f1f1',
            html: '<iframe width="100%" height="100%" id="usrViewFrame" name="frameContent" frameborder="0" src="FrmSelView.aspx"></iframe>'
        }, selPanel, cmdPanel]
                });
            }

            // 选择页单击时触发
            function OnSelViewRowClick(rec, param) {
                if (seltype == "single") {
                    store.removeAll();
                    AddSelections([rec]);
                }
            }

            // 选择页双击时触发
            function OnSelViewRowDblClick(rec, param) {
                if (seltype == "single") {
                    SelSingleUser(rec.json);
                } else {
                    AddSelections([rec]);
                }
            }

            // 初始化选择项
            function InitSelections() {
                var pval = Aim.PopUp.GetPopParamValue() || {};
                var uids = (pval["RoleID"] || "").split(",");
                var users = (pval["UserID"] || "").split(",");
                var unames = (pval["Name"] || "").split(",");

                var rtndata = [];
                for (var i = 0; i < uids.length; i++) {
                    if (uids[i]) {
                        rtndata.push({ "RoleID": uids[i], "Name": unames[i], "UserID": users });
                    }
                }

                $.each(rtndata, function() {
                    if (this) {
                        var rec = new DataRecord(this, this["RoleID"]);
                        store.add(rec);
                    }
                });
            }

            // 添加已选记录
            function AddSelections(recs) {
                if (recs != null) {
                    $.each(recs, function() {
                        if (this && !store.getById(this.id)) {
                            store.add(this);
                        }
                    })
                }
            }

            // 移除记录
            function RemoveSelections(recs) {
                if (recs != null) {
                    $.each(recs, function() {
                        try {
                            store.remove(this);
                        } catch (ex) {
                            alert(ex.message);
                        }
                    })
                }
            }

            function SelSingleUser(usr) {
                Aim.PopUp.ReturnValue(usr);
            }

            // 设置选人分类
            function SetCatalog(type, params) {
                catalogtype = type || 'default';
                var viewurl = "FrmSelView.aspx";

                viewurl = "FrmSelView.aspx?ctype=" + catalogtype;

                if (catalogtype != 'default') {
                    if (typeof (params) == "object") {
                        for (var key in params) {
                            if (typeof (key) == "string") {
                                viewurl += "&" + key + "=" + params[key];
                            }
                        }
                    }
                }

                usrViewFrame.location.href = viewurl;
            }

            function GetUsers(type) {
                switch (type) {
                    case "record":
                        rtns = store.getRange();
                        break;
                    case "array":
                        rtns = GetUserArray();
                        break;
                    case "json":
                    case "string":
                    default:
                        rtns = GetUserString();
                        break;
                }

                return rtns;
            }

            function GetUserString() {
                var strjson = {};

                store.each(function() {
                    var tdata = this.json || this.data;
                    for (var key in tdata) {
                        if (!strjson[key]) {
                            strjson[key] = tdata[key]
                        } else {
                            if (tdata[key]) {
                                strjson[key] += "," + tdata[key].toString();
                            }
                        }
                    }
                });

                return strjson;
            }

            function GetUserArray() {
                var arr = [];
                store.each(function() {
                    arr.push(this.json || this.data);
                });

                return arr;
            }
    
    </script>

</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header">
        <h1>
            授权管理</h1>
    </div>
</asp:Content>
