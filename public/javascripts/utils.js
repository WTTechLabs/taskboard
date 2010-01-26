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
 * Returns truncated string.
 * See: prototype.js: http://prototypejs.org
 */
String.prototype.truncate = function(length, truncation) {
	length = length || 30;
	truncation = truncation === undefined ? '...' : truncation;
		return this.length > length ?
			this.slice(0, length - truncation.length) + truncation : this + ""; // + "" needed because of strange problems with jQuery
};

/*
 * Returns the string with first letter in lower case
 */
String.prototype.lowerFirst = function() { return this.length ? this.charAt(0).toLowerCase() + this.substring(1, this.length) : this; };


String.prototype.escapeHTML = function() {
	return this.replace(/&/g, "&amp;").replace(/\"/g, "&quot;").replace(/>/g,"&gt;").replace(/</g,"&lt;");
};

String.prototype.unescapeHTML = function() {
	return this.replace(/&amp;/g, "&").replace(/&quot;/g, '"').replace(/&gt;/g,">").replace(/&lt;/g,"<");
};

String.prototype.escapeQuotes = function() {
	return this.replace(/'/g, "\\\'").replace(/"/g, "\\\"").replace(/</g, "\\<");
};

/*
 * Returns the string transformed into one compatible with HTML class attribute.
 * All the whitespace characters are transformed into double underscores and all characters
 * that are not letters, numbers, underscores or dashes are transformed into single underscore.
 */
String.prototype.toClassName = function() {
	return this.replace(/[^A-Za-z0-9\-]/g, function(str){ return "_" + str.charCodeAt(0) + "_" });
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

$.fn.tooltip = function(message, options){
 	var settings = {
            showEvent: 'mouseenter',
            hideEvent: 'mouseleave',
            timeout: false,
            styles: {},
            position: 'bottomLeft',
            className: ""
	};

	if(options) {
		$.extend(settings, options);
	}

        var positions = {
            bottomLeft: function(target){
                return  {
                    top : $(target).offset().top + $(target).outerHeight() + 10,
		    left : $(target).offset().left - 10
                }
            },

            rightMiddle: function(target){
                return  {
                    top : $(target).offset().top + ($(target).outerHeight() / 2) - ($('#tooltip').outerHeight() / 2),
		    left : $(target).offset().left + $(target).width() + 10
                }
            }
        }

        return $(this).each(function(){
            var target = this;
            var show = function(){
                $('#tooltip').stop().remove(); // if old tooltip is still animated
                $('<div id="tooltip"></div>').appendTo($('body'));
                $('#tooltip')
                    .data('targetTitle', $(target).attr('title'))
                    .addClass(settings.className)
                    .html(message)
                    .append($.tag("span", { className: 'tick ' + settings.position }));
                $(target).attr('title', '');
                $('#tooltip').css({visibility: "hidden", display: "block"});
                $.extend(settings.styles, positions[settings.position](target));
                $('#tooltip').css({visibility: "", display: ""});
                $('#tooltip').css(settings.styles).fadeIn(200);
            }

            var close = function(){
                $('#tooltip').fadeOut(200, function(){ $(this).remove(); });
                $(target).attr('title', $('#tooltip').data('targetTitle'));
            };
            if(settings.showEvent){
                $(target).bind(settings.showEvent, show);
                $(target).bind(settings.hideEvent, close);
            } else {
                show();
                $(target).one(settings.hideEvent, close);
            }

            if(settings.timeout){
                setTimeout(close, settings.timeout);
            }
	});
}

$.fn.warningTooltip = function(message, settings){
    return $(this).tooltip(message, $.extend({ className: "warning", showEvent: false, timeout: 3000 }, settings));
}

$.fn.helpTooltip = function(message){
    return $(this).tooltip(message, { showEvent: 'focus', hideEvent: 'blur', timeout: false, position: "rightMiddle" });
}

$.tag = function(tagName, content, attrs){
	if((attrs == null) && (content) && (content.constructor == Object)){
		attrs = content;
		content = "";
	}
	var tagArray = ['<', tagName];
    var value = "";
	for(var attr in attrs){
        value = ("" + attrs[attr]).escapeHTML();
		tagArray.push(" ", attr == "className" ? "class" : attr, "=\"", value, "\"");
	}
	tagArray.push(">", content, "</", tagName, ">");
	return tagArray.join("");
}

$.fn.scrollTo = function(){
  $('html, body').animate({ scrollTop: this.offset().top }, 500);
  return this;
}

$.fn.sortIn = function( elements, sortValueCallback, options ){
    if(typeof elements == 'string') elements = $(elements);
    options = $.extend({
        insertBeforeElements: elements,
        insertAfterElements: elements,
        compareFunction : undefined
    }, options);

    var currentPosition = elements.index(this),
        sortValue = sortValueCallback.call(this, this),
        valueArray = $.map(elements, sortValueCallback).sort(options.compareFunction),
        newPosition = $.inArray(sortValue, valueArray);

    if(newPosition == currentPosition) return this;
    if(newPosition < currentPosition){
        this.insertBefore( $(options.insertBeforeElements).eq(newPosition) );
    } else {
        this.insertAfter( $(options.insertAfterElements).eq(newPosition) );
    }
    return this;
}

})(jQuery); // just to make sure $ was a jQuery
