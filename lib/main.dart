import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GeofenceHomePage(),
    );
  }
}

class GeofenceHomePage extends StatefulWidget {
  const GeofenceHomePage({super.key});

  @override
  State<GeofenceHomePage> createState() => _GeofenceHomePageState();
}

class _GeofenceHomePageState extends State<GeofenceHomePage> {
  final GeofenceService _geofenceService = GeofenceService.instance;
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    _initGeofence();
  }

  void _logEvent(String message) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    setState(() {
      _eventLog.insert(0, "[$timestamp] $message");
    });
  }

  void _initGeofence() async {
    _geofenceService
      ..setup(
        interval: 5000,
        accuracy: 100,
        useActivityRecognition: false,
        allowMockLocations: true,
        geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
      )
      ..addGeofenceStatusChangedListener((geofence, radius, status) async {
        _logEvent(
          'Geofence ${geofence.id} → ${status.name} (${radius.length}m)',
        );
      })
      ..addStreamErrorListener((error) {
        _logEvent('Error: $error');
      });

    final geofenceList = [
      Geofence(
        id: 'TestArea',
        latitude: 37.4219999, // replace with your desired lat
        longitude: -122.0840575, // replace with your desired long
        radius: [GeofenceRadius(id: '100m', length: 100)],
      ),
    ];

    await _geofenceService.start(geofenceList);
    _logEvent('Geofence monitoring started.');
  }

  @override
  void dispose() {
    _geofenceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geofence Service Log')),
      body: ListView.builder(
        itemCount: _eventLog.length,
        itemBuilder:
            (context, index) => ListTile(title: Text(_eventLog[index])),
      ),
    );
  }
}
