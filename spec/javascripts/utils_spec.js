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
require("../../public/javascripts/utils.js");

Screw.Unit(function(){
  describe("Utils Prototypes", function(){

    describe("String.prototype", function(){

      describe("#trim", function(){
        it("should be defined", function(){
          expect(String.prototype.trim).to(be_function);
        });

        it("should return trimmed string", function(){
          expect("    trimmed string    ".trim()).to(equal, "trimmed string");
        });
      });

      describe("#lowerFirst", function(){
        it("should be defined", function(){
          expect(String.prototype.lowerFirst).to(be_function);
        });

        it("should return string with first letter in lower case", function(){
          expect("LowerFirstLetter".lowerFirst()).to(equal, "lowerFirstLetter");
        });

        it("should do nothing on empty strings", function(){
          expect("".lowerFirst()).to(equal, "");
        });
      });

      describe("#escapeHTML", function(){
        it("should be defined", function(){
          expect(String.prototype.escapeHTML).to(be_function);
        });

        it("should escape HTML tags and ampersand", function(){
          expect("<p>Test & test</p>".escapeHTML()).to(equal, "&lt;p&gt;Test &amp; test&lt;/p&gt;");
        });

        it("shouldn't change string that doesn't contain any HTML", function(){
          expect("Test and test".escapeHTML()).to(equal, "Test and test");
        });
      });

      describe("#toClassName", function(){
        it("should be defined", function(){
          expect(String.prototype.toClassName).to(be_function);
        });

        it("should turn all the spaces into double underscores", function(){
          expect("this is a tag with spaces".toClassName()).to(equal, "this__is__a__tag__with__spaces");
        });

        it("should turn all strange characters into single underscores", function(){
          expect("t4g w!th str@ng3 characters!".toClassName().escapeHTML()).to(equal, "t4g__w_th__str_ng3__characters_");
        });

        it("shouldn't change strings that are OK to be a class name", function(){
          expect("tag_that-is_OK".toClassName()).to(equal, "tag_that-is_OK");
        });
      });

    }); // String.prototype

    describe("Array.prototype", function(){

      describe("#sortBy", function(){
        var arrayToSort;

        before(function(){
          arrayToSort = [ { key : 3, value : 10 }, { key : 2, value : 30 }, { key : 1, value : 20 } ];
        });

        it("should be defined", function(){
          expect(Array.prototype.sortBy).to(be_function);
        });
        
        it("should sort properly by one key", function(){
          var arraySortedByNumeric = [ arrayToSort[2], arrayToSort[1], arrayToSort[0] ];
          expect(arrayToSort.sortBy('key')).to(equal, arraySortedByNumeric);
        });

        it("should sort properly by other key", function(){
          var arraySortedByString = [ arrayToSort[0], arrayToSort[2], arrayToSort[1] ];
          expect(arrayToSort.sortBy('value')).to(equal, arraySortedByString);
        });
      });

      describe("#sortByPosition", function(){
        it("should be defined", function(){
          expect(Array.prototype.sortBy).to(be_function);
        });

        it("should sort properly by 'position' key", function(){
          var arrayToSort = [ { position : 2 }, { position : 3 }, { position : 1 } ];
          var arraySorted = [ arrayToSort[2], arrayToSort[0], arrayToSort[1] ];
          expect(arrayToSort.sortByPosition()).to(equal, arraySorted);
        });
      });

    }); // Array.prototype

  }); // Utils prototypes
  
  describe("Utils jQuery", function(){

    describe("#exists", function(){
      it("should be defined", function(){
        expect($.fn.exists).to(be_function);
      });

      it("should be true for existing element", function(){
        expect($('#main').exists()).to(be_true);
      });

      it("should be false for non-existing element", function(){
        expect($('#nonexisting').exists()).to(be_false);
      });
    });

    describe("#sumWidth", function(){
      it("should be defined", function(){
        expect($.fn.sumWidth).to(be_function);
      });

      it("should properly count width of elements", function(){
        $('#main').css('visibility', 'hidden').show();
        var expectedWidth = 0;
        $('#main div').each(function(i, div){
          var width = 300 / (i + 1),
              margin = width / 10;
          $(this).css({ width: width, marginLeft: margin, marginRight: margin });
          expectedWidth += width + 2 * margin;
        });

        expect($('#main div').sumWidth()).to(equal, expectedWidth);

        $('#main div').css({ width: "", marginLeft: "", marginRight: "" });
        $('#main').css('visibility', '').hide();
      });
    });

    describe("#sumHeight", function(){
      it("should be defined", function(){
        expect($.fn.sumHeight).to(be_function);
      });

      it("should properly count height of elements", function(){
        $('#main').css('visibility', 'hidden').show();
        var expectedHeight = 0;
        $('#main div').each(function(i, div){
          var height = 300 / (i + 1),
              margin = height / 10;
          $(this).css({ height: height, marginTop: margin, marginBottom: margin });
          expectedHeight += height + 2 * margin;
        });

        expect($('#main div').sumHeight()).to(equal, expectedHeight);

        $('#main div').css({ height: "", marginTop: "", marginBottom: "" });
        $('#main').css('visibility', '').hide();
      });
    });

    describe("#equalHeight", function(){
      it("should be defined", function(){
        expect($.fn.equalHeight).to(be_function);
      });

      it("should properly set heights of elements", function(){
        $('#main').css('visibility', 'hidden').show();
        $('#main div').each(function(i, div){
          var height = 300 / (i + 1);
          $(this).css({ height: height });
        });

        $('#main div').equalHeight();

        expect($('#divA').css('min-height')).to(equal, '300px');
        expect($('#divB').css('min-height')).to(equal, '300px');
        expect($('#divC').css('min-height')).to(equal, '300px');

        $('#main div').css({ height: "" });
        $('#main').css('visibility', '').hide();
      });
    });

    describe("#rollover", function(){
      it("should be defined", function(){
        expect($.fn.rollover).to(be_function);
      });

      it("should properly set image of hovered element", function(){
        $('img').attr("src", "rollover_test_off.png").rollover();
        $('img').mouseover();
        expect($('img').attr('src')).to(equal, "rollover_test_on.png");

        $('img').mouseout();
        expect($('img').attr('src')).to(equal, "rollover_test_off.png");
      });
    });

    describe("#tag", function(){
      it("should be defined", function(){
        expect($.tag).to(be_function);
      });

      it("should build empty tag", function(){
        expect($.tag("span")).to(equal, "<span></span>");
      });

      it("should build an element with text in it", function(){
        expect($.tag("p", "text")).to(equal, "<p>text</p>");
      });

      it("should build empty tag if no content is defined", function(){
        expect($.tag("span", { id : "testingEmptySpan" })).to(equal, "<span id=\"testingEmptySpan\"></span>");
      });

      it("should build link tag with text and attributes", function(){
        expect($.tag("a", "example", { href : "http://example.com", rel : "external" })).to(equal, "<a href=\"http://example.com\" rel=\"external\">example</a>");
      });

      it("should build tag with 'class' attribute if 'className' param is given", function(){
        expect($.tag("div", "div with class", { className : "class" })).to(equal, "<div class=\"class\">div with class</div>");
      });
    });

  }); // Utils jQuery
});
