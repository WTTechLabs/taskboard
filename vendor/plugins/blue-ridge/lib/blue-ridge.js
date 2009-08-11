var BLUE_RIDGE_LIB_PREFIX = BLUE_RIDGE_LIB_PREFIX || "../../vendor/plugins/blue-ridge/lib/";

var BlueRidge = {
  require: function(url, options){
    // add a '../' prefix to all JavaScript paths because we expect to be ran from one of:
    // * test/javascript/fixtures
    // * specs/javascripts/fixtures
    // * examples/javascripts/fixtures
    url = "../" + url;
  
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.src = url;
  
    options = options || {};
  
    if(options['onload']) {
      // Attach handlers for all browsers
      script.onload = script.onreadystatechange = options['onload'];
    }
  
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

require(BLUE_RIDGE_LIB_PREFIX + "jquery-1.3.2.js");
require(BLUE_RIDGE_LIB_PREFIX + "jquery.fn.js");
require(BLUE_RIDGE_LIB_PREFIX + "jquery.print.js");
require(BLUE_RIDGE_LIB_PREFIX + "screw.builder.js");
require(BLUE_RIDGE_LIB_PREFIX + "screw.matchers.js");
require(BLUE_RIDGE_LIB_PREFIX + "screw.events.js");
require(BLUE_RIDGE_LIB_PREFIX + "screw.behaviors.js");
require(BLUE_RIDGE_LIB_PREFIX + "smoke.core.js");
require(BLUE_RIDGE_LIB_PREFIX + "smoke.mock.js");
require(BLUE_RIDGE_LIB_PREFIX + "smoke.stub.js");
require(BLUE_RIDGE_LIB_PREFIX + "screw.mocking.js");

require(BlueRidge.deriveSpecNameFromCurrentFile());
