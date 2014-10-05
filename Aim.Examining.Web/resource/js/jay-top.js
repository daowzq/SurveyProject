$(function() {
	if ( document.getElementById("hrb") ) {
		$("#hrb .meunIthems").click(function() {
			$(this).addClass("cur").siblings().removeClass("cur")
		});
	};
	
	$("#hrname").click(function() {
		$(".changeC",top.document).show();
	});
	
	$("a",top.document).click(function() {
        var	thisHTML = $(this).html();
		$("#hrname").html(thisHTML)
    });
});