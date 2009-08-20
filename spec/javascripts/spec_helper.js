// Use this file to require common dependencies or to setup useful test functions.

Screw.Matchers["be_function"] = {
  match: function(expected, actual) {
    return typeof actual == "function";
  },
  failure_message: function(expected, actual, not) {
    return 'expected ' + $.print(actual) + (not ? ' not' : '') + ' to be function';
  }
}

