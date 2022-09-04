import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Flutter Demo',
      theme:  ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => new _DemoPageState();

  DemoPage() {
    timeDilation = 1.0;
  }
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new DemoBody(screenSize: MediaQuery.of(context).size),
    );
  }
}

class DemoBody extends StatefulWidget {
  final Size screenSize;

  DemoBody({Key? key, required this.screenSize}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _DemoBodyState();
  }
}

class _DemoBodyState extends State<DemoBody> with TickerProviderStateMixin {
  late AnimationController animationController;
  final nodeList = <Node>[];
  final numNodes = 20;

  @override
  void initState() {
    super.initState();

    // Generate list of node
    new List.generate(numNodes, (i) {
      nodeList.add(new Node(id: i, screenSize: widget.screenSize));
    });

    animationController =
    new AnimationController(vsync: this, duration: new Duration(seconds: 20))
      ..addListener(() {
        for (int i = 0; i < nodeList.length; i++) {
          nodeList[i].move(animationController.value);
        }
      })
      ..repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new AnimatedBuilder(
        animation: new CurvedAnimation(
            parent: animationController, curve: Curves.easeInOut),
        builder: (context, child) => new CustomPaint(
          size: widget.screenSize,
          painter: new _DemoPainter(widget.screenSize, nodeList),
        ),
      ),
    );
  }
}

class _DemoPainter extends CustomPainter {
  final List<Node> nodeList;
  final Size screenSize;

  _DemoPainter(this.screenSize, this.nodeList);

  @override
  void paint(Canvas canvas, Size size) {
    for (var node in nodeList) {
      node.display(canvas);
    }
  }

  @override
  bool shouldRepaint(_DemoPainter oldDelegate) => true;
}

enum Direction {
  LEFT,
  RIGHT,
  TOP,
  BOTTOM,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT
}

class Node {
  late int id;
  late Size screenSize;
  late double radius;
  late double size;
  late Offset position;
  late Direction direction;
  late Random random;
  late Paint notePaint, linePaint;

  late Map<int, Node> connected;

  Node(
      {required this.id,
        this.size = 5.0,
        this.radius = 200.0,
        required this.screenSize}) {
    random = new Random();
    connected = new Map();
    position = screenSize.center(Offset.zero);
    direction = Direction.values[random.nextInt(Direction.values.length)];

    notePaint = new Paint()
      ..color = Colors.orange
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    linePaint = new Paint()
      ..color = Colors.orange
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
  }

