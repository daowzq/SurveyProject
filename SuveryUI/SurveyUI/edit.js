jQuery(document).ready(function($) {

    //----绑定事件----
    $(".ajaxGet").die().live("click", ajaxGet);

    $(".ajaxPost").die().live("click", function() {
        var func_name = $(this).attr("func");
        var func = null;
        if(isNotEmpty(func_name)) {
            eval("func = " + func_name);
            if(isNotEmpty(func)) {
                func();
            }
        }
    });

    $(".ajaxSubmit").die().live("submit", ajaxSubmit);

    //消除加载提示框
    // loadMack("off");

    //初始化题目
    init_question();
    init_question_desc();

    $("#proj_func_select").change(function(){
        var proj_func_id = $(this).val();
        var proj = {
            _id: {"$oid": get_oid(project)},
            project_func_id: proj_func_id
        };
        var data = {
            struct_str: toJSONString(proj),
            cls_type: "Project"
        };
        ajaxPost("/edit/ajax/struct_save/" + get_oid(project), data);
    });

    //切换页面时的检查函数
    $(window).focus(function(){
        $.ajax({
            type: "GET",
            url: "/edit/ajax/check_status_for_edit/?pid=" + get_oid(project),
            dataType: "JSON",
            success: function(ret){
                if (ret.user_online){
                    // console.log("user is online");
                }else{
                    // console.warn("user is offline");
                    jsAlert({content:"<p style='text-align:left;'>登录超时, 请重新登录</p>", obj: function(){
                        window.location.href = "/login/";
                    }});
                }
                if (ret.can_edit){
                    // console.log("this project can be edited");
                }else{
                    jsAlert({content:"<p style='text-align:left;'>您的问卷已经在收集中，如需修改问卷请至问卷列表页，点击设计按钮。</p>", obj: function(){
                        window.location.href = "/mysurvey/";
                    }});
                }
            }
        });
    });

    $.ajax({
        type: "GET",
        url: "/edit/ajax/check_status_for_edit/?pid=" + get_oid(project),
        dataType: "JSON",
        success: function(ret){
            if (ret.user_online){
                // console.log("user is online");
            }else{
                // console.warn("user is offline");
                jsAlert({content:"<p style='text-align:left;'>登录超时, 请重新登录</p>", obj: function(){
                    window.location.href = "/login/";
                }});
            }
            if (ret.can_edit){
                // console.log("this project can be edited");
            }else{
                jsAlert({content:"<p style='text-align:left;'>您的问卷已经在收集中，如需修改问卷请至问卷列表页，点击设计按钮。</p>", obj: function(){
                    window.location.href = "/mysurvey/";
                }});
            }
        }
    });

    $("#end_desc_type").change(function(){
        var desc_type = $(this).val();
        if (desc_type == "complete"){
            $("#end_desc").html(project.end_desc).attr("name", "end_desc");
        }else{
            $("#end_desc").html(project.custom_attr.screenout_desc||"").attr("name", "screenout_desc");
        }
    });

});

function matrixWidthProcess(qid, col_width_array){
    var table_width =0;
    var objPadding =0;
    $("li[oid='"+qid+"'] table tbody:eq(0) tr").each(function(m){
        table_width =0;
        $(this).children("td").each(function(i){
             objPadding=parseFloat($(this).css('paddingLeft'))+parseFloat($(this).css('paddingRight'))+1;

             if(col_width_array[i]==undefined){col_width_array[i]=col_width_array[i-1]};
             $(this).width(col_width_array[i]+"px");
             if(m>0&&i>0){
               $(this).wrapInner('<div class="div" style="width:'+(col_width_array[i])+'px"></div>');
             }
             table_width+=col_width_array[i]+objPadding;    
        }); 
         
    });
    $("li[oid='"+qid+"'] table").width(table_width);
}

function get_init_question(question_type) {
    return INIT_QUESTION_MAP[parseInt(question_type)];
}

function gen_init_template(question_type) {
    var init_question = get_init_question(question_type);
    var qmodel = get_qmodel(init_question);
    return qmodel.get_edit_html();
}

