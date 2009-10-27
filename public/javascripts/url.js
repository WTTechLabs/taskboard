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

TASKBOARD.url = {

    // list of supported url parameters
    parametersNames: ["tags","no_tags"],

    // indicates whether to interecept changes in url or not
    interceptUrlChanges: true,

    // initializes TASKBOARD.url module
    init : function() {
        // check what has been requested on init
        var parameters = {};
        $.each(this.parametersNames, function() {
            parameters[this] = $.address.parameter(this);
        });
        this.onChange(parameters);

        // connect to event
        $.address.change(function(event) {
            if (TASKBOARD.url.interceptUrlChanges) {
                TASKBOARD.url.onChange(event.parameters);
            }
        });
    },

    // to be invoked when url changes (only the value part)
    // i.e.: parameters.tags, parameters.other_propery_name
    onChange : function(parameters) {
        TASKBOARD.tags.importSelection(
            parameters.tags ? parameters.tags : "",
            parameters.no_tags || parameters.no_tags.lebgth == 0 ? parameters.no_tags != "false" : false);
    },

    // silent update of url - no event will be risen (onChange)
    silentUpdate : function(parameterName, parameterValue) {
        var urlValue = "";
        $.each(this.parametersNames, function() {
            var value = (this == parameterName) ? parameterValue : $.address.parameter(this);
            if(value) urlValue += this + "=" + value + "&";
        });
        this.interceptUrlChanges = false;
        $.address.value(urlValue.length==0 ? "" : "?" + urlValue.substr(0,urlValue.length-1));
        this.interceptUrlChanges = true;
    },

    // updates url with new tags selection
    updateSelectedTags : function(tagsSelection) {
        this.silentUpdate("tags", tagsSelection);
    },

    // updates url with no tags selection
    updateNoTags : function(toggled) {
        this.silentUpdate("no_tags", toggled);
    }
};