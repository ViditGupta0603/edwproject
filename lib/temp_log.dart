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

  // Function to show the info dialog
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850], // Dark background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          title: Text(
            'EDW PROJECT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'This project is a temperature and humidity logger built by Vidit Gupta(2023UEC2503), Akshat Verma(2023UEC2532) and Neeraj Kumar(2023UEC2516) under the guidance of Prof D.V. Gadre. '
              'It collects data from sensors, logs it in real-time, and stores it in Firebase Realtime Database.',
              style: TextStyle(
                color: Colors.grey[100],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, // Stylish button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for the button
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 75, 75, 75),
      appBar: AppBar(
        title: Text(
          'Temperature Logs',
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: _showInfoDialog, // Open the dialog on info button click
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
