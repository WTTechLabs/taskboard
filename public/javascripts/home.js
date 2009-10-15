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
 
(function(){
var TASKBOARD = window.TASKBOARD = {} || TASKBOARD;

TASKBOARD.home = {
    init: function(){
        var callbacks = TASKBOARD.home.callbacks;

        $("#projects > dt").addClass("toggleable")
           .click(callbacks.clickProjectTitle)
           .each(function(){
                $(this).data("id", $(this).attr("id").match(/\d+/)[0]);
            });

        $("dt .name").editable(callbacks.renameProject, { event: 'rename', select: true, height: 'none',
            data: function(){ return $(this).attr("title").unescapeHTML(); } });

        $("#projects .globalActions")
            .find(".expand")
                .click(callbacks.clickExpand).end()
            .find(".collapse")
                .click(callbacks.clickCollapse);

        $(".addTaskboard, .addProject").addClass("toggleable closed")
            .find("label")
                 .click(callbacks.clickAdd);

        $(".cloneTaskboard").hover(callbacks.toggleAction, callbacks.toggleAction);
        $(".renameProject").hover(callbacks.toggleAction, callbacks.toggleAction)
            .click(callbacks.clickRenameProject)

        $("form").submit(callbacks.submitForm)
           .find(":text").change(callbacks.changeInput);
    },
    callbacks: {
        renameProject: function(value){
            if(value.trim().length > 0) {
                $.getJSON("/project/rename", { id: $(this).closest("dt").data("id"), name: value });
                $(this).attr("title", value);
                value = value.escapeHTML();
                return value.truncate(25);
            } else {
                $(this).warningTooltip("Name cannot be blank!");
                return this.revert;
            }
        },

        clickRenameProject: function(event){
            event.stopPropagation(); event.preventDefault();
            $(this).closest("dt")
                .removeClass("rename")
                .find(".name").trigger("rename");
        },

        clickAdd: function(){
            $(this).closest(".toggleable").toggleClass("closed")
                .find(":text").focus();
        },

        clickProjectTitle: function(){
            if(!$(this).find("form").exists()){
                $(this).toggleClass("closed")
                    .next("dd").toggle("blind")
                    .find(".toggleable").addClass("closed");
            }
        },

        clickExpand: function(){
            $("#projects > dt.closed").removeClass("closed")
                .next("dd").show("blind");
            return false;
        },

        clickCollapse: function(){
            $("#projects > dt:not(.closed)").addClass("closed")
                .next("dd").hide("blind")
                    .find(".toggleable").addClass("closed");
            return false;
        },

        changeInput: function(){
            $(this).data("changed", true);
        },

        submitForm: function(){
            var input = $(this).find(":text");
            if(input.val().trim().length === 0 || input.data("changed") !== true){;
                input.effect("highlight", { color: "#FF0000" }).focus().select();
                if(input.data("changed")){
                    input.warningTooltip("Name cannot be blank!");
                }
                return false;
            }
        },

        toggleAction: function(event){
            var actionName = event.type === 'mouseenter' ? "(" + $(this).attr("rel") + ")" : "",
                parentToToggle = $(this).parent().parent().parent();
            if(!parentToToggle.find("form").exists()){
                parentToToggle.toggleClass($(this).attr("rel"), event.type === 'mouseenter')
            }
            parentToToggle.find(".actionName").text(actionName);
        }
    }
}

$(document).bind('ready.home', TASKBOARD.home.init);

})();

