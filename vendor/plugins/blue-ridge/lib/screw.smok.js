function checkAndResetSmok() {
  if(!Smok.check()) {
    Smok.reset();
    throw Smok.check.failure
  }
  Smok.reset();
}

Screw.Unit(function() {
  after(function() { checkAndResetSmok() });
});

