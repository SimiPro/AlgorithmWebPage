import 'dart:html';
import 'dart:collection';
import 'dart:math';

CanvasElement canvas;
CanvasRenderingContext2D ctx;

const int CELL_SIZE = 10;
Keyboard key = new Keyboard();


class Snake {
  // directions
  static const Point LEFT = const Point(-1, 0);
  static const Point RIGHT = const Point(1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);

  static const int START_LENGTH = 6;

  // coordinates of the body segments
  List<Point> _body;

  // current travel direction
  Point _dir = RIGHT;

  Snake() {
    int i = START_LENGTH - 1;
    _body = new List<Point>.generate(START_LENGTH, (int index) => new Point(i--, 0));


  }

  Point get head => _body.first;

  void _checkInput() {
    if (key.isPressed(KeyCode.LEFT) && _dir != RIGHT) {
      _dir = LEFT;
    }
    else if (key.isPressed(KeyCode.RIGHT) && _dir != LEFT) {
      _dir = RIGHT;
    }
    else if (key.isPressed(KeyCode.UP) && _dir != DOWN) {
      _dir = UP;
    }
    else if (key.isPressed(KeyCode.DOWN) && _dir != UP) {
      _dir = DOWN;
    }
  }

  void grow() {
    // add new head based on current direction
    _body.insert(0, head + _dir);
  }

  void _move() {
    // add a new head segment
    grow();

    // remove the tail segment
    _body.removeLast();
  }

  void _draw() {
    // starting with the head, draw each body segment
    for (Point p in _body) {
      drawCell(p, "green");
    }
  }

  bool checkForBodyCollision() {
    for (Point p in _body.skip(1)) {
      if (p == head) {
        return true;
      }
    }
    return false;
  }

  void update() {
    _checkInput();
    _move();
    _draw();
  }


}

void main() {
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');

  drawCell(new Point(10, 10), "salmon");

  Snake snake = new Snake();
  clear();
  snake.update();

  new Game()..run();
}


num _lastTimeStamp = 0;

// a few convenience variables to simplify calculations
int _rightEdgeX;
int _bottomEdgeY;

class Game {
  // smaller numbers make the game run faster
  static const num GAME_SPEED = 1;

  Snake _snake;
  Point _food;

  Game() {
    _rightEdgeX = canvas.width ~/ CELL_SIZE;
    _bottomEdgeY = canvas.height ~/ CELL_SIZE;

    init();
  }

  void update(num delta) {
    final num diff = delta - _lastTimeStamp;

    if (diff > GAME_SPEED) {
      _lastTimeStamp = delta;
      clear();
      drawCell(_food, "blue");
      _snake.update();
      _checkForCollisions();
    }

    // keep looping
    run();
  }

  void init() {
    _snake = new Snake();
    _food = _randomPoint();
  }

  Point _randomPoint() {
    Random random = new Random();
    return new Point(random.nextInt(_rightEdgeX),
        random.nextInt(_bottomEdgeY));
  }

  void _checkForCollisions() {
    // check for collision with food
    if (_snake.head == _food) {
      _snake.grow();
      _food = _randomPoint();
    }

    // check death conditions
    if (_snake.head.x <= -1 ||
        _snake.head.x >= _rightEdgeX ||
        _snake.head.y <= -1 ||
        _snake.head.y >= _bottomEdgeY ||
        _snake.checkForBodyCollision()) {
      init();
    }
  }

  void run() {
    window.animationFrame.then(update);
  }

}

void drawCell(Point coords, String color) {
  ctx
    ..fillStyle = color
    ..strokeStyle = "white";

  final int x = coords.x * CELL_SIZE;
  final int y = coords.y * CELL_SIZE;

  ctx
    ..fillRect(x, y, CELL_SIZE, CELL_SIZE)
    ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
}

void clear() {
  ctx
    ..fillStyle = "white"
    ..fillRect(0, 0, canvas.width, canvas.height);
}

class Keyboard {
  HashMap<int, int> _keys = new HashMap<int, int>();

  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent event) {
      if (!_keys.containsKey(event.keyCode)) {
        _keys[event.keyCode] = event.timeStamp;
      }
    });

    window.onKeyUp.listen((KeyboardEvent event) {
      _keys.remove(event.keyCode);
    });
  }

  bool isPressed(int keyCode) => _keys.containsKey(keyCode);
}