// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

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

    _setupGeofenceService();
    _startGeofenceService();
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
    debugPrint(
      'Geofence ${geofence.id} ${geofenceStatus.toString()} at ${location.latitude}, ${location.longitude}',
    );
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
    return const MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Geofence Example')),
        body: Center(child: Text('Geofence is running...')),
      ),
    );
  }
}
