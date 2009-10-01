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

        $("dt .name").editable(callbacks.renameProject, { event: 'rename', select: true, height: 'none' });

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

        $("form").submit(callbacks.submitForm);
    },
    callbacks: {
        renameProject: function(value){
            if(value.trim().length > 0) {
                $.getJSON("/project/rename", { id: $(this).closest("dt").data("id"), name: value });
                return value.escapeHTML();
            } else {
                $(this).tooltip("Name cannot be blank!");
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
                    .next("dd").toggle("blind");
            }
        },

        clickExpand: function(){
            $("#projects > dt.closed").removeClass("closed")
                .next("dd").show("blind");
            return false;
        },

        clickCollapse: function(){
            $("#projects > dt:not(.closed)").addClass("closed")
                .next("dd").hide("blind");
            return false;
        },

        submitForm: function(){
            var input = $(this).find(":text");
            if(input.val().trim().length === 0 || input.val().match(/Enter some nice name for your new (project|taskboard)/)){;
                input.effect("highlight", { color: "#FF0000" }).focus().select();
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

$(document).ready(TASKBOARD.home.init);

})();

