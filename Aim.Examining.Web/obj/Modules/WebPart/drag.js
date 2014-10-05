//http://boring.youngpup.net/2001/domdrag/

/**
 * Base class of Drag
 * 可拖拽 Element 的原形，用来将 event 绑定到各个钩子，这部分市比较通用的，netvibes 也是基本完全相同的实现，这部分推荐看 dindin 的这个，也会帮助理解，http://www.jroller.com/page/dindin/?anchor=pro_javascript_12
 * @example:
 * Drag.init( header_element, element );
 */
var Drag = {
	// 对这个element的引用，一次只能拖拽一个Element
	obj: null , 
	/**
	 * @param: elementHeader	used to drag..
	 * @param: element			used to follow..
	 */
	init: function(elementHeader, element) {
		// 将 start 绑定到 onmousedown 事件，按下鼠标触发 start
		elementHeader.onmousedown = Drag.start;
		// 将 element 存到 header 的 obj 里面，方便 header 拖拽的时候引用
		elementHeader.obj = element;
		// 初始化绝对的坐标，因为不是 position = absolute 所以不会起什么作用，但是防止后面 onDrag 的时候 parse 出错了
		if(isNaN(parseInt(element.style.left))) {
			element.style.left = "0px";
		}
		if(isNaN(parseInt(element.style.top))) {
			element.style.top = "0px";
		}
		// 挂上空 Function，初始化这几个成员，在 Drag.init 被调用后才帮定到实际的函数
		element.onDragStart = new Function();
		element.onDragEnd = new Function();
		element.onDrag = new Function();
	},
	// 开始拖拽的绑定，绑定到鼠标的移动的 event 上
	start: function(event) {
		var element = Drag.obj = this.obj;
		// 解决不同浏览器的 event 模型不同的问题
		event = Drag.fixE(event);
		// 看看是不是左键点击
		if(event.which != 1){
			// 除了左键都不起作用
			return true ;
		}
		// 参照这个函数的解释，挂上开始拖拽的钩子
		element.onDragStart();
		// 记录鼠标坐标
		element.lastMouseX = event.clientX;
		element.lastMouseY = event.clientY;
		// 绑定事件
		document.onmouseup = Drag.end;
		document.onmousemove = Drag.drag;
		return false ;
	}, 
	// Element正在被拖动的函数
	drag: function(event) {
		event = Drag.fixE(event);
		if(event.which == 0 ) {
		 	return Drag.end();
		}
		// 正在被拖动的Element
		var element = Drag.obj;
		// 鼠标坐标
		var _clientX = event.clientY;
		var _clientY = event.clientX;
		// 如果鼠标没动就什么都不作
		if(element.lastMouseX == _clientY && element.lastMouseY == _clientX) {
			return	false ;
		}
		// 刚才 Element 的坐标
		var _lastX = parseInt(element.style.top);
		var _lastY = parseInt(element.style.left);
		// 新的坐标
		var newX, newY;
		// 计算新的坐标：原先的坐标+鼠标移动的值差
		newX = _lastY + _clientY - element.lastMouseX;
		newY = _lastX + _clientX - element.lastMouseY;
		// 修改 element 的显示坐标
		element.style.left = newX + "px";
		element.style.top = newY + "px";
		// 记录 element 现在的坐标供下一次移动使用
		element.lastMouseX = _clientY;
		element.lastMouseY = _clientX;
		// 参照这个函数的解释，挂接上 Drag 时的钩子
		element.onDrag(newX, newY);
		return false;
	},
	// Element 正在被释放的函数，停止拖拽
	end: function(event) {
		event = Drag.fixE(event);
		// 解除事件绑定
		document.onmousemove = null;
		document.onmouseup = null;
		// 先记录下 onDragEnd 的钩子，好移除 obj
		var _onDragEndFuc = Drag.obj.onDragEnd();
		// 拖拽完毕，obj 清空
		Drag.obj = null ;
		return _onDragEndFuc;
	},
	// 解决不同浏览器的 event 模型不同的问题
	fixE: function(ig_) {
		if( typeof ig_ == "undefined" ) {
			ig_ = window.event;
		}
		if( typeof ig_.layerX == "undefined" ) {
			ig_.layerX = ig_.offsetX;
		}
		if( typeof ig_.layerY == "undefined" ) {
			ig_.layerY = ig_.offsetY;
		}
		if( typeof ig_.which == "undefined" ) {
			ig_.which = ig_.button;
		}
		return ig_;
	}
};

