import 'package:flutter/material.dart';

import 'calandar.dart';

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => WeekCalandarPage())),
              child: Text('Week'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MonthCalandarPage())),
              child: Text('Month'),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekCalandarPage extends StatefulWidget {
  const WeekCalandarPage({super.key});

  @override
  State<WeekCalandarPage> createState() => _WeekCalandarPageState();
}

class _WeekCalandarPageState extends State<WeekCalandarPage> {
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
        child: CalendarView.week(
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

class MonthCalandarPage extends StatefulWidget {
  const MonthCalandarPage({super.key});

  @override
  State<MonthCalandarPage> createState() => _MonthCalandarPageState();
}

class _MonthCalandarPageState extends State<MonthCalandarPage> {
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
            onPressed: () => _controller.previousMonth(),
            icon: Icon(Icons.arrow_left),
          ),
          IconButton(
            onPressed: () => _controller.nextMonth(),
            icon: Icon(Icons.arrow_right),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CalendarView.month(
            controller: _controller,
            saturdayDateColor: Colors.blueAccent,
            sundayDateColor: Colors.redAccent,
            onDateChange: (date) {
              setState(() {
                _date = date.toString();
              });
            },
          ),
        ),
      ),
    );
  }
}
