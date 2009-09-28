require("spec_helper.js");
require("../../public/javascripts/home.js");

Screw.Unit(function(){

  describe("Home", function(){

    it("should define TASKBOARD.home namespace", function(){
      expect(TASKBOARD.home).to_not(be_undefined);
    });

    it("should define init function", function(){
      expect(TASKBOARD.home.init).to(be_function);
    });

    describe("#init", function(){

      before(function(){
        TASKBOARD.home.init();
      })

      after(function(){
        $ = jQuery; // unmock $ as jQuery
        // clean-up classes and event that init() adds
        $("#projects > dt").removeClass('toggleable closed').unbind('click');
        $(".addTaskboard, .addProject").removeClass('toggleable closed').find("label").unbind('click');
        $("form").unbind("submit");
      })

      describe("projects sections", function(){

        it("should add 'toggleable' class to all projects' title elements", function(){
          expect($("#projects > dt")).to(match_selector, ".toggleable");
        });

        it("should toggle class 'closed' and taskboards' list when project name is clicked", function(){
          var dt = $("#projects > dt"), toggled_dt = $(dt), dd = dt.next("dd");
          $ = function(){ return dt; }; // mock $(this)
          mock(dt).should_receive("toggleClass").with_arguments("closed").exactly("once").and_return(toggled_dt);
          mock(toggled_dt).should_receive("next").with_arguments("dd").exactly("once").and_return(dd);
          mock(dd).should_receive("toggle").with_arguments("blind").exactly("once");
          jQuery("#projects > dt").click();
        });

      });

      describe("forms to add projects and taskboards", function(){

        it("should add 'toggleable' and 'closed' classes to add sections", function(){
          expect($(".addTaskboard, .addProject")).to(match_selector, ".closed.toggleable");
        });

        it("should toggle class 'closed' focus in text field label is clicked", function(){
          var label = $(".addTaskboard label"),
              toggleable = label.closest(".toggleable"), toggled = label.closest(".toggleable"),
              text = toggled.find(":text");
          $ = function(){ return label; }; // mock $(this)
          mock(label).should_receive("closest").with_arguments(".toggleable").exactly("once").and_return(toggleable);
          mock(toggleable).should_receive("toggleClass").with_arguments("closed").exactly("once").and_return(toggled);
          mock(toggled).should_receive("find").with_arguments(":text").exactly("once").and_return(text);
          mock(text).should_receive("focus").exactly("once");
          jQuery(".addTaskboard label").click();
        });

      });

      describe("clone action links", function(){

        it("should toggle class 'add' on list element containing hovered clone icon", function(){
          var icon = $(".cloneTaskboard").eq(0);
          icon.trigger('mouseenter');
          expect(icon.closest(".taskboards > li")).to(match_selector, ".add");
          icon.trigger('mouseleave');
          expect(icon.closest(".taskboards > li")).to_not(match_selector, ".add");
        });

      });

      describe("forms", function(){

        it("should highlight text field when empty name is submitted", function(){
          var form = $(".addProject form"),
              text = $(".addProject form :text");
          String.prototype.trim = function(){ return "" } // mock 'trim' so utils.js is not needed
          mock(window).should_receive("$").exactly("once").and_return(form);
          mock(form).should_receive("find").exactly("once").and_return(text);
          mock(text).should_receive("effect").with_arguments("highlight", { color: "#FF0000" }).exactly("once").and_return(text);
          form.submit();
        });

      });

    });

  });
});
