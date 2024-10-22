import 'dart:math';
import 'package:flutter/material.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  List<Fish> fishes = [];
  double speed = 1.0;
  Color selectedColor = Colors.blue;

  void _addFish() {
    setState(() {
      fishes.add(Fish(color: selectedColor));
    });
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
                onPressed: () {},
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

  Fish({required this.color});

  Widget build() {
    return Positioned(
      top: Random().nextDouble() * 300,
      left: Random().nextDouble() * 300,
      child: CircleAvatar(
        backgroundColor: color,
        radius: 10,
      ),
    );
  }
}
