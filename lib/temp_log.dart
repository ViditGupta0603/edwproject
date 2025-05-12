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
  bool _isLoading = true;

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

            if (log.containsKey('temperature') &&
                log.containsKey('humidity') &&
                log.containsKey('timestamp')) {
              loadedLogs.add(log);
            } else {
              debugPrint("Skipped log $key: missing fields");
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _logs = [];
          _isLoading = false;
        });
        debugPrint("No data found at 'logs'");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 75, 75, 75),
      appBar: AppBar(
        title: Text('Temperature Logs',style: TextStyle(color: Colors.white,fontSize: screenWidth*0.06,fontWeight: FontWeight.w700),),
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : _logs.isEmpty
              ? const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Card(
                      color: Colors.grey[800],
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Temp: ${log['temperature']}°C | Humidity: ${log['humidity']}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Timestamp: ${log['timestamp']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
