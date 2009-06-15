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

/*
 * Prototype utils.
 * Extending standard objects functionality
 * ====================================================
 */

/*
 * Simple trim method to String object
 */
String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, ''); };

/*
 * Returns the string with first letter in lower case
 */
String.prototype.lowerFirst = function() { return this.length ? this.charAt(0).toLowerCase() + this.substring(1, this.length) : this; };


/*
 * Returns the string transformed into one compatible with HTML class attribute.
 * All the whitespace characters are transformed into double underscores and all characters
 * that are not letters, numbers, underscores or dashes are transformed into single underscore.
 */
String.prototype.escapeHTML = function() {
	return this.replace(/&/g, "&amp;").replace(/>/g,"&gt;").replace(/</g,"&lt;");
};

/*
 * Returns the string transformed into one compatible with HTML class attribute.
 * All the whitespace characters are transformed into double underscores and all characters
 * that are not letters, numbers, underscores or dashes are transformed into single underscore.
 */
String.prototype.toClassName = function() {
	return this.replace(/\s/g, '__').replace(/[^A-Za-z0-9_\-]/g,'_');
};

/*
 * Sorts the array using given property as a key
 */
Array.prototype.sortBy = function(key) { 
	return this.sort(function(a,b){ return a[key] - b[key]; });
};

/*
 * Sorts the array using 'position' property as a key.
 * Useful for sorting cards and columns within a taskboard.
 */
Array.prototype.sortByPosition = function() { 
	return this.sortBy('position');
};

// TODO; test
Date.prototype.setISO8601 = function (string) {
	if(!string) return null;

	var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
		"(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
		"(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
	var d = string.match(new RegExp(regexp));
	var offset = 0;
	var date = new Date(d[1], 0, 1);

	if (d[3]) { date.setMonth(d[3] - 1); }
	if (d[5]) { date.setDate(d[5]); }
	if (d[7]) { date.setHours(d[7]); }
	if (d[8]) { date.setMinutes(d[8]); }
	if (d[10]) { date.setSeconds(d[10]); }
	if (d[12]) { date.setMilliseconds(Number("0." + d[12]) * 1000); }
	if (d[14]) {
		offset = (Number(d[16]) * 60) + Number(d[17]);
		offset *= ((d[15] == '-') ? 1 : -1);
	}

	offset -= date.getTimezoneOffset();
	time = (Number(date) + (offset * 60 * 1000));
	this.setTime(Number(time));
	return this;
};

/*
 * jQuery utils.
 * Some small useful jQuery plugins
 * ====================================================
 */

(function($) { // just to make sure $ is a jQuery

/*
 * Returns true if matched element exists
 */
$.fn.exists = function(){
	return $(this).length > 0;
};

/*
 * Returns sumarized width (outer width with margins) of all elements.
 */
$.fn.sumWidth = function(){
	var sum = 0;
	this.each(function(){ sum += $(this).outerWidth(true); });
	return sum;
};

/*
 * Returns sumarized height (outer height with margins) of all elements.
 */  
$.fn.sumHeight = function(){
	var sum = 0;
	this.each(function(){ sum += $(this).outerHeight(true); });
	return sum;
};

/*
 * Computes the maximum height of all the elements (as sum of children heights)
 * and expands all the elements to this height.
 *
 * @param options
 * @param options.offset   Offset in pixels to be added to max height (default = 0)
 * @param options.css      CSS attribute to be changed (default = min-height)
 */    
$.fn.equalHeight = function(options){
	var settings = {
		offset : 0,
		css    : "min-height"
	};

	if(options) {
		$.extend(settings, options);
	}

	var maxHeight = 0;
	var height;
	this.css(settings.css, "").each(function(i, el){
		height = $(el).height();
		if(maxHeight < height){
			maxHeight = height;
		}
	});
	return this.css(settings.css, maxHeight + settings.offset);
};

/*
 * Adds a rollover functionality for all images in the query.
 * Images names need to fit into naming convention:
 * '_on' for hover, '_off' for not hovered.
 *
 * TODO: add some options maybe?
 */
$.fn.rollover = function(){
	return this.filter('img').each(function(i, el){
		$(el).hover( function(){ $(this).attr("src", $(this).attr("src").split('_off').join('_on')); },
		             function(){ $(this).attr("src", $(this).attr("src").split('_on').join('_off')); } );
	});
};

$.tag = function(tagName, content, attrs){
	if((attrs == null) && (content) && (content.constructor == Object)){
		attrs = content;
		content = "";
	}
	var tagArray = ['<', tagName];
	for(var attr in attrs){
		tagArray.push(" ", attr == "className" ? "class" : attr, "=\"", attrs[attr], "\"");
	}
	tagArray.push(">", content, "</", tagName, ">");
	return tagArray.join("");
}

})(jQuery); // just to make sure $ was a jQuery
