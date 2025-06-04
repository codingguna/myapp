_geofenceService.setup(import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofence_service/models/geofence.dart';
import 'package:geofence_service/models/geofence_radius.dart';
import 'package:geofence_service/models/geofence_status.dart';
import 'package:geofence_service/models/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GeofenceApp());
}

class GeofenceApp extends StatelessWidget {
  const GeofenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geofence Logger',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GeofenceHomePage(),
    );
  }
}

class GeofenceHomePage extends StatefulWidget {
  const GeofenceHomePage({super.key});

  @override
  State<GeofenceHomePage> createState() => _GeofenceHomePageState();
}

class _GeofenceHomePageState extends State<GeofenceHomePage> {
  final List<String> _eventHistory = [];
  final _geofenceService = GeofenceService.instance;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPrefs();
    _initGeofence();
  }

  Future<void> _initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedEvents = _prefs.getStringList('geofence_events');
    if (savedEvents != null) {
      setState(() {
        _eventHistory.addAll(savedEvents);
      });
    }
  }

  void _logEvent(String event) async {
    final timestamp = DateTime.now().toIso8601String();
    final fullEvent = '$timestamp → $event';
    setState(() {
      _eventHistory.insert(0, fullEvent);
    });
    await _prefs.setStringList('geofence_events', _eventHistory);
  }

  void _initGeofence() {
    final geofenceList = [
      Geofence(
        id: 'TestArea',
        latitude: 37.4219983, // Replace with your coordinates
        longitude: -122.084,
        radius: [GeofenceRadius(id: 'radius_100m', length: 100)],
      ),
    ];

    
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 10000,
      statusChangeDelayMs: 1000,
      useActivityRecognition: false,
      allowMockLocations: true,
      printDevLog: true,
      onGeofenceStatusChanged: (geofence, status) {
        _logEvent('Geofence ${geofence.id} → ${status.name}');
      },
      onLocationChanged: (location) {
        debugPrint('Location changed: $location');
      },
      onLocationServicesStatusChanged: (enabled) {
        debugPrint('Location services status: $enabled');
      },
      onActivityChanged: (activity) {
        debugPrint('Activity changed: $activity');
      },
      onError: (error) {
        debugPrint('Error: $error');
      },
    );

    _geofenceService
        .start(geofenceList)
        .then((_) => debugPrint('Geofence monitoring started'))
        .catchError((e) => debugPrint('Error starting geofence: $e'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Event Logger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _prefs.remove('geofence_events');
              setState(() => _eventHistory.clear());
            },
          )
        ],
      ),
      body: _eventHistory.isEmpty
          ? const Center(child: Text('No geofence events logged yet.'))
          : ListView.builder(
              itemCount: _eventHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_eventHistory[index]),
                );
              },
            ),
    );
  }
}
