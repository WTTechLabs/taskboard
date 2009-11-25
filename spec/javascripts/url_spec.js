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
require("../../public/javascripts/url.js");

$.address = {}
TASKBOARD.tags = {}

Screw.Unit(function(){
  describe("Url tools", function(){

    it("should define TASKBOARD.url namespace", function(){
      expect(TASKBOARD.url).to_not(be_undefined);
    });

    describe("on initialization", function(){
        it("init method should be defined", function(){
          expect(TASKBOARD.url.init).to(be_function);
        });

        it("should do stuff", function(){
          Smok($.address).expects('parameterNames').returns(['selected_tags']);
          Smok($.address).expects('parameter').returns('tag1,tag 2');
          Smok(TASKBOARD.url).expects('onChange').with_args({ selected_tags: 'tag1,tag 2' });
          Smok($.address).expects('change');
          TASKBOARD.url.init();
        });
    });

    describe("on url change event", function(){
        it("onChange method should be defined", function(){
          expect(TASKBOARD.url.onChange).to(be_function);
        });

        it("should import tags selection using list of selected tasks", function(){
          Smok(TASKBOARD.tags).expects('importSelection').with_args('', false);
          TASKBOARD.url.onChange({ });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('', false);
          TASKBOARD.url.onChange({ selected_tags: '' });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('tag1', false);
          TASKBOARD.url.onChange({ selected_tags: 'tag1' });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('tag1,tag 2', false);
          TASKBOARD.url.onChange({ selected_tags: 'tag1,tag 2' });
        });

        it("should import tags selection using no_tags param", function(){
          Smok(TASKBOARD.tags).expects('importSelection').with_args('', false);
          TASKBOARD.url.onChange({ });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('', true);
          TASKBOARD.url.onChange({ no_tags: '' });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('', true);
          TASKBOARD.url.onChange({ no_tags: 'true' });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('', true);
          TASKBOARD.url.onChange({ no_tags: 'something' });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('', false);
          TASKBOARD.url.onChange({ no_tags: 'false' });
        });

        it("should import tags selection using combo params", function(){
          Smok(TASKBOARD.tags).expects('importSelection').with_args('', true);
          TASKBOARD.url.onChange({ selected_tags: '', no_tags: '' });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('tag1', true);
          TASKBOARD.url.onChange({ selected_tags: 'tag1', no_tags: 'true' });

          Smok(TASKBOARD.tags).expects('importSelection').with_args('tag1', false);
          TASKBOARD.url.onChange({selected_tags: 'tag1',  no_tags: 'false' });
        });
    });

    describe("when updating url", function(){
        it("silentUpdate method should be defined", function(){
          expect(TASKBOARD.url.silentUpdate).to(be_function);
        });

        it("should format correct url for not supported parameter", function(){
          //Smok($.address).expects('parameter').with_args('selected_tags').returns(undefined);
          //Smok($.address).expects('parameter').with_args('no_tags').returns(undefined);
          Smok($.address).expects('parameter').exactly(2, 'times').returns(undefined);
          Smok($.address).expects('value').with_args('');
          TASKBOARD.url.silentUpdate('new_param', 'new_value');
        });

        it("should format correct url for supported parameter", function(){
          Smok($.address).expects('parameter').exactly(1, 'times').returns(undefined);
          Smok($.address).expects('value').with_args('?selected_tags=new_value');
          TASKBOARD.url.silentUpdate('selected_tags', 'new_value');
        });

        it("should format correct url for supported parameter and already existing parameters", function(){
          Smok($.address).expects('parameter').exactly(1, 'times').returns('no_tags_value');
          Smok($.address).expects('value').with_args('?selected_tags=new_value&no_tags=no_tags_value');
          TASKBOARD.url.silentUpdate('selected_tags', 'new_value');

          Smok($.address).expects('parameter').exactly(1, 'times').returns('selected_tags_value');
          Smok($.address).expects('value').with_args('?selected_tags=selected_tags_value&no_tags=new_value');
          TASKBOARD.url.silentUpdate('no_tags', 'new_value');
        });
    });

    describe("when updating url: selectedTags", function(){
        it("should be defined", function(){
          expect(TASKBOARD.url.updateSelectedTags).to(be_function);
        });

        it("should perform correct url update", function(){
          Smok(TASKBOARD.url).expects('silentUpdate').with_args('selected_tags', 'tag1');
          TASKBOARD.url.updateSelectedTags('tag1');

          Smok(TASKBOARD.url).expects('silentUpdate').with_args('selected_tags', 'tag1,tag 2');
          TASKBOARD.url.updateSelectedTags('tag1,tag 2');

          Smok(TASKBOARD.url).expects('silentUpdate').with_args('selected_tags', undefined);
          TASKBOARD.url.updateSelectedTags('');

          Smok(TASKBOARD.url).expects('silentUpdate').with_args('selected_tags', undefined);
          TASKBOARD.url.updateSelectedTags(undefined);
        });
    });

    describe("when updating url: updateNoTags", function(){
        it("should be defined", function(){
          expect(TASKBOARD.url.updateNoTags).to(be_function);
        });
        
        it("should perform correct url update", function(){
          Smok(TASKBOARD.url).expects('silentUpdate').with_args('no_tags', '');
          TASKBOARD.url.updateNoTags('true');

          Smok(TASKBOARD.url).expects('silentUpdate').with_args('no_tags', '');
          TASKBOARD.url.updateNoTags('false');

          Smok(TASKBOARD.url).expects('silentUpdate').with_args('no_tags', '');
          TASKBOARD.url.updateNoTags('trash');

          Smok(TASKBOARD.url).expects('silentUpdate').with_args('no_tags', undefined);
          TASKBOARD.url.updateNoTags('');

          Smok(TASKBOARD.url).expects('silentUpdate').with_args('no_tags', undefined);
          TASKBOARD.url.updateNoTags(undefined);
        });
    });

  });
});
