/*
* pgfunc对ext ux的扩展
*/

//------------------------Aim ExtJs ux数据组件扩展 开始------------------------//

Ext.ux.data.AimAdjacencyListStore = Ext.extend(Ext.ux.maximgb.tg.AdjacencyListStore, {
    constructor: function(config) {
        config["parent_id_field_name"] = config["parent_id_field_name"] || "ParentID";
        config["leaf_field_name"] = config["leaf_field_name"] || "IsLeaf";
        config["autoLoad"] = !(config["autoLoad"] == false);    // 默认为true

        config["reader"] = config["reader"] || new Ext.ux.data.AimJsonReader(config);
        config["proxy"] = config["proxy"] || new Ext.ux.data.AimRemotingProxy(config);
        var singleSelect = config["singleSelect"] || false;
        config["sm"] = config["sm"] || new Ext.grid.RowSelectionModel({ singleSelect: singleSelect });

        Ext.ux.data.AimAdjacencyListStore.superclass.constructor.call(this, Ext.apply(config, {
    }));
},

isTopNode: function(rec) {
    return !this.getNodeParent(rec);
},

reload: function(args) {
    AimReloadStore(this, Ext.ux.maximgb.tg.AdjacencyListStore, args);
}

});

Ext.reg('aimadjacencyliststore', Ext.ux.data.AimAdjacencyListStore);

//------------------------Aim ExtJs ux数据组件扩展 开始------------------------//

//------------------------Aim ExtJs TreeGridPanel 开始------------------------//

Ext.ux.grid.AimTreeGridPanel = Ext.extend(Ext.ux.maximgb.tg.GridPanel, {
    constructor: function(config) {
        var singleSelect = config["singleSelect"] || false;
        config["sm"] = config["sm"] || new Ext.grid.RowSelectionModel({ singleSelect: singleSelect });

        Ext.ux.grid.AimTreeGridPanel.superclass.constructor.call(this, Ext.apply(config, {
    }));
},

expandLevel: 0,

expandAllNext: function(level, node) {
    var grid = this;
    this.expandLevel = level || 1;

    // 展开下一层
    var store = this.store;

    store.un("expandnode", this.expandNodeNext, this);
    store.on("expandnode", this.expandNodeNext, this);

    var expandNodes = [];
    if (node) {
        expandNodes = store.getNodeChildren(node);

        $.each(expandNodes, function() {
            store.expandNode(this);
        })
    } else {
        store.expandAll();
    }

    // store.un("expandnode", this.expandNodeNext, this);
},

expandNodeNext: function(store, node) {
    if (store && node) {
        var store = this.store;
        var depth = store.getNodeDepth(node);

        if (this.expandLevel && depth < this.expandLevel) {
            expandNodes = store.getNodeChildren(node);

            $.each(expandNodes, function() {
                store.expandNode(this);
            });
        } else {
            var nextsiblings = store.getNodeNextSibling(node);
            var unbindflag = true;  // 接触绑定标识
            if (nextsiblings && $.isArray(nextsiblings)) {
                // 后继兄弟节点全为叶节点
                $.each(nextsiblings, function() {
                    if (!store.isLeafNode(this)) {
                        unbindflag = false;
                        return;   // 跳出循环
                    }
                })
            }

            if (unbindflag) {
                // 解除绑定
                store.un("expandnode", this.expandNodeNext, this);
            }
        }
    }
},

expandLoaded: function() {
    var grid = this;
    var v = grid.getView();

    $.ensureExec(function() {
        // 确保第一行已渲染
        if (v.getRow(0)) {
            grid.expandLoadedNode();
            return true;
        }

        return false;
    });
},

expandLoadedNode: function(node) {
    // 展开所有已加载的节点(私有方法)
    var store = this.store;
    var grid = this;
    var expandNodes = [];
    if (node) {
        expandNodes = store.getNodeChildren(node);

        $.each(expandNodes, function() {
            if (store.isLoadedNode(this)) {
                grid.expandLoadedNode(this);
            }
        })
    } else {
        var r, i, len, records = store.data.getRange();
        this.suspendEvents();
        for (i = 0, len = records.length; i < len; i++) {
            r = records[i];
            if (!store.isExpandedNode(r) && store.isLoadedNode(r)) {
                store.expandNode(r);
            }
        }

        this.resumeEvents();
        this.fireEvent('datachanged', this);
    }
}
});

