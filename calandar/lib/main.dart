import 'package:calandar/weekly_calandar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final CalandarController _controller;

  late String _date;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CalandarController(initialDate: DateTime.now());
    _date = _controller.currentDate.toString();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_date),
        actions: [
          IconButton(
            onPressed: () => _controller.previousWeek(),
            icon: Icon(Icons.arrow_left),
          ),
          IconButton(
            onPressed: () => _controller.nextWeek(),
            icon: Icon(Icons.arrow_right),
          )
        ],
      ),
      body: Center(
        child: WeeklyCalandar(
          controller: _controller,
          onDateChange: (date) {
            setState(() {
              _date = date.toString();
            });
          },
        ),
      ),
    );
  }
}
