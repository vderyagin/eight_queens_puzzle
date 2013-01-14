this.chessBoardSize = 600
this.chessBoardDimension = 8

jQuery ->
  canvas = $('#canvas')[0]
  canvas.width = window.chessBoardSize
  canvas.height = window.chessBoardSize

  window.canvasContext = canvas.getContext('2d')

  board = new ChessBoard(window.chessBoardDimension)
  board.renderEmpty()

  handleSlider(board)

  $('#solve').click ->
    board.renderEmpty()
    board.renderQueen(x, y) for [x, y] in board.solve()
    $(this).text('Find another solution')


handleSlider = (board) ->
  $('#slider').slider
    min: 4
    max: 16
    value: window.chessBoardDimension
    slide: (event, ui) ->
      $('#size').text("Size: #{ui.value}")
      window.chessBoardDimension = ui.value
      board.setSize(window.chessBoardDimension)
      board.renderEmpty()
      $('#solve').text('Find solution')


class ChessBoard
  constructor: (n) -> @setSize(n)
  pos: (c) -> c * @tileSize

  setSize: (@n) ->
    @tileSize = window.chessBoardSize / @n
    @ctx = window.canvasContext

  renderTile: (x, y) ->
    color = if (x % 2 != y % 2) then '#aaaaaa' else '#eeeeee'
    @ctx.fillStyle = color
    @ctx.fillRect(@pos(x), @pos(y), @tileSize, @tileSize)

  renderEmpty: ->
    @renderTile x, y for x in [0...@n] for y in [0...@n]

  renderQueen: (x, y) ->
    img = new Image
    img.src = 'queen.png';

    ctx = @ctx
    xPos = @pos(x)
    yPos = @pos(y)
    s = @tileSize

    img.onload = -> ctx.drawImage img, xPos, yPos, s, s

  solve: ->
    findSolution(@n)


class Solution
  constructor: (@pairs) ->

  correct: ->
    notSame = (p1, p2) -> !(p1[0] == p2[0] and p1[1] == p2[1])

    for pair in @pairs
      others = (p for p in @pairs when notSame(p, pair))
      for other in others
        return false if @clash(pair, other)
    true

  clash: (pair1, pair2) ->
    [x1, x2, y1, y2] = [pair1[0], pair2[0], pair1[1], pair2[1]]
    return true if x1 == x2 or y1 == y2
    return true if x1 - y1 == x2 - y2 or x1 + y1 == x2 + y2
    false

findSolution = (n) ->
    rowsOrder = [0...n].sort -> 0.5 - Math.random()
    positions = ([0, i] for i in [0...n])

    rowIdx = 0

    until (new Solution(positions)).correct()
      completedRows = (rowsOrder[i] for i in [0..rowIdx])

      partialSolution = ([positions[y][0], y] for y in completedRows)

      if (new Solution(partialSolution)).correct()
        rowIdx += 1
      else
        while positions[rowsOrder[rowIdx]][0] == n - 1
          positions[rowsOrder[rowIdx]][0] = 0
          rowIdx -= 1
        positions[rowsOrder[rowIdx]][0] += 1

    positions
