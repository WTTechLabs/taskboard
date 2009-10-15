function checkAndResetSmok() {
  if(!Smok.check()) {
    Smok.reset();
    throw "Smok Expectation failed!"
  }
  Smok.reset();
}

Screw.Unit(function() {
  after(function() { checkAndResetSmok() });
});

