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
		var className = $("#filterTags a[href='#/notags']").parent().hasClass("current") ? "current" : "";
		tagsLinks += $.tag("li", $.tag("a", "No tags", { href : "#/notags", title : "Highlight cards with no tags" }),
							 { className : className } );

		$.each(this.tagList, function(){
			className = $("#filterTags a[href='#/" + this.className + "']").parent().hasClass("current") ? "current" : "";
			tagsLinks += $.tag("li", $.tag("a", this.tag, { href : "#/" + this.className, title: "Highlight cards tagged as '" + this.tag + "'" }),
								 { className : className });
		});
		$("#filterTags").html(tagsLinks);
	},

	updateCardSelection : function(){
		var cardSelectors = [];

		$("#filterTags .current a").each(function(){

			var cardSelector = "";
			if($(this).attr('href') === '#/notags'){
				cardSelector = ":not([class*='tagged_as_'])";
			} else {
				cardSelector = $(this).attr('href').replace("#/", ".");
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

    importSelection : function(selected) {
        $("#filterTags li").removeClass("current");
        $("#filterTags a[href='#/" + selected + "']").parent().toggleClass("current");
        this.updateCardSelection();
    }
};
