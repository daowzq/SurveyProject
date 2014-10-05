$(function() {
	$("#navUlWrap .tni-bg").click(function() {
		$(this).addClass("cur").siblings().removeClass("cur")
	});
	
	$(".closetab").click(function() {
		if ( $("#navUlWrap .tni-bg").length > 1) {
		  $(this).parent().parent().remove(); 
		   $("#navUlWrap .tni-bg:first-child").trigger("click")
		} else {
			//alert("没得移")
		}
		scrollbar();
    });
	

});

window.onload=window.onresize=function() { scrollbar() }
var ulw,ulin,ulscalc;
function scrollbar() {
	var thisInUl = $("#navUlWrap");
	var thisOutWrap = $("#navUlWraphide");
	ulw = thisOutWrap.width();
	ulin = thisInUl.outerWidth();
	ulscalc  = ulin - ulw;
	if (  ulscalc > 0 ) {
		//alert(ulscalc)
		$("a.prev").bind("click",function() {
			if ( thisInUl.css("marginLeft") < "0px" ) {
				thisInUl.animate({marginLeft:"0px"})
			}
		});
		$("a.next").bind("click",function() {
			if ( thisInUl.css("marginLeft") >= "0px" ) {
				thisInUl.animate({marginLeft:"-" + ulscalc + "px"})
			}
		});
	} else {
		$("a.next").unbind("click");
		thisInUl.animate({marginLeft:"0px"})
	};
};
