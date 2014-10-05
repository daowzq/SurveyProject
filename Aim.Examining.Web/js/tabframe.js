/**
 * TabView 配置参数
 * 
 * @return
 */
var TabOption = function() {
};
/**
 * TabView 配置参数
 */
TabOption.prototype = {
	containerId :'',// 容器ID,
	pageid :'',// pageId 页面 pageID
	cid :'',// 指定tab的id
	position :top,
	// tab位置，可为top和bottom，默认为top
	action : function(e, p) {
	}
};
/**
 * Tab Item 配置参数
 * 
 * @return
 */
var TabItemOption = function() {
}
/**
 * Tab Item 配置参数
 */
TabItemOption.prototype = {
	id :'tab_',// tabId
	title :'',// tab标题
	url :'',// 该tab链接的URL
	isClosed :false
// 该tab是否可以关闭
}
/**
 * @param {}
 *            option option 可选参数 containerId tab 容器ID pageid pageId 页面 pageID
 *            cid cid tab ID
 */
function TabView(option) {
	var tab_context = {
		current :null,
		current_index :0,
		current_page :null
	};
	var op = new TabOption();
	$.extend(op, option);
	var bottom = op.position == "bottom" ? "_bottom" : "";
	this.id = op.cid;
	this.pid = op.pageid;
	this.tabs = null;
	this.tabContainer = null;
	var tabTemplate = '<table class="tab_item"  id="{0}" border="0" cellpadding="0" cellspacing="0"><tr>' + '<td class="tab_item1"></td>'
			+ '<td class="tab_item2 tab_title">{1}</td>' + '<td class="tab_item2"><div class="tab_close"></div></td>' + '<td class="tab_item3"></td>'
			+ '</tr></table>';
	var tabContainerTemplate = '<div class="aim_ui_tab" id="{0}"><div class="tab_hr"></div></div>';
	var page = '<iframe id="{0}" frameborder="0" width="100%" height="100%" src="{1}"></iframe>';
	if (op.position == "bottom") {
		tabTemplate = '<table class="tab_item_bottom"  id="{0}" border="0" cellpadding="0" cellspacing="0"><tr>' + '<td class="tab_item1_bottom"></td>'
				+ '<td class="tab_item2_bottom tab_title">{1}</td>' + '<td class="tab_item2_bottom"><div class="tab_close tab_close_bottom"></div></td>'
				+ '<td class="tab_item3_bottom"></td>' + '</tr></table>';
		tabContainerTemplate = '<div class="aim_ui_tab aim_ui_tab_bottom" id="{0}"><div class="tab_hr tab_hr_bottom"></div></div>';
	}
	$("#" + op.containerId).append(tabContainerTemplate.replace("{0}", this.id));
	function initTab(el) {
		var theTab = $(el);
		var tab_item1 = $(theTab).find(".tab_item1" + bottom);
		var tab_item2 = $(theTab).find(".tab_item2" + bottom);
		var tab_item3 = $(theTab).find(".tab_item3" + bottom);
		if (tab_context.current == null || tab_context.current != this) {
			$(theTab).mouseover( function() {
				tab_item1.addClass("tab_item1_mouseover" + bottom);
				tab_item2.addClass("tab_item2_mouseover" + bottom);
				tab_item3.addClass("tab_item3_mouseover" + bottom);
			}).mouseout( function() {
				tab_item1.removeClass("tab_item1_mouseover" + bottom);
				tab_item2.removeClass("tab_item2_mouseover" + bottom);
				tab_item3.removeClass("tab_item3_mouseover" + bottom);
			}).click( function() {
				if (tab_context.current != null) {
					$(tab_context.current).find(".tab_item1" + bottom).removeClass("tab_item1_selected" + bottom);
					$(tab_context.current).find(".tab_item2" + bottom).removeClass("tab_item2_selected" + bottom);
					$(tab_context.current).find(".tab_item3" + bottom).removeClass("tab_item3_selected" + bottom);
					$(tab_context.current).find(".tab_close").addClass("tab_close_noselected");
				}
				tab_item1.addClass("tab_item1_selected" + bottom);
				tab_item2.addClass("tab_item2_selected" + bottom);
				tab_item3.addClass("tab_item3_selected" + bottom);
				tab_context.current = this;
				$(tab_context.current).find(".tab_close").removeClass("tab_close_noselected");
				activate($(this).attr("id"), false);
				
			});
			var tab_close = $(theTab).find(".tab_close").mouseover( function() {
				$(this).addClass("tab_close_mouseover");
			}).mouseout( function() {
				$(this).removeClass("tab_close_mouseover");
			}).click( function() {
				close(theTab.attr("id"));
			});
		}
	}
	function activate(id, isAdd) {
		if (isAdd) {
			//$("#" + id).trigger("click");
		}
		if (tab_context.current_page) {
			tab_context.current_page.hide();
		}
		tab_context.current_page = $("#page_" + id);
		tab_context.current_page.show();
		op.action($("#" + id), tab_context.current_page);
	}
	function close(id) {
		var close_page = $("#page_" + id);
		var close_tab = $("#" + id);
		if ($(tab_context.current).attr("id") == close_tab.attr("id")) {
			var next = close_tab.next();
			if (next.attr("id")) {
				activate(next.attr("id"), true);
			} else {
				var pre = close_tab.prev();
				if (pre.attr("id")) {
					activate(pre.attr("id"), true);
				}
			}
		} else {
		}
		// close_page.find("iframe").remove();
		close_page.remove();
		close_tab.remove();
	}
	this.init = function() {
		this.tabContainer = $("#" + this.id);
		this.tabs = this.tabContainer.find(".tab_item" + bottom);
		this.tabs.each( function() {
			initTab(this);
		});
	}
	this.add = function(option) {
		var op1 = new TabItemOption();
		$.extend(op1, option);
		//if (op1.title.length > 10) {
		//	op1.title = op1.title.substring(0, 10);
		//}
		if (op1.title.length < 4) {
			op1.title = "&nbsp;&nbsp;" + op1.title + "&nbsp;";
		}
		var pageHtml = page.replace("{0}", "page_" + op1.id).replace("{1}", op1.url);
		$("#" + this.pid).append(pageHtml);
		var html = tabTemplate.replace("{0}", op1.id).replace("{1}", op1.title);
		this.tabContainer.append(html);
		initTab($("#" + op1.id));
		if (!op1.isClosed) {
			$($("#" + op1.id)).find(".tab_close").hide();
		}
		// this.init();
		//this.activate(op1.id);//新加入立即加载
	}
	this.update = function(option) {
		var id = option.id;
		// alert(option.url);
		$("#" + id).find(".tab_title").html(option.title);
		$("#" + id).trigger("click");
		// $("#page_" + id).find("iframe").attr("src", option.url);
		$("#page_" + id).attr("src", option.url);
		// document.getElementById()
	}
	this.activate = function(id) {
		// $("#" + id).trigger("click");
		// activate(id, true);
		$("#" + id).trigger("click");
	}
	this.close = function(id) {
		close(id);
	}
	this.init();
}