function init_question(){
    for (var i = 0; i < project.questionpage_id_list.length; i++) {
        if (typeof(project.questionpage_id_list[i-1]) != "undefined"){
            $("#question_box").append(PAGE_TEMPLATE);
        }
        var page_id = project.questionpage_id_list[i];
        var page = get_questionpage(page_id);
        for (var k = 0; k < page.question_id_list.length; k++) {
            var question_id = page.question_id_list[k];
            var question = get_question(question_id);
            var question_content = null;
            try {
                var qmodel = get_qmodel(question);
                question_content = qmodel.gen_edit_template();
            } catch(e) {
                console.warn("qmodel_" + question.question_type + " has an error: " + e.toString());
                continue;
            }
            $("#question_box").append(question_content);
            if (isNotEmpty(question.jumpconstraint_id_list)){
                set_jumpconstraint_status(get_oid(question), true, question.jumpconstraint_id_list.length);
            }else{
                set_jumpconstraint_status(null, false);
            }
            if (check_in(question.question_type, [QUESTION_TYPE_MATRIX_SINGLE, QUESTION_TYPE_MATRIX_MULTIPLE, QUESTION_TYPE_MATRIX_SCORE, QUESTION_TYPE_MATRIX_BLANK])){
                Width_mate(get_oid(question));
                if ('col_width' in question.custom_attr){
                    matrixWidthProcess(get_oid(question), question.custom_attr.col_width.parseJSON());
                }
            }
        }
    }
}


function get_init_template(question_type) {
    var init_template = INIT_TEMPLATE_MAP[question_type];
    return init_template;
}

function save_question(question_type, question_index, page_count) {
    if (question_type != "page"){
        var init_question = INIT_QUESTION_MAP[question_type];
        if (isNotEmpty(init_question)){
            var page_id = project.questionpage_id_list[page_count];
            init_question.questionpage_id = page_id;
            var data = {
                "question_struct": toJSONString(init_question),
                "questionpage_id": page_id,
                "index": question_index
            };
            var url = "/edit/ajax/question_create/" + get_oid(project);
            var question_content = null;
            syncPost(url, data, function(ret){
                var question_struct = ret.question;
                var page_index = project.questionpage_id_list.indexOf(ret.page_id);
                var page = project.questionpage_list[page_index];
                page.question_list.splice(question_index, 0, question_struct);
                page.question_id_list.splice(question_index, 0, get_oid(question_struct));
                add_question(question_struct);
                var qmodel = get_qmodel(question_struct);
                question_content = qmodel.gen_edit_template();
            });
            return question_content;
        }
    }else{
        var orig_page = project.questionpage_list[page_count];
        var orig_question_list = orig_page.question_list.slice(0, question_index);
        var orig_question_id_list = orig_page.question_id_list.slice(0, question_index);
        var new_question_list = orig_page.question_list.slice(question_index);
        var new_question_id_list = orig_page.question_id_list.slice(question_index);
        orig_page.question_list = orig_question_list;
        orig_page.question_id_list = orig_question_id_list;
        var data = {
            'orig_page_id': get_oid(orig_page),
            'new_page_struct': toJSONString({
                'project_id': get_oid(project),
                'question_id_list': new_question_id_list
            })
        };
        syncPost('/edit/ajax/questionpage_create/'+get_oid(project), data, function(ret){
            var new_page = ret.new_page;
            new_page.question_list = new_question_list;
            for (var i = 0; i < new_page.question_list.length; i++) {
                var question = new_page.question_list[i];
                question.questionpage_id = get_oid(new_page);
            }
            project.questionpage_list.splice(page_count + 1, 0, new_page);
            project.questionpage_id_list.splice(page_count + 1, 0, get_oid(new_page));
            QUESTIONPAGE_DICT[get_oid(new_page)] = new_page;
        });
        return PAGE_TEMPLATE;
    }
}

function after_dropped(question_type){
    //保存题目的顺序

    //如果是新添加题目, 则不需要执行保存顺序的动作
    if (isNotEmpty(question_type) && !isNaN(question_type)){
        return;
    }
    save_question_order();
}

function save_question_order(){
    var order_list = get_project_order_list();
    var data = {
        "order_list_str": toJSONString(order_list),
        "project_id": get_oid(project)
    };
    var url = "/edit/ajax/save_question_order/" + get_oid(project);
    ajaxPost(url, data, function(ret){
        if (ret.status == "200"){
            update_pageid_for_question(order_list);
        }
    });
}

