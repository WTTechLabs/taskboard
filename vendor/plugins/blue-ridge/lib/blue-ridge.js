var BLUE_RIDGE_LIB_PREFIX = BLUE_RIDGE_LIB_PREFIX || "../../vendor/plugins/blue-ridge/lib/";

var BlueRidge = {
  require: function(url, callback){
    // add a '../' prefix to all JavaScript paths because we expect to be ran from one of:
    // * test/javascript/fixtures
    // * specs/javascripts/fixtures
    // * examples/javascripts/fixtures
    url = "../" + url;
  
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.src = url;
  
    if(callback){
        var done = false;
        // Attach handlers for all browsers
        script.onload = script.onreadystatechange = function(){
            if (!done && (!this.readyState ||
                    this.readyState == "loaded" || this.readyState == "complete") ) {
                done = true;
                callback.call();
                // Handle memory leak in IE
                script.onload = script.onreadystatechange = null;
                head.removeChild( script );
            }
        };
    };
    head.appendChild(script);
  },
  
  debug: function(message){
    document.writeln(message + " <br/>");
  },
  
  deriveSpecNameFromCurrentFile: function(){
    var file_prefix = new String(window.location).match(/.*\/(.*?)\.html/)[1];
    return file_prefix + "_spec.js";
  }
};

var require = require || BlueRidge.require;
var debug   = debug   || BlueRidge.debug;

// all required js libs are now nested to load properly

require(BLUE_RIDGE_LIB_PREFIX + "jquery-1.3.2.js", function(){
 require(BLUE_RIDGE_LIB_PREFIX + "jquery.fn.js", function(){
  require(BLUE_RIDGE_LIB_PREFIX + "jquery.print.js", function(){
   require(BLUE_RIDGE_LIB_PREFIX + "screw.builder.js", function(){
    require(BLUE_RIDGE_LIB_PREFIX + "screw.matchers.js", function(){
     require(BLUE_RIDGE_LIB_PREFIX + "screw.events.js", function(){
      require(BLUE_RIDGE_LIB_PREFIX + "screw.behaviors.js", function(){
       require(BLUE_RIDGE_LIB_PREFIX + "smoke.core.js", function(){
        require(BLUE_RIDGE_LIB_PREFIX + "smoke.mock.js", function(){
         require(BLUE_RIDGE_LIB_PREFIX + "smoke.stub.js", function(){
          require(BLUE_RIDGE_LIB_PREFIX + "screw.mocking.js",function(){
           require(BlueRidge.deriveSpecNameFromCurrentFile());
          });
         });
        });
       });
      });
     });
    });
   });
  });
 });
});


