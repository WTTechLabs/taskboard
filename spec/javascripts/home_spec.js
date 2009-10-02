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
require("../../public/javascripts/home.js");

Screw.Unit(function(){

  describe("TASKBOARD.home", function(){

    it("should define TASKBOARD.home namespace", function(){
      expect(TASKBOARD.home).to_not(be_undefined);
    });

    it("should define TASKBOARD.home.callbacks namespace", function(){
      expect(TASKBOARD.home.callbacks).to_not(be_undefined);
    });

    describe(".callbacks", function(){

      describe("#renameProject", function(){

        it("should send rename request when correct value is entered", function(){
          var nameSpan = $("dt .name")[0],
              value = 'new name',
              returned = '';
          String.prototype.trim = mock_function();
          String.prototype.trim.should_be_invoked().exactly('once').and_return(value);
          String.prototype.escapeHTML = mock_function();
          String.prototype.escapeHTML.should_be_invoked().exactly('once').and_return(value);

          $.getJSON = mock_function($.getJSON, "getJSON");
          $.getJSON.should_be_invoked().exactly('once').and_return('nothing');

          returned = TASKBOARD.home.callbacks.renameProject.call(nameSpan, value);
          expect(returned).to(equal, value);
        });

        it("should keep old value and show warning when empty value is entered", function(){
          var nameSpan = $("dt .name")[0],
              oldValue = 'old value',
              value = '   ',
              returned = '';
          nameSpan.revert = oldValue;

          String.prototype.trim = mock_function();
          String.prototype.trim.should_be_invoked().exactly('once').and_return('');
          String.prototype.escapeHTML = mock_function();
          String.prototype.escapeHTML.should_be_invoked().exactly(0);

          $.getJSON = mock_function($.getJSON, "getJSON");
          $.getJSON.should_be_invoked().exactly(0);

          $.fn.tooltip = mock_function();
          $.fn.tooltip.should_be_invoked().with_arguments("Name cannot be blank!").exactly('once');

          returned = TASKBOARD.home.callbacks.renameProject.call(nameSpan, value);
          expect(returned).to(equal, oldValue);
        });

      });

      describe("#clickRenameProject", function(){

        it("should remove class 'rename' from containing element and trigger 'rename' event", function(){
          var icon = $(".renameProject"),
              dt = icon.closest("dt").addClass("rename");
          renameCallback = mock_function();
          renameCallback.should_be_invoked().exactly('once');
          dt.find(".name").bind('rename', renameCallback);

          TASKBOARD.home.callbacks.clickRenameProject.call(icon, $.Event('click'));
          expect(dt.hasClass('rename')).to(be_false);
        });

        it("should stop click event propagation and disable default action", function(){
          var event = $.Event("click");
          TASKBOARD.home.callbacks.clickRenameProject.call(document, event);
          expect(event.isPropagationStopped()).to(be_true);
          expect(event.isDefaultPrevented()).to(be_true);
        });

      });

      describe("#clickAdd", function(){

        it("should toggle class 'closed' and focus in text field", function(){
          var label = $(".addTaskboard label"),
              toggleable = $(".addTaskboard").addClass("toggleable"),
              text = toggleable.find(":text");
          expect(toggleable.hasClass("closed")).to(be_false);

          $.fn.find = mock_function($.fn.find, "find")
          $.fn.find.should_be_invoked().with_arguments(":text").exactly('once').and_return(text);
          mock(text).should_receive("focus").exactly('once');

          TASKBOARD.home.callbacks.clickAdd.apply(label[0]);

          expect(toggleable.hasClass("closed")).to(be_true);
        });

      });

      describe("#clickProjectTitle", function(){

        after(function(){
          $("#projects > dt").removeClass("closed");
        });

        it("should toggle class 'closed' and taskboards' list when project name is clicked", function(){
          var dt = $("#projects > dt").removeClass("closed"),
              dd = dt.next("dd"),
              toggleable = dd.find(".addTaskboard").addClass(".toggleable").removeClass("closed");
          $.fn.exists = mock_function($.fn.exists, "exists");
          $.fn.exists.should_be_invoked().exactly(1).and_return(false); // find("form").exists = false

          $.fn.next = mock_function($.fn.next, "next");
          $.fn.next.should_be_invoked().with_arguments("dd").exactly('once').and_return(dd);
          mock(dd).should_receive("toggle").with_arguments("blind").exactly('once').and_return(dd);

          TASKBOARD.home.callbacks.clickProjectTitle.apply(dt[0]);

          expect(dt.hasClass("closed")).to(be_true);
          expect(toggleable.hasClass("closed")).to(be_true);
        });

        it("should do nothing if rename form is opened in project name", function(){
          var dt = $("#projects > dt"),
              dd = dt.next("dd");
          expect(dt.hasClass("closed")).to(be_false);

          $.fn.exists = mock_function($.fn.exists, "exists");
          $.fn.exists.should_be_invoked().exactly(1).and_return(true); // find("form").exists = true

          $.fn.next = mock_function($.fn.next, "next");
          $.fn.next.should_be_invoked().with_arguments("dd").exactly(0)
          mock(dd).should_receive("toggle").with_arguments("blind").exactly(0);

          TASKBOARD.home.callbacks.clickProjectTitle.apply(dt[0]);

          expect(dt.hasClass("closed")).to(be_false);
        });

      });

      describe("#clickExpand", function(){

        it("should expand all projects", function(){
          var dt = $("#projects > dt").addClass("closed"),
              dd = dt.next("dd");
          $.fn.next = mock_function($.fn.next, "next");
          $.fn.next.should_be_invoked().with_arguments("dd").exactly('once').and_return(dd);
          mock(dd).should_receive("show").with_arguments("blind").exactly('once');
          TASKBOARD.home.callbacks.clickExpand.call();
          expect(dt.hasClass('closed')).to(be_false);
        });

      });

      describe("#clickCollapse", function(){

        it("should collapse all projects", function(){
          var dt = $("#projects > dt").removeClass("closed"),
              dd = dt.next("dd"),
              toggleable = dd.find(".addTaskboard").addClass(".toggleable").removeClass("closed");
          $.fn.next = mock_function($.fn.next, "next");
          $.fn.next.should_be_invoked().with_arguments("dd").exactly('once').and_return(dd);
          mock(dd).should_receive("hide").with_arguments("blind").exactly('once').and_return(dd);
          TASKBOARD.home.callbacks.clickCollapse.call();
          expect(dt.hasClass('closed')).to(be_true);
          expect(toggleable.hasClass('closed')).to(be_true);
        });

      });

      describe("#changeInput", function(){

        it("should store a flag that value was changed", function(){
          var input = $(".addProject :text").removeData("changed");
          TASKBOARD.home.callbacks.changeInput.call(input);
          expect(input.data("changed")).to(be_true);
        });

      });

      describe("#submitForm", function(){

        it("should highlight text field when empty name is submitted", function(){
          var form = $(".addProject form"),
              text = $(".addProject form :text"),
              submitted = true;
          $.fn.val = mock_function($.fn.val, "val");
          $.fn.val.should_be_invoked().exactly('once').and_return('');

          String.prototype.trim = mock_function();
          String.prototype.trim.should_be_invoked().exactly('once').and_return('');

          $.fn.effect = mock_function($.fn.effect, "effect");
          $.fn.effect.should_be_invoked().with_arguments("highlight", { color: "#FF0000" }).exactly("once").and_return(text);
          mock(text).should_receive("focus").exactly("once").and_return(text);

          submitted = TASKBOARD.home.callbacks.submitForm.call(form[0]);
          expect(submitted).to_not(be_undefined);
          expect(submitted).to(be_false);
        });

        it("should highlight text field when value was not changed", function(){
          var form = $(".addProject form"),
              text = $(".addProject form :text").removeData("changed"),
              submitted = true;
          $.fn.val = mock_function($.fn.val, "val");
          $.fn.val.should_be_invoked().exactly('once').and_return('some value');

          String.prototype.trim = mock_function();
          String.prototype.trim.should_be_invoked().exactly('once').and_return('some value');

          $.fn.effect = mock_function($.fn.effect, "effect");
          $.fn.effect.should_be_invoked().with_arguments("highlight", { color: "#FF0000" }).exactly("once").and_return(text);
          mock(text).should_receive("focus").exactly("once").and_return(text);

          submitted = TASKBOARD.home.callbacks.submitForm.call(form[0]);
          expect(submitted).to_not(be_undefined);
          expect(submitted).to(be_false);
        });

        it("should submit form when correct value is entered", function(){
          var form = $(".addProject form"),
              text = $(".addProject form :text").data("changed", true)
              value = "correct value",
              submitted = true;
          $.fn.val = mock_function($.fn.val, "val");
          $.fn.val.should_be_invoked().exactly('once').and_return(value);

          String.prototype.trim = mock_function();
          String.prototype.trim.should_be_invoked().exactly('once').and_return(value);

          $.fn.effect = mock_function($.fn.effect, "effect");
          $.fn.effect.should_be_invoked().exactly(0);

          submitted = TASKBOARD.home.callbacks.submitForm.call(form[0]);
          expect(submitted).to(be_undefined);
        });

      });

      describe("#toggleAction", function(){

        it("should add class to containing element and show action name when hovered", function(){
          var icon = $(".cloneTaskboard"),
              rel = icon.attr("rel"),
              parent = icon.parent().parent().parent().removeClass(rel),
              actionName = parent.find(".actionName").text("");
          $.fn.exists = mock_function($.fn.exists, "exists");
          $.fn.exists.should_be_invoked().exactly(1).and_return(false); // find("form").exists = false

          TASKBOARD.home.callbacks.toggleAction.call(icon, $.Event("mouseenter"));
          expect(parent.hasClass(rel)).to(be_true);
          expect(actionName.text()).to(equal, "(" + rel + ")");
        });

        it("should remove class from containing element and hide action name when unhovered", function(){
          var icon = $(".cloneTaskboard"),
              rel = icon.attr("rel"),
              parent = icon.parent().parent().parent().addClass(rel),
              actionName = parent.find(".actionName").text("(" + rel + ")");
          $.fn.exists = mock_function($.fn.exists, "exists");
          $.fn.exists.should_be_invoked().exactly(1).and_return(false); // find("form").exists = false

          TASKBOARD.home.callbacks.toggleAction.call(icon, $.Event("mouseleave"));
          expect(parent.hasClass(rel)).to(be_false);
          expect(actionName.text()).to(be_empty);
        });

        it("should not change class when form is opened in containing element", function(){
          var icon = $(".cloneTaskboard"),
              rel = icon.attr("rel"),
              parent = icon.parent().parent().parent().removeClass(rel),
              actionName = parent.find(".actionName").text("");
          $.fn.exists = mock_function($.fn.exists, "exists");
          $.fn.exists.should_be_invoked().exactly(1).and_return(true); // find("form").exists = false

          TASKBOARD.home.callbacks.toggleAction.call(icon, $.Event("mouseenter"));
          expect(parent.hasClass(rel)).to(be_false);
          expect(actionName.text()).to(equal, "(" + rel + ")");
        });

      });

    })

    it("should define init function", function(){
      expect(TASKBOARD.home.init).to(be_function);
    });

    describe("#init", function(){

      after(function(){
        $("#projects *").unbind(); // clean-up events
      })

      describe("while initializing elements", function(){

        before(function(){
          $.fn.editable = function(){ return this }; // mock editable
          TASKBOARD.home.init();
        })

        it("should add 'toggleable' class to all projects' title elements", function(){
          expect($("#projects > dt")).to(match_selector, ".toggleable");
        });

        it("should store project id in title element data", function(){
          expect($("#projects > dt").data("id")).to(equal, 83);
        });

        it("should add 'toggleable' and 'closed' classes to add sections", function(){
          expect($(".addTaskboard, .addProject")).to(match_selector, ".closed.toggleable");
        });

      });

      describe("while initializing plugins", function(){
        it("should make project name editable", function(){
          $.fn.editable = mock_function($.fn.editable, 'editable');
          $.fn.editable.should_be_invoked()
              .with_arguments(TASKBOARD.home.callbacks.renameProject, { event: 'rename', select: true, height: 'none' })
              .exactly('once')
          TASKBOARD.home.init();
        });
      });

      describe("while initializing events", function(){

        it("should bind click event to projects' title elements", function(){
          TASKBOARD.home.callbacks.clickProjectTitle = mock_function(TASKBOARD.home.callbacks.clickProjectTitle, "clickProjectTitle");
          TASKBOARD.home.callbacks.clickProjectTitle.should_be_invoked().exactly('once').and_return('nothing');
          TASKBOARD.home.init();
          $("#projects > dt").click();
        });

        it("should bind click events to global expand/collapse actions", function(){
          TASKBOARD.home.callbacks.clickExpand = mock_function(TASKBOARD.home.callbacks.expandAll, "clickExpand");
          TASKBOARD.home.callbacks.clickExpand.should_be_invoked().exactly('once').and_return('nothing');
          
          TASKBOARD.home.callbacks.clickCollapse = mock_function(TASKBOARD.home.callbacks.collapseAll, "clickCollapse");
          TASKBOARD.home.callbacks.clickCollapse.should_be_invoked().exactly('once').and_return('nothing');
          
          TASKBOARD.home.init();
          $(".globalActions .expand").click();
          $(".globalActions .collapse").click();
        });

        it("should bind click events to add form labels", function(){
          TASKBOARD.home.callbacks.clickAdd = mock_function(TASKBOARD.home.callbacks.expandAll, "clickAdd");
          TASKBOARD.home.callbacks.clickAdd.should_be_invoked().exactly('twice').and_return('nothing');

          TASKBOARD.home.init();
          $(".addTaskboard label").click();
          $(".addProject label").click();
        });

        it("should bind click events to rename project icon", function(){
          TASKBOARD.home.callbacks.clickRenameProject = mock_function(TASKBOARD.home.callbacks.clickRenameProject, "clickRenameProject");
          TASKBOARD.home.callbacks.clickRenameProject.should_be_invoked().exactly('once').and_return('nothing');

          TASKBOARD.home.init();
          var event = $.Event("click");
          event.stopPropagation(); // make sure clicking doesn't propagate to parent element
          $(".renameProject").trigger(event);
        });

        it("should bind hover events to icons", function(){
          TASKBOARD.home.callbacks.toggleAction = mock_function(TASKBOARD.home.callbacks.toggleAction, "toggleAction");
          TASKBOARD.home.callbacks.toggleAction.should_be_invoked().exactly(4, 'times').and_return('nothing');

          TASKBOARD.home.init();
          $(".cloneTaskboard").mouseenter().mouseleave();
          $(".renameProject").mouseenter().mouseleave();
        });

        it("should bind change event to text inputs", function(){
          TASKBOARD.home.callbacks.changeInput = mock_function(TASKBOARD.home.callbacks.changeInput, "changeInput");
          TASKBOARD.home.callbacks.changeInput.should_be_invoked().exactly('twice').and_return('nothing');

          TASKBOARD.home.init();
          $(".addTaskboard :text").change();
          $(".addProject :text").change();
        });

        it("should bind submit event to forms", function(){
          TASKBOARD.home.callbacks.submitForm = mock_function(TASKBOARD.home.callbacks.submitForm, "submitForm");
          TASKBOARD.home.callbacks.submitForm.should_be_invoked().exactly('twice').and_return('nothing');

          TASKBOARD.home.init();
          $(".addTaskboard form").submit();
          $(".addProject form").submit();
        });

      });

    });

  });

});
