var dochei,winHeight,conHeight;
window.onload = window.onresize = function() { res() }
function res() {
	winHeight = document.documentElement.clientHeight; //获取windows高度
	conHeight = winHeight - 15 + "px";
	document.getElementById("mainGetHei").style.height = conHeight
}