
//添加问题
function addQuestion(store) {
    var recType = store.recordType;
    var sortIndex = 0;
    $.each(store.getRange(), function() {
        sortIndex = parseInt(this.get("SortIndex")) > sortIndex ? parseInt(this.get("SortIndex")) : sortIndex;
    });
    var typeObj = {
        Edit: '选择项',
        SurveyId: SurveyId,
        SortIndex: sortIndex + 1,
        IsMustAnswer: '是',
        QuestionType: '单选项',
        IsShowScore: '否',
        IsComment: '否'
    }
    var rec = new recType(typeObj);
    
    $.ajaxExec("AddQuestionItem", { SortIndex: typeObj.SortIndex, SurveyId: SurveyId }, function(rtn) {

        var arr = rtn.data.SubItemId.split('|');
        rec.set("Id", arr[0] || "")
        rec.set("SubItemId", arr[1] || "")

        store.insert(store.data.length, rec);
        if ($(".x-grid3-body").innerHeight() > $(".x-grid3-scroller").innerHeight()) {
            var top = $(".x-grid3-body").innerHeight() - $(".x-grid3-scroller").innerHeight();
            $(".x-grid3-scroller").scrollTop(top);
        }
    }, null, "Comman.aspx");
}

//复制
function copySurvey(store) {
    var recType = store.recordType;
    if (store.getRange().length > 0) {
        var rec = store.getAt(store.data.length - 1); //上一题

        $.ajaxExec("GetId", { LastItem: rec.get("SubItemId") || "" }, function(rtn) {

            var arr = rtn.data.SubItemId.split("|");
            if (!arr[0]) return;

            var newrec = new recType({
                'SurveyId': SurveyId,
                'SurveyTitle': rec.get("SurveyTitle"),
                'IsMustAnswer': rec.get("IsMustAnswer"),
                'IsComment': rec.get("IsComment"),
                'QuestionType': rec.get("QuestionType"),
                'IsShowScore': rec.get("IsShowScore"),

                Id: arr[1],
                'ImgIds': rec.get("ImgIds"),
                'SubItemId': arr[0],         //*
                'SubItems': rec.get("SubItems"),
                'Ext1': rec.get("Ext1"),
                'SortIndex': store.getRange().length + 1
            });

            store.insert(store.getRange().length, newrec);
            if ($(".x-grid3-body").innerHeight() > $(".x-grid3-scroller").innerHeight()) {
                var top = $(".x-grid3-body").innerHeight() - $(".x-grid3-scroller").innerHeight();
                $(".x-grid3-scroller").scrollTop(top);
            }
        }, null, "Comman.aspx");
    }
}