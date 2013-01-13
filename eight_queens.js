/*global $:true, console:true, alert:true, _:true, Image:true*/

(function () {
  'use strict';

  var tileSize = 70;
  var size = tileSize * 8;

  var checkBoundaries = function (x, y) {
    if (x > 7 || x < 0 || y > 7 || y < 0) {
      console.error('Out of boundaries', 'x= ', x, 'y =', y);
    }
  };

  var drawChessBoard = function (ctx) {
    var drawTile = function (x, y, color) {
      var xPos = x * tileSize;
      var yPos = y * tileSize;

      ctx.fillStyle = color;
      ctx.fillRect(xPos, yPos, tileSize, tileSize);
    };

    var color;
    _.each(_.range(8), function (row) {
      _.each(_.range(8), function (col) {
        color = (row % 2 !== col % 2) ? '#aaaaaa' : '#eeeeee';
        drawTile(col, row, color);
      });
    });
  };

  var drawQueen = function (ctx, x, y) {
    checkBoundaries(x, y);

    var img = new Image();

    img.onload = function () {
      ctx.drawImage(img, x * tileSize, y * tileSize, tileSize, tileSize);
    };

    img.src = 'queen.png';
  };

  var reset = function (ctx) {
    ctx.clearRect(0, 0, size, size);
    drawChessBoard(ctx);
  };

  var clash = function (a, b) {
    var x1 = a[0], x2 = b[0], y1 = a[1], y2 = b[1];

    if (x1 === x2 || y1 === y2) {
      return true;
    }

    if (x1 - y1 === x2 - y2) {
      return true;
    }

    if (x1 + y1 === x2 + y2) {
      return true;
    }

    return false;
  };


  var rightSolution = function (positions) {
    var points = _.map(positions, function (y, x) {
      return [x, y];
    });

    return rightSolutionPoints(points);
  };

  var rightSolutionPoints = function (points) {
    var clashDetected = false;

    _.each(points, function (point) {
      _.each(_.without(points, point), function (other) {
        if (clash(point, other)) {
          clashDetected = true;
        }
      });
    });

    return !clashDetected;
  };

  var solution = function () {
    var order = _.shuffle(_.range(8));
    var positions = [0, 0, 0, 0, 0, 0, 0, 0];

    var currentRowIdx = 0;

    var ix = function (num) {
      return [num, positions[num]];
    };

    while (!rightSolution(positions)) {
      if (rightSolutionPoints(_.first(_.map(order, ix), currentRowIdx + 1))) {
        currentRowIdx += 1;
      } else {
        while (positions[order[currentRowIdx]] === 7) {
          positions[order[currentRowIdx]] = 0;
          currentRowIdx -= 1;
        }
        positions[order[currentRowIdx]] += 1;
      }
    }

    return positions;
  };


  $(function () {
    var canvas = $('#canvas')[0];

    canvas.width = size;
    canvas.height = size;

    var context;

    if (canvas.getContext) {
      context = canvas.getContext('2d');
    } else {
      alert('Canvas is not supported in your browser');
    }

    reset(context);

    $('#solve').click(function () {
      reset(context);
      _.each(solution(), function (x, y) {
        drawQueen(context, x, y);
      });

      $(this).text('Find another solution');
    });
  });
})();