var DragDrop = Class.create();
DragDrop.prototype = {
	initialize: function(elementHeader_id , element_id){
		var element = document.getElementById(element_id);
		var elementHeader = document.getElementById(elementHeader_id);
		this._dragStart = ((typeof this.start_Drag == "function") ? this.start_Drag : start_Drag);
		this._drag = ((typeof this.when_Drag == "function") ? this.when_Drag : when_Drag);
		this._dragEnd = ((typeof this.end_Drag == "function") ? this.end_Drag : end_Drag);
		this._afterDrag = ((typeof this.after_Drag == "function") ? this.after_Drag : after_Drag);
		this.isDragging = false;
		this.elm = element;
		this.header = $(elementHeader.id);
		this.hasIFrame = this.elm.getElementsByTagName("IFRAME").length > 0;
		if( this.header) {
			this.header.style.cursor = "move";
			Drag.init( this.header, this.elm);
			this.elm.onDragStart = this._dragStart.bind(this);
			this.elm.onDrag = this._drag.bind(this);
			this.elm.onDragEnd = this._dragEnd.bind(this);
		}
	}
};

var DragUtil = new Object();
// 获得浏览器信息
DragUtil.getUserAgent = navigator.userAgent;
DragUtil.isGecko = DragUtil.getUserAgent.indexOf("Gecko") != -1;
DragUtil.isOpera = DragUtil.getUserAgent.indexOf("Opera") != -1;
// 计算每个可拖拽的元素的坐标
DragUtil.reCalculate = function(el) {
	for( var i = 0 ; i < DragUtil.dragArray.length; i++ ) {
		var ele = DragUtil.dragArray[i];
		var position = Position.positionedOffset(ele.elm);
		ele.elm.pagePosLeft = position[0];
		ele.elm.pagePosTop = position[1];
	}

};
// 拖动元素时显示的占位框
DragUtil.ghostElement = null ;
DragUtil.getGhostElement = function(){
	if(!DragUtil.ghostElement){
		DragUtil.ghostElement = document.createElement("DIV");
		DragUtil.ghostElement.className = "modbox";
		DragUtil.ghostElement.style.border = "2px dashed #aaa";
		DragUtil.ghostElement.innerHTML = "&nbsp;";
	}
	return DragUtil.ghostElement;
};
DragUtil.getSortIndex = function(){
	//var col_array = [ 'col_1' , 'col_2' , 'col_3'];
	var col_array = new Array();
	var j=0;
	for(var i=0;i<6;i++){
		j = i+1;
		if(document.getElementById('col_'+j) != null){
			col_array[i] = 'col_'+j;
		}
	}
	
	//alert(col_array.toString());
	var sortIndex = '';
	for(var i = 0; i < col_array.length ; i++){
		//sortIndex += col_array[i] + ":";
		var b=false;
		var childs = document.getElementsByClassName('drag_div' , col_array[i]);
		for(var j = 0 ; j < childs.length ; j++){
			if(!Element.hasClassName(childs[j] , 'no_drag')){
				//sortIndex += childs[j].id + ',';
				sortIndex += childs[j].id.replace('drag_','') + ',';
				b = true;
			}
		}
		if(b)
			sortIndex = sortIndex.substring(0,sortIndex.length-1);
		sortIndex += ";";
	}
	sortIndex = sortIndex.substring(0,sortIndex.length-1);
	return sortIndex;
}


// 初始化所有可拖拽的元素，依靠 className 来确定是否可拖拽，可拖拽的部分的 id 为该元素 id 加上 _h
var initDrag = function() {
	
	var tmpElements = document.getElementsByClassName('drag_div');
	DragUtil.dragArray = new Array();

	for(var i = 0 ; i < tmpElements.length ; i++){
		var tmpElement = tmpElements[i];
		var tmpElementId = tmpElement.id;
		var tmpHeaderElementId = tmpElement.id + '_h';
		DragUtil.dragArray[i] = new DragDrop(tmpHeaderElementId , tmpElementId);
	}

};