Ext.reg('aimtreegridpanel', Ext.ux.grid.AimTreeGridPanel);

//------------------------Aim ExtJs TreeGridPanel 结束------------------------//

//------------------------Aim ExtJs TreeGridPanel 开始------------------------//

Ext.ux.grid.AimEditorTreeGridPanel = Ext.extend(Ext.ux.maximgb.tg.EditorGridPanel, {
    constructor: function(config) {
        var singleSelect = config["singleSelect"] || false;
        config["sm"] = config["sm"] || new Ext.grid.RowSelectionModel({ singleSelect: singleSelect });

        Ext.ux.grid.AimEditorTreeGridPanel.superclass.constructor.call(this, Ext.apply(config, {
    }));
},

expandLevel: 0,

expandAllNext: function(level, node) {
    var grid = this;
    this.expandLevel = level || 1;

    // 展开下一层
    var store = this.store;

    store.un("expandnode", this.expandNodeNext, this);
    store.on("expandnode", this.expandNodeNext, this);

    var expandNodes = [];
    if (node) {
        expandNodes = store.getNodeChildren(node);

        $.each(expandNodes, function() {
            store.expandNode(this);
        })
    } else {
        store.expandAll();
    }

    // store.un("expandnode", this.expandNodeNext, this);
},

expandNodeNext: function(store, node) {
    if (store && node) {
        var store = this.store;
        var depth = store.getNodeDepth(node);

        if (this.expandLevel && depth < this.expandLevel) {
            expandNodes = store.getNodeChildren(node);

            $.each(expandNodes, function() {
                store.expandNode(this);
            });
        } else {
            var nextsiblings = store.getNodeNextSibling(node);
            var unbindflag = true;  // 接触绑定标识
            if (nextsiblings && $.isArray(nextsiblings)) {
                // 后继兄弟节点全为叶节点
                $.each(nextsiblings, function() {
                    if (!store.isLeafNode(this)) {
                        unbindflag = false;
                        return;   // 跳出循环
                    }
                })
            }

            if (unbindflag) {
                // 解除绑定
                store.un("expandnode", this.expandNodeNext, this);
            }
        }
    }
},

expandLoaded: function() {
    var grid = this;
    var v = grid.getView();

    $.ensureExec(function() {
        // 确保第一行已渲染
        if (v.getRow(0)) {
            grid.expandLoadedNode();
            return true;
        }

        return false;
    });
},

expandLoadedNode: function(node) {
    // 展开所有已加载的节点(私有方法)
    var store = this.store;
    var grid = this;
    var expandNodes = [];
    if (node) {
        expandNodes = store.getNodeChildren(node);

        $.each(expandNodes, function() {
            if (store.isLoadedNode(this)) {
                grid.expandLoadedNode(this);
            }
        })
    } else {
        var r, i, len, records = store.data.getRange();
        this.suspendEvents();
        for (i = 0, len = records.length; i < len; i++) {
            r = records[i];
            if (!store.isExpandedNode(r) && store.isLoadedNode(r)) {
                store.expandNode(r);
            }
        }

        this.resumeEvents();
        this.fireEvent('datachanged', this);
    }
}
});

Ext.reg('aimeditortreegridpanel', Ext.ux.grid.AimEditorTreeGridPanel);

