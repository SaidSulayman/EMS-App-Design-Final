import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/driver_model.dart';
import '../models/emergency_model.dart';
import '../models/trip_model.dart';
import '../services/routing_service.dart';
import '../services/firebase_service.dart';

enum AppState { home, selecting, requesting, tracking, completed, history }

class EmergencyProvider extends ChangeNotifier {
  static const _movementTick = Duration(seconds: 2);
  static const _ambulanceSpeedKmh = 35; // realistic urban speed
  static const Distance _distanceCalculator = Distance();

  final RoutingService _routingService = RoutingService();
  final FirebaseService _firebaseService = FirebaseService();

  AppState _appState = AppState.home;
  EmergencyType? _selectedEmergency;
  DriverModel? _currentDriver;
  Position? _userPosition;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _movementTimer;

  LatLng? _ambulancePosition;
  List<LatLng> _fullRoute = []; // Complete route from API
  final List<LatLng> _ambulanceRoute = []; // Ambulance path traveled
  final List<LatLng> _userTrail = [];
  double _routeProgress = 0.0; // Progress along route (0.0 to 1.0)
  double _distance = 3.5;
  int _eta = 5;
  double _initialDistance = 0;
  final List<TripModel> _tripHistory = [];
  
  AppState get appState => _appState;
  EmergencyType? get selectedEmergency => _selectedEmergency;
  DriverModel? get currentDriver => _currentDriver;
  LatLng? get userLocation =>
      _userPosition == null ? null : LatLng(_userPosition!.latitude, _userPosition!.longitude);
  LatLng? get ambulanceLocation => _ambulancePosition;
  List<LatLng> get ambulanceRoute => _fullRoute.isNotEmpty 
      ? List.unmodifiable(_fullRoute) 
      : List.unmodifiable(_ambulanceRoute);
  List<LatLng> get userTrail => List.unmodifiable(_userTrail);
  double get distance => _distance;
  int get eta => _eta;
  double get initialDistance => _initialDistance == 0 ? _distance : _initialDistance;
  List<TripModel> get tripHistory => _tripHistory;

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _movementTimer?.cancel();
    super.dispose();
  }

  void setAppState(AppState state) {
    _appState = state;
    notifyListeners();
  }

  void selectEmergency(EmergencyType type) {
    _selectedEmergency = type;
    _appState = AppState.requesting;
    notifyListeners();
    
    getUserLocation();

    // Simulate finding ambulance
    Future.delayed(const Duration(seconds: 3), () {
      _assignDriver();
    });
  }

  Future<void> _assignDriver() async {
    _currentDriver = DriverModel(
      name: 'Sarah Johnson',
      rating: 4.9,
      vehicleNumber: 'AMB-2847',
      photoUrl: null,
      phoneNumber: '+1 (555) 234-5678',
    );
    _appState = AppState.tracking;

    final user = userLocation;
    if (user != null) {
      // Set initial ambulance position (nearby but not at user)
      _ambulancePosition = LatLng(user.latitude + 0.03, user.longitude - 0.02);
      _ambulanceRoute.clear();
      _routeProgress = 0.0;

      // Calculate route following roads
      _fullRoute = await _routingService.getRoute(_ambulancePosition!, user) ?? 
                   [_ambulancePosition!, user];
      
      // Update distance and ETA using route
      final routeDistance = await _routingService.getRouteDistance(_ambulancePosition!, user);
      final routeDuration = await _routingService.getRouteDuration(_ambulancePosition!, user);
      
      if (routeDistance != null) {
        _distance = routeDistance / 1000; // Convert to km
        _initialDistance = _distance;
      }
      
      if (routeDuration != null) {
        _eta = (routeDuration / 60).round().clamp(1, 120); // Convert to minutes
      } else {
        _updateDistanceAndEta();
      }
    }

    notifyListeners();
    
    // Start ambulance movement following route
    _simulateAmbulanceMovement();
  }

  void _simulateAmbulanceMovement() {
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(_movementTick, (timer) {
      if (_appState != AppState.tracking) {
        timer.cancel();
        return;
      }

      final user = userLocation;
      if (user == null || _ambulancePosition == null) {
        return;
      }

      // Check if ambulance has arrived
      final remainingMeters = _distanceCalculator(_ambulancePosition!, user);
      if (remainingMeters < 50) {
        timer.cancel();
        completeTrip();
        return;
      }

      // Move along route if available
      if (_fullRoute.length > 1) {
        // Calculate progress increment based on speed
        final tickDistanceMeters = (_ambulanceSpeedKmh * 1000 / 3600) * _movementTick.inSeconds;
        final totalRouteDistance = _calculateRouteDistance(_fullRoute);
        final progressIncrement = totalRouteDistance > 0 
            ? (tickDistanceMeters / totalRouteDistance).clamp(0.0, 0.05)
            : 0.01;
        
        _routeProgress = (_routeProgress + progressIncrement).clamp(0.0, 0.99);
        
        // Get new position along route
        final newPosition = _routingService.getPointAlongRoute(_fullRoute, _routeProgress);
        if (newPosition != null) {
          _ambulancePosition = newPosition;
          // Do not append to a dynamic ambulance trail while moving. We keep
          // the full route in `_fullRoute` so the polyline shows the planned
          // route without leaving a persistent moving "tail" behind the
          // ambulance marker.
        }
      } else {
        // Fallback to straight line if route not available
        final tickDistanceMeters = (_ambulanceSpeedKmh * 1000 / 3600) * _movementTick.inSeconds;
        final ratio = (tickDistanceMeters / remainingMeters).clamp(0.02, 0.4);
        _ambulancePosition = LatLng(
          _ambulancePosition!.latitude + (user.latitude - _ambulancePosition!.latitude) * ratio,
          _ambulancePosition!.longitude + (user.longitude - _ambulancePosition!.longitude) * ratio,
        );
        // Also avoid appending to `_ambulanceRoute` for the same reason as
        // above — rely on `_fullRoute` for the route visual instead of a
        // growing dynamic trail.
      }

      _updateDistanceAndEta();
      notifyListeners();
    });
  }

  double _calculateRouteDistance(List<LatLng> route) {
    if (route.length < 2) return 0;
    double total = 0;
    for (int i = 0; i < route.length - 1; i++) {
      total += _distanceCalculator(route[i], route[i + 1]);
    }
    return total;
  }

  void _updateDistanceAndEta() {
    final user = userLocation;
    final ambulance = _ambulancePosition;
    if (user == null || ambulance == null) return;

    final meters = _distanceCalculator(ambulance, user);
    _distance = (meters / 1000).clamp(0, 1000);
    const double speedPerMinute = _ambulanceSpeedKmh / 60;
    _eta = speedPerMinute == 0 ? 1 : (_distance / speedPerMinute).round().clamp(1, 120);
  }

  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (_positionSubscription != null) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _updateUserPosition(position);

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen(_updateUserPosition);
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _updateUserPosition(Position position) {
    _userPosition = position;
    _userTrail.add(LatLng(position.latitude, position.longitude));
    _updateDistanceAndEta();
    notifyListeners();
  }

  Future<void> completeTrip() async {
    _movementTimer?.cancel();

    if (_selectedEmergency != null && _currentDriver != null) {
      final trip = TripModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        emergencyType: _selectedEmergency!,
        driverName: _currentDriver!.name,
        vehicleNumber: _currentDriver!.vehicleNumber,
        date: DateTime.now(),
        distance: _distance,
        duration: _eta,
        rating: null,
      );
      _tripHistory.insert(0, trip);
      
      // Save to Firebase
      final userId = _firebaseService.currentUser?.uid;
      if (userId != null) {
        try {
          await _firebaseService.saveTrip(trip, userId);
        } catch (e) {
          debugPrint('Error saving trip to Firebase: $e');
        }
      }
    }
    
    _appState = AppState.completed;
    notifyListeners();
  }

  void rateTrip(double rating, String feedback) {
    if (_tripHistory.isNotEmpty) {
      _tripHistory[0] = _tripHistory[0].copyWith(
        rating: rating,
        feedback: feedback,
      );
    }
    notifyListeners();
  }

  void resetToHome() {
    _movementTimer?.cancel();
    _appState = AppState.home;
    _selectedEmergency = null;
    _currentDriver = null;
    _distance = 3.5;
    _eta = 5;
    _initialDistance = 0;
    _routeProgress = 0.0;
    _ambulancePosition = null;
    _fullRoute.clear();
    _ambulanceRoute.clear();
    _userTrail.clear();
    notifyListeners();
  }

  void showHistory() {
    _appState = AppState.history;
    notifyListeners();
  }
}
