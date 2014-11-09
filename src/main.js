define([], function() {
  var Main = {};

  // This is your main function. After configuration in config.js, it is called.
  Main.main = function() {
    require([
    ], function() {
      console.log(true);
    });
  };

  return Main;
});
