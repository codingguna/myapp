// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

/// Example app for GeofenceService
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final geofenceService = GeofenceService.instance;
  final List<String> geofenceEvents = [];
  late SharedPreferences _prefs;

  final List<Geofence> geofenceList = [
    Geofence(
      id: 'Home',
      latitude: 37.4219983,
      longitude: -122.084,
      radius: [GeofenceRadius(id: 'radius_100m', length: 100)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGeofenceEvents();

    _setupGeofenceService();
    _startGeofenceService();
  }

  Future<void> _loadGeofenceEvents() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      geofenceEvents.addAll(_prefs.getStringList('geofenceEvents') ?? []);
    });
  }

  void _addGeofenceEvent(String event) {
    setState(() {
      geofenceEvents.add(event);
    });
    _saveGeofenceEvents();
  }

  void _saveGeofenceEvents() {
    _prefs.setStringList('geofenceEvents', geofenceEvents);
  }

  void _setupGeofenceService() {
    geofenceService.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 10000,
      statusChangeDelayMs: 1000,
      useActivityRecognition: false,
      allowMockLocations: false,
      printDevLog: true,
    );

    geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    geofenceService.addLocationChangeListener(_onLocationChanged);
    geofenceService.addLocationServicesStatusChangeListener(
      _onLocationServicesStatusChanged,
    );
    geofenceService.addStreamErrorListener(_onError);
  }

  Future<void> _startGeofenceService() async {
    final locationPermission = await geolocator.Geolocator.checkPermission();
    if (locationPermission == geolocator.LocationPermission.denied ||
        locationPermission == geolocator.LocationPermission.deniedForever) {
      await geolocator.Geolocator.requestPermission();
    }

    await geofenceService.start(geofenceList);
  }

  Future<void> _onGeofenceStatusChanged(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    Location location,
  ) async {
    final event =
        'Geofence ${geofence.id} ${geofenceStatus.toString()} at ${location.latitude}, ${location.longitude}';
    debugPrint(event);
    HapticFeedback.heavyImpact();
    _addGeofenceEvent(event);
  }

  void _onLocationChanged(Location location) {
    debugPrint('Location: ${location.latitude}, ${location.longitude}');
  }

  void _onLocationServicesStatusChanged(bool status) {
    debugPrint('Location Services: ${status ? 'Enabled' : 'Disabled'}');
  }

  void _onError(dynamic error) {
    debugPrint('Error: $error');
  }

  @override
  void dispose() {
    geofenceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Geofence Example'),
        ),
        body: ListView.builder(
          itemCount: geofenceEvents.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(geofenceEvents[index]),
            );
          },
        ),
      ),
    );
  }
}
