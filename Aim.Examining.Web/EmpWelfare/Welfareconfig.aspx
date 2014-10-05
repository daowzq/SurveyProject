<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="Welfareconfig.aspx.cs" Inherits="Aim.Examining.Web.EmpWelfare.Welfareconfig" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>
    <script src="/js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>
    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "WelfareConfigEdit.aspx";

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
                //			{ name: 'Id' },
                //			{ name: 'CorpId' },
                //			{ name: 'CorpName' },
                //			{ name: 'DetpId' },
                //			{ name: 'DeptName' },

                //			{ name: 'TravelAddress' },
                //			{ name: 'TravelTimeSegment' },
                //			{ name: 'Ext1' },
                //			{ name: 'Ext2' },

                //			{ name: 'CreateId' },
                //			{ name: 'CreateName' },
                //			{ name: 'CreateTime' }
			{name: 'Id' },
			{ name: 'CorpId' },
			{ name: 'CorpName' },
			{ name: 'DetpId' },
			{ name: 'DeptName' },
			{ name: 'TravelName' },
			{ name: 'TravelAddress' },
			{ name: 'TravelTimeSegment' },
			{ name: 'TravelStartTime' },
			{ name: 'TravelEndTime' },
			{ name: 'WorkAge' },
			{ name: 'TravelCount' },
			{ name: 'NeedMoney' },
			{ name: 'Ext1' },
			{ name: 'Ext2' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
			{ name: 'ISEnable' },
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
                columns: 5,
                items: [
                { fieldLabel: '公司', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CorpName' }"} },
                 { fieldLabel: '部门', id: 'DeptName', schopts: { qryopts: "{ mode: 'Like', field: 'DeptName' }"} },
                  { fieldLabel: '旅游名称', id: 'TravelName', schopts: { qryopts: "{ mode: 'Like', field: 'TravelName' }"} },
				{ fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询', handler: function () {
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
                    handler: function () {
                        //$.ajaxExec("GetID", {}, function(rtn) {
                        //ID = rtn.data.thisid;
                        var EntRecord = grid.getStore().recordType;
                        var p = new EntRecord({});
                        grid.stopEditing();
                        var insRowIdx = store.data.length;
                        store.insert(insRowIdx, p);
                        //});

                    }
                }, {
                    text: '删除',
                    id: "btnDelete",
                    iconCls: 'aim-icon-delete',
                    handler: function () {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请先选择要删除的记录！");
                            return;
                        }
                        var ISEnable = false;
                        $.each(recs, function () {
                            if (this.get("ISEnable") == "Y") ISEnable = true;
                        });

                        if (ISEnable) {
                            AimDlg.show("启用状态的记录不能删除！");
                            return;
                        }
                        if (confirm("确定删除所选记录？")) {
                            for (var i = 0; i < recs.length; i++) {
                                if (recs[i] && (recs[i].get("Id") == null || recs[i].get("Id") == "")) {
                                    store.remove(recs[i]);
                                    store.commitChanges();
                                }
                            }
                            if (grid.getSelectionModel().getSelections().length > 0)
                                ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                        }
                    }
                }, {
                    text: '保存',
                    iconCls: 'aim-icon-save',
                    handler: function () {
                        // 保存修改的数据
                        var recs = store.getModifiedRecords();
                        if (recs && recs.length > 0) {
                            var dt = store.getModifiedDataStringArr(recs) || [];
                            jQuery.ajaxExec('batchsave', { "data": dt }, function () {
                                store.commitChanges();
                                store.reload();
                                AimDlg.show("保存成功！");
                            });
                        }
                    }
                },
                //                , {
                //                    text: '修改',
                //                    iconCls: 'aim-icon-edit',
                //                    handler: function() {
                //                        ExtOpenGridEditWin(grid, EditPageUrl, "u", EditWinStyle);
                //                    }
                //                }
               '-', {
                   text: '启用',
                   iconCls: 'aim-icon-run',
                   handler: function () {
                       var recs = grid.getSelectionModel().getSelections();
                       if (!recs || recs.length <= 0) {
                           AimDlg.show("请先选择要操作的记录！");
                           return;
                       }
                       var thisID = "";
                       if (confirm("确定启用所选记录？")) {
                           for (var i = 0; i < recs.length; i++) {
                               recs[i].set("ISEnable", "Y");
                               if (i != recs.length)
                                   thisID += "'" + recs[i].get("Id") + "'";
                               else thisID += "'" + recs[i].get("Id") + "',";
                               recs[i].commit();
                           }
                       }
                       $.ajaxExecSync("ISEnable", { Enable: "Y", ID: thisID }, function (rtn) {
                           store.reload();
                           AimDlg.show("操作成功!");
                       });
                   }
               }, {
                   text: '停用',
                   iconCls: 'aim-icon-stop',
                   handler: function () {
                       var recs = grid.getSelectionModel().getSelections();
                       if (!recs || recs.length <= 0) {
                           AimDlg.show("请先选择要操作的记录！");
                           return;
                       }
                       var thisID = "";
                       if (confirm("确定停用所选记录？")) {
                           for (var i = 0; i < recs.length; i++) {
                               recs[i].set("ISEnable", "N");
                               if (i != recs.length)
                                   thisID += "'" + recs[i].get("Id") + "'";
                               else thisID += "'" + recs[i].get("Id") + "',";
                           }
                       }

                       $.ajaxExecSync("ISEnable", { Enable: "N", ID: thisID }, function (rtn) {
                           store.reload();
                           AimDlg.show("操作成功!");

                       });

                   }
               }

 ]
            });


            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                tbar: tlBar,
                items: [schBar]
            });

            // 表格面板
            grid = new Ext.ux.grid.AimEditorGridPanel({
                broder: false,
                store: store,
                margins: '0 0 0 0',
                clicksToEdit: 1,
                viewConfig: { forceFit: true, scrollOffset: 10 },
                region: 'center',
                columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'CorpName', dataIndex: 'CorpName', header: '公司', width: 220,
					    editor: { xtype: 'aimdeptselector', seltype: 'single', popAfter: selGroup,
					        popUrl: '/CommonPages/Select/GrpSelect/MGrpSelect.aspx?rtntype=array&cid=2&seltype=single&tp=corp'
					    }, renderer: RowRender
					},
					{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 180, editor: { xtype: 'aimdeptselector', seltype: 'single', popAfter: selDept, listeners: {
					    'beforeshow': function (obj) {
					        var rec = store.getAt(grid.activeEditor.row);
					        obj.popUrl = "/CommonPages/Select/GrpSelect/MGrpSelect.aspx?rtntype=array&cid=2&seltype=single&CompanyId=" + rec.get("CorpId");
					    }
					}
					}
					},

					{ id: 'TravelName', dataIndex: 'TravelName', header: '旅游名称', width: 150, editor: { xtype: 'textfield', allowBlank: false} },
                    { id: 'NeedMoney', dataIndex: 'NeedMoney', header: '旅游费用(元/人)', width: 120, editor: { xtype: 'textfield', allowBlank: true, regex: /^[0-9]{1,5}$/, regexText: "请输入金额"} },
					{ id: 'TravelStartTime', dataIndex: 'TravelStartTime', header: '出行开始时间', width: 150, editor: { xtype: 'textfield', allowBlank: false, listeners: {
					    focus: function (obj) {
					        WdatePicker({
					            dateFmt: "yyyy/MM/dd",
					            onpicked: function () { grid.stopEditing(); }
					        });
					    }, blur: function (obj) {
					        return false;
					    }
					}
					}, sortable: true
					},


					{ id: 'TravelEndTime', dataIndex: 'TravelEndTime', header: '出行结束时间', width: 150, editor: { xtype: 'textfield', allowBlank: false, listeners: {
					    focus: function (obj) {
					        WdatePicker({
					            dateFmt: "yyyy/MM/dd",
					            onpicked: function () { grid.stopEditing(); }
					        });
					    }, blur: function (obj) {
					        return false;
					    }
					}
					}, sortable: true
					},
		        	{ id: 'WorkAge', dataIndex: 'WorkAge', header: '工龄', width: 80, editor: { xtype: 'numberfield', maxValue: 50} },
				    { id: 'TravelAddress', dataIndex: 'TravelAddress', header: '出行地点', width: 160, editor: { xtype: 'textfield', allowBlank: false} },
				    { id: 'TravelCount', dataIndex: 'TravelCount', header: '人数', width: 80, editor: { xtype: 'numberfield', maxValue: 1000, allowBlank: false} },
				    { id: 'ISEnable', dataIndex: 'ISEnable', header: '是否启用', width: 80, renderer: RowRender }
                    ],
                bbar: pgBar,
                tbar: titPanel
            });

            grid.on("afteredit", function (e) {
                var arr = [];
                if (e.record.data.TravelCount) {
                    if (!/^[0-9]*$/.test(e.record.data.TravelCount)) {
                        AimDlg.show("人数应为整数");
                        e.record.set("TravelCount", "");
                        return;
                    }
                }

                if (e.record.data.WorkAge) {
                    if (!/^[0-9]*$/.test(e.record.data.WorkAge)) {
                        AimDlg.show("工龄应为整数");
                        e.record.set("WorkAge", "");
                        return;
                    }
                }

                if (e.record.data.TravelStartTime)
                    Ext.util.Format.date(e.record.data.TravelStartTime)


                if (e.record.data.TravelEndTime)
                    Ext.util.Format.date(e.record.data.TravelEndTime)

                if (e.record.data.TravelStartTime && e.record.data.TravelEndTime) {
                    if (e.record.data.TravelStartTime.length != 0 && e.record.data.TravelEndTime.length != 0) {
                        var time = new Date(e.record.data.TravelEndTime).getTime() - new Date(e.record.data.TravelStartTime).getTime();
                        if (time <= 0) {
                            AimDlg.show("出行结束时间应大于出行开始时间");
                            e.record.set("TravelEndTime", "");
                            return;
                        }
                    }
                }

                arr.push(e.record);
                var strRec = store.getModifiedDataStringArr(arr);
                //                $.ajaxExec("SaveItem", { strRec: strRec }, function(rtn) {
                //                    e.record.commit();
                //                })

            });

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [grid]
            });
        }

        function recordValidate(e) {
            if (e.record.data.TravelCount) {
                if (!/^[0-9]*$/.test(e.record.data.TravelCount)) {
                    AimDlg.show("人数应为整数");
                    e.record.set("TravelCount", "");
                    return false;
                }
            }

            if (e.record.data.WorkAge) {
                if (!/^[0-9]*$/.test(e.record.data.WorkAge)) {
                    AimDlg.show("工龄应为整数");
                    e.record.set("WorkAge", "");
                    return false;
                }
            }

            if (e.record.data.TravelStartTime)
                Ext.util.Format.date(e.record.data.TravelStartTime)


            if (e.record.data.TravelEndTime)
                Ext.util.Format.date(e.record.data.TravelEndTime)

            if (e.record.data.TravelStartTime && e.record.data.TravelEndTime) {
                if (e.record.data.TravelStartTime.length != 0 && e.record.data.TravelEndTime.length != 0) {
                    var time = new Date(e.record.data.TravelEndTime).getTime() - new Date(e.record.data.TravelStartTime).getTime();
                    if (time <= 0) {
                        AimDlg.show("出行结束时间应大于出行开始时间");
                        //  e.record.set("TravelEndTime", "");
                        return false;
                    }
                }
            }
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
        }

        function Manager(rtn) {
            if (rtn && rtn.data && grid.activeEditor) {
                var rec = store.getAt(grid.activeEditor.row);
                if (rec) {
                    var data = rtn.data || [];
                    var UserName = "";
                    var UserId = "";
                    if (data) {
                        UserName = data.Name;
                        UserId = data.UserID;

                    }

                    rec.set("ManagerId", UserId);
                    rec.set("ManagerName", UserName);
                    grid.stopEditing(false);
                }
            }
        }

        function SManager(rtn) {
            if (rtn && rtn.data && grid.activeEditor) {
                var rec = store.getAt(grid.activeEditor.row);
                if (rec) {
                    var data = rtn.data || [];
                    var UserName = "";
                    var UserId = "";
                    if (data) {
                        UserName = data.Name;
                        UserId = data.UserID;

                    }

                    rec.set("SManagerId", UserId);
                    rec.set("SManagerName", UserName);
                    grid.stopEditing(false);
                }
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
            rec.set("CorpName", temp);
            rec.set("CorpId", tempid);
            grid.activeEditor.setValue(temp);
            grid.stopEditing();
        }

        function selDept(rtn) {
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

            rec.set("DeptName", temp);
            rec.set("DetpId", tempid);
            grid.activeEditor.setValue(temp);
            grid.stopEditing();
        }
        function HR(rtn) {
            if (rtn && rtn.data && grid.activeEditor) {
                var rec = store.getAt(grid.activeEditor.row);
                if (rec) {
                    var data = rtn.data || [];
                    var UserName = "";
                    var UserId = "";
                    if (data) {
                        UserName = data.Name;
                        UserId = data.UserID;
                    }

                    rec.set("HRUsrId", UserId);
                    rec.set("HRUserName", UserName);
                    grid.stopEditing(false);
                }
            }
        }

        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn;
            switch (this.id) {
                case "ISEnable":
                    rtn = (value == "N" || !!!value ? "停用" : "启用");
                    break;
                default:
                    rtn = value || "";
                    cellmeta.attr = 'ext:qtitle=""' + 'ext:qtip="' + value + '"';
                    break;
            }
            return rtn;
        }
    
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
