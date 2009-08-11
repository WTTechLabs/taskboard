if(arguments.length == 0) {
  print("Usage: test_runner.js spec/javascripts/file_spec.js");
  quit(1);
}

var PLUGIN_PREFIX = environment["blue.ridge.prefix"] || "../../vendor/plugins/blue-ridge";

var BlueRidge = {
  require: function(file, options){ 
    load(file); 
  
    options = options || {};
    if(options['onload']) {
      options['onload'].call();
    }
  },

  debug: function(message){
    print(message);
  },
  
  get fixtureFile(){
    return "fixtures/" + this.specFile.replace(/^(.*?)_spec\.js$/, "$1.html");
  }
};

BlueRidge.specFile = arguments[0];

var require = require || BlueRidge.require;
var debug   = debug   || BlueRidge.debug;

// Mock up the Firebug API for convenience.
var console = console || {debug: debug};

load(PLUGIN_PREFIX + "/lib/env.rhino.js");
window.location = BlueRidge.fixtureFile;

load(PLUGIN_PREFIX + "/lib/jquery-1.3.2.js");
load(PLUGIN_PREFIX + "/lib/jquery.fn.js");
load(PLUGIN_PREFIX + "/lib/jquery.print.js");
load(PLUGIN_PREFIX + "/lib/screw.builder.js");
load(PLUGIN_PREFIX + "/lib/screw.matchers.js");
load(PLUGIN_PREFIX + "/lib/screw.events.js");
load(PLUGIN_PREFIX + "/lib/screw.behaviors.js");
load(PLUGIN_PREFIX + "/lib/smoke.core.js");
load(PLUGIN_PREFIX + "/lib/smoke.mock.js");
load(PLUGIN_PREFIX + "/lib/smoke.stub.js");
load(PLUGIN_PREFIX + "/lib/screw.mocking.js");
load(PLUGIN_PREFIX + "/lib/consoleReportForRake.js");

print("Running " + BlueRidge.specFile + " with fixture '" + BlueRidge.fixtureFile + "'...");
load(BlueRidge.specFile);
jQuery(window).trigger("load");
