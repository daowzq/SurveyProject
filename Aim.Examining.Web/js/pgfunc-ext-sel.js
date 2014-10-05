/*
* pgfunc对ext选择页面的扩展
*/

var seltype = 'single';  // multi(多选), single(单选)
var rtntype = 'string'; // string, json(json字符串), record(Ext DataRecord), array(数组)

var AimSelGrid, AimSelCheckModel;

function onPgLoad() {
    rtntype = $.getQueryString({ ID: "rtntype", DefaultValue: "string" }).toLowerCase();
    seltype = $.getQueryString({ ID: "seltype", DefaultValue: "single" }).toLowerCase();

    var cm = null;
    if (seltype == 'multi') {
        AimSelCheckModel = new Ext.grid.MultiSelectionModel();
    } else {
        AimSelCheckModel = new Ext.grid.SingleSelectionModel();
    }

    onSelPgLoad();

    if (!AimSelGrid) {
        return;
    }

    // AimSelGrid.sm = AimSelGrid.sm || sm;

    if (AimSelGrid) {
        AimSelGrid.on("rowdblclick", function(grid, rowIndex, e) {
            var rec = grid.store.getAt(rowIndex);
            AimGridSelect([rec]);
        });
    }
}

function AimGridSelect(recs) {
    
    if (!AimSelGrid) {
        return;
    }

    if (!recs) {
        recs = AimSelGrid.getSelectionModel().getSelections();
    }

    if (seltype == "multi") {
        var vals = AimGridGetValues(recs, rtntype);
        Aim.PopUp.ReturnValue(vals);
    } else {
        if (recs && recs.length > 0) {
            Aim.PopUp.ReturnValue(recs[0].json);
        } else {
            Aim.PopUp.ReturnValue();
        }
    }
}

function AimGridGetValues(recs, type) {
    switch (type) {
        case "record":
            rtns = recs;
            break;
        case "array":
            rtns = AimGridGetValueArray(recs);
            break;
        case "json":
        case "string":
        default:
            rtns = AimGridGetValueString(recs);
            break;
    }

    return rtns;
}

function AimGridGetValueString(recs) {
    var strjson = {};

    if (recs && $.isArray(recs)) {
        $.each(recs, function() {
            for (var key in this.json) {
                if (!strjson[key]) {
                    strjson[key] = this.json[key]
                } else {
                    if (this.json[key]) {
                        strjson[key] += "," + this.json[key].toString();
                    }
                }
            }
        });
    }

    return strjson;
}

function AimGridGetValueArray(recs) {
    var arr = [];

    if (recs && $.isArray(recs)) {
        $.each(recs, function() {
            arr.push(this.json);
        });
    }

    return arr;
}

Ext.override(Ext.grid.CheckboxSelectionModel, {
    handleMouseDown: function(g, rowIndex, e) {
        if (e.button !== 0 || this.isLocked()) {
            return;
        }
        var view = this.grid.getView();
        if (e.shiftKey && !this.singleSelect && this.last !== false) {
            var last = this.last;
            this.selectRange(last, rowIndex, e.ctrlKey);
            this.last = last; // reset the last     
            view.focusRow(rowIndex);
        } else {
            var isSelected = this.isSelected(rowIndex);
            if (isSelected) {
                this.deselectRow(rowIndex);
            } else if (!isSelected || this.getCount() > 1) {
                this.selectRow(rowIndex, true);
                view.focusRow(rowIndex);
            }
        }
    }
});