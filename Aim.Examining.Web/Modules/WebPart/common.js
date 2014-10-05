/**
 * Filename:       common.js
 * Function:       include public js function.
 * Encoding:       utf-8
 * Author:         xiulin.liu www.weaver.com.cn
 * Date:           2007-1-8
 * Version:        1.x
 * Teems Version:  1.x
*/

//引用js/css文件;
function include(path,type,title){
	var s,i,t;
	if(arguments.length < 1){
		return ;
	}
	if(arguments.length == 1){
		type = "js";
	}
	switch(type.toLowerCase()){
		case "css":
				t = document.getElementsByTagName("link");
				for(i=0;i<t.length;i++){
					if(t[i].href && t[i].href.indexOf(path)!=-1){
						return;
					}
				}
				s=document.createElement("link");
				s.rel="alternate stylesheet";
				s.type="text/css";
				s.href=path;
				s.title=title;
				s.disabled=false;
				break;
		case "js":
		case "javascript":
		default:
				t = document.getElementsByTagName("script");
				for(i=0;i<t.length;i++){
					if(t[i].src && t[i].src.indexOf(path)!=-1){
						return;
					}
				}
				s=document.createElement("script");
				s.type="text/javascript";
				s.src=path;
			break;
	}
	var h=document.getElementsByTagName("head")[0];
	h.appendChild(s);
}
//字符处理;
//去左右空格; 
function trim(s){
 	return rtrim(ltrim(s)); 
}
//去左空格; 
function ltrim(s){
 	return s.replace( /^\s*/, ""); 
} 
//去右空格; 
function rtrim(s){ 
 	return s.replace( /\s*$/, ""); 
}
//验证信息;
//空字符值; 
function isEmpty(s){
	s = trim(s); 
	return s.length == 0; 
}
//Email;
function isEmail(s){
	s = trim(s); 
 	var p = /^[_\.0-9a-z-]+@([0-9a-z][0-9a-z-]+\.){1,4}[a-z]{2,3}$/i; 
 	return p.test(s);
}
//数字; 
function isNumber(s){
	return !isNaN(s); 
}
//颜色值; 
function isColor(s){ 
	s = trim(s); 
	if (s.length !=7) return false; 
	return s.search(/\#[a-fA-F0-9]{6}/) != -1; 
}
//手机号码; 
function isMobile(s){ 
	s = trim(s); 
	var p = /13\d{9}/; 
	return p.test(s);
}
//身份证;
function isCard(s){ 
	s = trim(s); 
	var p = /^\d{15}(\d{2}[xX0-9])?$/; 
	return p.test(s);
}
//URL;
function isURL(s){
	s = trim(s).toLowerCase();
	var p = /^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/;
	return p.test(s);
}
//Phone;
function isPhone(s){
	s = trim(s);
	var p = /^((\(\d{3}\))|(\d{3}\-))?(\(0\d{2,3}\)|0\d{2,3}-)?[1-9]\d{6,7}$/;
	return p.test(s);
}
//Zip;
function isZip(s){
	s = trim(s);
	var p = /^[1-9]\d{5}$/;
	return p.test(s);
}
//Double;
function isDouble(s){
	s = trim(s);
	var p = /^[-\+]?\d+(\.\d+)?$/;
	return p.test(s);
}
//Integer;
function isInteger(s){
	s = trim(s);
	var p = /^[-\+]?\d+$/;
	return p.test(s);
}
//English;
function isEnglish(s){
	s = trim(s);
	var p = /^[A-Za-z]+$/;
	return p.test(s);
}
//中文;
function isChinese(s){
	s = trim(s);
	var p = /^[\u0391-\uFFE5]+$/;
	return p.test(s);
}
//双字节
function isDoubleChar(s){
	var p = /^[^\x00-\xff]+$/;
	return p.test(s);
}
//含有中文字符
function hasChineseChar(s){
	var p = /[^\x00-\xff]/;
	return p.test(s);
}
//特殊符号(包括中文字符)
function hasAccountChar(s){
	var p = /^[a-zA-Z0-9][a-zA-Z0-9_-]{0,15}$/;
	return p.test(s);
}
function limitLen(s,Min,Max){
	s=trim(s);
	if(s=="") return false;
	if((s.length<Min)||(s.length>Max))
		return false;
	else
		return true;
}

//检查日期是否正确
function checkDate(pFMT,pDate) 
{ 
	var ResultOK = null 
	var RegDateDot = /\d{4}\.{1}\d{1,2}\.{1}\d{1,2}/ 
	var RegDateLine = /\d{4}-{1}\d{1,2}-{1}\d{1,2}/ 
	
	switch (pFMT) 
	{ 
		case 1: 
			ResultOK = RegDateDot.test(pDate) 
			break 
		case 2: 
			ResultOK = RegDateLine.test(pDate) 
			break 
		default:
			ResultOK = RegDateDot.test(pDate) 
			break 
	}
	
	if(!ResultOK) 
	{ 
	   return false 
	} 
	
	var mYear = 0,mMonth = 0,mDay = 0 
	var iPos1 = 0,iPos2 = 0 
	var sDate = pDate.toString() 
	var mSepChar = ((pFMT == 1) ? ".":"-") 
	
	var MonthDays = new Array(null,31,28,31,30,31,30,31,31,30,31,30,31) 
	
	iPos1 = sDate.indexOf(mSepChar) 
	iPos2 = sDate.indexOf(mSepChar,iPos1+1) 
	
	mYear = sDate.substring(0,iPos1) 
	mMonth = sDate.substring(iPos1+1,iPos2) 
	mDay = sDate.substr(iPos2+1) 
	
	if(mYear <= 0 || mYear > 9999) 
	{ 
		return false 
	} 
	if (mYear.length > 4)
	{
		return false 
	}

	mMonth = parseInt(mMonth,10);
	
	if(mMonth <= 0 || mMonth > 12) 
	{ 
		return false 
	}
	if (mMonth.length > 2)
	{
		return false 
	}
	
	var RightDay = 0 
	if(mMonth == 2) 
		RightDay = (((mYear%4 == 0) && (mYear%100 != 0) || (mYear%400 == 0))? 29: 28) 
	else {
		RightDay = MonthDays[mMonth];
	}

	if (mDay.length > 2)
	{
		return false 
	}
	
	if(mDay <= 0 || mDay > RightDay) 
	{ 
		return false 
	} 
	
	return true 
} 

function checkTime(n,t){
       var pattern = /^(\d|([0-1]\d)|(2[0-4])):(\d|([0-5]\d))$/;
       if( t != "" && !pattern.test(t)) {
              return false;
       }
	   return dcheckTime(t);
}


//check time
function dcheckTime(t) {

	var x = ":";
	var p = "his";
	var a = t.split(x);
	var sh = a[p.indexOf("h")];
	var si = a[p.indexOf("i")];

	var h = parseInt(sh,10);
	var i = parseInt(si,10);

	if (h==24 && i > 0){
		return false;
	}

	return true;
}

function betterDate(strDateStart,strDateEnd){
   var strSeparator = "-"; 
   var strDateArrayStart;
   var strDateArrayEnd;
   var intDay
   strDateArrayStart = strDateStart.split(strSeparator);
   strDateArrayEnd = strDateEnd.split(strSeparator);
   var strDateS = new Date(strDateArrayStart[0] + "/" + strDateArrayStart[1] + "/" + strDateArrayStart[2]);
   var strDateE = new Date(strDateArrayEnd[0] + "/" + strDateArrayEnd[1] + "/" + strDateArrayEnd[2]);
   intDay = (strDateS-strDateE)/(1000*3600*24)
   return intDay
}


//功能;
//延时事件;
function setDeferEvent(type,action,time){
	if (trim(time).length == 0) time = 1;
	if (typeof(time)!="number") time = 1;
	
	switch(type.toLowerCase()){
		case "go":
			window.setTimeout("window.location='"+ action +"'",time);
			break;
		case "alert":
			window.setTimeout("alert('"+ action +"')",time);
			break;
		case "js":
		case "javascript":
			window.setTimeout("'"+ action.toString() +"'",time);
			break;
		default:
			alert("Nothing will do!");
			break
	}		
}
/*
function addLoadListener(handler){
	if (typeof window.addEventListener != 'undefined')
		window.addEventListener('load', handler, false);
	else if (typeof document.addEventListener != 'undefined')
		document.addEventListener('load', handler, false);
	else if (typeof window.attachEvent != 'undefined')
		window.attachEvent('onload', handler);
};
function addEventListener(element, eventType, handler, capture)
{
	try
	{
		if (element.addEventListener)
			element.addEventListener(eventType, handler, capture);
		else if (element.attachEvent)
			element.attachEvent("on" + eventType, handler);
	}
	catch (e) {}
};

function removeEventListener(element, eventType, handler, capture)
{
	try
	{
		if (element.removeEventListener)
			element.removeEventListener(eventType, handler, capture);
		else if (element.detachEvent)
			element.detachEvent("on" + eventType, handler);
	}
	catch (e) {}
};
*/
//Image;
function preloadImages(){
	var d = document;
	if(d.images){
		if(!d.p_i_a) d.p_i_a = new Array();
		var i,j=d.p_i_a.length,a=arguments;
		for(i=0;i<a.length;i++){
			d.p_i_a[j]= new Image();
			d.p_i_a[j++].src = a[i];
		}
	}
}
//Ajax功能; prototype.js用法
function loadAjaxElement(e,u,p,f,l){
	if(arguments.length < 3){
		return ;
	}
	o = $(e);
	o.innerHTML = l;
	p = $H(p).toQueryString();
	new Ajax.Updater(					 
                    {success: e},
                    u,
                    {method: 'get', parameters: p, onFailure: f});
}
function loadAjaxData(u,p,s,f){
	if(arguments.length < 3){
		return ;
	}
	p = $H(p).toQueryString();
	new Ajax.Request(					 
                    u,
                    {method: 'get', parameters: p, onSuccess:s,onFailure: f});
}
function sendAjaxElement(e,u,p,f,l){
	if(arguments.length < 3){
		return ;
	}
	o = $(e);
	o.innerHTML = l;
	p = $H(p).toQueryString();
	new Ajax.Updater(					 
                    {success: e},
                    u,
                    {method: 'post', parameters: p, onFailure: f});
}
function sendAjaxData(u,p,s,f){
	if(arguments.length < 3){
		return ;
	}
	p = $H(p).toQueryString();
	new Ajax.Request(					 
                    u,
                    {method: 'post', parameters: p, onSuccess:s,onFailure: f});
}

//提醒输入
function checkNoSpec(id,v){
	if (trim(v) != ""){
		$(id).className = "notegray";
	}
	else{
		$(id).className = "notegreen";
	}
	if ($(id).focus == false){
		$(id).className = "notegray";
	}
}

//xmlHttp 
var prefixes = ["MSXML2.XmlHttp","Microsoft.XmlHttp","MSXML3.XmlHttp", "MSXML.XmlHttp"];

function getDomObject(){
	for (var i = 0; i < prefixes.length; i++) {
		try{xmlHttp = new ActiveXObject(prefixes[i]);}catch(ex){};
	}
	return xmlHttp;
}

var loadStr = '<img src="/images/loading01.gif"> Loading...';

function showResult(strUrl,objExisted,objDivResult){
	objDivResult.innerHTML = loadStr;
	var xmlHttp = getDomObject();
	xmlHttp.open("GET",strUrl, true);
	xmlHttp.onreadystatechange = function () {	
		switch (xmlHttp.readyState) {		
           case 3 : 
				objDivResult.innerHTML = loadStr;
		        break;
		   case 4 :  
			   if (xmlHttp.status == 200){
                    objDivResult.innerHTML = xmlHttp.responseText; 
					objExisted.value = xmlHttp.responseText;
		       }
		} 
	}		
	xmlHttp.setRequestHeader("Content-Type","text/xml")	
	xmlHttp.send(null);	
}

function showHiddenInfo(tid,imgid,openimg,closeimg){
	var objTid = $(tid);
	var objImgid = $(imgid);
	if (objTid.style.display == ''){
		hiddenInfo(tid,imgid,openimg);
	}
	else{
		showInfo(tid,imgid,closeimg);
	}
}

function showInfo(tid,imgid,closeimg){
	var objTid = $(tid);
	var objImgid = $(imgid);
	if (typeof(imgid) == 'object'){
		objImgid = imgid;
	}
	objTid.style.display = '';
	if(closeimg == "" || typeof(closeimg) == "undefined"){
		objImgid.src = "/images/arrowdown.gif"
		
	}
	else{
		objImgid.src = closeimg;
	}
}

function hiddenInfo(tid,imgid,openimg){
	var objTid = $(tid);
	var objImgid = $(imgid);
	if (typeof(imgid) == 'object'){
		objImgid = imgid;
	}
	objTid.style.display = 'none';

	if(openimg == "" || typeof(openimg) == "undefined"){
		objImgid.src = "/images/arrowup.gif";
	}
	else{
		objImgid.src = openimg;
	}
}

function doPage(url,idload,idmain){
	var objload = $(idload);
	var objmain = $(idmain);
	objload.style.display = '';
	objload.innerHTML = loadStr;
	var xmlHttp = getDomObject();
	xmlHttp.open("GET",url, true);
	xmlHttp.onreadystatechange = function () {	
		switch (xmlHttp.readyState) {		
           case 3 : 
			    objload.style.display = '';
				objload.innerHTML = loadStr;
		        break;
		   case 4 :  
			   if (xmlHttp.status == 200){
					objload.innerHTML = "";
					objload.style.display = 'none';
                    objmain.innerHTML = xmlHttp.responseText; 
		       }

		} 
	}		
	xmlHttp.setRequestHeader("Content-Type","text/xml")	
	xmlHttp.send(null);	
}

function checkWarningFlag(id,imgid){
	var objID = $(id);
	var objImgid = $(imgid);
	if (objID.value != ""){
		objImgid.style.display = 'none'
	}
	else{
		objImgid.style.display = ''
	}
}

function saveData(url,objsave){
	objsave.style.display = '';
	var xmlHttp = getDomObject();
	xmlHttp.open("GET",url, true);
	xmlHttp.onreadystatechange = function () {	
		switch (xmlHttp.readyState) {		
           case 3 : 
				objsave.style.display = '';
		        break;
		   case 4 :  
			   if (xmlHttp.status == 200){
			   //	alert(xmlHttp.responseText);

                    objsave.style.display = 'none';
		       }
		} 
	}		
	xmlHttp.setRequestHeader("Content-Type","text/xml")	
	xmlHttp.send(null);	
}

function selectData(url,objselect){
	objselect.style.display = 'none';
	var xmlHttp = getDomObject();
	xmlHttp.open("GET",url, true);
	xmlHttp.onreadystatechange = function () {	
		switch (xmlHttp.readyState) {		
           case 3 : 
				objselect.style.display = 'none';
		        break;
		   case 4 :  
			   if (xmlHttp.status == 200){
					objselect.innerHTML = xmlHttp.responseText;
					if (objselect.innerHTML !=""){
						objselect.style.display = '';
					}
					else{
						objselect.style.display = 'none';
					}
		       }
		} 
	}		
	xmlHttp.setRequestHeader("Content-Type","text/xml")	
	xmlHttp.send(null);	
}

function GetCookieVal(offset){
	var endstr = document.cookie.indexOf (";", offset);
	if (endstr == -1)
	endstr = document.cookie.length;
	return unescape(document.cookie.substring(offset, endstr));
}

function SetCookie(name, value ,expiresDate){
	var expdate = new Date();
	var argv = SetCookie.arguments;
	var argc = SetCookie.arguments.length;
	var expires = (argc > 2) ? argv[2] : null;
	var path = (argc > 3) ? argv[3] : null;
	var domain = (argc > 4) ? argv[4] : null;
	var secure = (argc > 5) ? argv[5] : false;
	if(expiresDate!=null) expdate.setTime(expdate.getTime() + ( expiresDate * 1000 * 3600 * 24));
	document.cookie = name + "=" + escape (value) +((expiresDate == null) ? "" : ("; expires="+ expdate.toGMTString()))
	+((path == null) ? "" : ("; path=" + path)) +((domain == null) ? "" : ("; domain=" + domain))
	+((secure == true) ? "; secure" : "");
}

function DelCookie(name){
	var exp = new Date();
	exp.setTime (exp.getTime() - 1);
	var cval = GetCookie (name);
	document.cookie = name + "=" + cval + "; expires="+ exp.toGMTString();
}

function GetCookie(name){
	var arg = name + "=";
	var alen = arg.length;
	var clen = document.cookie.length;
	var i = 0;
	while (i < clen){
		var j = i + alen;
		if (document.cookie.substring(i, j) == arg)
		return GetCookieVal (j);
		i = document.cookie.indexOf(" ", i) + 1;
		if (i == 0) break;
	}
	return null;
}

function openWindow(url,w,h){
	w = w>0?w:210;
	h = h>0?h:350;
	th = "edge:raised;scroll:1;status:0;help:0;resizable:1;dialogWidth:"+w+"px;dialogHeight:"+h+"px;";
	window.showModalDialog(url,self,th);
}

function showOText(){
	Element.show('divsave');
	var objOtext = document.getElementById('otext');
	var objOtextImg = document.getElementById('imgotext');
	objOtext.innerHTML = "操作已成功";
	objOtext.style.color = "green";
	objOtextImg.src="/images/workflow/success.gif";
	setTimeout("hideOText()",2000);
}

function hideOText(){
	Element.hide('divsave');
	var objOtext = document.getElementById('otext');
	var objOtextImg = document.getElementById('imgotext');
	objOtextImg.src="/images/loading01.gif";
	objOtext.style.color = "black";
	objOtext.innerHTML = "加载中...";
	
}

function showNText(){
	Element.show('divnote');
	setTimeout("hideNText()",2000);
}

function hideNText(){
	Element.hide('divnote');
	
}

function LoadWindowUser(inputID,inputName,formName)
{
	  URL="/module/user_select_new/?inputID="+inputID+"&inputName="+inputName+"&formName="+formName;
	  loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	  loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
	  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:355px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}
//用户选择，单个 edit by sun 2007-12-19 
function LoadWindowUserSingle(inputID,inputName,formName)
{
	  URL="/module/user_select_single_new/?inputID="+inputID+"&inputName="+inputName+"&formName="+formName;
	  loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	  loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
	  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:355px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}


function LoadWindowPriv(inputID,inputName,formName)
{
	  URL="/module/priv_select_new/?inputID="+inputID+"&inputName="+inputName+"&formName="+formName;
	  loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	  loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
	  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:200px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}
//角色选择，单个 edit by sun 2007-12-19 
function LoadWindowPrivSingle(inputID,inputName,formName)
{
	  URL="/module/priv_select_single_new/?inputID="+inputID+"&inputName="+inputName+"&formName="+formName;
	  loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	  loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
	  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:200px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}

function LoadWindowDept(inputID,inputName,formName)
{
	  URL="/module/dept_select_new/?inputID="+inputID+"&inputName="+inputName+"&formName="+formName;
	  loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	  loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
	  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:355px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}
//部门选择，多个包括所有部门 edit by sun 2007-12-19
function LoadWindowDeptAll(inputID,inputName,formName)
{
	  URL="/module/dept_select_new_all/?inputID="+inputID+"&inputName="+inputName+"&formName="+formName;
	  loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	  loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
	  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:355px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}
//部门选择，单个 edit by sun 2007-12-19 
function LoadWindowDeptSingle(inputID,inputName,formName)
{
	  URL="/module/dept_select_single_new/?inputID="+inputID+"&inputName="+inputName+"&formName="+formName;
	  loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	  loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
	  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:355px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}

function openWindows(url){
	loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
  	//window.showModalDialog(url,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:700px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
	window.open (url, '', 'height=400, width=700, top, left, toolbar=no, menubar=no,scrollbars=yes, resizable=yes,location=no, status=1') 

}
//文档窗口
function openDocumentsWindows(url){
	var ScreenWidth = screen.availWidth	;
    var ScreenHeight = screen.availHeight ;
    var loc_x = (ScreenWidth - 500) / 2 ;
    var loc_y = (ScreenHeight - 500) / 2 ;
	//alert(loc_x);
	//loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
	//loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
  	//window.showModalDialog(url,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:700px;dialogHeight:400px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
	window.open (url, '', "top="+loc_y+", left="+loc_x+",height=600px, width=700px, toolbar=no, menubar=no,scrollbars=yes, resizable=yes,location=no, status=1") 

}
//获得宽高
function getObjInfoXY(o){
	var to=new Object();
	to.left=to.right=to.top=to.bottom=0;
	var o = document.getElementById(o);
	
	var twidth=o.offsetWidth;
	
	var theight=o.offsetHeight;
	while(o!=document.body){
		to.left+=o.offsetLeft;
		to.top+=o.offsetTop;
		o=o.offsetParent;
	}
	to.right=to.left+twidth;
	to.bottom=to.top+theight;
	return to;
}
//JS判断控制上传文件的大小
function limitUploadFile (from_name,file_name,max_size) {
if (document.getElementsByName(from_name)) {
	window.oldOnError = window.onerror;    
	window.onerror = function (err) {
		if (err.indexOf('utomation') != -1) {
		alert('没有访问文件的权限');        
		return true;      
		}else{ 
		return false;
		}};
	var	fileName =  document.getElementsByName(file_name)[0] ;
    var fso = new ActiveXObject('Scripting.FileSystemObject');
    var file = fso.GetFile(fileName.value);    
    window.onerror = window.oldOnError;
	file_size = Math.round(file.size/1024,2);
	if(file_size>max_size){
		//objFile.value = "";
		alert('你上传的文件超过规定大小！不能上传！');
		fileName.focus();
		fileName.select();
		return false;
	}
    return true; 
	}
}
//文档夹选择
function LoadWindowSelectFile(sortid,sortname,getwhat,filesort)
{
	//alert(filesort);
  URL="/module/document_file_select?sortid="+sortid+"&sortname="+sortname+"&getwhat="+getwhat+"&filesort="+filesort;
  //loc_x=document.body.scrollLeft+event.clientX-event.offsetX-100;
  //loc_y=document.body.scrollTop+event.clientY-event.offsetY+170;
   var ScreenWidth = screen.availWidth	;
   var ScreenHeight = screen.availHeight ;
   var loc_x = (ScreenWidth - 500) / 2 ;
   var loc_y = (ScreenHeight - 200) / 2 ;
  window.showModalDialog(URL,self,"edge:raised;scroll:0;status:0;help:0;resizable:1;dialogWidth:300px;dialogHeight:395px;dialogTop:"+loc_y+"px;dialogLeft:"+loc_x+"px");
}
//字符处理;
//去左右空格; 
function trim(s){
 	return rtrim(ltrim(s)); 
}
//去左空格; 
function ltrim(s){
 	return s.replace( /^\s*/, ""); 
} 
//去右空格; 
function rtrim(s){ 
 	return s.replace( /\s*$/, ""); 
}
document.write('<div style="display:none;position:absolute; visibility:show;left:0px;top:0px;padding:1px;background:#ffffff;border:1px solid #696969;width:120px;color:#666666;z-index: 9999;filter:alpha(opacity=80);" id="divsave"><table><tr><td><img src="/images/loading.gif" id="imgotext"></td> <td><span id="otext">加载中...</span></td></tr></table></div>');

document.write('<div style="display:none;position:absolute; visibility:show;left:0px;top:0px;padding:1px;background:#ffffff;border:1px solid #00BE00;width:120px;color:#666666;z-index: 9999;filter:alpha(opacity=100);" id="divnote"><table><tr><td><img src="/images/workflow/success.gif" id="imgntext"></td> <td><span id="ntext" style="color:green">保存成功</span></td></tr></table></div>');

