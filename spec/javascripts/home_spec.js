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

$(function(){ $(document).unbind('ready.home'); });

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

          var nameSpan = $("dt .name").attr("title", "old name"),
              value = 'new name',
              returned = '';

          Smok(String.prototype).expects('trim').returns(value);
          Smok(String.prototype).expects('escapeHTML').returns(value);
          Smok(String.prototype).expects('truncate').with_args(25).returns(value);
          Smok($).expects('getJSON');

          returned = TASKBOARD.home.callbacks.renameProject.call(nameSpan, value);
          expect(returned).to(equal, value);
          expect(nameSpan.attr("title")).to(equal, value);
        });

        it("should keep old value and show warning when empty value is entered", function(){
          var oldValue = 'old name',
              nameSpan = $("dt .name").attr("title", oldValue),
              value = '   ',
              returned = '';
          nameSpan[0].revert = oldValue;

          Smok(String.prototype).expects('trim').returns('');
          Smok(String.prototype).expects('escapeHTML').exactly(0, 'times');
          Smok(String.prototype).expects('truncate').exactly(0, 'times');
          Smok($).expects('getJSON').exactly(0, 'times');

          $(nameSpan[0]).expects('warningTooltip').with_args("Name cannot be blank!");

          returned = TASKBOARD.home.callbacks.renameProject.call(nameSpan[0], value);
          expect(returned).to(equal, oldValue);
          expect(nameSpan.attr("title")).to(equal, oldValue);
        });

      });

      describe("#clickRenameProject", function(){

        it("should remove class 'rename' from containing element and trigger 'rename' event", function(){
          var icon = $(".renameProject"),
              dt = icon.closest("dt").addClass("rename");
          dt.find(".name").expects('trigger').with_args('rename');
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
              toggleable = $(".addTaskboard").addClass("toggleable").removeClass("closed"),
              text = toggleable.find(":text");
          text.expects("focus");

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
          dt.find("form").expects("exists").returns(false);
          dd.expects("toggle").with_args("blind");

          TASKBOARD.home.callbacks.clickProjectTitle.apply(dt[0]);

          expect(dt.hasClass("closed")).to(be_true);
          expect(toggleable.hasClass("closed")).to(be_true);
        });

        it("should do nothing if rename form is opened in project name", function(){
          var dt = $("#projects > dt").removeClass("closed"),
              dd = dt.next("dd");
          dt.find("form").expects("exists").returns(true);
          dd.expects("toggle").with_args("blind").exactly(0, 'times');

          TASKBOARD.home.callbacks.clickProjectTitle.apply(dt[0]);

          expect(dt.hasClass("closed")).to(be_false);
        });

      });

      describe("#clickExpand", function(){

        it("should expand all projects", function(){
          var dt = $("#projects > dt").addClass("closed"),
              dd = dt.next("dd");
          dd.expects("show").with_args("blind");
          TASKBOARD.home.callbacks.clickExpand.call();
          expect(dt.hasClass('closed')).to(be_false);
        });

      });

      describe("#clickCollapse", function(){

        it("should collapse all projects", function(){
          var dt = $("#projects > dt").removeClass("closed"),
              dd = dt.next("dd"),
              toggleable = dd.find(".addTaskboard").addClass(".toggleable").removeClass("closed");
          dd.expects("hide").with_args("blind");
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
          text.expects("val").returns("");
          Smok(String.prototype).expects("trim").returns("");
          text.expects("effect").with_args("highlight", { color: "#FF0000" });
          text.expects("focus");
          text.expects('warningTooltip').with_args("Name cannot be blank!");

          submitted = TASKBOARD.home.callbacks.submitForm.call(form[0]);
          expect(submitted).to_not(be_undefined);
          expect(submitted).to(be_false);
        });

        it("should highlight text field when value was not changed", function(){
          var form = $(".addProject form"),
              text = $(".addProject form :text").removeData("changed"),
              submitted = true;
          text.expects("val").returns('some value');
          Smok(String.prototype).expects("trim").returns('some value');
          text.expects("effect").with_args("highlight", { color: "#FF0000" });
          text.expects("focus");
          text.expects('warningTooltip').exactly(0, 'times');

          submitted = TASKBOARD.home.callbacks.submitForm.call(form[0]);
          expect(submitted).to_not(be_undefined);
          expect(submitted).to(be_false);
        });

        it("should submit form when correct value is entered", function(){
          var form = $(".addProject form"),
              text = $(".addProject form :text").data("changed", true)
              value = "correct value",
              submitted = true;
          text.expects("val").returns(value);
          Smok(String.prototype).expects("trim").returns(value);
          text.expects("effect").exactly(0, 'times');

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
          parent.find("form").expects("exists").returns(false);

          TASKBOARD.home.callbacks.toggleAction.call(icon, $.Event("mouseenter"));
          expect(parent.hasClass(rel)).to(be_true);
          expect(actionName.text()).to(equal, "(" + rel + ")");
        });

        it("should remove class from containing element and hide action name when unhovered", function(){
          var icon = $(".cloneTaskboard"),
              rel = icon.attr("rel"),
              parent = icon.parent().parent().parent().addClass(rel),
              actionName = parent.find(".actionName").text("(" + rel + ")");
          parent.find("form").expects("exists").returns(false);

          TASKBOARD.home.callbacks.toggleAction.call(icon, $.Event("mouseleave"));
          expect(parent.hasClass(rel)).to(be_false);
          expect(actionName.text()).to(be_empty);
        });

        it("should not change class when form is opened in containing element", function(){
          var icon = $(".cloneTaskboard"),
              rel = icon.attr("rel"),
              parent = icon.parent().parent().parent().removeClass(rel),
              actionName = parent.find(".actionName").text("");
          parent.find("form").expects("exists").returns(true);

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
          $("dt .name").expects("editable")
//          .with_args(TASKBOARD.home.callbacks.renameProject, { event: 'rename', select: true, height: 'none' });
          TASKBOARD.home.init();
        });
      });

      describe("while initializing events", function(){

        it("should bind click event to projects' title elements", function(){
          Smok(TASKBOARD.home.callbacks).expects('clickProjectTitle');
          TASKBOARD.home.init();
          $("#projects > dt").click();
        });

        it("should bind click events to global expand/collapse actions", function(){
          Smok(TASKBOARD.home.callbacks).expects('clickExpand');
          Smok(TASKBOARD.home.callbacks).expects('clickCollapse');
          TASKBOARD.home.init();
          $(".globalActions .expand").click();
          $(".globalActions .collapse").click();
        });

        it("should bind click events to add form labels", function(){
          Smok(TASKBOARD.home.callbacks).expects('clickAdd').exactly(2, 'times');
          TASKBOARD.home.init();
          $(".addTaskboard label").click();
          $(".addProject label").click();
        });

        it("should bind click events to rename project icon", function(){
          Smok(TASKBOARD.home.callbacks).expects('clickRenameProject');
          TASKBOARD.home.init();
          var event = $.Event("click");
          event.stopPropagation(); // make sure clicking doesn't propagate to parent element
          $(".renameProject").trigger(event);
        });

        it("should bind hover events to icons", function(){
          Smok(TASKBOARD.home.callbacks).expects('toggleAction').exactly(4, 'times');
          TASKBOARD.home.init();
          $(".cloneTaskboard").mouseenter().mouseleave();
          $(".renameProject").mouseenter().mouseleave();
        });

        it("should bind change event to text inputs", function(){
          Smok(TASKBOARD.home.callbacks).expects('changeInput').exactly(2, 'times');
          TASKBOARD.home.init();
          $(".addTaskboard :text").change();
          $(".addProject :text").change();
        });

        it("should bind submit event to forms", function(){
          Smok(TASKBOARD.home.callbacks).expects('submitForm').exactly(2, 'times').returns(false);;
          TASKBOARD.home.init();
          $(".addTaskboard form").submit();
          $(".addProject form").submit();
        });

      });

    });

  });

});
