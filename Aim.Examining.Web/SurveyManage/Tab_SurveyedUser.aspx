<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.master" AutoEventWireup="true"
    CodeBehind="Tab_SurveyedUser.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Tab_SurveyedUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <script type="text/javascript">
        var store = "";
        var SurveyId = $.getQueryString({ ID: 'SurveyId' }) || '';
        var op = $.getQueryString({ ID: 'op' }) || '';
        var type = $.getQueryString({ ID: 'type' }) || ""; //iframesign
        function onPgLoad() {
            setPgUI();
            if (store.getRange().length > 0) {
                window.parent.HaveReview = true;  //表示生成人员
            }
        }
        function setPgUI() {
            myData1 = {
                total: AimSearchCrit["RecordCount"],
                records: AimState["DataList1"] || []
            };
            store = new Ext.ux.data.AimJsonStore({
                dsname: 'DataList1',
                idProperty: 'Id',
                data: myData1,
                fields: [
			{ name: 'Id' },
			{ name: 'SurveyId' },
			{ name: 'SurveyTile' },
			{ name: 'UserId' },
			{ name: 'UserName' },
			{ name: 'WorkNo' },
			{ name: 'CreateWay' },
			{ name: 'ExecTime' },
			{ name: 'CompanyId' },
			{ name: 'CompanyName' },
			{ name: 'DeptId' },
			{ name: 'DeptName' },

			{ name: 'Commited' },
			{ name: 'Phone' },
			{ name: 'Email' },
			{ name: 'EmailIsFilled' },
			{ name: 'MsgIsFilled' },
			{ name: 'CreateTime' }
			      ],
                listeners: {
                    aimbeforeload: function (proxy, options) {
                        options.data = options.data || {};
                        options.data.SurveyId = SurveyId;
                    }
                }
            });

            // 分页栏
            pgBar1 = new Ext.ux.AimPagingToolbar({
                pageSize: AimSearchCrit["PageSize"],
                store: store
            });
            // 搜索栏
            schBar1 = new Ext.ux.AimSchPanel({
                store: store,
                columns: '3',
                collapsed: false,
                items: [
                   { fieldLabel: '姓名', id: 'UserName', schopts: { qryopts: "{ mode: 'Like', field: 'A.UserName' }"} },
                   { fieldLabel: '工号', id: 'WorkNo', schopts: { qryopts: "{ mode: 'Like', field: 'A.WorkNo' }"} },
                   { fieldLabel: '按钮', xtype: 'button', iconCls: 'aim-icon-search', width: 60, margins: '2 30 0 0', text: '查 询',
                       handler: function () {
                           Ext.ux.AimDoSearch(
                           Ext.getCmp("UserName")
                           );
                       }
                   }
                ]
            });

            tlBar1 = new Ext.Toolbar({
                items: [
                {
                    hidden: (type == "iframesign") ? false : true,
                    id: 'creatUsr',
                    text: '<b>生成人员</b>',
                    iconCls: 'aim-icon-preview2',
                    handler: function () {

                        var operEle = window.parent.document.body;
                        if (!$("#OrgNames", operEle).val()) {
                            AimDlg.show("请填写组织机构!");
                            return;
                        };

                        var OrgIds = $("#OrgIds", operEle).val();    //组织机构
                        var OrgNames = $("#OrgNames", operEle).val(); //

                        var PostionIds = $("#PostionIds", operEle).val();
                        var PostionNames = $("#PostionNames", operEle).val();

                        var BornAddr = $("#BornAddr", operEle).val(); //籍贯
                        BornAddr = (BornAddr + "").indexOf("籍贯") > -1 ? "" : BornAddr;

                        var StartWorkTime = $("#StartWorkTime", operEle).val();
                        var UntileWorkTime = $("#UntileWorkTime", operEle).val();

                        var Sex = $(":radio[name='Sex']:checked", operEle).val(); //性别
                        var StartAge = $("#StartAge", operEle).val();        //年龄范围
                        var EndAge = $("#EndAge", operEle).val();
                        var WorkAge = $(":radio[name='WorkAge']:checked", operEle).val(); //资深员工

                        var Major = $("#Major", operEle).val(); //学历
                        //  $("[name='Major']:checked", operEle).each(function(i) {
                        //      if (i > 0 && $(this).val()) Major += ",";
                        //      Major += $(this).val();
                        //   });

                        //职位等级
                        var PositionDegree_E = $("#PositionDegree_E", operEle).val();
                        var PositionDegree_S = $("#PositionDegree_S", operEle).val();

                        var PersonType = "";   //人员类别
                        $("input[name='personType']:checked", operEle).each(function (i) {
                            if (i > 0 && $(this).val()) PersonType += ",";
                            PersonType += $(this).val();
                        });

                        //关键岗位
                        var CruxPositon = $("input[name='CruxPositon']:checked", operEle).val() || "";
                        //岗位序列
                        var PositionSeq = $("#PositionSeq", operEle).val();

                        Ext.getBody().mask("调查问卷人员生成中..."); //去除MASK
                        $.ajaxExec("SaveSurveyedObj", {
                            SurveyId: SurveyId,
                            OrgIds: OrgIds,
                            OrgNames: OrgNames,
                            PostionIds: PostionIds,
                            PostionNames: PostionNames,
                            BornAddr: BornAddr,
                            StartWorkTime: StartWorkTime,
                            UntileWorkTime: UntileWorkTime,
                            Sex: Sex,
                            PositionSeq: PositionSeq, //岗位序列
                            StartAge: StartAge,
                            EndAge: EndAge,
                            WorkAge: WorkAge,
                            Major: Major,
                            CruxPositon: CruxPositon,
                            PersonType: PersonType,
                            PositionDegree0: PositionDegree_S,
                            PositionDegree1: PositionDegree_E

                        }, function (rtn) {
                            if (rtn.data.State == "1") {
                                $.ajaxExec("CreateUser", { SurveyId: SurveyId }, function (rtn) {
                                    if (rtn.data.CreateState == "1") {
                                        store.reload();
                                        window.parent.HaveReview = true;  //表示生成人员,有人人员
                                        AimDlg.show("调查问卷人员生成成功!");
                                    } else if (rtn.data.CreateState == "0") {
                                        store.reload();
                                        window.parent.HaveReview = false; //表示无人员
                                        AimDlg.show("没有筛选的符合条件的人员!")
                                    } else {
                                        window.parent.HaveReview = false;
                                        AimDlg.show("调查问卷人员生成失败!");
                                    }
                                    Ext.getBody().unmask(); //去除MASK
                                }, null, "Comman.aspx");
                            }
                        }, null, "Comman.aspx");
                    }

                    //window.parent.HaveReview = true;  //表示生成人员

                }, {
                    hidden: (op == "r" || op == "v") ? true : false,
                    id: 'addBtn1',
                    text: '添加人员',
                    iconCls: 'aim-icon-add',
                    handler: function () {
                        openUsrWin(gridAccess);
                    }
                }, {
                    hidden: (op == "r" || op == "v") ? true : false,
                    text: '<font size=2em>导入人员</font>',
                    iconCls: 'aim-icon-trans',
                    handler: function () {
                        ImpUser("Surveyed", SurveyId, function () {
                            // store.reload();
                            window.parent.HaveReview = true;  //表示生成人员,有人人员
                            AimDlg.show("导入成功！");
                            store.reload();
                            window.location.reload();
                        });
                    }
                }, {
                    hidden: (type == "iframesign") ? false : true,
                    text: '<font size=2em>人员导入模板</font>',
                    iconCls: 'aim-icon-download',
                    handler: function () {
                        var url = "/CommonPages/File/DownLoad.aspx?FileName=SurveyUsrImp.xlsx";
                        $("body").append("<iframe style='display:none;' src=" + url + "></iframe>");
                    }
                }, '-', {
                    hidden: (type == "iframesign") ? false : true,
                    id: 'countBtn',
                    text: '问卷有效数量',
                    iconCls: 'aim-icon-cog',
                    handler: function () {

                        if (typeof window.parent.EffectiveCount == "function") {
                            $.ajaxExec("EffectiveCount", { SurveyId: SurveyId }, function (rtn) {
                                var valArr = (rtn.data.value + "").split("|");
                                window.parent.EffectiveCount(valArr[0] || 0, valArr[1]);
                            })

                        }
                    }
                },
               {
                   hidden: (op == "r" || op == "v") ? true : false,
                   id: 'delBtn1',
                   text: '移除人员',
                   iconCls: 'aim-icon-delete',
                   handler: function () {
                       var recs = gridAccess.getSelectionModel().getSelections();
                       if (!recs || recs.length <= 0) {
                           AimDlg.show("请先选择要删除的记录！");
                           return;
                       }
                       if (confirm("确定删除所选记录？")) {
                           ExtBatchOperate('batchdelete', recs, null, null, onExecuted);
                           //                           var task = new Ext.util.DelayedTask();
                           //                           task.delay(200, function() {
                           //                               if (store.getRange().length == 0) {
                           //                                   window.parent.HaveReview = false;  //表示生成人员,有人人员
                           //                               }
                           //                           });

                       }
                   }
               },
                {
                    // hidden: (type == "iframesign") ? true : false,
                    text: '<font size=2em>导出人员</font>',
                    iconCls: 'aim-icon-xls',
                    handler: function () {
                        ExtGridExportExcel(gridAccess, { store: null, title: '问卷人员' });
                    }
                },
              '->',
                 {
                     hidden: (op == "r" || op == "v" || type == "iframesign") ? true : false,
                     text: '收起',
                     iconCls: 'aim-icon-arrow-down',
                     handler: function () {
                         schBar1.toggleCollapse(false);
                         if (this.getText() == "收起") {
                             this.setText("展开");
                             this.setIconClass("aim-icon-arrow-up")
                         }
                         else {
                             this.setText("收起");
                             this.setIconClass("aim-icon-arrow-down")
                         }
                     }
                 }
]
            });


            // 工具标题栏
            titPanel = new Ext.ux.AimPanel({
                // renderTo: 'addUsrTool',
                tbar: tlBar1,
                items: [schBar1]
            });
            var columns = [
                    { id: 'Id', dataIndex: 'Id', header: 'Id', hidden: true },
                    { id: 'UserId', dataIndex: 'UserId', header: 'UserId', hidden: true },
                    new Ext.ux.grid.AimRowNumberer(),
                    new Ext.ux.grid.AimCheckboxSelectionModel(),
                    { id: 'UserName', dataIndex: 'UserName', header: '姓名', width: 90, sortable: true },
                    { id: 'WorkNo', dataIndex: 'WorkNo', header: '工号', width: 100 },
                    { id: 'Email', dataIndex: 'Email', header: '邮箱', width: 150 },
                    { id: 'Phone', dataIndex: 'Phone', header: '手机', width: 100 },
                    { id: 'EmailIsFilled', dataIndex: 'EmailIsFilled', header: '发送状态(邮件)', width: 90 },
                    { id: 'MsgIsFilled', dataIndex: 'MsgIsFilled', header: '发送状态(短信)', width: 90 },
					{ id: 'DeptName', dataIndex: 'DeptName', header: '组织名称', width: 200, sortable: true }
            //{ id: 'CreateWay', dataIndex: 'CreateWay', header: '创建标识', width: 80, sortable: true, renderer: RowRender }
                    ];

            if (type == "add") {
                var cmObj1 = { id: 'Commited', dataIndex: 'Commited', header: '提交状态', width: 80, sortable: true, renderer: RowRender }
                var cmObj = { id: 'Edit', dataIndex: 'Edit', header: '补填', width: 80, sortable: true, renderer: RowRender }
                columns.push(cmObj1);
                columns.push(cmObj);
            }

            // 表格面板
            gridAccess = new Ext.ux.grid.AimGridPanel({
                region: 'center',
                store: store,
                height: 300,
                //renderTo: 'addUsrDiv',
                tbar: titPanel,
                bbar: pgBar1,
                //viewConfig: { forceFit: true, scrollOffset: 10 },
                autoExpandColumn: 'DeptName',
                columns: columns
            });
            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [gridAccess]
            });
        }

        // 提交数据成功后
        function onExecuted() {
            store.reload();
            var task = new Ext.util.DelayedTask();
            task.delay(200, function () {
                if (store.getRange().length == 0) {
                    window.parent.HaveReview = false;  //表示生成人员,有人人员
                }
            });
        }

        //人员选择
        function openUsrWin(gridSg) {
            var style = "dialogWidth:720px; dialogHeight:430px; scroll:yes; center:yes; status:no; resizable:yes;";
            var url = "/CommonPages/FrmNeedUserSelect.aspx?seltype=multi&rtntype=array";
            // var url = "/CommonPages/Select/UsrSelect/MUsrSelect.aspx?seltype=multi&rtntype=array";

            OpenModelWin(url, {}, style, function () {
                if (this.data == null || this.data.length == 0 || !this.data.length) return;
                window.parent.HaveReview = true;  //表示生成人员,有人人员
                // var gird = Ext.getCmp(gridSg);
                var gird = gridSg
                var EntRecord = gird.getStore().recordType;

                for (var i = 0; i < this.data.length; i++) {
                    if (gird.store.find("UserId", this.data[i]["UserID"]) != -1) continue;

                    var UserId = this.data[i]["UserID"];
                    var UserName = this.data[i]["Name"];

                    $.ajaxExecSync("GetOrgs", { UserId: UserId }, function (rtn) {
                        var OrgName = rtn.data.OrgName.split('|');
                        var rec = new EntRecord({
                            UserId: UserId,
                            WorkNo: OrgName[0],
                            UserName: UserName,
                            DeptName: OrgName[1] || "",
                            Email: OrgName[2] || "",
                            Phone: OrgName[3] || ""
                        });
                        gird.getStore().insert(gird.getStore().data.length, rec);
                    }, null, "Comman.aspx");
                    // var lastRec = gird.getStore().getAt(store.data.length - 1)
                    //  lastRec = gird.getStore().getModifiedDataStringArr(lastRec);
                }

                var recs = gridAccess.getStore().getRange();
                recs = gridAccess.getStore().getModifiedDataStringArr(recs);

                $.ajaxExec("Save", { Record: recs, SurveyId: SurveyId }, function (rtn) {
                    if ($(".x-grid3-body").innerHeight() > $(".x-grid3-scroller").innerHeight()) {
                        var top = $(".x-grid3-body").innerHeight() - $(".x-grid3-scroller").innerHeight();
                        $(".x-grid3-scroller").scrollTop(top);
                    }
                });
            })
        }

        //导入人员
        function ImpUser(surObj, surveyId, doSuccess) {

            var mode = 'single' //当个文件上传
            var UploadStyle = "dialogHeight:405px; dialogWidth:465px; help:0; resizable:0; status:0;scroll=0;";
            var uploadurl = '/CommonPages/File/Upload.aspx?IsSingle=true&Filter=(*.xls;*.xlsx)|*.xls;*.xlsx';
            var rtn = window.showModalDialog(uploadurl, window, UploadStyle);

            Ext.getBody().mask("人员导入中，请稍后！");
            rtn && $.ajaxExec("ImpUser", { FileId: rtn, SurveyId: surveyId, Sign: surObj }, function (rtn) {
                Ext.getBody().unmask();
                if (rtn.data.State == "1") {
                    doSuccess();
                    window.parent.HaveReview = true;  //表示生成人员,有人人员
                }
                else {
                    AimDlg.show("导入异常！");
                }
            }, null, "Comman.aspx");
            !rtn && Ext.getBody().unmask();
        }


        function RowRender(value, cellmeta, record, rowIndex, columnIndex, store) {
            var rtn = "";
            switch (this.id) {
                case "CreateWay":
                    rtn = value == "0" ? "导入" : "创建";
                    break;
                case "Commited":
                    rtn = value == "Y" ? '已提交' : "未提交";
                    break;
                case "Edit":
                    if (record.get("Commited") == "N") {
                        var str = "<span style='color:blue; cursor:pointer; text-decoration:underline;' onclick='statitcsWin(\"" + record.get("UserId") + "\",\"" + record.get("UserName") + "\",\"" + record.get("WorkNo") + "\")'>" + "&nbsp;&nbsp;补填&nbsp;&nbsp;" + "</span>";
                    }
                    rtn = str;
                    break;
            }
            return rtn;
        }

        //查看统计
        function statitcsWin(uid, userName, workNo) {
            var task = new Ext.util.DelayedTask();
            var userName = escape(userName);
            task.delay(100, function () {
                var url = "/SurveyManage/InternetSurvey.aspx?Id=" + SurveyId + "&op=r&type=add&uid=" + uid + "&uname=" + userName + "&workno=" + workNo;
                opencenterwin(url, "", 1000, 700);
            });
        }

        function opencenterwin(url, name, iWidth, iHeight) {
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            window.open(url, name, 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=yes,resizable=yes');
        }
        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>
