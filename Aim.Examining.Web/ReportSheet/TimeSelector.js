function initTimeSelector() {
    year_cb = new Ext.ux.form.AimComboBox({
        id: 'year_combo',
        enumdata: yearArr,
        lazyRender: false,
        allowBlank: false,
        style: {
            marginTop: '0px'
        },
        fieldLabel: '年份',
        margins: '0 0 0 5',
        width: 70,
        autoLoad: true,
        // schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'BeginDate' }" },
        //forceSelection: true,
        //blankText: "none",
        //valueField: 'text',
        value: year,
        triggerAction: 'all',
        mode: 'local',
        listeners: {
            collapse: function (obj) {
                if (Ext.getCmp("btn_Week").pressed == true) {
                    //---event
                    var selyear = obj.value; //Ext.getCmp("year_combo").getValue();
                    var selmonth = Ext.getCmp("month_combo").getValue();
                    //var selweek = Ext.getCmp("week_combo").getValue();                        
                    var week = showWeekDate(selyear, selmonth);
                    var weekArr = new Object;
                    weekArr.a1 = "第一周(" + week.week1.start + "-" + week.week1.end + ")";
                    weekArr.a2 = "第二周(" + week.week2.start + "-" + week.week2.end + ")";
                    weekArr.a3 = "第三周(" + week.week3.start + "-" + week.week3.end + ")";

                    if (week.hasOwnProperty("week4")) {
                        weekArr.a4 = "第四周(" + week.week4.start + "-" + week.week4.end + ")";
                    }
                    if (week.hasOwnProperty("week5")) {
                        weekArr.a5 = "第五周(" + week.week5.start + "-" + week.week5.end + ")";
                    }

                    //var newStore = new Ext.data.SimpleStore({ fields: ['text', 'value'] });
                    //newStore.loadData(adjustData(weekArr));
                    var weekField = Ext.getCmp("week_combo");
                    weekField.store.loadData(adjustData(weekArr));

                    //                        if (weekField.view)
                    //                            weekField.view.setStore(newStore);
                    Ext.getCmp("week_combo").setValue("a1");
                    //
                }
            }
        }
    });

    quarter_cb = new Ext.ux.form.AimComboBox({
        id: 'quarter_combo',
        enumdata: { 1: '第一季度', 2: '第二季度', 3: '第三季度', 4: '第四季度' },
        lazyRender: false,
        allowBlank: false,
        style: {
            marginTop: '0px'
        },
        fieldLabel: '季度',
        autoLoad: true,
        hidden: true,
        // schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'BeginDate' }" },
        //forceSelection: true,
        //blankText: "none",
        //valueField: 'text',
        value: 1,
        width: 100,
        triggerAction: 'all',
        mode: 'local'
    });
    month_cb = new Ext.ux.form.AimComboBox({
        id: 'month_combo',
        hideLabel: false,
        enumdata: { 1: '一月', 2: '二月', 3: '三月', 4: '四月', 5: '五月', 6: '六月', 7: '七月', 8: '八月', 9: '九月', 10: '十月', 11: '十一月', 12: '十二月' },
        lazyRender: false,
        fieldLabel: '月份',
        style: {
            marginTop: '0px'
        },
        allowBlank: false,
        autoLoad: true,
        hidden: true,
        width: 70,
        // schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'BeginDate' }" },
        //forceSelection: true,
        //blankText: "none",
        //valueField: 'text',
        value: new Date().getMonth() + 1,
        triggerAction: 'all',
        mode: 'local',
        listeners: {
            collapse: function (obj) {
                if (Ext.getCmp("btn_Week").pressed == true) {
                    //---event
                    var selyear = Ext.getCmp("year_combo").getValue();
                    var selmonth = obj.value;
                    //var selweek = Ext.getCmp("week_combo").getValue();                        
                    var week = showWeekDate(selyear, selmonth);
                    var weekArr = new Object;
                    weekArr.a1 = "第一周(" + week.week1.start + "-" + week.week1.end + ")";
                    weekArr.a2 = "第二周(" + week.week2.start + "-" + week.week2.end + ")";
                    weekArr.a3 = "第三周(" + week.week3.start + "-" + week.week3.end + ")";

                    if (week.hasOwnProperty("week4")) {
                        weekArr.a4 = "第四周(" + week.week4.start + "-" + week.week4.end + ")";
                    }
                    if (week.hasOwnProperty("week5")) {
                        weekArr.a5 = "第五周(" + week.week5.start + "-" + week.week5.end + ")";
                    }

                    //var newStore = new Ext.data.SimpleStore({ fields: ['text', 'value'] });
                    //newStore.loadData(adjustData(weekArr));
                    var weekField = Ext.getCmp("week_combo");
                    weekField.store.loadData(adjustData(weekArr));

                    //                        if (weekField.view)
                    //                            weekField.view.setStore(newStore);
                    Ext.getCmp("week_combo").setValue("a1");
                    //
                }
            }
        }
    });

    week_cb = new Ext.ux.form.AimComboBox({
        id: 'week_combo',
        enumdata: {},
        lazyRender: false,
        allowBlank: false,
        style: {
            marginTop: '0px'
        },
        fieldLabel: '周',
        width: 210,
        autoLoad: true,
        hidden: true,
        // schopts: { qryopts: "{ mode: 'GreaterThan', datatype:'Date', field: 'BeginDate' }" },
        //forceSelection: true,
        //blankText: "none",
        //valueField: 'text',
        value: 1,
        triggerAction: 'all',
        mode: 'local'
    });
}