function delete_question(args){
    var page_count = args.page_count;
    var qid = args.oid;
    if (isNotEmpty(qid)){
        var page_id = project.questionpage_id_list[page_count];
        var url = "/edit/ajax/delete_question/"+get_oid(project);
        var data = {"qid": qid, "page_id": page_id};
        ajaxPost(url, data, function(ret){
            if (ret.status == "200"){
                var qid = ret.qid;
                $(".module[oid="+ qid +"]").remove();
                init_question_desc();
                var question = get_question(qid);
                var questionpage = project.questionpage_list[page_count];
                questionpage.question_list.pop(questionpage.question_list.indexOf(question));
                questionpage.question_id_list.pop(questionpage.question_id_list.indexOf(get_oid(question)));
                remove_question(qid);

                var rel_map = ret.rel_map.parseJSON();
                //更新逻辑数量的值
                if (isNotEmpty(rel_map)){
                    for(var qid in rel_map){
                        var count = rel_map[qid];
                        if (count != 0){
                            set_jumpconstraint_status(qid, true, count);
                        }else{
                            set_jumpconstraint_status(qid, false);
                        }
                    }
                }
            }
        });
    }
}

function create_option(qid, str_list, batch){
    var option_list = [];
    var question = get_question(qid);
    //如果是批量添加, 并且题目中含有默认选项, 则删除
    if (batch){
        var need_remove_opid_list = [];
        var option_text_list = $.map(question.option_list, function(option){
            return option.title;
        });
        if (isNotEmpty(option_text_list)){
            if (match_text_remove(option_text_list)){
                need_remove_opid_list = $.map(question.option_list, function(option){
                    return get_oid(option);
                });
                question.option_list = [];
                update_question(question);
                delete_option(get_oid(question), need_remove_opid_list);
            }
        }
    }

    for (var i = 0; i < str_list.length; i++) {
        var option_title = str_list[i];
        if (!isNotEmpty(option_title)){
            continue;
        }
        var option_struct = {"title": option_title, "question_id": qid};
        if (question.question_type == QUESTION_TYPE_MULTIPLE_BLANK){
            option_struct['custom_attr'] = {'text_col': '15', 'text_row': '1'};
        }else if (question.question_type == QUESTION_TYPE_MATRIX_BLANK){
            option_struct['custom_attr'] = {'text_col': '10', 'text_row': '1'};
        }
        option_list.push(option_struct);
    }
    var option_id_list = [];
    syncPost("/edit/ajax/option_create/" + get_oid(project),
        {"question_id": qid, "option_list_str": toJSONString(option_list)},
        function(ret){
            if (ret.status == "200"){
                option_id_list = $.map(ret.option_id_list, function(oid){
                    return "" + oid;
                });
                var question = get_question(qid);
                question.option_id_list = question.option_id_list.concat(option_id_list);
                question.option_list = question.option_list.concat(ret.option_list);
                update_question(question);
            }
        });
    return option_id_list;
}

function create_matrixrow(qid, str_list, batch){
    var question = get_question(qid);
    //如果是批量添加, 并且题目中含有默认矩阵行, 则删除
    if (batch){
        var need_remove_rid_list = [];
        var row_text_title = $.map(question.matrixrow_list, function(row){
            return row.title;
        });
        if (isNotEmpty(row_text_title)){
            if (match_text_remove(row_text_title)){
                need_remove_rid_list = $.map(question.matrixrow_list, function(row){
                    return get_oid(row);
                });
                question.matrixrow_list = [];
                update_question(question);
                delete_matrixrow(get_oid(question), need_remove_rid_list);
            }
        }
    }

    var row_list = [];
    for (var i = 0; i < str_list.length; i++) {
        var row_title = str_list[i];
        if (!isNotEmpty(row_title)){
            continue;
        }
        row_list.push({"title": row_title, "question_id": qid});
    }
    var row_id_list = [];
    syncPost("/edit/ajax/matrixrow_create/" + get_oid(project),
        {"question_id": qid, "row_list_str": toJSONString(row_list)},
        function(ret){
            if (ret.status == "200"){
                row_id_list = $.map(ret.row_id_list, function(oid){
                    return "" + oid;
                });
                question.matrixrow_id_list = question.matrixrow_id_list.concat(row_id_list);
                question.matrixrow_list = question.matrixrow_list.concat(ret.row_list);
                update_question(question);
            }
        });
    return row_id_list;
}

