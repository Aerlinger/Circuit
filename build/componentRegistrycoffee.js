(function() {
  define([], function() {
    var ComponentRegistry;
    ComponentRegistry = (function() {
      function ComponentRegistry() {}

      ComponentRegistry.registerAll = function() {
        var Component, _i, _len, _ref, _results;
        _ref = this.ComponentDefs;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          Component = _ref[_i];
          if (process.env.NODE_ENV === 'development') {
            console.log("Registering Element: " + Component.prototype + " ");
          }
          _results.push(this.register(Component));
        }
        return _results;
      };

      ComponentRegistry.register = function(componentConstructor) {
        var dumpClass, dumpType, e, newComponent;
        try {
          newComponent = new componentConstructor(0, 0, 0, 0, 0, null);
          dumpType = newComponent.getDumpType();
          dumpClass = componentConstructor;
          if (this.dumpTypes[dumpType] === dumpClass) {
            console.log("" + componentConstructor + " is a dump class");
            return;
          }
          if (this.dumpTypes[dumpType] != null) {
            console.log("Dump type conflict: " + dumpType + " " + this.dumpTypes[dumpType]);
            return;
          }
          return this.dumpTypes[dumpType] = componentConstructor;
        } catch (_error) {
          e = _error;
          if (process.env.NODE_ENV === 'development') {
            return Logger.warn("Element: " + componentConstructor.prototype + " Not yet implemented: [" + e.message + "]");
          }
        }
      };

      return ComponentRegistry;

    })();
    return ComponentRegistry;
  });

}).call(this);
