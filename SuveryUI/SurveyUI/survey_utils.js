function get_question(qid_or_qcid) {
    for(var key in QUESTION_DICT){
        if (get_oid(QUESTION_DICT[key]) == qid_or_qcid || QUESTION_DICT[key].cid == qid_or_qcid){
            return QUESTION_DICT[key];
        }
    }
    return null;
}

function get_option(qid, option_id_or_list){
    var question = get_question(qid);
    if (!isNotEmpty(question)){
        return null;
    }
    if (option_id_or_list.constructor == Array){
        var option_list = [];
        for (var i = 0; i < question.option_list.length; i++) {
            var option = question.option_list[i];
            if (check_in(get_oid(option), option_id_or_list)){
                option_list.push(option);
            }
        }
        return option_list;
    }else{
        for (var i = 0; i < question.option_list.length; i++) {
            var option = question.option_list[i];
            if (get_oid(option) == option_id_or_list){
                return option;
            }
        }
    }
    return null;
}

function get_matrixrow(qid, row_id_or_list){
    //row_id_or_list可能为一个list, 可能以为单个的rcid或者rid
    var question = get_question(qid);
    if (!isNotEmpty(question) || !isNotEmpty(question.matrixrow_list)){
        return null;
    }
    if (row_id_or_list.constructor == String){
        for (var i = 0; i < question.matrixrow_list.length; i++) {
            var matrixrow = question.matrixrow_list[i];
            if (get_oid(matrixrow) == row_id_or_list){
                return matrixrow;
            }
        }
    }else {
        var row_list = [];
        for (var i = 0; i < question.matrixrow_list.length; i++) {
            var matrixrow = question.matrixrow_list[i];
            if (check_in(get_oid(matrixrow), row_id_or_list)){
                row_list.push(matrixrow);
            }
        }
        return row_list;
    }
    return null;
}

function get_qmodel(qid_or_qcid_or_question){
    var question = null;
    if (qid_or_qcid_or_question.constructor == String){
        question = get_question(qid_or_qcid_or_question);
    }else{
        question = qid_or_qcid_or_question;
    }
    if (isNotEmpty(question)){
        if (isNotEmpty(QMODEL_DICT[get_oid(question)])){
            return QMODEL_DICT[get_oid(question)];
        }else{
            var qmodel = QModelFactory.getQModel(question);
            QMODEL_DICT[get_oid(question)] = qmodel;
            return qmodel;
        }
    }else{
        return null;
    }
}

function get_questionpage(page_id){
    return QUESTIONPAGE_DICT[page_id];
}

function get_question_list_by_page(oid_or_page){
    var page = null;
    if (oid_or_page.constructor == String){
        page = get_questionpage(oid_or_page);
    }else{
        page = oid_or_page;
    }
    return $.map(page.question_id_list, get_question);
}

function update_question(question){
    QUESTION_DICT[get_oid(question)] = question;
    QMODEL_DICT[get_oid(question)] = null;
}

function get_jumpconstraint(jump_id){
    for(var key in JUMPCONSTRIANT_DICT){
        var jump = JUMPCONSTRIANT_DICT[key];
        if (get_oid(jump) == jump_id){
            return jump;
        }
    }
    return null;
}

function check_hide_for_question(qid){
    var css_str = $("#question_"+qid).css("display");
    if (!isNotEmpty(css_str) || css_str == "none"){
        return true;
    }
    return false;
}

function Process_title_p(id) {
    var title_html = $('#' + id + ' .topic_title p:eq(0)').html();
    $('#' + id + ' .topic_title p:eq(0)').replaceWith("<span>"+title_html+"</span>");
}

function check_answer_integrity(){
    var is_intact = true;
    return is_intact;
    if (!isNotEmpty(current_page_id)){
        return is_intact;
    }
    var page = get_questionpage(current_page_id);
    for (var k = 0; k < page.question_id_list.length; k++) {
        var qid = page.question_id_list[k];
        var question = get_question(qid);
        if ("allow_null" in question.custom_attr || $("#question_"+qid).attr("hideByLogic") === "1" || question.question_type === QUESTION_TYPE_DESC || $("#question_"+qid).length === 0){
            continue;
        }else{
            if (!(qid in total_answers)){
                is_intact = false;
                return is_intact;
            }
        }
    }
    return is_intact;
}