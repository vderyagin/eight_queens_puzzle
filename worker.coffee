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

solve = (event) ->
  self.postMessage(findSolution(event.data))

self.addEventListener 'message', solve, false