function delete_page(page_count){
    var page = project.questionpage_list[page_count];
    syncPost('/edit/ajax/questionpage_delete/'+get_oid(project), {"page_id": get_oid(page), "page_count": page_count, "project_id": get_oid(project)}, function(ret){
        if (ret.is_del){
            var next_page = project.questionpage_list[page_count + 1];
            for (var i = 0; i < next_page.question_id_list.length; i++) {
                var qid = next_page.question_id_list[i];
                var question = get_question(qid);
                question.questionpage_id = get_oid(page);
            }
            page.question_list = page.question_list.concat(next_page.question_list);
            page.question_id_list = page.question_id_list.concat(next_page.question_id_list);
            project.questionpage_list.remove(page_count + 1);
            project.questionpage_id_list.remove(page_count + 1);
            problem_design.Site_total();
        }
    });
    
}

function insert_page(question_id, new_page){
    var orig_page_id = get_question(question_id).questionpage_id;
    var orig_page_index = project.questionpage_id_list.indexOf(orig_page_id);
    var orig_page = project.questionpage_list[orig_page_index];
    var question_index = orig_page.question_id_list.indexOf(question_id);
    var orig_question_list = orig_page.question_list.slice(0, question_index + 1);
    var orig_question_id_list = orig_page.question_id_list.slice(0, question_index + 1);
    var new_question_list = orig_page.question_list.slice(question_index + 1);
    new_page.question_list = new_question_list;
    for (var i = 0; i < new_question_list.length; i++) {
        var question = new_question_list[i];
        question.questionpage_id = get_oid(new_page);
    }
    orig_page.question_id_list = orig_question_id_list;
    orig_page.question_list = orig_question_list;
    project.questionpage_list.splice(orig_page_index + 1, 0, new_page);
    project.questionpage_id_list.splice(orig_page_index + 1, 0, get_oid(new_page));
    QUESTIONPAGE_DICT[get_oid(new_page)] = new_page;
}

function save_title(title, type, id){
    var data = {
        type: type,
        content: title,
        oid: id
    };
    ajaxPost('/edit/ajax/save_content/'+get_oid(project), data, function(ret){
        if (type == "option"){
            var option = get_option(ret.qid, id);
            option.title = title;
        }else if (type == "row"){
            var row = get_matrixrow(ret.qid, id);
            row.title = title;
        }
    });
}

function delete_option(qid, option_id_or_list){
    var option_param = null;
    if (option_id_or_list.constructor == Array){
        option_param = toJSONString(option_id_or_list);
    }else{
        option_param = option_id_or_list;
    }
    var data = {
        qid: qid,
        option_id_or_list: option_param
    };
    syncPost('/edit/ajax/delete_option/' + get_oid(project), data, function(ret){
        if (ret.jump_count != 0){
            set_jumpconstraint_status(ret.qid, true, ret.jump_count);
        }else{
            set_jumpconstraint_status(ret.qid, false);
        }
        var question = get_question(qid);
        if (option_id_or_list.constructor == Array){
            for (var i = 0; i < option_id_or_list.length; i++) {
                var option_id = option_id_or_list[i];
                var option_index = question.option_id_list.indexOf(option_id);
                question.option_id_list.remove(option_index);
                question.option_list.remove(option_index);
                // get_parent($("#" + option_id), "li").remove().empty();
                textEdit.obj=$('#'+option_id);
                textEdit.Del_edit(true);
                textEdit.obj='';
            }
        }else{
            var option_index = question.option_id_list.indexOf(option_id_or_list);
            question.option_id_list.remove(option_index);
            question.option_list.remove(option_index);
        }
        update_question(question);
    });
}

function delete_matrixrow(qid, row_id_or_list){
    var row_param = null;
    if (row_id_or_list.constructor == Array){
        row_param = toJSONString(row_id_or_list);
    }else{
        row_param = row_id_or_list;
    }
    var data = {
        qid: qid,
        row_id_or_list: row_param
    };
    syncPost("/edit/ajax/delete_matrixrow/" + get_oid(project), data, function(ret){
        var question = get_question(qid);
        if (row_id_or_list.constructor == Array){
            for (var i = 0; i < row_id_or_list.length; i++) {
                var row_id = row_id_or_list[i];
                var row_index = question.matrixrow_id_list.indexOf(row_id);
                question.matrixrow_id_list.remove(row_index);
                question.matrixrow_list.remove(row_index);
                textEdit.obj=$('#' + row_id);
                textEdit.Del_edit(true);
                textEdit.obj='';
            }
        }else{
            var row_index = question.matrixrow_id_list.indexOf(row_id_or_list);
            question.matrixrow_id_list.remove(row_index);
            question.matrixrow_list.remove(row_index);
        }
        update_question(question);
    });
}