  void move(double seed) {
    switch (direction) {
      case Direction.LEFT:
        position -= new Offset(1.0 + seed, 0.0);
        if (position.dx <= 5.0) {
          List<Direction> dirAvailableList = [
            Direction.RIGHT,
            Direction.BOTTOM_RIGHT,
            Direction.TOP_RIGHT
          ];
          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }

        break;
      case Direction.RIGHT:
        position += new Offset(1.0 + seed, 0.0);
        if (position.dx >= screenSize.width - 5.0) {
          List<Direction> dirAvailableList = [
            Direction.LEFT,
            Direction.BOTTOM_LEFT,
            Direction.TOP_LEFT
          ];
          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }
        break;
      case Direction.TOP:
        position -= new Offset(0.0, 1.0 + seed);
        if (position.dy <= 5.0) {
          List<Direction> dirAvailableList = [
            Direction.BOTTOM,
            Direction.BOTTOM_LEFT,
            Direction.BOTTOM_RIGHT
          ];
          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }
        break;
      case Direction.BOTTOM:
        position += new Offset(0.0, 1.0 + seed);
        if (position.dy >= screenSize.height - 5.0) {
          List<Direction> dirAvailableList = [
            Direction.TOP,
            Direction.TOP_LEFT,
            Direction.TOP_RIGHT,
          ];
          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }
        break;
      case Direction.TOP_LEFT:
        position -= new Offset(1.0 + seed, 1.0 + seed);
        if (position.dx <= 5.0 || position.dy <= 5.0) {
          List<Direction> dirAvailableList = [
            Direction.BOTTOM_RIGHT,
          ];

          //if y invalid and x valid
          if (position.dy <= 5.0 && position.dx > 5.0) {
            dirAvailableList.add(Direction.LEFT);
            dirAvailableList.add(Direction.RIGHT);
            dirAvailableList.add(Direction.BOTTOM);
            dirAvailableList.add(Direction.BOTTOM_LEFT);
          }
          //if x invalid and y valid
          if (position.dx <= 5.0 && position.dy > 5.0) {
            dirAvailableList.add(Direction.TOP);
            dirAvailableList.add(Direction.RIGHT);
            dirAvailableList.add(Direction.BOTTOM);
            dirAvailableList.add(Direction.TOP_RIGHT);
          }

          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }
        break;
      case Direction.TOP_RIGHT:
        position -= new Offset(-1.0 - seed, 1.0 + seed);
        if (position.dx >= screenSize.width - 5.0 || position.dy <= 5.0) {
          List<Direction> dirAvailableList = [
            Direction.BOTTOM_LEFT,
          ];

          //if y invalid and x valid
          if (position.dy <= 5.0 && position.dx < screenSize.width - 5.0) {
            dirAvailableList.add(Direction.LEFT);
            dirAvailableList.add(Direction.RIGHT);
            dirAvailableList.add(Direction.BOTTOM);
            dirAvailableList.add(Direction.BOTTOM_RIGHT);
          }
          //if x invalid and y valid
          if (position.dx >= screenSize.width - 5.0 && position.dy > 5.0) {
            dirAvailableList.add(Direction.TOP);
            dirAvailableList.add(Direction.BOTTOM);
            dirAvailableList.add(Direction.LEFT);
            dirAvailableList.add(Direction.TOP_LEFT);
          }

          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }
        break;
      case Direction.BOTTOM_LEFT:
        position -= new Offset(1.0 + seed, -1.0 + seed);
        if (position.dx <= 5.0 || position.dy >= screenSize.height - 5.0) {
          List<Direction> dirAvailableList = [
            Direction.TOP_RIGHT,
          ];
          //if y invalid and x valid
          if (position.dy >= screenSize.height - 5.0 && position.dx > 5.0) {
            dirAvailableList.add(Direction.LEFT);
            dirAvailableList.add(Direction.RIGHT);
            dirAvailableList.add(Direction.TOP);
            dirAvailableList.add(Direction.TOP_LEFT);
          }
          //if x invalid and y valid
          if (position.dx <= 5.0 && position.dy < screenSize.height - 5.0) {
            dirAvailableList.add(Direction.TOP);
            dirAvailableList.add(Direction.BOTTOM);
            dirAvailableList.add(Direction.RIGHT);
            dirAvailableList.add(Direction.BOTTOM_RIGHT);
          }

          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }
        break;
      case Direction.BOTTOM_RIGHT:
        position += new Offset(1.0 + seed, 1.0 + seed);
        if (position.dx >= screenSize.width - 5.0 ||
            position.dy >= screenSize.height - 5.0) {
          List<Direction> dirAvailableList = [
            Direction.TOP_LEFT,
          ];
          //if y invalid and x valid
          if (position.dy >= screenSize.height - 5.0 &&
              position.dx < screenSize.width - 5.0) {
            dirAvailableList.add(Direction.LEFT);
            dirAvailableList.add(Direction.RIGHT);
            dirAvailableList.add(Direction.TOP);
            dirAvailableList.add(Direction.TOP_RIGHT);
          }
          //if x invalid and y valid
          if (position.dx >= screenSize.width - 5.0 &&
              position.dy < screenSize.height - 5.0) {
            dirAvailableList.add(Direction.TOP);
            dirAvailableList.add(Direction.BOTTOM);
            dirAvailableList.add(Direction.LEFT);
            dirAvailableList.add(Direction.BOTTOM_LEFT);
          }

          direction = dirAvailableList[random.nextInt(dirAvailableList.length)];
        }
        break;
    }
  }

  void display(Canvas canvas) {
    canvas.drawCircle(position, size, notePaint);

    connected.forEach((id, node) {
      canvas.drawLine(position, node.position, linePaint);
    });
  }

  bool operator ==(o) => o is Node && o.id == id;

  int get hashCode => id;
}
