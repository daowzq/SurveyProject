<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="ManagerDetail.aspx.cs" Inherits="Aim.Examining.Web.CommonPages.ManagerDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var PId = $.getQueryString({ ID: 'PId' }) || "";
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
			{ name: 'PId' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
		    { name: 'UserIds' },
			{ name: 'UserNames' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'CreateTime' }
			],
                aimbeforeload: function(proxy, options) {
                    options.data = options.data || {};
                    options.data.PId = PId;
                }
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
                columns: 3,
                items: [
                { fieldLabel: '公司', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CompanyName' }"} },

				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function() {
				    Ext.ux.AimDoSearch(Ext.getCmp("DeptName"));   //Number 为任意
				}
				}
                ]
            });


            // 工具栏
            tlBar = new Ext.ux.AimToolbar({
                items: [{
                    text: '添加',
                    id: 'btnAdd',
                    iconCls: 'aim-icon-add',
                    handler: function() {
                        var EntRecord = grid.getStore().recordType;
                        var p = new EntRecord({ "Month": 1 });
                        grid.stopEditing();
                        var insRowIdx = store.data.length;
                        store.insert(insRowIdx, p);
                    }
                }, {
                    text: '保存',
                    iconCls: 'aim-icon-save',
                    handler: function() {
                        // 保存修改的数据
                        var recs = store.getModifiedRecords();
                        if (recs && recs.length > 0) {
                            $.each(recs, function() {
                                this.set("PId", PId)
                            });
                            var dt = store.getModifiedDataStringArr(recs) || [];
                            jQuery.ajaxExec('BatchSave', { "data": dt }, function() {
                                store.reload();
                                AimDlg.show("保存成功！");
                            });
                        }
                    }
                }, {
                    text: '删除',
                    id: "btnDelete",
                    iconCls: 'aim-icon-delete',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }

                        if (confirm("确定删除所选记录？")) {
                            ExtBatchOperate('BachDelete', recs, null, null, onExecuted);
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
                    clicksToEdit: 1,
                    region: 'center',
                    autoExpandColumn: 'UserNames',
                    columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'CompanyName', dataIndex: 'CompanyName', header: '公司', width: 200, editor: { xtype: 'aimdeptselector', seltype: 'single', popAfter: selGroup }, renderer: RowRender },
					{ id: 'UserNames', dataIndex: 'UserNames', header: '职位', width: 120,
					    editor: {
					        xtype: 'aimpopup',
					        popUrl: '/CommonPages/GWSelect.aspx?seltype=multi',
					        popStyle: 'dialogWidth:680px;dialogHeight:500px',
					        allowBlank: false,
					        listeners: {
					            'beforeshow': function(obj) {
					                var rec = store.getAt(grid.activeEditor.row);
					                obj.popUrl = "/CommonPages/GWSelect.aspx?seltype=multi&CorpId=" + rec.get("CompanyId");
					            }
					        },
					        popAfter: afterSlt

					    }
					}
                    ],
                    bbar: pgBar,
                    tbar: titPanel
                    //,
                    //                    listeners: {
                    //                        afteredit: function(e) {
                    //                            if (e.record.get("CompanyName")) {
                    //                                var arr = [];
                    //                                arr.push(e.record);
                    //                                var strRec = store.getModifiedDataStringArr(arr);
                    //                                $.ajaxExec("DoSave", { PId: PId, dt: strRec }, function(rtn) {
                    //                                    if (!e.record.get("Id")) e.record.set("Id", rtn.data.Id);
                    //                                    e.record.commit();
                    //                                })
                    //                            }
                    //                        }
                    //                    }
                });


                // 页面视图
                viewport = new Ext.ux.AimViewport({
                    items: [grid]
                });
            }


            // 提交数据成功后
            function onExecuted() {
                store.reload();
            }

            //选中后获取
            function afterSlt(rtn) {
                var rec = store.getAt(grid.activeEditor.row);

                if (rec && !$.isEmptyObject(rtn.data)) {
                    var Names = rtn.data.XL;
                    // var UserIds = rtn.data.UserID;
                    this.setValue(Names);
                    //rec.set("UserIds", UserIds);
                    rec.set("UserNames", Names);
                    grid.stopEditing();
                }
            }

            function selGroup(rtn) {

                if (!rtn || !rtn.data)
                    return;
                var rec = store.getAt(grid.activeEditor.row);
                var data = rtn.data || [];
                var temp = "";
                var tempid = "";

                if (data.length) {

                    for (var i = 0; i < data.length; i++) {
                        temp += data[i].Name + ",";
                        tempid += data[i].GroupID + ",";
                    }
                    if (temp.length > 0) {
                        temp = temp.substring(0, temp.length - 1);
                        tempid = tempid.substring(0, tempid.length - 1);
                    }
                }
                else {
                    temp = data.Name;
                    tempid = data.GroupID;
                }
                rec.set("CompanyName", temp);
                rec.set("CompanyId", tempid);
                grid.activeEditor.setValue(temp);
                grid.stopEditing();
            }


            function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
                var rtn;
                switch (this.id) {
                    default:
                        value = value || "";
                        cellmeta.attr = 'ext:qtitle=""' + 'ext:qtip="' + value + '"';
                        return value;
                        break;
                }
                return rtn;
            }
    
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
