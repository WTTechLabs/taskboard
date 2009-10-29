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

TASKBOARD.tags = {
	tagList : {},

	add : function(tag){
		var tagObject = this.tagList[tag];
		if(tagObject) {
			tagObject.count++;
			return tagObject;
		} else {
			tagObject = { tag : tag, className : "tagged_as_" + tag.toClassName(), count : 1 };
			this.tagList[tag] = tagObject;
			return tagObject;
		}
	},

	rebuildTagList : function(){
		this.tagList = {};
		$("#taskboard .cards > li").each(function(){
			$.each($(this).data("data").tag_list, function(i, tag){
				TASKBOARD.tags.add(tag);
			});
		});
	},

	updateTagsList : function(){
		this.rebuildTagList();

		var tagsLinks = "";
		var className = $("#filterTags a[href='#/?no_tags=']").parent().hasClass("current") ? "current" : "";
		tagsLinks += $.tag("li", $.tag("a", "No tags", { href : "#/?no_tags=", title : "Highlight cards with no tags" }),
							 { className : className } );

		$.each(this.tagList, function(){
			className = $("#filterTags a[href='#/" + this.className + "']").parent().hasClass("current") ? "current" : "";
			tagsLinks += $.tag("li", $.tag("a", this.tag, { href : "#/?selected_tags=" + this.tag, title: "Highlight cards tagged as '" + this.tag + "'" }),
								 { className : className });
		});
		$("#filterTags").html(tagsLinks);
	},

	updateCardSelection : function(){
		var cardSelectors = [];

		$("#filterTags .current a").each(function(){
			var cardSelector = "";
			if($(this).attr('href') === '#/?no_tags='){
				cardSelector = ":not([class*='tagged_as_'])";
			} else {
				//cardSelector = $(this).attr('href').replace("#/", ".");
                cardSelector = ".tagged_as_" + $(this).text();
			}
			cardSelectors.push(cardSelector);
		});

		var filtered = $("#taskboard .cards > li").css("opacity", null);
		$.each(cardSelectors, function(){
			filtered = filtered.not("#taskboard .cards > li" + this);
		});
		if($("#filterTags .current a").length){
			filtered.css("opacity", 0.2);
		}
	},

    importSelection : function(selected, noTagsSelected) {
        var selectedTags = selected.split(",");
        $("#filterTags li a[href!='#/?no_tags=']").each(function(){
            var current = $.inArray($(this).text(), selectedTags) >= 0;
            $(this).parent().toggleClass('current', current);
        });
        $("#filterTags li a[href='#/?no_tags=']")
            .parent().toggleClass('current', noTagsSelected);
        this.updateCardSelection();
    },

    exportSelection : function() {
        var tags = "";
         $("#filterTags li[class='current'] a[href!='#/?no_tags=']").each(function(){
            tags += $(this).text() + ",";
        });
        // get riddle of last coma
        if (tags.length > 0) tags = tags.substr(0, tags.length - 1);
        return(tags);
    }
};
