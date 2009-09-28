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
        $("#projects > dt").addClass("toggleable")
           .click(function(){
               $(this).toggleClass("closed")
                   .next("dd").toggle("blind");
            });

        $(".addTaskboard, .addProject").addClass("toggleable closed")
            .find("label")
                 .click(function(ev){
                    $(this).closest(".toggleable").toggleClass("closed")
                        .find(":text").focus();
                 });

        var toggleClassAdd = function(){ $(this).closest(".taskboards > li").toggleClass("add"); }
        $(".cloneTaskboard").hover(toggleClassAdd, toggleClassAdd);

        $("form").submit(function(){
            var input = $(this).find(":text");
            if(input.val().trim().length === 0 || input.val().match(/Enter some nice name for your new (project|taskboard)/)){;
                input.effect("highlight", { color: "#FF0000" }).focus().select();
                return false;
            }
        });
    }
}

$(document).ready(TASKBOARD.home.init);

})();