function move_option(qid, option_id, direction){
    var data = {
        question_id: qid,
        option_id: option_id,
        direction: direction
    };
    ajaxPost("/edit/ajax/option_move/"+get_oid(project), data, function(ret){
        if (isNotEmpty(ret.option_id_list)){
            var question = get_question(qid);
            question.option_id_list = ret.option_id_list;
            question.option_list = $.map(ret.option_id_list, function(option_id){
                return get_option(qid, option_id);
            });
        }
    });
}

function move_matrixrow(qid, row_id, direction){
    var data = {
        question_id: qid,
        row_id: row_id,
        direction: direction
    };
    ajaxPost("/edit/ajax/matrixrow_move/"+get_oid(project), data, function(ret){
        if (isNotEmpty(ret.row_id_list)){
            var question = get_question(qid);
            question.matrixrow_id_list = ret.row_id_list;
            question.matrixrow_list = $.map(ret.row_id_list, function(row_id){
                return get_matrixrow(qid, row_id);
            });
        }
    });
}

function check_whether_insert_page(question_id, title){
    var reg = /\[(Q\d{1,3})\]/g;
    var cid_int = null;
    var match_group = title.match(reg);
    if (!isNotEmpty(match_group)){
        return false;
    }
    for (var i = 0; i < match_group.length; i++) {
        var match_str = match_group[i];
        if (isNotEmpty(cid_int)){
            var tmp_cid_int = match_str.match(/(\d{1,3})/)[0];
            if (parseInt(tmp_cid_int) > parseInt(cid_int)){
                cid_int = tmp_cid_int;
            }
        }else{
            var tmp_cid_int = match_str.match(/(\d{1,3})/)[0];
            cid_int = tmp_cid_int;
        }
    }
    if (isNotEmpty(cid_int)){
        var modules = $(".module");
        var qcid = "Q" + cid_int;
        var h = modules.find("h4:contains('"+qcid+"')");
        var begin_module = get_parent(h, "li");
        var end_module = modules.filter("[oid="+question_id+"]");
        var begin_index = modules.index(begin_module);
        var end_index = modules.index(end_module);
        var has_page = false;
        $(".module:lt("+end_index+"):gt("+begin_index+")").each(function(){
            if ($(this).hasClass("paging")){
                has_page = true;
                return false;
            }
        });
        if (!has_page){
            var page_count = 0;
            modules.filter(":lt("+end_index+")").each(function(){
                if ($(this).hasClass("paging")){
                    page_count += 1;
                }
            });
            var question = get_question(question_id);
            var page = get_questionpage(question.questionpage_id);
            var index = page.question_id_list.indexOf(question_id);
            save_question("page", index, page_count);
            end_module.before(PAGE_TEMPLATE);
            init_question_desc();
        }
    }
}

function get_option_list(qid){
    return question_option_map[qid];
}

function get_source_q_list(){
    var temp_qid_list = qid_list.slice(0, qid_list.length);
    return $.map(temp_qid_list, function(qid){
        if (check_in(qid, disabled_qid_list)){
            return;
        }
        var question = q_attr_dict[qid];
        // if (check_in(question.qtype, [QUESTION_TYPE_SINGLE, QUESTION_TYPE_MULTIPLE])){
        // if (question.qtype != QUESTION_TYPE_DESC){
        //     return question;
        // }
        return question;
    });
}

function get_jump_q_list(qid){
    var q_index = qid_list.indexOf(qid);
    var after_qid_list = qid_list.slice(q_index+1);
    return $.map(after_qid_list, function(qid){
        return q_attr_dict[qid];
    });
}

function check_all_question_selected(){
    var all_selected = true;
    for (var i = 0; i < qid_list.length; i++) {
        var qid = qid_list[i];
        if (!check_in(qid, disabled_qid_list)){
            all_selected = false;
            break;
        }
    }
    return all_selected;
}


var need_select_title_list = ['单选题', '多选题', '填空题', '多项填空题', '打分题', '矩阵单选题', '矩阵多选题', '矩阵打分题', '矩阵填空题', '排序题', '段落说明'];
function check_title_select(title){
    if (check_in(title, need_select_title_list)){
        return true;
    }
    if (/^选项\d+$/.test(title) || /^矩阵行\d+$/.test(title)|| /^请打分\d+$/.test(title)|| /^请填空\d+$/.test(title)){
        return true;
    }
    return false;
}

