/*
* 对ext M选择页面的扩展
* @author Ray Liu
*/

var TitleString = '';
var StatusEnum = { '1': '有效', '0': '无效' };
var SelCatalogUrl = ''; // 分类页面地址
var SelSelViewUrl = ''; // 选择页面地址
var SelGrid;
var AimPopParamValue = {};

var catalogtype = '';
var catalogid = '';

var seltype = 'multi';  // multi(多选), single(单选)
var rtntype = 'string'; // string, json(json字符串), record(Ext DataRecord), array(数组)

function onPgLoad() {
    rtntype = $.getQueryString({ ID: "rtntype", DefaultValue: "string" }).toLowerCase();
    seltype = $.getQueryString({ ID: "seltype", DefaultValue: "multi" }).toLowerCase();

    catalogtype = $.getQueryString({ ID: "ctype", DefaultValue: "" }).toLowerCase();
    catalogid = $.getQueryString({ ID: "cid", DefaultValue: "" }).toLowerCase();


    AimPopParamValue = Aim.PopUp.GetPopParamValue() || {};  // 获取源参数值

    if (typeof (onSelPgLoad) == "function") {
        onSelPgLoad();
    }

    if (SelSelViewUrl && catalogid) {
        SelSelViewUrl = $.combineQueryUrl(SelSelViewUrl, { ctype: catalogtype, cid: catalogid });
    }

    if (TitleString) {
        // 设置标题
        document.title = TitleString;
        $("#header").find("h1").html(TitleString);
    }

    if (SelGrid) {
        SelGrid.on("rowdblclick", function(grid, rowIndex, e) {
            var rec = SelGrid.store.getAt(rowIndex);
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
                if (viewFrame.GetSelections) {
                    recs = viewFrame.GetSelections();
                }
                AddSelections(recs);
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
                hidden: (seltype == "single"),
                width: 200,
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
                //                hidden: catalogid || !SelCatalogUrl,
                //                margins: '0 0 0 0',
                //                cls: 'empty',
                //                width: 200,
                //                bodyStyle: 'background:#f1f1f1',
                //                html: '<iframe width="100%" height="100%" id="catalogFrame" name="catalogFrame" frameborder="0" src="' + SelCatalogUrl + '"></iframe>'
                //            },
            {
            region: 'center',
            split: true,
            margins: '0 0 0 0',
            cls: 'empty',
            bodyStyle: 'background:#f1f1f1',
            html: '<iframe width="100%" height="100%" id="viewFrame" name="viewFrame" frameborder="0" src="' + SelSelViewUrl + '"></iframe>'
        }, selPanel, cmdPanel]
            });
        }

        if (typeof (onSelPgLoaded) == "function") {
            onSelPgLoaded();
        }
    }

    // 选择页单击时触发
    function OnSelViewRowClick(rec, param) {
        if (seltype == "single") {
            store.removeAll();
            AddSelections([rec]);
        }
    }

    // 选择页双击时触发(由选择页面调用)
    function OnSelViewRowDblClick(rec, param) {
        if (seltype == "single") {
            SelectSingle(rec.json);
        } else {
            AddSelections([rec]);
        }
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
                store.remove(this);
            })
        }
    }

    // 设置分类(由选择索引页面调用)
    function SetCatalog(type, params) {
        catalogtype = type || 'default';
        var viewurl = SelSelViewUrl;

        viewurl = $.combineQueryUrl(SelSelViewUrl, "ctype=" + catalogtype);

        if (catalogtype != 'default') {
            if (typeof (params) == "object") {
                for (var key in params) {
                    if (typeof (key) == "string") {
                        viewurl += "&" + key + "=" + params[key];
                    }
                }
            }
        }

        var notation = viewurl.indexOf("?") > -1 ? "&sign=" : "?sign=";
        viewurl += notation + $.gerQueryString({ ID: 'sign' }) || "";
        viewFrame.location.href = viewurl;
    }

    function SelectSingle(ent) {
        Aim.PopUp.ReturnValue(ent);
    }

    function Select(recs) {

        if (!SelGrid) {
            return;
        }

        if (!recs) {
            recs = SelGrid.store.getRange();
        }

        if (seltype == "multi") {

            var vals = GetValues(recs, rtntype);
            Aim.PopUp.ReturnValue(vals);
        } else {
            if (recs && recs.length > 0) {
                Aim.PopUp.ReturnValue(recs[0].json);
            } else {
                Aim.PopUp.ReturnValue();
            }
        }
    }

    function GetValues(recs, type) {
        switch (type) {
            case "record":
                rtns = recs;
                break;
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

