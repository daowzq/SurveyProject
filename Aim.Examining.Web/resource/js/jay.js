var winHeight, 
	sideHeight,
	$this_1,
	winChi;
$(function() {
	//日历区域的上下伸缩
	$("#toggleRili").click(function() {
       var riliArea = $("div.rili-dataArea"), 
	   		tabbox4= $("#tabbox_4"),
			tablay = tabbox4.find("div.layers");
		if ( riliArea.is(":visible")) {
			tablay.animate({height: "+=" + riliArea.height()},"fast")
			riliArea.slideUp("fast");
			
		} else {
			tablay.animate({height: "-=" + riliArea.height()},"fast")
			riliArea.slideDown("fast");
		}
	  
    });
	
	if ( document.getElementById("weah") ) {
		$( "#weah" ).draggable({containment: "parent"});
		$( "#weah .closewea" ).click(function() {
            $(this).fadeOut();
			$( "#weah .wf-3" ).fadeOut();
			$( "#weah .wasun" ).addClass("wsmin",300);
			$( "#weah .wf-1" ).addClass("wf-1min",300);
			$( "#weah .wf-2" ).addClass("wf-2min",300);
			$( "#weah .wf-4" ).addClass("wf-4min",300);
			$( "#weah" ).draggable("destroy");
			$( "#weah" ).removeAttr("style");
			$( "#weah").delay(500).addClass("wapdown",300)
			return false;
        });
		$("#weah").click(function() {
			if ( $(this).hasClass("wapdown")) {
				$( "#weah .closewea" ).show(0);
				$( "#weah .wf-3" ).fadeIn();
				$( "#weah .wasun" ).removeClass("wsmin",300);
				$( "#weah .wf-1" ).removeClass("wf-1min",300);
				$( "#weah .wf-2" ).removeClass("wf-2min",300);
				$( "#weah .wf-4" ).removeClass("wf-4min",300);
				$( "#weah").delay(500).removeClass("wapdown",300)
				$( "#weah" ).draggable({containment: "parent"});
			}
        });
	}
	
	if ( $("div.EnabledMinbtn").length > 0 ) {
		$("div.EnabledMinbtn a.minBtn").click(function() {
			var slideArea = $(this).parent().parent().parent().find(".tabbox");
			if (slideArea.is(":visible")) {
				slideArea.slideUp("fast");
				$(this).html("+");
			} else {
				slideArea.slideDown("fast");
				$(this).html("-");
			}
			return false;
        });
	};
	
	if ( document.getElementById("sideBarShow") ) {
		$( '#sideBarShow' ).cycle({
			fx:"scrollHorz",
			pager:".siderpaperR em"
		});
	};
	
	
	if ( document.getElementById("sideBar") ) {
		$("#sideBar .sib-icons").click(function() {
			$(this).addClass("sibcur").siblings().removeClass("sibcur")
		});
	};


	if ( document.getElementById("useithems") ) {
		$(".cenitems").click(function() {
			$(this).addClass("cur").siblings().removeClass("cur")
		});
	};
	
	$( ".rili-dataArea" ).datepicker({
		showOtherMonths: true,
		selectOtherMonths: true
		
	});
	
	
	$("#sideBar").bind({ 
		mouseenter:function() {
			$this_1 = $(this)
			$this_1.stop(true).animate({left:["-30px",'easeOutElastic']});
		},
		mouseleave:function() {
			sideBack()
		}
	});
	
	function sideBack() {
		$this_1.delay(600).animate({left:["-106px",'easeInOutBack']});
	}
	$("#locksidebar").click(function() {
		if ( $(this).hasClass("locked") ) {
			$("#sideBar").bind("mouseleave", function() { sideBack() });
			$(this).removeClass("locked").html("锁定导航");
		} else {
			$("#sideBar").unbind("mouseleave")
			$(this).addClass("locked").html("解锁导航");
		}
	});
	
});

window.onload=window.onresize=window.onclick=function() {
	dochei();
}

function dochei() {
	winChi =   document.documentElement.clientHeight;
	document.getElementById("content").style.minHeight =  winChi - 140 + "px"
	winHeight = document.body.clientHeight - 120;
	sideHeight = document.getElementById("sideBar").offsetHeight;
	document.getElementById("sideBar").style.height = winHeight + "px";
}

var appendTimeout;
function appendText() {
	clearTimeout(appendTimeout);
	appendTimeout = setTimeout(function() {
			$("div.rili-dataArea a").filter(function(index){
				return $(this).text() == '6';
			}).parent().addClass("hasProgram");
	},1);
}
