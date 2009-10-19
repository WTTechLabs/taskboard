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

    // indicates whether to interecept changes in url or not
    interceptUrlChanges: true,

    // initializes TASKBOARD.url module
    init : function() {
        var requestedUrlValue = $.address.value();

        // perform action indicated by url when page is reloaded
        if (requestedUrlValue != "/") {
            this.onChange(requestedUrlValue.substring(1));
        }

        // connect to event
        $.address.change(function(event) {
            if (TASKBOARD.url.interceptUrlChanges) {
                TASKBOARD.url.onChange(event.value.substring(1));
            }
        });
    },

    // silent update of url - no event will be risen (onChange)
    silentUpdate : function(urlValue) {
        this.interceptUrlChanges = false;
        $.address.value(urlValue);
        this.interceptUrlChanges = true;
    },

    // to be invoked when url changes (only the value part)
    onChange : function(urlValue) {
        TASKBOARD.tags.importSelection(urlValue);
    }
    
};