function update_pageid_for_question(order_list){
    for (var i = 0; i < order_list.length; i++) {
        var questionpage_order = order_list[i];
        var page_id = project.questionpage_id_list[i];
        var page = get_questionpage(page_id);
        page.question_id_list = questionpage_order;
        for (var k = 0; k < questionpage_order.length; k++) {
            var qid = questionpage_order[k];
            var question = get_question(qid);
            question.questionpage_id = get_oid(page);
        }
    }
}

function copy_question(qid, question_index){
    var data = {
        'qid': qid
    };
    var question_content = null;
    syncPost("/edit/ajax/copy_question/"+get_oid(project), data, function(ret){
        var question_struct = ret.new_q_struct;
        if (!isNotEmpty(question_struct.option_list)){
            question_struct.option_list = [];
        }
        if (!isNotEmpty(question_struct.matrixrow_list)){
            question_struct.matrixrow_list = [];
        }
        var page_index = project.questionpage_id_list.indexOf(question_struct.questionpage_id);
        var page = project.questionpage_list[page_index];
        page.question_list.splice(question_index, 0, question_struct);
        page.question_id_list.splice(question_index, 0, get_oid(question_struct));
        add_question(question_struct);
        var qmodel = get_qmodel(question_struct);
        question_content = qmodel.gen_edit_template();
    });
    // return question_content;
    if (isNotEmpty(question_content)){
        add_question_html(question_index, question_content);
        init_question_desc();
    }
}

function check_page_logic(page_index){
    var page_id = project.questionpage_id_list[page_index];
    var data = {
        'project_id': get_oid(project),
        'page_id': page_id
    }
    var valid = false;
    syncPost("/edit/ajax/check_page_logic/", data, function(ret){
        valid = ret.valid;
    });

    return valid;
}

function check_is_blank(question){
    return check_in(question.question_type, [QUESTION_TYPE_BLANK, QUESTION_TYPE_MULTIPLE_BLANK, QUESTION_TYPE_MATRIX_BLANK]);
}

function get_edit_lock(){
    window.location.reload();
}

function close_window(){
    // window.opener=null;
    // window.open('','_self');
    // window.close();
    window.location.href = "/mysurvey";
}

function insert_question_html(qid, q_index){
    var qmodel = get_qmodel(qid);
    insert_question_html(q_index, qmodel.gen_edit_template());
    if (check_in(qmodel.question.question_type, [QUESTION_TYPE_MATRIX_SINGLE, QUESTION_TYPE_MATRIX_MULTIPLE, QUESTION_TYPE_MATRIX_SCORE, QUESTION_TYPE_MATRIX_BLANK])){
        Width_mate(get_oid(qmodel.question));
    }
    init_question_desc();
    if (isNotEmpty(qmodel.question.jumpconstraint_id_list)){
        set_jumpconstraint_status(get_oid(qmodel.question), true, qmodel.question.jumpconstraint_id_list.length);
    }else{
        set_jumpconstraint_status(get_oid(qmodel.question), false);
    }
    if (project.p_type === 1){
        if ("need_permission" in qmodel.question.custom_attr){
            set_quesitonLock_status(get_oid(qmodel.question), true);
        }else{
            set_quesitonLock_status(get_oid(qmodel.question), false);
        }
    }
}

