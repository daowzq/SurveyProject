<%@ Page Title="岗位名称" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="MiddleDbPositionView.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.Select.CustomerSlt.MiddleDBPositionView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">

        //全局变量对象
        var globalVal = {
            param: $.getQueryString({ ID: "param" }) || "",  //控制参数
            rtntype: $.getQueryString({ ID: "rtntype" }) || "string", //array,json,string
            seltype: $.getQueryString({ ID: 'seltype' }) || 'multi',
            ckNode: { id: "", text: '' },
            viewFrameUrl: "MiddleDbPostionSlt.aspx"
        }

        var SelGrid, store;
        function onPgLoad() {
            DataRecord = Ext.data.Record.create([
            { name: 'GroupID', type: 'string' },
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
                new Ext.ux.grid.AimCheckboxSelectionModel(),
				{ id: 'Name', header: "组名", width: 160, sortable: true, dataIndex: 'Name' }
      ],
                autoExpandColumn: 'Name'
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
                items: [{ xtype: 'button',
                    text: '选择',
                    handler: function() {
                        AddSelections();
                    }
                }, { xtype: 'button', text: '移除', handler: function() {
                    var recs = SelGrid.getSelectionModel().getSelections();
                    RemoveSelections(recs);
                }
                }, { xtype: 'button', text: '清空', handler: function() {
                    SelGrid.store.each(function() {
                        SelGrid.store.remove(this);
                    })
                } }]
                });
                selPanel = new Ext.ux.AimPanel({
                    region: 'east',
                    split: true,
                    // hidden: (seltype == "single"),
                    width: 260,
                    layout: 'border',
                    items: [selCmdPanel, SelGrid]
                });

                cmdPanel = new Ext.Panel({
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
                            Select();
                        }
                    }, { xtype: 'button', text: '清空',
                        handler: function() {
                            Aim.PopUp.ReturnValue({});
                        }
                    }, { xtype: 'button', text: '取消',
                        handler: function() {
                            window.close();
                        }
}]
                    });

                    // 页面视图
                    viewport = new Ext.ux.AimViewport({
                        layout: 'border',
                        items: [{
                            region: 'center',
                            split: true,
                            margins: '0 0 0 0',
                            cls: 'empty',
                            bodyStyle: 'background:#f1f1f1',
                            html: '<iframe width="100%" height="100%" id="viewFrame" name="viewFrame" frameborder="0" ></iframe>'
                        }, selPanel, cmdPanel]
                    });

                    viewFrame.location.href = globalVal.viewFrameUrl + "?param=" + globalVal.param;
                }

                function InitSelections(pval) {
                    //there have bug  'AimPopParamValue' is all object is all true

                    //var pval = AimPopParamValue || {};
                    var pval = Aim.PopUp.GetPopParamValue() || {};
                    var ids = (pval["GroupID"] || $.getQueryString({ ID: "GroupID" }) || "").split(",");
                    var names = (pval["Name"] || $.getQueryString({ ID: "Name" }) || "").split(",");

                    var rtndata = [];
                    for (var i = 0; i < ids.length; i++) {
                        if (ids[i]) {
                            rtndata.push({ "GroupID": ids[i], "Name": names[i] });
                        }
                    }
                    $.each(rtndata, function() {
                        if (this) {
                            var rec = new DataRecord(this, this["GroupID"]);
                            store.add(rec);
                        }
                    });
                }
                //选择
                function AddSelections() {
                    if (globalVal.seltype == "single") {
                        recType = store.recordType;
                        var rec = new recType({ GroupID: globalVal.ckNode.id, Name: globalVal.ckNode.text });

                        if (store.getRange().length > 0) {
                            var havRepeat = false;
                            $.each(store.getRange(), function() {
                                if (this && this.get("GroupID") == globalVal.ckNode.id) {
                                    havRepeat = true;
                                }
                            });
                            !havRepeat && store.insert(0, rec);
                        } else {
                            store.insert(0, rec);
                        }

                    } else if (globalVal.seltype == "multi") {
                        recType = store.recordType;
                        var rec = new recType({ GroupID: globalVal.ckNode.id, Name: globalVal.ckNode.text });
                        if (store.getRange().length > 0) {
                            var havRepeat = false;
                            $.each(store.getRange(), function() {
                                if (this && this.get("GroupID") == globalVal.ckNode.id) {
                                    havRepeat = true;
                                }
                            });
                            !havRepeat && tore.insert(store.data.length, rec);
                        } else {
                            store.insert(store.data.length, rec);
                        }

                    }
                }

                //双击
                function treeDbClick(node) {

                    //id text		var recType = store.recordType;
                    if (globalVal.seltype == "single") {
                        recType = store.recordType;
                        var rec = new recType({ GroupID: node.id, Name: node.text });

                        if (store.getRange().length > 0) {
                            var havRepeat = false;
                            $.each(store.getRange(), function() {
                                if (this && this.get("GroupID") == node.id) {
                                    havRepeat = true;
                                }
                            });

                            !havRepeat && store.insert(0, rec);
                        } else {
                            store.insert(0, rec);
                        }

                    } else if (globalVal.seltype == "multi") {
                        recType = store.recordType;
                        var rec = new recType({ GroupID: node.id, Name: node.text });
                        if (store.getRange().length > 0) {
                            var havRepeat = false;
                            $.each(store.getRange(), function() {
                                if (this && this.get("GroupID") == node.id) {
                                    havRepeat = true;
                                }
                            });
                            !havRepeat && store.insert(store.data.length, rec);
                        } else {
                            store.insert(store.data.length, rec);
                        }

                    }

                }

                //点击
                function treeClick(node) {
                    globalVal.ckNode.id = node.id || "";
                    globalVal.ckNode.text = node.text || "";
                }

                // 移除记录
                function RemoveSelections(recs) {
                    if (recs != null) {
                        $.each(recs, function() {
                            store.remove(this);
                        })
                    }
                }

                function Select(recs) {
                    if (!SelGrid) {
                        return;
                    }
                    if (!recs) {
                        recs = SelGrid.store.getRange();
                    }
                    if (globalVal.seltype == "multi") {
                        var vals = GetValues(recs, globalVal.rtntype);
                        Aim.PopUp.ReturnValue(vals);
                    } else {
                        if (recs && recs.length > 0) {
                            Aim.PopUp.ReturnValue(recs[0].json);
                        } else {
                            Aim.PopUp.ReturnValue();
                        }
                    }
                }

                //----------------------选择-----------------------
                function GetValues(recs, type) {
                    switch (type) {
                        case "array":
                            rtns = GetValueArray(recs);
                            break;
                        case "json":
                        case "string":
                        default:
                            rtns = GetValueString(recs);
                            break;
                    }
                    return rtns;
                }
                function GetValueArray(recs) {

                    var arr = [];
                    if (recs && $.isArray(recs)) {
                        $.each(recs, function() {
                            if (this.json) {
                                arr.push(this.json);
                            }
                            else {
                                arr.push({ GroupID: this.get("GroupID"), Name: this.get("Name") });
                            }
                        });
                    }

                    return arr;
                }

                function GetValueString(recs) {
                    var strjson = {};

                    if (recs && $.isArray(recs)) {
                        $.each(recs, function() {
                            for (var key in this.data) {
                                if (!strjson[key]) {
                                    strjson[key] = this.data[key]
                                } else {
                                    if (this.data[key]) {
                                        strjson[key] += "," + this.data[key].toString();
                                    }
                                }
                            }
                        });
                    }

                    return strjson;
                }

                //--------------------------------------------

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
