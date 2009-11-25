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

require("spec_helper.js");
require("../../public/javascripts/tags.js");
require("../../public/javascripts/utils.js");

Screw.Unit(function(){
  describe("Tags tools", function(){

    it("should define TASKBOARD.tags namespace", function(){
      expect(TASKBOARD.tags).to_not(be_undefined);
    });

    describe("while creating tag collection", function(){
        it("add method should be defined", function(){
          expect(TASKBOARD.tags.add).to(be_function);
        });

        it("should create proper tag object", function(){
          var tagObject = TASKBOARD.tags.add('tagName');
          expect(tagObject.tag).to(equal, 'tagName');
          expect(tagObject.className).to(equal, 'tagged_as_tagName');
          expect(tagObject.count).to(equal, 1);

          tagObject = TASKBOARD.tags.add('tagName');
          expect(tagObject.count).to(equal, 2);

          expect(TASKBOARD.tags.tagList['tagName']).to(equal, tagObject);
        });

    });

  });
});
