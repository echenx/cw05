import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cw05/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquarium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Aquarium'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<Fish> fishes = [];
  double speed = 1.0;
  Color selectedColor = Colors.blue;
  late AnimationController _controller;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat();

    _controller.addListener(() {
      setState(() {
        for (var fish in fishes) {
          fish.updatePosition();
        }
      });
    });

    _loadFishesFromDatabase();
  }

  Future<void> _loadFishesFromDatabase() async {
    List<FishData> dbFishes = await dbHelper.getAllFishes();
    setState(() {
      fishes = dbFishes
          .map((fishData) => Fish(
                color: Color(fishData.color),
                top: fishData.top,
                left: fishData.left,
                speed: fishData.speed,
                controller: _controller,
              ))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFish() {
    if (fishes.length < 10) {
      setState(() {
        fishes.add(
            Fish(color: selectedColor, controller: _controller, speed: speed));
      });
    }
  }

  void _removeFish() {
    if (fishes.isNotEmpty) {
      setState(() {
        fishes.removeLast();
      });
    }
  }

  void _saveFishesToDatabase() async {
    await dbHelper.deleteAllFishes();
    for (var fish in fishes) {
      await dbHelper.insertFish(FishData(
        color: fish.color.value,
        top: fish.top,
        left: fish.left,
        speed: fish.speed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Stack(
              children: fishes.map((fish) => fish.build()).toList(),
            ),
          ),
          Slider(
            value: speed,
            min: 0.5,
            max: 5.0,
            divisions: 10,
            label: "Speed: ${speed.toStringAsFixed(1)}",
            onChanged: (newSpeed) {
              setState(() {
                speed = newSpeed;
              });
            },
          ),
          DropdownButton<Color>(
            value: selectedColor,
            items: [
              DropdownMenuItem(
                child: Text("Blue"),
                value: Colors.blue,
              ),
              DropdownMenuItem(
                child: Text("Red"),
                value: Colors.red,
              ),
              DropdownMenuItem(
                child: Text("Green"),
                value: Colors.green,
              ),
            ],
            onChanged: (color) {
              setState(() {
                selectedColor = color!;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addFish,
                child: Text("Add Fish"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _removeFish,
                child: Text("Remove Fish"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _saveFishesToDatabase,
                child: Text("Save Settings"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Fish {
  final Color color;
  double top = Random().nextDouble() * 300;
  double left = Random().nextDouble() * 300;
  late AnimationController controller;
  double speed;

  Fish({
    required this.color,
    required this.controller,
    this.top = 0,
    this.left = 0,
    this.speed = 1.0,
  }) {
    _setRandomDirection();
    _startDirectionChangeTimer();
  }

  double verticalDirection = 1;
  double horizontalDirection = 1;
  Timer? _directionChangeTimer;

  void updatePosition() {
    top += verticalDirection * speed;
    left += horizontalDirection * speed;

    if (top <= 0 || top >= 300) {
      verticalDirection *= -1;
      top = top.clamp(0, 300);
    }

    if (left <= 0 || left >= 300) {
      horizontalDirection *= -1;
      left = left.clamp(0, 300);
    }
  }

  void _setRandomDirection() {
    verticalDirection = Random().nextBool() ? 1 : -1;
    horizontalDirection = Random().nextBool() ? 1 : -1;
  }

  void _startDirectionChangeTimer() {
    _directionChangeTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _setRandomDirection();
    });
  }

  void dispose() {
    _directionChangeTimer?.cancel();
  }

  Widget build() {
    return Positioned(
      top: top,
      left: left,
      child: CircleAvatar(
        backgroundColor: color,
        radius: 10,
      ),
    );
  }
}
