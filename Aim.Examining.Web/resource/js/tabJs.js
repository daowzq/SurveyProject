(function($){
	$.fn.extend({
		Tabs:function(options){
			// 处理参数
			options = $.extend({
				event : 'mouseover',	//事件类型  
				timeout : 0,			//设置事件延迟
				auto : 0,				//多少秒自动切换一次  
				callback : null			//回调函数
			}, options);
			
			var self = $(this),
				tabBox = self.find( '.tab_box' ).children( 'div' ),
				menu = self.find( '.tab_menu' ),
				items = menu.find( '.limenu' ),
				timer;
				
			var tabHandle = function( elem ){
					elem.siblings( '.limenu' )
						.removeClass( 'cur' )
						.end()
						.addClass( 'cur' );
						
					tabBox.siblings( 'div' )
						.addClass( 'hide' )
						.end()
						.eq( elem.index() )
						.removeClass( 'hide' );
				},
					
				delay = function( elem, time ){
					time ? setTimeout(function(){ tabHandle( elem ); }, time) : tabHandle( elem );
				},
				
				start = function(){
					if( !options.auto ) return;
					timer = setInterval( autoRun, options.auto );
				},
				
				autoRun = function(){
					var current = menu.find( '.cur' ),
						firstItem = items.eq(0),
						len = items.length,
						index = current.index() + 1,
						item = index === len ? firstItem : current.next( '.limenu' ),
						i = index === len ? 0 : index;
					
					current.removeClass( 'cur' );
					item.addClass( 'cur' );
					
					tabBox.siblings( 'div' )
						.addClass( 'hide' )
						.end()
						.eq(i)
						.removeClass( 'hide' );
				};
							
			items.bind( options.event, function(){
				delay( $(this), options.timeout );
				if( options.callback ){
					options.callback( self );
				}
			});
			
			if( options.auto ){
				start();
				self.hover(function(){
					clearInterval( timer );
					timer = undefined;
				},function(){
					start();
				});
			}
			
			return this;
		}
	});
})(jQuery);

//范例
//<div class="tabs">
//			<ul class="tab_menu">
//				<li class="current">111</li>
//				<li>444</li>
//				<li>555</li>
//			</ul>
//			<div class="tab_box">
//				<div>1c</div>
//				<div class="hide">2c</div>
//				<div class="hide">3c</div>
//			</div>
//</div>

$(function() {
	$("#tabox_1").Tabs({auto : 3000, event : 'click'}); 
	$("#tabbox_2").Tabs({auto : 0, event : 'click'}); 
	$("#tabbox_3").Tabs({auto : 0, event : 'click'}); 
	$("#tabbox_4").Tabs({auto : 0, event : 'click'}); 
});