function QuestionImg(qid) {
    this.qid = qid;
    this.m = 0;
    this.main = function() {
        var _this = this;
        $('.AddQImgCon').dmUploader({
            url: '/edit/form/ajax/create_image_option/' + get_oid(project) + '/',
            dataType: 'json',
            allowedTypes: 'image/*',
            extraData: {
                qid: _this.qid,
                _xsrf: $.cookie("_xsrf") || ""
            },
            maxFileSize:5242880,
            extFilter: 'jpg;png;gif;bmp',
            //初始化插件
            onInit: function() {
                //$.danidemo.addLog('#demo-debug', 'default', 'Plugin initialized correctly');
            },
            //检查浏览器是否支持该插件
            onBeforeUpload: function(id) {

            },
            //添加新文件
            onNewFile: function(id,file) {
                
                $.danidemo.addFile('#demo-files', id, file);
                _this.AddImgCon(_this.qid, id);
            },
            //
            onComplete: function() {},
            //如果浏览器支持上传进度，这将被调用的时候，我们有一个更新。
            onUploadProgress: function(id, percent) {
                var percentStr = percent + '%';
                $('#' + _this.qid + '_' + id).find('.pbg').width(percentStr);
            },
            //上传成功
            onUploadSuccess: function(id, data) {
   
                if(data.status == '200') {

                    var Pobj = $('#' + _this.qid + '_' + id);
                    Pobj.find('.QImgCon img').attr('src', data.option_struct.custom_attr.images.thumbnail_src);
                    Pobj.find('.QImgCon img').attr('Maxsrc', data.option_struct.custom_attr.images.src);
                    Pobj.find('.QImgCon img').attr('orig_width', data.option_struct.custom_attr.images.orig_width);
                    Pobj.find('.ImgBox_loading').hide();
                    Pobj.find('.QImgCon').show();
                    Pobj.append(_this.AddImgOption(get_oid(data.option_struct), data.option_struct.title));
                    var option_id = get_oid(data.option_struct);
                    var question = get_question(_this.qid);
                    if (question.hasOwnProperty('option_list')){
                        question.option_list.push(data.option_struct);
                        question.option_id_list.push(option_id);
                    }else{
                        question.option_list = [data.option_struct];
                        question.option_id_list = [option_id];
                    }
                    Pobj.attr("id", option_id);
                    
                    $("#"+option_id+" .QImgCon").click(function() {
                        var _this = $(this).find("img");
                        var url = _this.attr("Maxsrc");
                        var option_id = _this.parents(".questionImgBox").attr("id");
                        var bbox = _this.attr("bbox");
                        var orig_width = _this.attr("orig_width");

                        if(bbox==undefined){bbox="[75,75,150,150]";}
                        bbox = bbox.parseJSON();
                        CreateJcrop(url, ChgThumbnailCallback, option_id,bbox,orig_width);
                    });

                }

            },
            onUploadError: function(id) {
                var Pobj = $('#' + _this.qid + '_' + id);
                    Pobj.find('.ProgressBar').html('<span class="text_red">上传失败</span>');
                    setTimeout(function(){
                      Pobj.remove();
                    },3000);
            },
            onFileTypeError: function(file) {
                alert(file.name+" 该图片格式有误");
            },
            onFileSizeError: function(file) {

                alert(file.name+" 该图片太大,单张不能超过5M");
            },
            /*onFileExtError: function(file){
                      $.danidemo.addLog('#demo-debug', 'error', 'File \'' + file.name + '\' has a Not Allowed Extension');
                    },*/
            onFallbackMode: function(message) {

                $('li[oid="' + _this.qid + '"] .AddQImgCon').hide();
                $('li[oid="' + _this.qid + '"] .AddQImgCon_ie').show();
            }
        });

    }
    //批量添加图片题选项
    this.AddImgCon = function(qid, id) {
        var question = $('li[oid="' + qid + '"]');
        var optionLength = question.find('.Imgli li').length;
        var imgli = '<li><div class="questionImgBox" id="' + qid + '_' + id + '"><div class ="ImgBox_loading"><div class ="ProgressBar"><div class="pbg"></div></div></div>' + '<div style="display:none;" class="QImgCon"><img Maxsrc="" src=""></div>' + '</div></li>';
        $('.dragZone', question).before(imgli);
    }
    this.AddImgOption = function(oid, name) {
        var question = get_question(this.qid);
        if (question.question_type === QUESTION_TYPE_SINGLE){
            var optionCon = '<input type="radio" name="radio" id="option_' + oid + '" value="option_' + oid + '">' + '<label class="T_edit_min" for="" name="option" id="' + oid + '">' + name + '</label>';
        }else{
            var optionCon = '<input type="checkbox" name="checkbox" id="option_' + oid + '" value="option_' + oid + '">' + '<label class="T_edit_min" for="" name="option" id="' + oid + '">' + name + '</label>';
        }
        return optionCon;
    }

    return this.main();
}

