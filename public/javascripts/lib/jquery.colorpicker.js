/*
 * Copyright (C) 2009 Cognifide
 * 
 * This file is part of Taskboard.
 * 
 * Taskboard is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Taskboard is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with Taskboard. If not, see <http://www.gnu.org/licenses/>.
 */

/** 
 * This is based on: 
 * http://www.syronex.com/software/jquery-color-picker
 * (C) 2008 Syronex / J.M. Rosengard
 */

(function($) {
	$.colorPicker = function(options) {
		// Defaults
		var defaults = {
			new_colors: [ "#EE0000", "#FF8800", "#FFDD22", "#DDDD22", "#55CC22", "#00DDFF",       //"#33FF88", "#777777",
						  "#EE6666", "#FFBB77", "#FFEE88", "#DDDD88", "#99DD77", "#77DDEE",       //"#88FFBB", "#AAAAAA",
						  "#2288FF", "#4466DD", "#8855FF", "#BB44DD", "#FF00AA", "#888888",
						  "#88BBEE", "#99AADD", "#BB99EE", "#CC99DD", "#EE77BB", "#EEEEEE"
			],
			
			colors : new Array(
				"#FFFFFF", "#EEEEEE", "#FFFF88", "#FF7400", "#CDEB8B", "#6BBA70",
				"#006E2E", "#C3D9FF", "#4096EE", "#356AA0", "#FF0096", "#B02B2C", 
				"#000000"
				),
			defaultColor: '#EEEEEE',
			click: function(color){},
			preview : function(color){},
			top : 'auto',
			left : 'auto',
			right : 'auto',
			bottom : 'auto',
			id : 'colorPicker',
			columns : 0
		};
		
		var settings = $.extend({}, defaults, options);
		
		// hide existing picker
		if($('#' + settings.id).exists()) $('#' + settings.id).fadeOut("fast", function(){ $(this).remove() });

		var picker = $('<div id="' + settings.id + '"></div>');
		var colors = $('<ol></ol>').appendTo(picker);

		$.each(settings.colors, function(i, color){
			$('<li></li>').addClass('color').addClass(color.substr(1)).data('color', color).css({ backgroundColor : color }).appendTo(colors);
		});

		colors.children().click(function(){
			$('#' + settings.id + ' .color').removeClass('check').removeClass('checkwht').removeClass('checkblk');
			$(this).addClass('check').addClass(isdark($(this).data('color')) ? 'checkwht' : 'checkblk');
			settings.click($(this).data('color'));
			$('#' + settings.id).fadeOut("fast", function(){ $(this).remove() });
		});
			
		// Simulate click for defaultColor
		picker.appendTo($('body'));
		picker.children('ol')
				.width( (colors.children().width() + 4) * (settings.columns || colors.children().length) )
				.end()
			.css( { top : settings.top, left : settings.left, bottom : settings.bottom, right : settings.right })
			.find('.' + settings.defaultColor.substr(1)).each(function(){
				$(this).addClass('check').addClass(isdark($(this).data('color')) ? 'checkwht' : 'checkblk');
			});

		$('body').one('click', function(ev){
			$('#' + settings.id).fadeOut("fast", function(){ $(this).remove() });
		});
	};

})(jQuery);

/**
 * Return true if color is dark, false otherwise.
 * (C) 2008 Syronex / J.M. Rosengard
 **/
function isdark(color){
	var colr = parseInt(color.substr(1), 16);
	return (colr >>> 16) // R
		+ ((colr >>> 8) & 0x00ff) // G 
		+ (colr & 0x0000ff) // B
		< 500;
}
