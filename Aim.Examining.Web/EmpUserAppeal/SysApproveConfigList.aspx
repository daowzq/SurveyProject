<%@ Page Title="标题" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="SysApproveConfigList.aspx.cs" Inherits="Aim.Examining.Web.SysApproveConfigList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadHolder" runat="server">

    <script type="text/javascript">
        var EditWinStyle = CenterWin("width=650,height=600,scrollbars=yes");
        var EditPageUrl = "SysApproveConfigEdit.aspx";

        var store, myData;
        var pgBar, schBar, tlBar, titPanel, grid, viewport;

        function onPgLoad() {
            setPgUI();
        }

        function setPgUI() {

            // 表格数据
            myData = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["SysApproveConfigList"] || []
            };

            // 表格数据源
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'SysApproveConfigList',
                idProperty: 'Id',
                data: myData,
                fields: [
			{ name: 'Id' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },

			{ name: 'ManagerId' },
			{ name: 'ManagerName' },
			{ name: 'SManagerId' },
			{ name: 'SManagerName' },

			{ name: 'HRUsrId' },
			{ name: 'HRUserName' },
			{ name: 'HRManagerId' },
			{ name: 'HRManagerName' },
			{ name: 'CompanyLeaderId' },
			{ name: 'CompanyLeaderName' },
			{ name: 'HQHRUserId' },
			{ name: 'HQHRUserName' },

			{ name: 'HQHRMajorId' },
			{ name: 'HQHRMajorName' },

			{ name: 'HQHRManagerId' },
			{ name: 'HQHRManagerName' },
			{ name: 'CoupleWelfareId' },
			{ name: 'CoupleWelfareName' },
			{ name: 'ChildWelfareId' },
			{ name: 'ChildWelfareName' },
			{ name: 'TravelWelfareId' },
			{ name: 'TravelWelfareName' },
			{ name: 'HealthyWelfareId' },
			{ name: 'HealthyWelfareName' },
			{ name: 'WomanWelfareId' },
			{ name: 'WomanWelfareName' },
			{ name: 'CouponCost' },
			{ name: 'MarryCheckCost' },
			{ name: 'NoMarryCheckCost' },
			{ name: 'Ext1' },
			{ name: 'Ext2' },
			{ name: 'CreateId' },
			{ name: 'CreateName' },
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
                columns: 4,
                items: [
                { fieldLabel: '公司', id: 'CompanyName', schopts: { qryopts: "{ mode: 'Like', field: 'CompanyName' }"} },
                 { fieldLabel: '部门', id: 'DeptName', schopts: { qryopts: "{ mode: 'Like', field: 'DeptName' }"} },
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
                    handler: function() {
                        // 保存修改的数据
                        var recs = store.getModifiedRecords();
                        if (recs && recs.length > 0) {

                            $.each(recs, function(i) {
                                if (this.get("ManagerName") == "")
                                    this.set("ManagerId", "")
                                if (this.get("SManagerName") == "")
                                    this.set("SManagerId", "")

                                if (this.get("HRUserName") == "")
                                    this.set("HRUsrId", "")
                                if (this.get("HRManagerName") == "")
                                    this.set("HRManagerId", "")

                                if (this.get("CompanyLeaderName") == "")
                                    this.set("CompanyLeaderId", "")
                                if (this.get("HQHRUserName") == "")
                                    this.set("HQHRUserId", "")

                                if (this.get("CoupleWelfareName") == "")
                                    this.set("CoupleWelfareId", "")
                                if (this.get("ChildWelfareName") == "")
                                    this.set("ChildWelfareId", "")

                                if (this.get("TravelWelfareName") == "")
                                    this.set("TravelWelfareId", "")
                                if (this.get("HealthyWelfareName") == "")
                                    this.set("HealthyWelfareId", "")

                                if (this.get("WomanWelfareName") == "")
                                    this.set("WomanWelfareId", "")


                            });

                            //判断添加了重复的数据 公司,部门
                            for (var i = 0; i < recs.length; i++) {
                                var index = store.find("DeptId", recs[i].get("DeptId"));
                                if (index != -1) {
                                    AimDlg.show("已添加了重复的部门 " + recs[i].get("DeptName") + " !");
                                    return;
                                }
                            }

                            var dt = store.getModifiedDataStringArr(recs) || [];
                            jQuery.ajaxExec('batchsave', { "data": dt }, function() {
                                store.commitChanges();
                                store.reload();
                                AimDlg.show("保存成功！");
                            });
                        }
                    }
                }, '-', {
                    hidden: true,
                    text: '其他配置信息',
                    iconCls: 'aim-icon-tabs',
                    handler: function() {
                        var recs = grid.getSelectionModel().getSelections();
                        if (!recs || recs.length <= 0) {
                            AimDlg.show("请选择要配置的记录！");
                            return;
                        }

                        var sw = new Ext.Window({
                            title: '其他配置信息',
                            width: 350,
                            height: 350,
                            padding: '15 5 5 5',
                            autoScroll: true,
                            layout: 'form',
                            bodyStyle: 'overflow-y:auto;overflow-x:auto;',
                            items: [
                            { xtype: 'label',
                                fieldLabel: '说明',
                                text: '填写多项时请使用","分割,例"北京,上海"'
                            },
                            { xtype: 'textfield',
                                allowBlank: true,
                                fieldLabel: '旅游地点',
                                id: 'roadLine',
                                width: 210
                            },
                             { xtype: 'textarea',
                                 allowBlank: true,
                                 fieldLabel: '出行时间段',
                                 id: 'roadLine1',
                                 height: 100,
                                 width: 210,
                                 emptyText: '多个时间段,请使用","分割,如:\r\n4/5-4/9,\r\n4/10-4/12'
                             }

],
                            buttons: [{
                                text: '确认',
                                handler: function() {
                                    sw.close();
                                    Ext.getBody().mask("信息添加中,请稍等...");
                                    $.ajaxExec("AddExtInfo", { "UserId": Ext.getCmp('UserId').getValue(), "UserName": escape(Ext.getCmp('UserName').getValue()) }, function() {

                                        Ext.getBody().unmask();
                                    });
                                }
                            }, {
                                text: '取消',
                                handler: function() {
                                    sw.close();
                                }
}]
                            }).show();
                        }
                    }, {
                        text: '导出Excel',
                        iconCls: 'aim-icon-xls',
                        handler: function() {
                            ExtGridExportExcel(grid, { store: null, title: '标题' });
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
                        //autoExpandColumn: 'CompanyName',
                        // viewConfig: { forceFit: true, scrollOffset: 10 },
                        columns: [
                    { id: 'Id', dataIndex: 'Id', header: '标识', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
					{ id: 'CompanyName', dataIndex: 'CompanyName', header: '公司', width: 200, editor: { xtype: 'aimdeptselector', seltype: 'single', popAfter: selGroup }, renderer: RowRender },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '部门', width: 200, editor: { xtype: 'aimdeptselector', seltype: 'single', popAfter: selDept, listeners: {
					    'beforeshow': function(obj) {
					        var rec = store.getAt(grid.activeEditor.row);
					        obj.popUrl = "/CommonPages/Select/GrpSelect/MGrpSelect.aspx?rtntype=array&cid=2&seltype=single&CompanyId=" + rec.get("CompanyId");
					    }
					}
					}
					},
                        //{ id: 'ManagerName', dataIndex: 'ManagerName', header: '问卷审批人', width: 120, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: Manager, allowBlank: false} },
                        //{ id: 'SManagerName', dataIndex: 'SManagerName', header: '经理', width: 120, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: SManager, allowBlank: false} },

                    {id: 'HRUserName', dataIndex: 'HRUserName', header: 'HR专员', width: 120, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: HR, allowBlank: false} },
                    { id: 'HRManagerName', dataIndex: 'HRManagerName', header: 'HR经理', width: 120, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: HRmanageer, allowBlank: false} },

                    { id: 'HQHRUserName', dataIndex: 'HQHRUserName', header: '总部HR专员', width: 100, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: ZBHR, allowBlank: false} },
                    { id: 'HQHRManagerName', dataIndex: 'HQHRManagerName', header: '总部HR经理', width: 100, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: ZBHRMgr, allowBlank: false} },
                    { id: 'HQHRMajorName', dataIndex: 'HQHRMajorName', header: '总部HR总监', width: 100, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: HQHRMgr, allowBlank: false} },

                    { id: 'CompanyLeaderName', dataIndex: 'CompanyLeaderName', header: '一级组织负责人', width: 100, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: First, allowBlank: false} },
                        //{ id: 'CoupleWelfareName', dataIndex: 'CoupleWelfareName', header: '员工配偶审批人', width: 120, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: Double, allowBlank: false} },
                    {id: 'ChildWelfareName', dataIndex: 'ChildWelfareName', header: '员工保险审批人', width: 350, editor: { xtype: 'aimuser', seltype: 'multi', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: child, allowBlank: false} },
                    { id: 'TravelWelfareName', dataIndex: 'TravelWelfareName', header: '员工旅游审批人', width: 120, editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: Trvel, allowBlank: false} }
                        //{ id: 'HealthyWelfareName', dataIndex: 'HealthyWelfareName', header: '员工体检审批人', editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: Health, allowBlank: false} },
                        //{id: 'WomanWelfareName', dataIndex: 'WomanWelfareName', header: '妇女节福利审批人', editor: { xtype: 'aimuser', popStyle: 'dialogWidth:650px;dialogHeight:500px', popAfter: Women, allowBlank: false} },
                        //{ id: 'CouponCost', dataIndex: 'CouponCost', header: '购物券金额', width: 80, editor: { xtype: 'numberfield' }, sortable: true },
                        // { id: 'MarryCheckCost', dataIndex: 'MarryCheckCost', header: '已婚女子体检金额', editor: { xtype: 'numberfield' }, width: 110, sortable: true },
                        // { id: 'NoMarryCheckCost', dataIndex: 'NoMarryCheckCost', header: '未婚女子体检金额', width: 110, editor: { xtype: 'numberfield' }, sortable: true }
                    ],
                        bbar: pgBar,
                        tbar: titPanel
                    });

                    //  grid.on("cellclick", function(grid, rowIndex, columnIndex, e) {
                    //      var record = grid.getStore().getAt(rowIndex);  // Get the Record
                    //      var fieldName = grid.getColumnModel().getDataIndex(columnIndex); // Get field name
                    //      var data = record.get(fieldName);

                    //   });

                    // 页面视图
                    viewport = new Ext.ux.AimViewport({
                        items: [{ xtype: 'box', region: 'north', applyTo: 'header', height: 30 }, grid]
                    });
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
                    rec.set("CompanyName", temp);
                    rec.set("CompanyId", tempid);
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
                    rec.set("DeptId", tempid);
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



                function HRmanageer(rtn) {
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

                            //                        for (var i = 0; i < data.length; i++) {
                            //                            UserName += data[i].Name + ",";
                            //                            UserId += data[i].UserID + ",";
                            //                        }
                            //                        if (UserId.length > 0) {
                            //                            UserName = UserName.substring(0, UserName.length - 1);
                            //                            UserId = UserId.substring(0, UserId.length - 1);
                            //                        }

                            rec.set("HRManagerId", UserId);
                            rec.set("HRManagerName", UserName);
                            grid.stopEditing(false);
                        }
                    }
                }

                function First(rtn) {
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

                            rec.set("CompanyLeaderId", UserId);
                            rec.set("CompanyLeaderName", UserName);
                            grid.stopEditing(false);
                        }
                    }
                }


                function ZBHR(rtn) {
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


                            rec.set("HQHRUserId", UserId);
                            rec.set("HQHRUserName", UserName);
                            grid.stopEditing(false);
                        }
                    }
                }


                function ZBHRMgr(rtn) {
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
                            rec.set("HQHRManagerId", UserId);
                            rec.set("HQHRManagerName", UserName);
                            grid.stopEditing(false);
                        }
                    }
                }

                function HQHRMgr(rtn) {
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

                            rec.set("HQHRMajorId", UserId);
                            rec.set("HQHRMajorName", UserName);
                            grid.stopEditing(false);
                        }
                    }
                }

                function Double(rtn) {

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

                            //                        for (var i = 0; i < data.length; i++) {
                            //                            UserName += data[i].Name + ",";
                            //                            UserId += data[i].UserID + ",";
                            //                        }
                            //                        if (UserId.length > 0) {
                            //                            UserName = UserName.substring(0, UserName.length - 1);
                            //                            UserId = UserId.substring(0, UserId.length - 1);
                            //                        }

                            rec.set("CoupleWelfareId", UserId);
                            rec.set("CoupleWelfareName", UserName);
                            grid.stopEditing(false);
                        }
                    }



                }
                function child(rtn) {
                    if (rtn && rtn.data && grid.activeEditor) {
                        var rec = store.getAt(grid.activeEditor.row);
                        if (rec) {

                            var data = rtn.data || [];
                            var UserName = "";
                            var UserId = "";

                            $.each(data, function(i) {
                                if (i > 0) UserName += ",";
                                if (i > 0) UserId += ",";

                                UserName += this.Name;
                                UserId += this.UserID;
                            });

                            rec.set("ChildWelfareId", UserId);
                            rec.set("ChildWelfareName", UserName);
                            //grid.stopEditing(false);
                        }

                    }
                }

                function Trvel(rtn) {


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
                            rec.set("TravelWelfareId", UserId);
                            rec.set("TravelWelfareName", UserName);
                            grid.stopEditing(false);
                        }

                    }


                }


                function Health(rtn) {

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
                            rec.set("HealthyWelfareId", UserId);
                            rec.set("HealthyWelfareName", UserName);
                            grid.stopEditing(false);
                        }

                    }


                }


                function Women(rtn) {

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
                            rec.set("WomanWelfareId", UserId);
                            rec.set("WomanWelfareName", UserName);
                            grid.stopEditing(false);
                        }

                    }



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
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyHolder" runat="server">
    <div id="header" style="display: none;">
        <h1>
            标题</h1>
    </div>
</asp:Content>
