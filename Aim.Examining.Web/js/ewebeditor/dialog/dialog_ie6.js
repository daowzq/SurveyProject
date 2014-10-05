/*
*######################################
* eWebEditor v7.3 - Advanced online web based WYSIWYG HTML editor.
* Copyright (c) 2003-2011 eWebSoft.com
*
* For further information go to http://www.ewebeditor.net/
* This copyright notice MUST stay intact for use.
*######################################
*/

(function(){var zH=window.pL=function(){var eP=window.document.body;if(eP.clientWidth==0||eP.clientHeight==0){return false;}for(var i=0;i<eP.childNodes.length;i++){var child=eP.childNodes[i];switch(child.className){case "tr":child.style.left=Math.max(0,eP.clientWidth-tr.clientWidth);break;case "tc":child.style.width=Math.max(0,eP.clientWidth-tl.clientWidth-tr.clientWidth);break;case "ml":child.style.height=Math.max(0,eP.clientHeight-tl.clientHeight-bl.clientHeight);break;case "mr":child.style.left=Math.max(0,eP.clientWidth-mr.clientWidth);child.style.height=Math.max(0,eP.clientHeight-tr.clientHeight-br.clientHeight);break;case "mc":child.style.width=Math.max(0,eP.clientWidth-ml.clientWidth-mr.clientWidth);child.style.height=Math.max(0,eP.clientHeight-TitleArea.clientHeight-bc.clientHeight);break;case "bl":child.style.top=Math.max(0,eP.clientHeight-bl.clientHeight);break;case "br":child.style.left=Math.max(0,eP.clientWidth-br.clientWidth);child.style.top=Math.max(0,eP.clientHeight-br.clientHeight);break;case "bc":child.style.width=Math.max(0,eP.clientWidth-bl.clientWidth-br.clientWidth);child.style.top=Math.max(0,eP.clientHeight-bc.clientHeight);break;}}return true;};window.wj=function(){if(!window.pL()){window.setTimeout(window.wj,1);return;}dm.oA(window.frameElement);};var xr=function(){this.className="TitleCloseButtonHover";};var xp=function(){this.className="TitleCloseButton";};var yR=function(){var vl=document.getElementById("TitleCloseButton");vl.onmouseover=xr;vl.onmouseout=xp;};var onLoad=function(){yR();window.detachEvent("onload",onLoad);};window.attachEvent("onload",onLoad);})();