// 开始拖拽
function start_Drag(){
	DragUtil.reCalculate(this);	// 重新计算所有可拖拽元素的位置
	this.origNextSibling = this.elm.nextSibling;
	var _ghostElement = DragUtil.getGhostElement();
	var offH = this.elm.offsetHeight;
	if(DragUtil.isGecko){	// 修正 Gecko 引擎的怪癖
		offH -= parseInt(_ghostElement.style.borderTopWidth)  *   2 ;
	}
	var offW = this.elm.offsetWidth;
	var position = Position.positionedOffset(this.elm);
	var offLeft = position[0];
	var offTop = position[1];
	// 在元素的前面插入占位虚线框
	_ghostElement.style.height = offH + "px";
	this.elm.parentNode.insertBefore(_ghostElement,  this .elm.nextSibling);
	// 设置元素样式属性
	this.elm.style.width = offW + "px";
	this.elm.style.position = "absolute";
	this.elm.style.zIndex = 100;
	this.elm.style.left = offLeft + "px";
	this.elm.style.top = offTop + "px";
	this.isDragging = false;
	return false;
}

// 拖动时触发这个函数（每次鼠标坐标变化时）
function when_Drag(clientX , clientY){
	if (!this.isDragging){	// 第一次移动鼠标，设置它的样式
		this.elm.style.filter = "alpha(opacity=70)";
		this.elm.style.opacity = 0.7;
		this.isDragging = true;
	}
	// 计算离当前鼠标位置最近的可拖拽的元素，把该元素放到 found 变量中
	var found = null;
	var max_distance = 100000000;
	for(var i = 0 ; i < DragUtil.dragArray.length; i++) {
		var ele = DragUtil.dragArray[i];
		var distance = Math.sqrt(Math.pow(clientX - ele.elm.pagePosLeft, 2 ) + Math.pow(clientY - ele.elm.pagePosTop, 2 ));
		if(ele == this ) {
			continue;
		}
		if(isNaN(distance)){
			continue;
		}
		if(distance < max_distance){
			max_distance = distance;
			found = ele;
		}
	}
	// 把虚线框插到 found 元素的前面
	var _ghostElement = DragUtil.getGhostElement();
	if(found != null && _ghostElement.nextSibling != found.elm) {
		found.elm.parentNode.insertBefore(_ghostElement, found.elm);
		if(DragUtil.isOpera){	// Opera 的毛病
			document.body.style.display = "none";
			document.body.style.display = "";
		}
	}
}
// 结束拖拽
function end_Drag(){
	if(this._afterDrag()){
		// 在这可以做一些拖拽成功后的事，比如 Ajax 通知服务器端修改坐标，以便下次用户进来时位置不变
		var str = DragUtil.getSortIndex();
		var par = 'Param=SaveOrder&Orders='+str+'&BlockType='+_blockType+"&"+_params;
		saveDrag('/CommonPages/Data/HomeData.aspx', par);
	}
	return true;
}

function saveDrag(url,par){
	queryString = par;
	new Ajax.Request
	(
		url,
		{
			method: "post",	
			onSuccess : function(resp)
						{
							//alert(resp.responseText)
							
						},
			onFailure : function()
						{
							alert("保存布局出错！");
						},
			parameters : queryString
		}
	);

}

// 结束拖拽时调用的函数
function after_Drag(){
	var returnValue = false;
	// 把拖动的元素的样式回复到原来的状态
	this.elm.style.position = "";
	this.elm.style.top = "";
	this.elm.style.left = "";
	this.elm.style.width = "";
	this.elm.style.zIndex = "";
	this.elm.style.filter = "";
	this.elm.style.opacity = "";
	// 在虚线框的地方插入拖动的这个元素
	var ele = DragUtil.getGhostElement();
	if(ele.nextSibling != this.origNextSibling) {
		ele.parentNode.insertBefore( this.elm, ele.nextSibling);
		returnValue = true;
	}
	// 删除虚线框
	ele.parentNode.removeChild(ele);
	if(DragUtil.isOpera) {
		document.body.style.display = "none";
		document.body.style.display = "" ;
	}
	return returnValue;
}