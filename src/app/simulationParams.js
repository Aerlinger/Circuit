(function() {
  define([], function() {

    /*
      Stores Circuit-specific settings.
      Usually loaded from the params object of a .json file
     */
    var CircuitParams;
    CircuitParams = (function() {
      function CircuitParams(paramsObj) {
        this.completionStatus = (paramsObj != null ? paramsObj['completion_status'] : void 0) || "in development";
        this.createdAt = paramsObj != null ? paramsObj['created_at'] : void 0;
        this.currentSpeed = (paramsObj != null ? paramsObj['current_speed'] : void 0) || 63;
        this.updatedAt = paramsObj != null ? paramsObj['updated_at'] : void 0;
        this.description = paramsObj != null ? paramsObj['description'] : void 0;
        this.flags = paramsObj != null ? paramsObj['flags'] : void 0;
        this.id = paramsObj != null ? paramsObj['id'] : void 0;
        this.name = paramsObj != null ? paramsObj['name_unique'] : void 0;
        this.powerRange = paramsObj != null ? paramsObj['power_range'] : void 0;
        this.voltageRange = paramsObj != null ? paramsObj['voltage_range'] : void 0;
        this.simSpeed = paramsObj != null ? paramsObj['sim_speed'] : void 0;
        this.timeStep = paramsObj != null ? paramsObj['time_step'] : void 0;
        this.title = paramsObj != null ? paramsObj['title'] : void 0;
        this.topic = paramsObj != null ? paramsObj['topic'] : void 0;
      }

      return CircuitParams;

    })();
    return CircuitParams;
  });

}).call(this);
