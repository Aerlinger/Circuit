(function() {
  define([], function() {
    var CircuitState;
    CircuitState = (function() {
      function CircuitState() {}

      CircuitState.RUNNING = "RUN";

      CircuitState.PAUSED = "PAUSE";

      CircuitState.EDITING = "EDIT";

      return CircuitState;

    })();
    return CircuitState;
  });

}).call(this);
