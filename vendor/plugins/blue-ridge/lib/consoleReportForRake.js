(function($) {
  var failedSpecs = [],
      ESC = String.fromCharCode(27),
      GREEN = ESC + "[32m",
      RED = ESC + "[31m",
      RESET =  ESC + "[0m",

// change it to false if your text output doesn't support colouring
      coloured = true;

  function printGreen(message){
    if(coloured) { message = GREEN + message + RESET; }
    print(message);
  }

  function printRed(message){
    if(coloured) { message = RED + message + RESET; }
    print(message);
  }

  $(Screw).bind("before", function(){
    var currentContext = "";

    function context_name(element){
      var context_name = "";
      $(element).parents(".describe").children("h1").each(function(){
        context_name = $(this).text() + " " + context_name;
      });
      return context_name.replace(/^\s+|\s+$/g, '');
    }

    function example_name(element){
      return $(element).children("h2").text();
    }

    function updateContext(context){
      if(context != currentContext){
        currentContext = context;
        print("\n" + context);
      }
    };

    function report(example, failReason){
      var failed = typeof failReason != 'undefined',
          context = context_name(example),
          example = example_name(example),
          print = failed ? printRed : printGreen,
          message = " - " + example;
      if (failed) {
        message += " (FAILED - " + (failedSpecs.length+1) + ")";
        failedSpecs.push([context, example, failReason])
      }
      updateContext(context);
      print(message);
    }

    $('.it')
      .bind('passed', function(){ 
        report(this);
      })
      .bind('failed', function(e, reason){
        report(this, reason);
      });
  });

  $(Screw).bind("after", function(){
    var testCount = $('.passed').length + $('.failed').length;
    var failures = $('.failed').length;
    var elapsedTime = ((new Date() - Screw.suite_start_time)/1000.0);

    print("\n")
    $.each(failedSpecs, function(i, fail){
      printRed((i+1) + ")");
      printRed(fail[0] + " " + fail[1] + " FAILED:")
      printRed("    " + fail[2] + "\n");
    });
    print(testCount + ' test(s), ' + failures + ' failure(s)');
    print(elapsedTime.toString() + " seconds elapsed");

    if(failures > 0) { java.lang.System.exit(1) };
  });
})(jQuery);
