import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_picker/src/widgets/timepicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<DateTime> timestamps = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Timestamp demo'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: timestamps.length > 0
                ? ListView(
                    children: timestamps
                        .map(
                          (time) => ListTile(
                            contentPadding: EdgeInsets.all(8),
                            leading: Icon(Icons.access_time),
                            title: Text(_formatTime(time)),
                          ),
                        )
                        .toList(),
                  )
                : Text('No timestamps yet'),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showTimePicker(),
          icon: Icon(Icons.add),
          label: Text('Add Timestamp!'),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final formatter = new DateFormat.jm();
    return formatter.format(time);
  }

  void _showTimePicker() async {
    final time = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      backgroundColor: Color(0x00000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return TimePicker();
      },
    );
    setState(() {
      if (time != null) {
        timestamps.add(time);
      }
    });
  }
}
