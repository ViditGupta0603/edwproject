import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TemperatureLoggerPage extends StatefulWidget {
  const TemperatureLoggerPage({super.key});

  @override
  State<TemperatureLoggerPage> createState() => _TemperatureLoggerPageState();
}

class _TemperatureLoggerPageState extends State<TemperatureLoggerPage> {
  final _dbRef = FirebaseDatabase.instance.ref('logs');
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  void _fetchLogs() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<String, dynamic>> loadedLogs = [];

        data.forEach((key, value) {
          try {
            final log = Map<String, dynamic>.from(value);
            // Optional: Validate required fields
            if (log['temperature'] != null && log['humidity'] != null && log['timestamp'] != null) {
              loadedLogs.add(log);
            } else {
              debugPrint("Skipped log $key due to missing fields.");
            }
          } catch (e) {
            debugPrint("Error parsing log $key: $e");
          }
        });

        loadedLogs.sort((a, b) {
          final timeA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(0);
          final timeB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(0);
          return timeB.compareTo(timeA);
        });

        setState(() {
          _logs = loadedLogs;
        });
      } else {
        debugPrint("No data found at 'logs'");
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temperature Logs')),
      body: _logs.isEmpty
          ? const Center(child: Text('No data available'))
          : ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Temp: ${log['temperature']}°C | Humidity: ${log['humidity']}%'),
              subtitle: Text('Timestamp: ${log['timestamp']}'),
            ),
          );
        },
      ),
    );
  }
}