/*//使用帮助
var tab=null;
$( function() {
	  tab = new TabView( {
		containerId :'tab_menu',
		pageid :'page',
		cid :'tab_po',
		position :"bottom"
	});
	tab.add( {
		id :'tab1_id_index1',
		title :"百度主页",
		url :"http://www.baidu.com",
		isClosed :true
	});
	tab.add( {
		id :'tab2_id_index2',
		title :"谷歌主页",
		url :"http://www.google.cn",
		isClosed :false
	});
	tab.add( {
		id :'tab3_id_index3',
		title :"我的主页",
		url :"http://blog.csdn.net/myloon",
		isClosed :false
	});
	tab.add( {
		id :'tab4_id_index4',
		title :"标签页面1",
		url :"tabs/tab1.html",
		isClosed :true
	});
	
});
var index=1;
function addTab(){
	var id='tab5_id_index'+(index+12);
	var name=document.getElementById("tab_name").value;
	var url=document.getElementById("tab_url").value;
	var close=$("input:radio:checked").val().toString();
 
	tab.add( {
		id :id,
		title :name==""?("标签页面"+(index+1)):name,
		url :url==""?("tabs/tab"+((index%3)+1)+".html"):url,
		isClosed :close=='1'?true:false
	});
	index++;
	
}



<h2>2、使用方法</h2>
<p>
<pre>
	var tab = new TabView( {
		containerId :'tab_menu',  	标签容器ID
		pageid :'page', 		页面容器Id
		cid :'tab_po', 			指定tab ID
		position :"bottom"    		tab位置，只支持top和bottom
	});
	添加tab
	tab.add( {
		id :'tab1_id_index1',		标签ID
		title :"百度主页",		标签标题
		url :"http://www.baidu.com",	该标签所链接的URL地址
		isClosed :true			是否可以关闭标签
	});
</pre>
</p>
<h2>3、API参考</h2>
<p>
<pre>
	<b>add(option)： </b>
		添加一个新标签，例如：
				tab.add( {
					id :'tab1_id_index1',		标签ID
					title :"百度主页",		标签标题
					url :"http://www.baidu.com",	该标签所链接的URL地址
					isClosed :true			是否可以关闭标签
				});
	<b>update(option)：</b>
			更新标签,例如：
				tab.update({
							id : uid,
							url : url,
							title : title
				});
	<b>activate(id)：</b>
			激活一个标签，例如：
			tab.activate(tab_id)；
	<b>close(id)</b>
			关闭一个标签,例如：
			tab.close(tab_id);
</pre>
*/



