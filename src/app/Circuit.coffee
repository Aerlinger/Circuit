# #######################################################################
# Circuit:
#     Top-level class specification for a circuit
#
# @author Anthony Erlinger
# @year 2012
#
# Uses the Observer Design Pattern:
#   Observes: <none>
#   Observed By: Solver, Render
#
#
# Events:
#   ON_UPDATE
#   ON_PAUSE
#   ON_RESUME
#
#   ON_ADD_COMPONENT
#   ON_REMOVE_COMPONENT
#
# #######################################################################

# <DEFINE>
define [
#  'cs!Logger',
  'cs!CircuitState',
#  'cs!CircuitCanvas',
#  'cs!Grid',
  'cs!CircuitEngineParams',
#  'cs!MouseState',
#  'cs!Settings',
#  'cs!ComponentRegistry',
#  'cs!Hint',
#  'cs!CircuitSolver',
  'cs!Observer'
], (
#  Logger,
  CircuitState,
#  CircuitCanvas,
#  Grid,
  CircuitEngineParams,
#  MouseState,
#  Settings,
#  ComponentRegistry,
#  Hint,
#  CommandHistory,
#  CircuitSolver,
  Observer
) ->
# </DEFINE>

  class Circuit extends Observer

    # Messages Dispatched to listeners:
    @ON_START_UPDATE = "ON_START_UPDATE"
    @ON_COMPLETE_UPDATE = "ON_END_UPDATE"

    @ON_START = "ON_START"
    @ON_PAUSE = "ON_PAUSE"
    @ON_RESET = "ON_RESET"

    @ON_ADD_COMPONENT = "ON_ADD_COMPONENT"
    @ON_REMOVE_COMPONENT = "ON_MOVE_COMPONENT"
    @ON_MOVE_COMPONENT = "ON_MOVE_COMPONENT"

    @ON_ERROR = "ON_ERROR"
    @ON_WARNING = "ON_WARNING"


    constructor: () ->
      @Params = new CircuitEngineParams()

      @clearAndReset()
      @bindListeners()


    setParamsFromJSON: (jsonData) ->
      @Params = new CircuitEngineParams(jsonData)

    ###
    Removes all circuit elements and scopes from the workspace and resets time to zero.
    ###
    clearAndReset: ->
      # TODO: Prompt to save before destroying components
      for element in @elementList?
        element.destroy()

#      @Solver = new CircuitSolver(this)
#      @Grid = new Grid()

      @nodeList = []
      @elementList = []
      @voltageSources = []

      @scopes = []
      @scopeColCount = []  # Array of integers

      @time = 0
      @lastTime = 0

      # State Handlers
#      @mouseState = new MouseState()

      @state = CircuitState.RUNNING

      @clearErrors()

      @notifyObservers @ON_RESET


    bindListeners: ->
#      @Solver
      #bind(@Solver.completeStep, )

    setupScopes: ->


      # "Solders" a new element to this circuit (adds it to the element list array).
    solder: (newElement) ->

      # TODO DISPATCH EVENT

      newElement.setParentCircuit(this)
      newElement.setPoints()
      console.log("Soldering Element: " + newElement)
      @elementList.push newElement


    # "Desolders" an existing element to this circuit (removes it to the element list array).
    desolder: (component, destroy = false) ->

      # TODO DISPATCH EVENT

      component.Circuit = null
      @elementList.remove component
      if destroy
        component.destroy()

    getVoltageSources: ->
      @voltageSources

    #It may be worthwhile to return a defensive copy here
    getElements: ->
      @elementList

    findElm: (searchElm) ->
      for circuitElm in @elementList
        return circuitElm if searchElm == circuitElm
      return false

    getElmByIdx: (elmIdx) ->
      return @elementList[elmIdx]

    numElements: ->
      return @elementList.length


    #########################
    # Scopes:
    #########################

    # Scopes aren't implemented yet
    getScopes: ->
      []


    #########################
    # Nodes:
    #########################

    resetNodes: ->
      @nodeList = []

    addCircuitNode: (circuitNode) ->
      @nodeList.push circuitNode

    getNode: (idx) ->
      @nodeList[idx]

    getNodes: ->
      @nodeList

    numNodes: ->
      @nodeList.length

    getGrid: ->