Ext.ux.grid.AimEditorTreeGridPanelEx = Ext.extend(Ext.ux.grid.AimEditorTreeGridPanel, {
    clipBoard: { records: [] },   // 剪切板
    contextRow: null,     // 右键鼠标所在行
    rowContextMenu: null,    // 右键菜单

    constructor: function(config) {
        var grid = this;
        config = config || {};
        
        var singleSelect = config["singleSelect"] || false;
        config["sm"] = config["sm"] || new Ext.grid.RowSelectionModel({ singleSelect: singleSelect });

        Ext.ux.grid.AimEditorTreeGridPanelEx.superclass.constructor.call(this, Ext.apply(config, {}));

        this.addEvents('copy', 'cut', 'paste');
    },

    getSelections: function() {
        var sm = this.getSelectionModel();
        return sm.getSelections() || [];
    },

    getFirstSelection: function() {
        var selrecs = this.getSelections();

        if (!selrecs || selrecs.length <= 0) {
            return null;
        } else {
            return selrecs[0];
        }
    },

    hasSelection: function() {
        var sm = this.getSelectionModel();
        return sm.hasSelection();
    },

    getIdStringList: function(recs) {
        var dt = [];
        recs = recs || getSelections();

        $.each(recs, function() {
            dt.push(this.id);
        });

        return dt;
    },

    reload: function(args) {
        this.store.reload(args);
    },

    clearNodes: function(recs) {
        // 清空所有节点
        var store = this.store;
        recs = recs || store.getRange();

        $.each(recs, function() {
            if (store.getById(this.id)) {
                store.remove(this);
            }
        });
    },

    copy: function(recs) {
        // 复制
        var grid = this;
        grid.fireEvent('copy', this, recs);

        recs = recs || grid.getSelections();
        grid.clearClipBoard();

        if (recs) {
            grid.clipBoard.type = 'copy';
            grid.clipBoard.records = (recs || getSelections());
            var v = grid.getView();

            $.each(recs, function() {
                var rowIdx = grid.store.indexOf(this);
                v.addRowClass(rowIdx, 'x-grid3-row-copy');
            })
        }
    },

    cut: function(recs) {
        // 剪切
        var grid = this;
        grid.fireEvent('cut', this, recs);
        recs = recs || this.getSelections();
        grid.clearClipBoard();

        if (recs) {
            grid.clipBoard.type = 'cut';
            grid.clipBoard.records = recs;
            var v = grid.getView();

            $.each(recs, function() {
                var rowIdx = grid.store.indexOf(this);
                v.addRowClass(rowIdx, 'x-grid3-row-cut');
            })
        }
    },

    paste: function(type, rec) {
        // 粘贴
        type = type || 'sib';   // 默认粘贴为兄弟节点(选中节点之下)
        rec = rec || this.getFirstSelection();
        var grid = this;

        var store = this.store;
        if (!rec || !this.clipBoard.records || this.clipBoard.records.length <= 0) {
            return;
        }

        grid.fireEvent('paste', this, type, rec, this.clipBoard);

        // 清空剪切板
        grid.clearClipBoard();
    },

    clearClipBoard: function() {
        var grid = this;
        var v = grid.getView();
        var recs = grid.clipBoard.records;

        if (recs && recs.length > 0) {
            $.each(recs, function() {
                var rowIdx = grid.store.indexOf(this);
                v.removeRowClass(rowIdx, 'x-grid3-row-copy');
                v.removeRowClass(rowIdx, 'x-grid3-row-cut');
            });

            this.clipBoard.type = null;
            this.clipBoard.records = [];
        }
    },

    selectRow: function(rowIdx) {
        // 选中某一行
        this.getSelectionModel().selectRow(rowIdx, false);
    },

    onRowSelect: function(sm, ridx, e) {
        var rec = this.store.getAt(ridx);

        this.saveRow();

        this.fireEvent('rowactivate', this, rec);
    }
});

Ext.reg('aimeditortreegridpanelex', Ext.ux.grid.AimEditorTreeGridPanelEx);

//------------------------Aim ExtJs TreeGridPanel 结束------------------------//

