jQuery ->
  board = new ChessBoard
    size: 8
    sizePx: 600
    canvas: $('#canvas')[0]

  drawSolution = (event) ->
    $('#solve')
      .text('Find another solution')
      .attr('disabled', false)
    board.drawSolution(event.data)

  worker = new Worker('worker.js')
  worker.addEventListener 'message', drawSolution, false

  $('#slider').slider
    min: 4
    max: 26
    value: board.size
    slide: (_, ui) ->
      $('.ui-slider-handle').tooltip('destroy')
      size = ui.value
      board.setSize(size)
      $('#size').text("Size: #{size}×#{size}")
      [t, u] = solutionsFor(size)
      $('#solutions').text("Solutions: #{t} total, #{u} unique")
      $('#solve').text('Find solution')

  $('#solve').click ->
    $(this)
      .html('<img src="progress_bar.gif">')
      .attr('disabled', true)
    worker.postMessage(board.getSize())

  $('#solve').tooltip
    title: 'Press to solve puzzle'
    trigger: 'manual'
    placement: 'left'

  $('.ui-slider-handle').tooltip
    title: 'Drag to change board size'
    trigger: 'manual'
    placement: 'bottom'

  $('#solve').one 'click', ->
    $(this).tooltip('destroy')
    $('.ui-slider-handle').tooltip('show')

  $('#solve').tooltip('show')

solutionsFor = (s) ->
  {
    4:  ['2', '1']
    5:  ['10', '2']
    6:  ['4', '1']
    7:  ['40', '6']
    8:  ['92', '12']
    9:  ['352', '46']
    10: ['724', '92']
    11: ['2,680', '341']
    12: ['14,200', '1,787']
    13: ['73,712', '9,233']
    14: ['365,596', '45,752']
    15: ['2,279,184', '285,053']
    16: ['14,772,512', '1,846,955']
    17: ['95,815,104', '11,977,939']
    18: ['666,090,624', '83,263,591']
    19: ['4,968,057,848', '621,012,754']
    20: ['39,029,188,884', '4,878,666,808']
    21: ['314,666,222,712', '39,333,324,973']
    22: ['2,691,008,701,644', '336,376,244,042']
    23: ['24,233,937,684,440', '3,029,242,658,210']
    24: ['227,514,171,973,736', '28,439,272,956,934']
    25: ['2,207,893,435,808,350', '275,986,683,743,434']
    26: ['22,317,699,616,364,000', '2,789,712,466,510,280']
  }[s]

class ChessBoard
  constructor: (opts) ->
    @sizePx = opts['sizePx']

    canvas = opts['canvas']
    canvas.width = @sizePx
    canvas.height = @sizePx
    @ctx = canvas.getContext('2d')

    @setSize(opts['size'])

  pos: (c) -> c * @tileSize

  setSize: (@size) ->
    @tileSize = @sizePx / @size
    @renderEmpty()

  getSize: -> @size

  renderTile: (x, y) ->
    color = if (x % 2 != y % 2) then '#aaaaaa' else '#eeeeee'
    @ctx.fillStyle = color
    @ctx.fillRect(@pos(x), @pos(y), @tileSize, @tileSize)

  renderEmpty: ->
    @renderTile x, y for x in [0...@size] for y in [0...@size]

  renderQueen: (x, y) ->
    img = new Image
    img.src = 'queen.png';

    ctx = @ctx
    xPos = @pos(x)
    yPos = @pos(y)
    s = @tileSize

    img.onload = -> ctx.drawImage img, xPos, yPos, s, s

  drawSolution: (solution) =>
    @renderEmpty()
    @renderQueen(x, y) for [x, y] in solution
