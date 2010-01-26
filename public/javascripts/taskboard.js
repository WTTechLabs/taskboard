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

(function($) { // just to make sure $ is a jQuery

/* 
 * A Taskboard object containing some global methods.
 */
var TASKBOARD = {};
window.TASKBOARD = TASKBOARD;

/*
 * Some taskboard utils
 * =========================================================
 */
TASKBOARD.utils = {
	/* 
	 * Expand columns to the height of the highest column.
	 * Use 50 pixel offset for easier dragging and dropping
	 * and min-height property to keep them expandable.
	 */  
	expandColumnsHeight : function(){
		$("#taskboard .lane:first .row").each(function(){
			$("#taskboard .row_" + $(this).data("data").id).equalHeight({ offset: 30, css : "min-height" });
		});
		$("#taskboard .column h2").equalHeight({ css : "min-height" });
	},

	/* 
	 * Expand taskboard width so all columns can fit into it,
	 * but don't make the body narrower than window.
	 */
	//FIXME body width with meta column
	expandTaskboardWidth : function(){
		var columnsWidth = $("#taskboard .lane").sumWidth() + 10;
		$("body").width(columnsWidth);
		if ($(window).width() > columnsWidth){
			$("body").width($(window).width());
		}
		$("#taskboard").width(columnsWidth);
	},

	/* 
	 * Expand taskboard width and height.
	 * @see expandColumnsHeight
	 * @see expandTaskboardWidth
	 */ 
	expandTaskboard : function(){
		this.expandColumnsHeight();
		this.expandTaskboardWidth();
	}
};

/*
 * Methods used to build taskboard elements from data
 * =========================================================
 */
TASKBOARD.builder = {};

/*
 * Various taskboard options
 * ================================================
 */
TASKBOARD.builder.options = {
	// TODO: edit-mode-only
	/* Options for sorting cards */
	cardSort : {
		connectWith: ["#taskboard ol.cards"],
		cursor: "move",
		opacity: 0.40,
		placeholder: "placeholder",
		distance : 30,
		revert: 50,
		tolerance: 'pointer',
		start: function(ev, ui){
			ui.placeholder.html($(ui.item).html());
			if($(ui.item).hasClass("collapsed")){
				 ui.placeholder.addClass("collapsed");
			}
			//TODO: get padding from CSS?
			ui.helper.width($(ui.item).parent().width() - 25);
			// fixing IE7 drag overlapping bug
			if($.browser.msie){
				ui.item.closest(".column").css("zIndex", "4");
			}
		},
		//.TODO: just a workaround for opacity
		sort : function(ev, ui){
			ui.item.css({opacity : 0.4});
			// unselect any text selected during drag
			if (document.selection) {
				document.selection.empty();
			} else {
				window.getSelection().removeAllRanges();
			}
		},
		change : function(ev, ui){
			TASKBOARD.utils.expandTaskboard();
		},
		stop : function(ev, ui){
			if($.browser.msie){
				$("#taskboard .column").css("zIndex", "");
			}
			TASKBOARD.utils.expandColumnsHeight();
			ui.item.width("auto");
			// get current position of card counting from 1
			// there is no placeholder already
			var position = ui.item.parent().children().index(ui.item) + 1;
			var column_id = ui.item.parent().parent().data('data').id;
			var row_id = ui.item.parent().data('data').id;
			// TODO: check if card column and position changed
			//	if(position != ui.item.data('position')){
				TASKBOARD.remote.api.moveCard(ui.item.data("data").id, column_id, row_id, position);
			//	}
		},
		zIndex : 5
	},

	// TODO: edit-mode-only
	/* Options for sorting columns */
	columnSort : {
		connectWith: ["#taskboard"],
		items: ".column",
		cursor: "move",
		placeholder: "lane column placeholder",
		revert: 50,
		start: function(ev, ui){
			var position = $("#taskboard .column").index(ui.item);
			ui.item.data('position', position);
			ui.placeholder.height($(ui.item).height());
			ui.placeholder.width($(ui.item).width());
		},
		sort : function(ev, ui){
			ui.item.css({opacity : 0.4});
		},
		stop: function(ev, ui){
			var position = $("#taskboard .column").index(ui.item);
			if(position !== ui.item.data('position')){
				// server counts positions starting from 1
				TASKBOARD.remote.api.moveColumn(ui.item.data("data").id, position + 1);
				TASKBOARD.form.updateColumnSelect();
			}
		},
		axis: "x",
		opacity: 0.40,
		zIndex : 5,
		appendTo : 'body',
		handle : $.browser.msie ? "h2" : false
	},

	/* Options for resizing columns */
	columnResize : {
		minWidth : 100,
		maxWidth: 500,
		handles: "e",
		transparent: false, 
		resize : function(ev, ui){
			TASKBOARD.utils.expandTaskboard();
			ui.element.height("auto");
		},
		stop : function(ev, ui){
			TASKBOARD.cookie.setColumnWidth(ui.helper.data("data").id, ui.size.width);
			TASKBOARD.utils.expandTaskboard();
			ui.element.height("auto");
		}
	}
};

/* String constants */
// TODO: get rid of this
TASKBOARD.builder.strings = {
	columnHeaderTitle : "Double-click to edit",

	tagsTooltip: "You can use '<strong>,</strong>' to add multiple tags<br/>e.g.: <strong>exempli, gratia</strong>",

	notesTooltip: "<p>You can use Markdown syntax:</p>" +
				  "<p># This is an H1<br/> ### This is an H3, etc...</p>"+
				  "<p>**<strong>bold text</strong>** <em>_italic text_</em></p>"+
				  "<p>* first list item<br/>* second list item</p>" +
				  "<p>1. first ordered list item<br/>2. second ordered list item</p>" +
				  "<p>Remember to put empty line to start new paragraph.</p>"+
				  "Learn more from <a rel='external' href='http://daringfireball.net/projects/markdown/basics'>official Markdown syntax guide</a>."
};

TASKBOARD.builder.actions = {
	changeColorAction : function(){
		return $.tag("a", "Change the color", { className : "changeColor", title : "Change the color", href : "#" });
	},

	deleteCardAction : function(){
		return $.tag("a", "Delete card", { className : "deleteCard", title : "Delete card", href : "#" });
	},

	deleteColumn : function(){
		return $.tag("a", "Delete column", { className : 'deleteColumn', title : 'Delete column', href : '#' });
	},

	cleanColumn : function(){
		return $.tag("a", "Delete all cards from column", { className : 'cleanColumn', title : 'Delete all cards from column', href : '#' });
	},

	deleteRow : function(){
		return $.tag("a", "Delete row", { className : 'deleteRow', title : 'Delete row', href : '#' });
	},


	cleanRow : function(){
		return $.tag("a", "Delete all cards from column", { className : 'cleanRow', title : 'Delete all cards from row', href : '#' });
	}
};

/*
 * Builds a column element from JSON data.
 */
TASKBOARD.builder.buildColumnFromJSON = function(column){
	var header = $.tag("h2", column.name.escapeHTML());
	var columnLi = "";
	// edit-mode-only
	if(TASKBOARD.editor){
		var actionsColumn = $.tag("li", TASKBOARD.builder.actions.deleteColumn());
		actionsColumn += $.tag("li", TASKBOARD.builder.actions.cleanColumn());
		columnLi = $.tag("ul", actionsColumn, { className : 'actions' });
	}
	columnLi += header;
	columnLi = $.tag("li", columnLi, { id : 'column_' + column.id, className :'lane column' });
	columnLi = $(columnLi)
				.data('data', column)
				.resizable(TASKBOARD.builder.options.columnResize);
	$.each(column.rows.sortByPosition(), function(i, row){
		var cardsOl = $.tag("ol", { className : 'cards' });
		cardsOl = $(cardsOl);
		cardsOl.data("data", row).addClass("row").addClass("row_" + row.id);
		if(TASKBOARD.editor){
			cardsOl.sortable(TASKBOARD.builder.options.cardSort);
		}
		if(column.cardsMap && column.cardsMap[row.id]){
			$.each(column.cardsMap[row.id].sortByPosition(), function(j, card){
				cardsOl.append(TASKBOARD.builder.buildCardFromJSON(card));
			});
		}
		columnLi.append(cardsOl);
	});
	var width = TASKBOARD.cookie.getColumnWidth(column.id) ? parseInt(TASKBOARD.cookie.getColumnWidth(column.id), 10) : "";
	columnLi.width(width);
	// edit-mode-only
	if(TASKBOARD.editor){
		columnLi.find("h2")
			.editable(function(value, settings){ 
					var id = $(this).closest(".column").data('data').id;
					TASKBOARD.remote.api.renameColumn(id, value);
					$(this).closest(".column").data('data').name = value;
					return value.escapeHTML();
				}, { event : "dblclick",
					 data : function(){ return $(this).closest(".column").data('data').name; },
					 callback: function(){ TASKBOARD.utils.expandColumnsHeight(); }
			 })
			.attr("title", TASKBOARD.builder.strings.columnHeaderTitle);
		// edit-mode-only
		columnLi.find(".deleteColumn")
			.bind("click", function(ev){
                                ev.preventDefault();
                                var closestColumn = $(this).closest('.column');
                                if(closestColumn.find("ol.cards").children().length !== 0){
					$(this).warningTooltip("You cannot delete a column that is not empty!");
				} else if ($("#taskboard .column").length == 1) {
					$(this).warningTooltip("You cannot delete last column!");
				}else {
					TASKBOARD.remote.api.deleteColumn(closestColumn.data('data').id);
					closestColumn.fadeOut(1000, function(){ $(this).remove(); } );
				}
			});

		columnLi.find(".cleanColumn")
			.bind("click", function(ev){
				ev.preventDefault();
				var closestColumn = $(this).closest('.column');
				if(closestColumn.find("ol.cards").children().length == 0){
					$(this).warningTooltip("Column have no cards!");
				}else if(confirm("Are you sure to delete all cards from column?")){
					TASKBOARD.remote.api.cleanColumn(closestColumn.data('data').id);
					closestColumn.find("ol.cards").children().fadeOut(375, function(){ $(this).remove(); } );
				}
			});
	}
	return columnLi;
};

TASKBOARD.builder.buildRowMeta = function(row){
	var rowDiv = $.tag("div", { className : 'row' });
	rowDiv = $(rowDiv);
	rowDiv.data("data", row).addClass("row_" + row.id);
	if(TASKBOARD.editor){
		var actionsRow = $.tag("li", TASKBOARD.builder.actions.deleteRow());
		actionsRow += $.tag("li", TASKBOARD.builder.actions.cleanRow());
		rowDiv.append($.tag("ul", actionsRow, { className : 'actions' }));
		rowDiv.find(".deleteRow")
			.bind("click", function(ev){
				ev.preventDefault();
				var cards = $(".column .row_" + row.id).children();
				if(cards.length !== 0){
					$(this).warningTooltip("You cannot delete a row that is not empty!", { position: "rightMiddle" });
				} else if($("#metaLane .row").length == 1) {
					$(this).warningTooltip("You cannot delete last row!", { position: "rightMiddle" });
				} else {
					TASKBOARD.remote.api.deleteRow(row.id);
					$(".row_" + row.id).fadeOut(1000, function(){ $(this).remove(); } );
				}
			});
		rowDiv.find(".cleanRow")
			.bind("click", function(ev){
				ev.preventDefault();
				var cards = $(".column .row_" + row.id).children();
				if(cards.length == 0){
					$(this).warningTooltip("Row have no cards!", { position: "rightMiddle" });
				} else if(confirm("Are you sure to delete all cards from row?")) {
					TASKBOARD.remote.api.cleanRow(row.id);
					cards.fadeOut(375, function(){ $(this).remove(); } );
				}
			});
	}
	return rowDiv;
};

TASKBOARD.builder.buildMetaLane = function(){
	var metaLane = $($.tag("li", { id: "metaLane", className: "lane"}));
	$.each(TASKBOARD.data.rows.sortByPosition(), function(i, row){
		var rowDiv = TASKBOARD.builder.buildRowMeta(row);
		metaLane.append(rowDiv);
	});
	return metaLane;
}
/*
 * Builds a card element from JSON data.
 */
TASKBOARD.builder.buildCardFromJSON = function(card){
	var cardLi = "";
	if(card.issue_no){
		cardLi += $.tag('span', $.tag('a', card.issue_no, { href : card.url, rel : 'external'}) + ": ",	{ className : 'alias' });
	}
	cardLi += $.tag("span", card.name.escapeHTML(), { className : 'title' });

	cardLi += $.tag("span", "hours left: " + $.tag("span", card.hours_left, { className : 'hours' }), { className : 'progress' });

	if(card.tag_list.length){
		var tagsUl = "";
		$.each(card.tag_list, function(i, tag){
			tagsUl += $.tag("li", tag.escapeHTML());
		});
		tagsUl = $.tag("ul", tagsUl, { className : 'tags' });
		cardLi += tagsUl;
	}

	// build card actions
	var actionsUl = "";

	// edit-mode-only
	if(TASKBOARD.editor){
		actionsUl += $.tag("li", TASKBOARD.builder.actions.deleteCardAction());
		actionsUl += $.tag("li", TASKBOARD.builder.actions.changeColorAction());

		actionsUl = $.tag("ul", actionsUl, { className : 'actions' });
		cardLi += actionsUl;
	}

	cardLi = $.tag("li", cardLi, { id : 'card_' + card.id });
	cardLi = $(cardLi)
		.css("background-color", card.color)
		.data("data", card)
		.bind("dblclick", function(){
			TASKBOARD.openCard($(this).data('data'));
		});

	$.each(card.tag_list, function(i, tag){
		cardLi.addClass('tagged_as_' + tag.toClassName());
	});

	// edit-mode-only
	if(TASKBOARD.editor){
		cardLi.find(".progress .hours").editable(function(val){
				var updatedDateString = $(this).closest(".cards > li").data('data').hours_left_updated;
				var updatedToday = false;
				if(updatedDateString){
					var updatedDate = new Date();
					updatedDate.setISO8601($(this).closest(".cards > li").data('data').hours_left_updated);
					var now = new Date();
					if(now.getYear() == updatedDate.getYear() && now.getMonth() == updatedDate.getMonth() && now.getDay() == updatedDate.getDay()){
						updatedToday = true;
					}
				}
				var value;
				if((!updatedToday || confirm("You already updated hours today. Are you sure you want to change them?\n\n" + 
											 "Click 'Cancel' to leave hours unchanged and wait till tomorrow or (if you are really sure) click 'OK' to save hours.")) && 
											 !isNaN(val) && val >= 0) {
						TASKBOARD.remote.api.updateCardHours($(this).parent().parent().data('data').id, val);
						$(this).parent().parent().data('data').hours_left = val;
						return val;
					} else {
						return this.revert;
					}
			});

		cardLi.find(".deleteCard").click(function(ev){
				if(confirm("Do you really want to delete this card?")){
					TASKBOARD.remote.api.deleteCard($(this).closest(".cards > li").data('data').id);
					$(this).closest(".cards > li").fadeOut(1000, function(){$(this).remove();} );
				}
				ev.preventDefault();
			});

		cardLi.find(".changeColor").click(function(ev){
				var card = $(this).closest(".cards > li");
				TASKBOARD.openColorPicker(card, $(this).offset().top - 8, $(this).offset().left + 12);
				ev.preventDefault();
				ev.stopPropagation();
			});
	}
	return cardLi;
};

TASKBOARD.builder.buildBigCard = function(card){
	var cardDl = "";
	cardDl += $.tag("dt", "Actions", { id: "cardActionsTitle"});

	if(TASKBOARD.editor){
		var actions = $.tag("li", TASKBOARD.builder.actions.changeColorAction());
		actions = $.tag("ul", actions, { className: "big actions"});
		cardDl += $.tag("dd", actions, { id: "cardActions"});
	}

	if(card.issue_no) {
		cardDl +=  $.tag("dt", "Issue");
		cardDl +=  $.tag("dd", card.issue_no.escapeHTML());

		cardDl +=  $.tag("dt", "URL");
		cardDl +=  $.tag("dd", $.tag("a", card.url, { href : card.url, rel : 'external' }));
	}
	cardDl += $.tag("dt", "Name");
	cardDl += $.tag("dd", card.name.escapeHTML(), { id : "name", className : "editable" });

	var notes = card.notes ? (new Showdown.converter()).makeHtml(card.notes.escapeHTML()) : "";
	cardDl += $.tag("dt", "Notes");
	cardDl += $.tag("dd", notes, { id : "notes", className : "editable" });

	var tagsUl = "";
	$.each(card.tag_list, function(){
		var tagLi = $.tag("span", this.escapeHTML(), { className : "tag" });
		if(TASKBOARD.editor){
			tagLi += $.tag("a", "X", { className : "deleteTag", href : "#" });
		}
		tagsUl += $.tag("li", tagLi);
	});
	tagsUl = $.tag("ul", tagsUl, { className : 'tags' });

	cardDl += $.tag("dt", "Tags");
	cardDl += $.tag("dd", tagsUl, { id: 'tags' });

	// edit-mode-only
	if(TASKBOARD.editor){
		var tagsForm = $.tag("input", { type : "text", value : "Add tags...", id : 'inputTags', name : 'inputTags', size : 30 });
		tagsForm = $.tag("form", tagsForm, { id : 'tagsForm' });
		tagsForm = $.tag("dd", tagsForm);
		cardDl += tagsForm;
	}

	cardDl += $.tag("dt", "Hours left");
	cardDl += $.tag("dd", card.hours_left, { id : "progress" });

	cardDl = $.tag("dl", cardDl, { id: 'bigCard_' + card.id, className : 'bigCard'});

	var bigCard = $(cardDl).css({ backgroundColor : card.color });

	// edit-mode-only
	if(TASKBOARD.editor){
		var deleteTagCallback = function(){
			var tag = $(this).parent().find(".tag").text();
			TASKBOARD.remote.api.removeTag(card.id, tag);
			var index = card.tag_list.indexOf(tag);
			card.tag_list.splice(index, 1);
			TASKBOARD.api.updateCard({ card: card });
			TASKBOARD.remote.api.removeTag(card.id, tag);
			$(this).parent().remove();
		};

		bigCard.find(".changeColor").click(function(ev){
			TASKBOARD.openColorPicker(bigCard, $(this).offset().top - 5, $(this).offset().left + 12);
			ev.preventDefault();
			ev.stopPropagation();
		});

		bigCard.find('#tagsForm').submit(function(ev){
			var cardTags = $.map(card.tag_list, function(n){ return n.toUpperCase() });
			var tags = $(this).find(':text').val();
			// remove empty and already added tags
			tags = $.map(tags.split(','), function(n){ return (n.trim() && ($.inArray(n.trim().toUpperCase(),cardTags) < 0)) ? n.trim() : null; });
			var uniqueTags = []
			$.each(tags, function(i,v){
				if($.inArray(v.toUpperCase(), cardTags) < 0){
					uniqueTags.push(v);	
					cardTags.push(v.toUpperCase());
				}
			});
			$.merge(card.tag_list, uniqueTags);
			TASKBOARD.api.updateCard({ card: card });
			if(uniqueTags.length > 0){
				TASKBOARD.remote.api.addTags(card.id, uniqueTags.join(','));
			}
			// TODO: wait for response?
			$("#tags ul").html("");
			$.each(card.tag_list, function(){
				var tagLi = $.tag("span", this.escapeHTML(), { className : "tag" }) +
							$.tag("a", "X", { className : "deleteTag", href : "#" });
				$("#tags ul").append($.tag("li", tagLi));
				$("#tags .deleteTag").bind('click', deleteTagCallback);
			});
			ev.preventDefault();
		}).find(":text").click(function() { $(this).val(""); });

		bigCard.find('#inputTags').helpTooltip(TASKBOARD.builder.strings.tagsTooltip);

		bigCard.find('#name')
			.editable(function(value, settings){
					TASKBOARD.remote.api.renameCard(card.id, value);
					card.name = value;
					TASKBOARD.api.updateCard({ card: card }); // redraw small card
					return value.escapeHTML();
				}, { height: 'none', width: '100%',
					 submit : 'Save', cancel : 'Cancel', onblur : 'ignore',
					 data : function(){ return $(this).closest('dl').data('data').name; },
					 readyCallback: function(){ $(this).removeClass("hovered"); }
			})
			.bind("mouseenter.editable", function(){ if($(this).find("form").length){ return; } $(this).addClass("hovered");})
			.bind("mouseleave.editable", function(){ $(this).removeClass("hovered"); });

		bigCard.find('#notes')
			.editable(function(value){
					TASKBOARD.remote.api.updateCardNotes(card.id, value);
					card.notes = value;
					return value ? (new Showdown.converter()).makeHtml(value.escapeHTML()) : "";
				}, { height: '200px', width: '100%',
					 type : 'textarea', submit : 'Save', cancel : 'Cancel', onblur : 'ignore',
					 data : function(){ return $(this).closest('dl').data('data').notes || ""; },
					 readyCallback : function(){
						$(this).removeClass("hovered").find("textarea").helpTooltip(TASKBOARD.builder.strings.notesTooltip);
					}
			})
			.bind("mouseenter.editable", function(){ if($(this).find("form").length){ return; } $(this).addClass("hovered"); })
			.bind("mouseleave.editable", function(){ $(this).removeClass("hovered"); });

		bigCard.find('#progress').editable(function(val){
			if(!isNaN(val) && val >= 0) {
					TASKBOARD.remote.api.updateCardHours(card.id, val, $(this).find("select").val());
					TASKBOARD.remote.get.cardBurndown(card.id, function(data){
						TASKBOARD.burndown.render($('#cardBurndown'), data);
					});
					card.hours_left = val;
					TASKBOARD.api.updateCard({ card: card }); // redraw small card
					return val;
			} else {
				return this.revert;
			}
		}, { type : 'textselect', onblur : 'ignore', submit : 'Save', cancel : 'Cancel',
			readyCallback: function(){ $(this).removeClass("hovered"); }
		})
		.bind("mouseenter.editable", function(){ if($(this).find("form").length){ return; } $(this).addClass("hovered"); })
		.bind("mouseleave.editable", function(){ $(this).removeClass("hovered"); });

		bigCard.find('#tags .deleteTag').bind('click', deleteTagCallback);
	}

	bigCard.data('data',card);
	return bigCard;
};

/*
 * Utilities for managing Add cards and Add column form
 * =========================================================
 */
TASKBOARD.form = {
	/* Keeps currently opened form */
	current : "",
	
	/* Actions performed by form */
	actions : {
		addCards : function(){
			var value = $('#inputAddCards').val().trim();
			if(value.length === 0){
				$('#inputAddCards').effect("highlight", { color: "#FF0000" }).focus();
				return false;
			}
			var columnId = $('#selectColumn').val();
			TASKBOARD.remote.api.addCards(value, columnId);
			TASKBOARD.form.close();
			return false;
		},
		addColumn : function(){
			var value = $('#inputAddColumn').val().trim();
			if(value.length === 0){
				$('#inputAddColumn').effect("highlight", { color: "#FF0000" }).focus();
				return false;
			}
			TASKBOARD.remote.api.addColumn(value);
			TASKBOARD.form.close();
			return false;
		}
	},
	
	/*
	 * Submits data to server.
	 * Detects currently opened form and chooses proper action.
	 * @see this.actions
	 */
	submit : function(){
		var self = TASKBOARD.form;
		// get action name from current fieldset id
		var action = self.current.replace(/#([a-z]+)/,'').lowerFirst();
		self.actions[action]();
		return false;
	},
	
	toggle : function(id){
		id === this.current ? this.close() : this.open(id);
	},
	
	open : function(id){
		$("#formActions fieldset").hide();
		$(id).show();
		$("#formActions")
			.show("slide", { direction: "up" }, "fast", function(){
				$(id + " :text").focus();
			});
		
		this.current = id;
	},
	
	close : function(){
		var self = TASKBOARD.form;
		$("#formActions")
			.hide("slide", { direction: "up" }, "fast", function(){
				$("#actions li").removeClass("current");
				$("#formActions fieldset").hide();
				$("#formActions :text").val("");
				self.current = "";
			});
	},

	updateColumnSelect : function(){
		var options = [];
		$('#taskboard .column').each(function(){
			var title = $(this).find("h2").text();
			var id = $(this).data("data").id;
			options.push($.tag("option", title, { value : id }));
		});
		var select = $("#selectColumn").html(options.join(''));
		var fieldset = select.closest("fieldset");
		
		fieldset.show().closest("form").css({visibility: "hidden"}).show();
		var othersWidth = select.outerWidth() + fieldset.find("span").outerWidth() + fieldset.find(":submit").outerWidth() + 25; // 25px is for spaces etc.
		$("#inputAddCards").width(fieldset.width() - othersWidth);
		fieldset.hide().closest("form").hide().css({visibility: ""});
	}
};

/*
 * Functions to load and build taskboard elements from AJAX calls
 * ==================================================================
 */
TASKBOARD.api = {
	/*
	 * Adds a column from JSON as a first column of taskboard.
	 */
	addColumn : function(column){
		if(column.column){
			column = column.column;
		}
		var rows = [];
		$("#taskboard .lane:first .row").each(function(){ rows.push($(this).data("data")); });
		column.rows = rows;
		TASKBOARD.builder.buildColumnFromJSON(column)
			.insertBefore($("#taskboard .column:first"))
			.effect("highlight", {}, 2000);
		TASKBOARD.utils.expandTaskboard();
		TASKBOARD.form.updateColumnSelect();
		TASKBOARD.remote.loading.stop();
	},

	moveColumn : function(column){
		column = column.column;
		var columnLi = $('#column_' + column.id);
		var currentPosition = $("#taskboard .column").index(columnLi) + 1;
		if(currentPosition > column.position){
			$($('#taskboard').children(".column")[column.position - 1]).before(columnLi);
		} else if(currentPosition < column.position){
			$($('#taskboard').children(".column")[column.position - 1]).after(columnLi);
		}
		columnLi.effect('highlight', {}, 1000);
		TASKBOARD.form.updateColumnSelect();
	},

	/*
	 * Adds a column from JSON as a last row of taskboard.
	 */
	addRow : function(row){
		if(row.row){
			row = row.row;
		}
		var rowMeta = TASKBOARD.builder.buildRowMeta(row);
		$("#taskboard #metaLane").append(rowMeta);
		$("#taskboard .column").each(function(){
			var cardsOl = $.tag("ol", { className : 'cards' });
			cardsOl = $(cardsOl);
			cardsOl.data("data", row).addClass("row").addClass("row_" + row.id);
			if(TASKBOARD.editor){
				cardsOl.sortable(TASKBOARD.builder.options.cardSort);
			}
			$(this).append(cardsOl);
		});
		$(".row_" + row.id).effect("highlight", {}, 2000);
		TASKBOARD.utils.expandTaskboard();
	},

	/*
	 * Loads cards from JSON into first column.
	 */
	addCards : function(cards){
		$.each(cards, function(i, card){
			card = card.card;
			$("#column_" + card.column_id + " ol.cards").eq(0).prepend(TASKBOARD.builder.buildCardFromJSON(card));
		});
		TASKBOARD.utils.expandTaskboard();
		TASKBOARD.remote.loading.stop();
		TASKBOARD.tags.updateTagsList();
		TASKBOARD.tags.updateCardSelection();
	},

	moveCard : function(card){
		card = card.card;
		var cardLi = $('#card_' + card.id),
			currentPosition = cardLi.parent().children().index(cardLi) + 1,
			currentColumn = cardLi.parent().parent().data('data').id,
			currentRow = cardLi.parent().data('data').id;

		if((currentColumn !== card.column_id) || (currentRow !== card.row_id) || (currentPosition !== card.position)){
			var targetCell = $("#column_" + card.column_id + " .row_" + card.row_id);
			targetCell.append(cardLi);
			if(targetCell.children().length != card.position){
				targetCell.children().eq(card.position - 1).before(cardLi);
			}
		}
		cardLi.effect('highlight', {}, 1000);
		TASKBOARD.utils.expandTaskboard();
	},

	deleteCard : function(card){
		card = card.card;
		var cardLi = $('#card_' + card.id);
		cardLi.fadeOut(1000, function(){
			$(this).remove();
			TASKBOARD.utils.expandTaskboard();
			TASKBOARD.tags.updateTagsList();
			TASKBOARD.tags.updateCardSelection();
		});
	},

	deleteColumn : function(column){
		column = column.column;
		var columnLi = $('#column_' + column.id);
		columnLi.fadeOut(1000, function(){$(this).remove();} );
		TASKBOARD.form.updateColumnSelect();
		TASKBOARD.utils.expandTaskboard();
	},

	cleanColumn : function(column){
		column = column.column;
		var cards = $('#column_' + column.id).find("ol.cards").children();
		cards.fadeOut(375, function(){ $(this).remove(); } );
	},

	deleteRow : function(row){
		row = row.row;
		var row = $('.column .row_' + row.id);
		row.fadeOut(1000, function(){$(this).remove();} );
		TASKBOARD.utils.expandTaskboard();
	},

	cleanRow : function(row){
		row = row.row;
		var cards = $(".column .row_" + row.id).children();
		cards.fadeOut(375, function(){$(this).remove();} );
	},

	renameColumn : function(column){
		column = column.column;
		$('#column_' + column.id + ' h2')
			.text(column.name)
			.effect('highlight', {}, 1000);
		TASKBOARD.form.updateColumnSelect();
	},

	renameCard : function(card){
		card = card.card;
		$('#card_' + card.id + ' .title')
			.text(card.name)
			.effect('highlight', {}, 1000);
	},

	// TODO: update also big card
	updateCard : function(card){
		card = card.card;
		var newCard = TASKBOARD.builder.buildCardFromJSON(card);
		$('#card_' + card.id).before(newCard).remove();
		newCard.effect('highlight', {}, 1000);
		TASKBOARD.tags.updateTagsList();
		TASKBOARD.tags.updateCardSelection();
	},

	renameTaskboard : function(name){
		document.title = name + " - Taskboard";
		$('h1 span.title')
			.text(name)
			.effect('highlight', {}, 1000);
	},

	changeCardColor : function(card){
		card = card.card;
		var cardElements = $('#card_' + card.id).add("#bigCard_" + card.id);
		cardElements.css({ backgroundColor : card.color });
		cardElements.data('data').color = card.color;
	}
};

/* 
 * Initializes taskboard action links and forms functionality
 * before content is loaded by JSON.
 */ 
TASKBOARD.init = function(){
	var expand;
	var collapse = function(){
		$("#taskboard").addClass("collapsed");
		$(this).text("Expand All").one("click", expand);
		TASKBOARD.utils.expandColumnsHeight();
		return false;
	};
	
	expand = function(){
		$("#taskboard").removeClass("collapsed");
		$(this).text("Collapse All").one("click", collapse);
		TASKBOARD.utils.expandColumnsHeight();
		return false;
	};
	
	TASKBOARD.zoom = TASKBOARD.cookie.setTaskboardZoom(TASKBOARD.id) ? parseInt(TASKBOARD.cookie.setTaskboardZoom(TASKBOARD.id), 10) : 5;
	$("#taskboard").addClass("zoom_" + TASKBOARD.zoom);
	TASKBOARD.max_zoom = 5;
	var zoom = function(ev){
		$('#taskboard').removeClass("zoom_" + TASKBOARD.zoom);
		TASKBOARD.zoom = TASKBOARD.zoom < TASKBOARD.max_zoom ? TASKBOARD.zoom + 1 : 0;
		$('#taskboard').addClass("zoom_" + TASKBOARD.zoom);
		
		TASKBOARD.cookie.setTaskboardZoom(TASKBOARD.id, TASKBOARD.zoom);
		
		if(TASKBOARD.zoom < TASKBOARD.max_zoom){
			$(this).text("Zoom in");
		} else {
			$(this).text("Zoom out");
		}
		TASKBOARD.utils.expandTaskboard();
		
		ev.preventDefault();
	};
	$(".actionToggleAll").text("Zoom out").bind("click", zoom);
	if(TASKBOARD.zoom != TASKBOARD.max_zoom){
		$(".actionToggleAll").text("Zoom in");
	}
	
	$(".actionAddCards").bind("click", function(ev){
		$(this).parent().siblings().removeClass("current").end().toggleClass("current");
		TASKBOARD.form.toggle('#fieldsetAddCards');
		ev.preventDefault();
	});

	$(".actionAddColumn").bind("click", function(ev){
		$(this).parent().siblings().removeClass("current").end().toggleClass("current");
		TASKBOARD.form.toggle('#fieldsetAddColumn');
		ev.preventDefault();
	});

	$(".actionAddRow").bind("click", function(ev){
		TASKBOARD.remote.api.addRow();
		ev.preventDefault();
	});

	$(".actionShowTagSearch").bind("click", function(ev){
		$(this).parent().siblings().removeClass("current").end().toggleClass("current");
		TASKBOARD.form.toggle('#fieldsetTags');
		ev.preventDefault();
	});
	
	$("#filterTags a").live("click", function(){
		$(this).parent().toggleClass("current");
		TASKBOARD.tags.updateCardSelection();
		return false;
	});

	$(".actionShowBurndown").bind("click", this.showBurndown);

	$("#formActions img").rollover();
	$("#formActions .actionHideForm").click(function(){ TASKBOARD.form.close(); $("#actions li").removeClass("current"); });
	$("#formActions").hide();
	$("#formActions").submit(TASKBOARD.form.submit);
};

/*
 * Loads taskboard content from JSON.
 *
 * TODO: refactor JSON parameter names
 * TODO: refactor the code
 */ 
TASKBOARD.loadFromJSON = function(taskboard){
	var self = TASKBOARD;
	taskboard = taskboard.taskboard;
	self.data = taskboard;
	var title = $($.tag("span", taskboard.name.escapeHTML(), { className : 'title' }));
	document.title = taskboard.name.escapeHTML() + " - Taskboard"; 
	if(TASKBOARD.editor){
		title.editable(function(value, settings){
			if(value.trim().length > 0) {
				TASKBOARD.remote.api.renameTaskboard(value);
				TASKBOARD.data.name = value;
				return value.escapeHTML();
			} else {
				$(this).warningTooltip("Name cannot be blank!");
				return this.revert;
			}
			}, { event : "dblclick", data : function(){ return TASKBOARD.data.name; } })
		.attr("title", TASKBOARD.builder.strings.columnHeaderTitle);
	}
	$("#header h1")
		.find("span.title").remove().end()
		.append(title);

	$("#taskboard").html("")

	if(TASKBOARD.editor){
		var metaLane = TASKBOARD.builder.buildMetaLane();
		$("#taskboard").append(metaLane);
	}
	// build a mapping between cards and their position in columns/rows
	var cardsMap = {}
	$.each(taskboard.cards, function(i, card){
		if(typeof cardsMap[card.column_id] === 'undefined'){
			cardsMap[card.column_id] = {};
		}
		if(typeof cardsMap[card.column_id][card.row_id] === 'undefined'){
			cardsMap[card.column_id][card.row_id] = [];
		}
		cardsMap[card.column_id][card.row_id].push(card);
	});
	// build columns
	$.each(taskboard.columns.sortByPosition(), function(i, column){
		column.cardsMap = cardsMap[column.id];
		column.rows = taskboard.rows;
		$("#taskboard").append(TASKBOARD.builder.buildColumnFromJSON(column));
	});
	if(TASKBOARD.editor){
		$("#taskboard").sortable(TASKBOARD.builder.options.columnSort);
	}
	TASKBOARD.utils.expandTaskboard();
	TASKBOARD.form.updateColumnSelect();
	TASKBOARD.tags.updateTagsList();
};

TASKBOARD.burndown = {};

TASKBOARD.burndown.options = {
	xaxis: {
		mode: "time",
		timeformat: "%d-%b",
		tickSize: [1, "day"]
	},
	yaxis: { min: 0 },
	bars: {
		show: true,
		barWidth: 24 * 60 * 60 * 1000, // unit is a millisecond and a bar should have 1 day width
		align: 'center'
	},
	grid : { backgroundColor: 'white' }
};

TASKBOARD.burndown.render = function(element, data){
	if(!data.length){
		var date = new Date();
		date.setMilliseconds(0); date.setSeconds(0); date.setMinutes(0); date.setHours(0);
		data.push([date.getTime(), 0]);
	}
	$.extend(TASKBOARD.burndown.options.xaxis, {
		min: data[0][0] - 16 * 60 * 60 * 1000,  // leave some margin between bars and axis
		max: data[data.length - 1][0] + ((data.length < 10 ? 10 - data.length : 0) * 24 + 16) * 60 * 60 * 1000
	});
	$.plot(element, [data], TASKBOARD.burndown.options);
};


TASKBOARD.showBurndown = function(ev){
	ev.preventDefault();
	var self = TASKBOARD;
	TASKBOARD.remote.get.taskboardBurndown(self.id, function(data){

		if(!$('#burndown').exists()){
			$('body').append('<div id="burndown"></div>');
		}

		// div must have height and width to plot
		$("#burndown").css({ height: '400px', width : '600px' });
		$("#burndown").show();
		
		TASKBOARD.burndown.render($('#burndown'), data);
		$("#burndown").openOverlay({
			height: '400px',
			width : '600px',
			position: 'fixed',
			top: '50%',
			left: '50%',
			marginTop: '-200px',
			marginLeft:'-300px',
			backgroundColor: 'white',
			border: '1px solid #CCCCCC',
			borderRadius: '20px',
			zIndex: 1001
		});
		
	});
};

TASKBOARD.openCard = function(card){
	$('.bigCard').remove();
	var bigCard = TASKBOARD.builder.buildBigCard(card);
	bigCard.appendTo($('body')).hide()
		.openOverlay({ zIndex: 1001 });

	TASKBOARD.remote.get.cardBurndown(card.id, function(data){
		var burndown = $("<dd id='cardBurndown'></dd>");
		burndown.css({ width: '550px', height: '300px' });
		bigCard.append(burndown);
		TASKBOARD.burndown.render(burndown, data);
	});	
};

TASKBOARD.openColorPicker = function(card, top, left){
	$.colorPicker({
		click : function(color){
			$(card).css({ backgroundColor : color});
			$(card).data('data').color = color;
			TASKBOARD.remote.api.changeCardColor($(card).data('data').id, color);
		},
		colors : ['#F8E065', '#FAA919', '#12C2D9', '#FF5A00', '#35B44B'],
		columns: 5,
		top : top,
		left : left,
		defaultColor : $(card).data('data').color
	});
}

$(document).ready(function() {
	var self = TASKBOARD;
	self.init();
	TASKBOARD.remote.get.taskboardData(self.id, self.loadFromJSON);

	// highlight resizing columns
	$(".ui-resizable-handle")
		.live("mouseover", function(){ $(this).parent().addClass("resizing"); })
		.live("mouseout", function(){ $(this).parent().removeClass("resizing"); });

	// open external links in new window
	$('a[rel="external"]').live('click',function(ev) {
		window.open( $(this).attr('href') );
		ev.preventDefault();
	});
});

TASKBOARD.refresh = function(message) {
	message = message || "Taskboard refreshed.";
	var callback = function(data){
		TASKBOARD.loadFromJSON(data);
		if (message) $.notify(message);
	}
	TASKBOARD.remote.get.taskboardData(TASKBOARD.id, callback);
}

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
		var className = $("#filterTags a[href='#notags']").parent().hasClass("current") ? "current" : "";
		tagsLinks += $.tag("li", $.tag("a", "No tags", { href : "#notags", title : "Highlight cards with no tags" }),
							 { className : className } );
		
		$.each(this.tagList, function(){
			className = $("#filterTags a[href='#" + this.className + "']").parent().hasClass("current") ? "current" : "";
			tagsLinks += $.tag("li", $.tag("a", this.tag, { href : "#" + this.className, title: "Highlight cards tagged as '" + this.tag + "'" }),
								 { className : className });
		});
		$("#filterTags").html(tagsLinks);
	},
	
	updateCardSelection : function(){
		var cardSelectors = [];
		
		$("#filterTags .current a").each(function(){
		
			var cardSelector = "";
			if($(this).attr('href') === '#notags'){
				cardSelector = ":not([class*='tagged_as_'])";
			} else {
				cardSelector = $(this).attr('href').replace("#", ".");
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
	}
};

// TODO: refactor and make more generic plugin
$.fn.openOverlay = function(css){
	var self = this;
	$('body').append('<div id="overlay"></div>');
		$("#overlay").css({ 
			height: '100%',
			width : '100%',
			position: 'fixed',
			top: '0',
			left: '0',
			backgroundColor: 'white',
			opacity: 0.8,
			zIndex: 1000
		}).click(function(){
			if($(self).find(".editable form").length) {
				alert("You have unsaved changes. Save or cancel them before closing");
				return;
			}
			$('#overlay').remove();
			$(self).hide();
			$('#taskboard').css({ position : ''});
		});
		$(this).css(css);
	$(this).show();
	$('#taskboard').css({ position : 'fixed'});
};

TASKBOARD.remote = {
	/*
	 * Utilities for managing loading taskboard image
	 * =========================================================
	 */
	loading : {
		start : function(){
			if(!$('#loading').exists()){
				$('<div id="loading"></div>').appendTo($('body'));
			}
		},
		stop : function(){
			$('#loading').fadeOut(function(){ $(this).remove(); });
		}
	},

	// TODO: is this needed? 
	checkStatus : function(json){
		TASKBOARD.remote.loading.stop();
		return json.status;
	},

	callback : function(url, params, successCallback){
			if(successCallback){
				TASKBOARD.remote.loading.start();
			}
			$.getJSON(url, params,
					function(json){
						if(TASKBOARD.remote.checkStatus(json) === 'success'){
							if(successCallback && !juggernaut.is_connected){
								sync[successCallback](json, true);
							}
						} else {
							$.notify(json.message, { cssClass : "error" });
						}
					});
	},
	get: {
		taskboardData: function(id, callback){
			$.getJSON("/taskboard/get_taskboard/" + id, function(data){
				callback(data);
				TASKBOARD.remote.loading.stop();
			});
		},
		taskboardBurndown: function(id, callback){
			TASKBOARD.remote.loading.start();
			$.getJSON('/taskboard/load_burndown/' + id, function(data){
				callback(data);
				TASKBOARD.remote.loading.stop();
			});
		},
		cardBurndown: function(id, callback){
			$.getJSON('/card/load_burndown/' + id, callback);
		}
	},
	//TODO: change to POST requests
	api: {
		addCards : function(name, column_id){
			TASKBOARD.remote.callback("/taskboard/add_card",
							{ name : name, taskboard_id : TASKBOARD.id, column_id : column_id },
							'addCards');
		},
		addColumn : function(name){
			TASKBOARD.remote.callback("/taskboard/add_column",
							{ name : name, taskboard_id : TASKBOARD.id },
							'addColumn');
		},
		addRow : function(){
			TASKBOARD.remote.callback("/taskboard/add_row",
							{ taskboard_id : TASKBOARD.id },
							'addRow');
		},
		moveCard : function(cardId, columnId, rowId, position){
			TASKBOARD.remote.callback("/taskboard/reorder_cards",
							{ position : position, column_id : columnId, id : cardId, row_id: rowId });
		},
		moveColumn : function(columnId, position){
			TASKBOARD.remote.callback("/taskboard/reorder_columns",
							{ position : position, id : columnId });
		},
		renameTaskboard : function(name){
			TASKBOARD.remote.callback('/taskboard/rename_taskboard', { id : TASKBOARD.id, name : name });
		},
		renameColumn : function(columnId, name){
			TASKBOARD.remote.callback('/taskboard/rename_column', { id : columnId, name : name });
		},
		renameCard : function(cardId, name){
			TASKBOARD.remote.callback('/card/update_name', { id : cardId, name : name });
		},
		updateCardNotes : function(cardId, notes){
			TASKBOARD.remote.callback('/card/update_notes', { id : cardId, notes : notes });
		},
		addTags : function(cardId, tags){
			TASKBOARD.remote.callback('/card/add_tag', { id : cardId, tags : tags });
		},
		removeTag : function(cardId, tag){
			TASKBOARD.remote.callback('/card/remove_tag', { id : cardId, tag : tag });
		},
		deleteColumn : function(columnId){
			TASKBOARD.remote.callback('/taskboard/remove_column/', { id: columnId });
		},
		cleanColumn : function(columnId){
			TASKBOARD.remote.callback('/taskboard/clean_column/', { id: columnId });
		},
		deleteRow : function(rowId){
			TASKBOARD.remote.callback('/taskboard/remove_row/', { id: rowId });
		},
		cleanRow : function(rowId){
			TASKBOARD.remote.callback('/taskboard/clean_row/', { id: rowId });
		},
		updateCardHours : function(cardId, hours, updatedAt){
			TASKBOARD.remote.callback('/card/update_hours/', { id: cardId, hours_left: hours, updated_at: updatedAt });
		},
		deleteCard : function(cardId){
			TASKBOARD.remote.callback('/taskboard/remove_card/', { id: cardId });
		},
		changeCardColor : function(cardId, color){
			TASKBOARD.remote.callback('/card/change_color/', { id: cardId, color : color });
		}
	}
};


/*
 * Implementation of synchronisation API.
 * These methods are launched by synchronisation service (via juggernaut).
 */
window.sync = {
	call : function(action, json, self){
		if(typeof(self) === 'undefined'){ self = false; }
		var callback = !self ? TASKBOARD.remote.checkStatus(json) === 'success' : true;
		if(callback){
			$.notify(json.message);
			TASKBOARD.api[action](json.object);
		}
	}
};

$.each(['renameTaskboard',
		'addColumn', 'renameColumn', 'moveColumn', 'deleteColumn', 'cleanColumn',
		'addRow', 'deleteRow', 'cleanRow',
		'addCards','moveCard','updateCardHours','changeCardColor','deleteCard', 'renameCard', 'updateCard'],
		function(){
			var action = this;
			sync[action] = function(data, self){
				sync.call(action, data, self);
			};
		});

/* TODO refactor notifications */
$(document).ready(function() {
	$('body').append('<ol id="notifications"></ol>');
});

$.notify = function(msg, options){
	var settings = { cssClass : "", timeout : 5000 };
	$.extend(settings, options);

	var notification = $("<li></li>");
	if(settings.cssClass){
		notification.addClass(settings.cssClass);
	}
	notification.text(msg);
	notification.click(function(){ $(this).fadeOut(); });
	$("#notifications").prepend(notification);
	if(settings.timeout > 0){
		setTimeout(function(){ notification.fadeOut(); }, settings.timeout);
	}
};

/* TODO: clean up */
$.each(["connect", "connected", "errorConnecting", "disconnected", "reconnect", "noFlash"], function(){
	var self = this;
	var msgs = {
		"initialized" : "Synchronization service initialized.",
		"connect"     : "Trying to connect to synchronization service.",
		"connected"   : "Successfully connected to synchronization service.",
		"errorConnecting" : "Cannot connect to synchronization service.",
		"disconnected" : "Connection with synchronization service was lost.",
		"reconnect" : "Trying to reconnect with synchronisation service.",
		"noFlash" : "Flash plugin was not detected! Real time synchronisation will not work."
	};
	$(document).bind("juggernaut:" + self, function(){
		$.notify(msgs[self]);
	});
});

$(document).bind("juggernaut:connected", function(){
	TASKBOARD.refresh();
});


TASKBOARD.cookie = {
	// all cookies are valid for 30 days
	options : { expires: 30 },

	getColumnWidth : function(columnId){
		return $.cookie('column_width_' + columnId);
	},

	setColumnWidth : function(columnId, width){
		return $.cookie('column_width_' + columnId, width, this.options);
	},

	getTaskboardZoom : function(taskboardId){
		return $.cookie('taskboard_zoom_' + taskboardId);
	},

	setTaskboardZoom : function(taskboardId, zoom){
		return $.cookie('taskboard_zoom_' + taskboardId, zoom, this.options);
	}
};



})(jQuery); // just to make sure $ was a jQuery

