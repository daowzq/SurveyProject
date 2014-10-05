function showWeekDate(year, month) {
    var date = new Date();
    try {
        date = new Date(year, month - 1, 1);
    }
    catch (ex) {
        date = new Date(date.getFullYear(), date.getMonth(), 1);
    }
    //    if (year.length > 0 && month.length > 0) {
    //        date = new Date(year, month - 1, 1);
    //    } else {
    //        date = new Date(date.getFullYear(), date.getMonth(), 1);
    //    }

    var week = new Object;
    week.week1 = new Object;
    week.week2 = new Object;
    week.week3 = new Object;
    week.week4 = new Object;
    //

    //本月第一天是周几 
    week.today = date.getDay();
    if (week.today == 0) {//本月第一天是星期天则本月第一周第一天为本月的第二天
        date.setDate(date.getDate() + 1);
        week.today = date.getDay();
    }
    else if (week.today == 1) {
        date.setDate(date.getDate()); //本月第一天是星期一,则本月第一周第一天为本月第一天
    }
    else {
        date.setDate(date.getDate() + (8 - week.today));
    }

    //本月第一周工作日
    //week.week1.workDays = 5 - week.today + 1;
    week.week1.workDays = 5;
    //if (week.week1.workDays < 0) week.week1.workDays = 0;
    //本月第一周起始日期
    week.week1.start = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
    //本月第一周结束日期
    date.setDate(date.getDate() + (1 + week.week1.workDays));
    week.week1.end = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();


    //本月第二周起始日期
    date.setDate(date.getDate() + 1);
    week.week2.workDays = 5;
    week.week2.start = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
    //本月第二周结束日期
    date.setDate(date.getDate() + (1 + week.week2.workDays));
    week.week2.end = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();


    //本月第三周起始日期
    date.setDate(date.getDate() + 1);
    week.week3.workDays = 5;
    week.week3.start = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
    //本月第三周结束日期
    date.setDate(date.getDate() + (1 + week.week3.workDays));
    week.week3.end = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();

    //            //本月第四周起始日期
    //            date.setDate(date.getDate() + 1);
    //            week.week4.workDays = 5;
    //            week.week4.start = date.getDate() + "/" + (date.getMonth() + 1);
    //            //本月第四周结束日期
    //            date.setDate(date.getDate() + (1 + week.week4.workDays));
    //            week.week4.end = date.getDate() + "/" + (date.getMonth() + 1);



    //------------------
    //计算月底日期 
    var nextMonth = new Date(date.getFullYear(), date.getMonth() + 1, 1);
    var monthLastDay = new Date(nextMonth - 86400000);

    if (date <= monthLastDay) {
        week.week4 = new Object;

        date.setDate(date.getDate() + 1);
        week.week4.start = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();

        date.setDate(date.getDate() + 6);
        if (date <= monthLastDay) {
            week.week4.workDays = 4;
            week.week4.end = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
            if (date < monthLastDay) {
                //week.week5 = new Object;有五周的月末和下月月初衔接
                //date.setDate(date.getDate() + 1);
                //week.week5.start = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
                //week.week5.end = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + monthLastDay.getDate();
                //week.week5.workDays = 5;
                week.week5 = new Object
                week.week5.workDays = 5;
                date.setDate(date.getDate() + 1);
                //if (week.week1.workDays < 0) week.week1.workDays = 0;
                //本月第一周起始日期
                week.week5.start = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
                //本月第一周结束日期
                date.setDate(date.getDate() + (1 + week.week5.workDays));
                week.week5.end = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
                
            }
        } else {
            week.week4.end = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
            week.week4.workDays = monthLastDay.getDay();
            if (week.week4.workDays > 4) week.week4.workDays = 5;
        }
        return week;
    } else {

    }
}