(function() {
  define([], function() {
    var Grid;
    Grid = (function() {
      function Grid() {
        this.updateSize();
      }

      Grid.prototype.updateSize = function() {};

      Grid.prototype.snapGrid = function(x) {
        return (x + this.gridRound) & this.gridMask;
      };

      return Grid;

    })();
    return Grid;
  });

}).call(this);