function CreateJcrop(url, Callback, option_id,bbox,orig_width) {
    var cjimgId = new Date().getTime();

    if(orig_width>400){var imgwidth = 400;}else{var imgwidth = orig_width;}

    jsConfirm({
        'title': '图片裁剪',
        'content': '<div class="cjimg"><img width="'+imgwidth+'" src="'+url+'" id="'+cjimgId+'" alt="图片加载错误" /></div>',
        'obj': SavefCutOut,
        'conw': 440,
        'obj_text': '裁剪',
        //'close_text':'取消',
        'Param': '#target'
    });
    initJcrop("#"+cjimgId);
       
    function initJcrop(obj) {
        $('.requiresjcrop').hide();
        // Invoke Jcrop in typical fashion
        $(obj).Jcrop({
            // onRelease: releaseCheck
            onSelect: showCoords,
            minSize: [75,75]
        }, function() {
          
            jcrop_api = this;
            jcrop_api.animateTo(bbox);
            jcrop_api.setOptions({
                aspectRatio: 4 / 4
            });

            $('.requiresjcrop').show();

        });
        return false;
    }

    var Coordinate = {};
    Coordinate.x =75;
    Coordinate.y =75;
    Coordinate.x2 =150;
    Coordinate.y2 =150;


    function showCoords(c) {
        Coordinate = c;
    };

    function SavefCutOut() {
        var bbox = [Coordinate.x, Coordinate.y, Coordinate.x2, Coordinate.y2]
        var data = {
            "option_id": option_id,
            "bbox": toJSONString(bbox)
        };
        ajaxPost("/edit/form/ajax/upload_cut_image/"+get_oid(project), data, function(ret){
            var new_thumb_url = ret.thumb_url;
            new_thumb_url += "&s=" + Math.random();
            Callback(new_thumb_url, option_id, ret.bbox);
        });
    }
}
//裁剪图片回调方法
function ChgThumbnailCallback(imgurl,oid,bbox){

    // var imgobj = new Image();
    // imgobj.onload=function(){
        setTimeout(function(){
            var maxsrc = $("#"+oid+ ' .QImgCon img').attr('maxsrc');
            var orig_width = $("#"+oid+ ' .QImgCon img').attr('orig_width');
            $("#"+oid+ ' .QImgCon img').remove();
            var NewImg = $('<img maxsrc="'+maxsrc+'" bbox="'+bbox+'" orig_width="'+orig_width+'" src="'+imgurl+'"></img>').appendTo("#"+oid+ ' .QImgCon');
        }, 50);
        
    // }
    // imgobj.src = imgurl;

   // $("#"+oid+ ' .QImgCon img').attr('src',imgurl);
}


function upload_img_success_for_ie(qid,option_struct){
        var question = $('li[oid="' + qid + '"]');
        var optionLength = question.find('.Imgli li').length-1;
        var Pobj = $('#' + qid + '_' +optionLength);

        Pobj.find('.QImgCon img').attr('src',option_struct.custom_attr.images.thumbnail_src);
        Pobj.find('.QImgCon img').attr('Maxsrc',option_struct.custom_attr.images.src);
        Pobj.find('.QImgCon img').attr('orig_width',option_struct.custom_attr.images.orig_width);
        Pobj.find('.ImgBox_loading').hide();
        Pobj.find('.QImgCon').show();
        Pobj.append(AddImgOption(get_oid(option_struct),option_struct.title));
        var option_id = get_oid(option_struct);
        Pobj.attr("id", option_id);
        $("#"+option_id+" .QImgCon img").click(function() {
            var url = $(this).attr("Maxsrc");
            var orig_width = $(this).attr("orig_width");
            var option_id = $(this).parents(".questionImgBox").attr("id");
            CreateJcrop(url, ChgThumbnailCallback, option_id,orig_width);
        });
    
        function AddImgOption(oid,name) {
            var question = get_question(this.qid);
            if (question.question_type === QUESTION_TYPE_SINGLE){
                var optionCon = '<input type="radio" name="radio" id="option_' + oid + '" value="option_' + oid + '">' + '<label class="T_edit_min" for="" name="option" id="' + oid + '">' + name + '</label>';
            }else{
                var optionCon = '<input type="checkbox" name="checkbox" id="option_' + oid + '" value="option_' + oid + '">' + '<label class="T_edit_min" for="" name="option" id="' + oid + '">' + name + '</label>';
            }
            return optionCon;
        }

}
function start_upload_img_for_ie(qid){
        var question = $('li[oid="' + qid + '"]');
        var optionLength = question.find('.Imgli li').length;
        var imgli = '<li><div class="questionImgBox" id="' + qid + '_' + optionLength + '"><div class ="ImgBox_loading"><div class ="ProgressBar"><div class="pbg"></div></div></div>' + '<div style="display:none;" class="QImgCon"><img Maxsrc="" src=""></div>' + '</div></li>';
        $('.dragZone', question).before(imgli);
        $("#"+qid+"_"+optionLength+" .pbg").animate({width:'+90%'}, "1000");
}