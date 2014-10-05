var dochei, winHeight, conHeight;
window.onload = window.onresize = function() { res() }
function res() {
    winHeight = document.documentElement.clientHeight; //获取windows高度
    if (winHeight > 0) {
        conHeight = winHeight - 47 + "px";
        document.getElementById("gethei").style.height = conHeight
    }
}
$(function() {
    $("#gethei").niceScroll()
})