#      return @Grid



    #########################
    # Simulation state
    #########################

    run: ->
      @notifyObservers @ON_START
      @Solver.run()

    pause: ->
      @notifyObservers @ON_PAUSE
      @Solver.pause("Circuit is paused")

    restartAndStop: ->
      @restartAndRun()
      @simulation = cancelAnimationFrame()
      @Solver.pause("Restarted Circuit from time 0")

    restartAndRun: ->
      if(!@Solver)
        halt("Solver not initialized!");

    reset: ->
      element.reset() for element in @elementList
      scope.resetGraph() for scope in @scopes

      @Solver.reset()



    #########################
    # Computation
    #########################

    ###
    UpdateCircuit:

     Updates the circuit each frame.

      1. ) Reconstruct Circuit:
            Rebuilds a data representation of the circuit (only applied when circuit changes)
      2. ) Solve Circuit build matrix representation of the circuit solve for the voltage and current for each component.
            Solving is performed via LU factorization.
    ###
    updateCircuit: () ->
      @notifyObservers(@ON_START_UPDATE)
      #@simulation = requestAnimationFrame(Circuit.prototype.updateCircuit, @)
      startTime = (new Date()).getTime()

      # Reconstruct circuit
      @Solver.reconstruct()

      # If the circuit isn't stopped,
      unless @Solver.isStopped
        @Solver.solveCircuit()
        @lastTime = @updateTimings()
      else
        @lastTime = 0

      @notifyObservers(@ON_COMPLETE_UPDATE)

      endTime = (new Date()).getTime()
      frameTime = endTime - startTime
      @lastFrameTime = @lastTime


    # Returns the y position of the bottom of the circuit
    getCircuitBottom: ->
      if @circuitBottom
        return @circuitBottom

      for element in @elementList
        rect = element.boundingBox
        bottom = rect.height + rect.y
        @circuitBottom = bottom if (bottom > @circuitBottom)

      return @circuitBottom


    updateTimings: () ->
      sysTime = (new Date()).getTime()
      #if @lastTime != 0
      inc = Math.floor(sysTime - @lastTime)
      currentSpeed = Math.exp(@Params.currentSpeed / 3.5 - 14.2)
      @Params.currentMult = 1.7 * inc * currentSpeed

      if (sysTime - @secTime) >= 1000
        @framerate = @frames
        @steprate = @Solver.steps
        @frames = 0
        @steps = 0
        @secTime = sysTime

      @frames++
      return sysTime


    findBadNodes: ->
      badNodes = []
      for circuitNode in @nodeList
        if not circuitNode.intern and circuitNode.links.length is 1
          numBadPoints = 0
          firstCircuitNode = circuitNode.links[0]
          for circuitElm in @elementList
            console.log "Compare: #{firstCircuitNode.elm.toString()}  #{circuitElm.toString()}"
            if firstCircuitNode.elm.toString() != circuitElm.toString() and circuitElm.boundingBox.contains(circuitNode.x,
              circuitNode.y)
              numBadPoints++
          if numBadPoints > 0
            # Todo: outline bad nodes here
            badNodes.push circuitNode
      return badNodes


    warn: (message) ->
#      Logger.warn message
      @warnMessage = message

    halt: (message) ->
#      Logger.error message
      @stopMessage = message

    clearErrors: ->
      @stopMessage = null
      @stopElm = null


    ###
    Delegations:
    ###
    isStopped: ->
      @Solver.isStopped

    voltageRange: ->
      return @Params['voltageRange']

    powerRange: ->
      return @Params['powerRange']

    currentSpeed: ->
      return 62
    #return @Params['currentMult']

    getState: ->
      return @state


  #####################################
  # RENDERINGS:
  #####################################

  #    renderInfo: () ->
  #      realMouseElm = @mouseElm
  #      @mouseElm = @stopElm unless @mouseElm?
  #
  #      if @stopMessage?
  #        @halt @stopMessage
  #      else
  #        @getCircuitBottom() if @circuitBottom is 0
  #
  #        # Array of messages to be displayed at the bottom of the canvas
  #        info = []
  #        if @mouseElm?
  #          if @mousePost is -1
  #            @mouseElm.getInfo info
  #          else
  #            info.push "V = " + Units.getUnitText(@mouseElm.getPostVoltage(@mousePost), "V")
  #        else
  #          Settings.fractionalDigits = 2
  #          info.push "t = " + Units.getUnitText(@Solver.time, "s") + "\nft: " + (@lastTime - @lastFrameTime) + "\n"
  #        unless @Hint.hintType is -1
  #          hint = @Hint.getHint()
  #          unless hint
  #            @Hint.hintType = -1
  #          else
  #            info.push hint
  #
  #        @Renderer.drawInfo(info)
  #        @mouseElm = realMouseElm
  #
  #
  #    renderCircuit: () ->
  #      @powerMult = Math.exp(@Params.powerRange / 4.762 - 7)
  #
  #      # Draw each circuit element
  #      for circuitElm in @elementList
  #        @Renderer.drawComponent(circuitElm)
  #
  #      # Draw the posts for each circuit
  #      tempMouseMode = @mouseState.tempMouseMode
  #      if tempMouseMode is MouseState.MODE_DRAG_ROW or
  #      tempMouseMode is MouseState.MODE_DRAG_COLUMN or
  #      tempMouseMode is MouseState.MODE_DRAG_POST or
  #      tempMouseMode is MouseState.MODE_DRAG_SELECTED
  #
  #        for circuitElm in @elementList
  #          circuitElm.drawPost circuitElm.x1, circuitElm.y1
  #          circuitElm.drawPost circuitElm.x2, circuitElm.y2

  # TODO: Draw selection outline:


  renderScopes: () ->
    # TODO Implement scopes



  getRenderer: ->
    @Renderer



  return Circuit
