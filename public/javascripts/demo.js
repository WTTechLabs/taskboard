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

(function($) {
    $(document).ready(function(){
       var login_message = "type \"editor\" or \"viewer\"";
       var password_message = "type \"editor_password\" for editor or \"viewer_password\" for viewer";
       $("input#login").tooltip(login_message, { showEvent: 'focus', hideEvent: 'blur', timeout: false, position: "rightMiddle" }).focus();
       $("input#password").tooltip(password_message, { showEvent: 'focus', hideEvent: 'blur', timeout: false, position: "rightMiddle" });
    });
})(jQuery)