var ddsmoothmenu={

//Specify full URL to down and right arrow images (23 is padding-right added to top level LIs with drop downs):
arrowimages: {down:['downarrowclass', '../images/tabframe/down.gif', 23], right:['rightarrowclass', '../images/tabframe/right.gif']},
transition: {overtime:300, outtime:300}, //duration of slide in/ out animation, in milliseconds
shadow: {enable:true, offsetx:5, offsety:5}, //enable shadow?
showhidedelay: {showdelay: 100, hidedelay: 200}, //set delay in milliseconds before sub menus appear and disappear, respectively

///////Stop configuring beyond here///////////////////////////

detectwebkit: navigator.userAgent.toLowerCase().indexOf("applewebkit")!=-1, //detect WebKit browsers (Safari, Chrome etc)
detectie6: document.all && !window.XMLHttpRequest,

getajaxmenu:function($, setting){ //function to fetch external page containing the panel DIVs
	var $menucontainer=$('#'+setting.contentsource[0]) //reference empty div on page that will hold menu
	$menucontainer.html("Loading Menu...")
	$.ajax({
		url: setting.contentsource[1], //path to external menu file
		async: true,
		error:function(ajaxrequest){
			$menucontainer.html('Error fetching content. Server Response: '+ajaxrequest.responseText)
		},
		success:function(content){
			$menucontainer.html(content)
			ddsmoothmenu.buildmenu($, setting)
		}
	})
},


buildmenu:function($, setting){
	var smoothmenu=ddsmoothmenu
	var $mainmenu=$("#"+setting.mainmenuid+">ul") //reference main menu UL
	$mainmenu.parent().get(0).className=setting.classname || "ddsmoothmenu"
	var $headers=$mainmenu.find("ul").parent()
	$headers.hover(
		function(e){
			$(this).children('a:eq(0)').addClass('selected')
		},
		function(e){
			$(this).children('a:eq(0)').removeClass('selected')
		}
	)
	$headers.each(function(i){ //loop through each LI header
		var $curobj=$(this).css({zIndex: 100-i}) //reference current LI header
		var $subul=$(this).find('ul:eq(0)').css({display:'block'})
		$subul.data('timers', {})
		this._dimensions={w:this.offsetWidth, h:this.offsetHeight, subulw:$subul.outerWidth(), subulh:$subul.outerHeight()}
		this.istopheader=$curobj.parents("ul").length==1? true : false //is top level header?
		$subul.css({top:this.istopheader && setting.orientation!='v'? this._dimensions.h+"px" : 0})
		$curobj.children("a:eq(0)").css(this.istopheader? {paddingRight: smoothmenu.arrowimages.down[2]} : {}).append( //add arrow images
			'<img src="'+ (this.istopheader && setting.orientation!='v'? smoothmenu.arrowimages.down[1] : smoothmenu.arrowimages.right[1])
			+'" class="' + (this.istopheader && setting.orientation!='v'? smoothmenu.arrowimages.down[0] : smoothmenu.arrowimages.right[0])
			+ '" style="border:0;" />'
		)
		if (smoothmenu.shadow.enable){
			this._shadowoffset={x:(this.istopheader?$subul.offset().left+smoothmenu.shadow.offsetx : this._dimensions.w), y:(this.istopheader? $subul.offset().top+smoothmenu.shadow.offsety : $curobj.position().top)} //store this shadow's offsets
			if (this.istopheader)
				$parentshadow=$(document.body)
			else{
				var $parentLi=$curobj.parents("li:eq(0)")
				$parentshadow=$parentLi.get(0).$shadow
			}
			this.$shadow=$('<div class="ddshadow'+(this.istopheader? ' toplevelshadow' : '')+'"></div>').prependTo($parentshadow).css({left:this._shadowoffset.x+'px', top:this._shadowoffset.y+'px'})  //insert shadow DIV and set it to parent node for the next shadow div
		}
		$curobj.hover(
			function(e){
				var $targetul=$subul //reference UL to reveal
				var header=$curobj.get(0) //reference header LI as DOM object
				clearTimeout($targetul.data('timers').hidetimer)
				$targetul.data('timers').showtimer=setTimeout(function(){
					header._offsets={left:$curobj.offset().left, top:$curobj.offset().top}
					var menuleft=header.istopheader && setting.orientation!='v'? 0 : header._dimensions.w
					menuleft=(header._offsets.left+menuleft+header._dimensions.subulw>$(window).width())? (header.istopheader && setting.orientation!='v'? -header._dimensions.subulw+header._dimensions.w : -header._dimensions.w) : menuleft //calculate this sub menu's offsets from its parent
					if ($targetul.queue().length<=1){ //if 1 or less queued animations
						$targetul.css({left:menuleft+"px", width:header._dimensions.subulw+'px'}).animate({height:'show',opacity:'show'}, ddsmoothmenu.transition.overtime)
						if (smoothmenu.shadow.enable){
							var shadowleft=header.istopheader? $targetul.offset().left+ddsmoothmenu.shadow.offsetx : menuleft
							var shadowtop=header.istopheader?$targetul.offset().top+smoothmenu.shadow.offsety : header._shadowoffset.y
							if (!header.istopheader && ddsmoothmenu.detectwebkit){ //in WebKit browsers, restore shadow's opacity to full
								header.$shadow.css({opacity:1})
							}
							header.$shadow.css({overflow:'', width:header._dimensions.subulw+'px', left:shadowleft+'px', top:shadowtop+'px'}).animate({height:header._dimensions.subulh+'px'}, ddsmoothmenu.transition.overtime)
						}
					}
				}, ddsmoothmenu.showhidedelay.showdelay)
			},
			function(e){
				var $targetul=$subul
				var header=$curobj.get(0)
				clearTimeout($targetul.data('timers').showtimer)
				$targetul.data('timers').hidetimer=setTimeout(function(){
					$targetul.animate({height:'hide', opacity:'hide'}, ddsmoothmenu.transition.outtime)
					if (smoothmenu.shadow.enable){
						if (ddsmoothmenu.detectwebkit){ //in WebKit browsers, set first child shadow's opacity to 0, as "overflow:hidden" doesn't work in them
							header.$shadow.children('div:eq(0)').css({opacity:0})
						}
						header.$shadow.css({overflow:'hidden'}).animate({height:0}, ddsmoothmenu.transition.outtime)
					}
				}, ddsmoothmenu.showhidedelay.hidedelay)
			}
		) //end hover
	}) //end $headers.each()
	$mainmenu.find("ul").css({display:'none', visibility:'visible'})
},

init:function(setting){
	if (typeof setting.customtheme=="object" && setting.customtheme.length==2){ //override default menu colors (default/hover) with custom set?
		var mainmenuid='#'+setting.mainmenuid
		var mainselector=(setting.orientation=="v")? mainmenuid : mainmenuid+', '+mainmenuid
		document.write('<style type="text/css">\n'
			+mainselector+' ul li a {background:'+setting.customtheme[0]+';}\n'
			+mainmenuid+' ul li a:hover {background:'+setting.customtheme[1]+';}\n'
		+'</style>')
	}
	this.shadow.enable=(document.all && !window.XMLHttpRequest)? false : this.shadow.enable //in IE6, always disable shadow
	jQuery(document).ready(function($){ //ajax menu?
		if (typeof setting.contentsource=="object"){ //if external ajax menu
			ddsmoothmenu.getajaxmenu($, setting)
		}
		else{ //else if markup menu
			ddsmoothmenu.buildmenu($, setting)
		}
	})
}

} //end ddsmoothmenu variable