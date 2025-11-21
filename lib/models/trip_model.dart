import 'emergency_model.dart';

class TripModel {
  final String id;
  final EmergencyType emergencyType;
  final String driverName;
  final String vehicleNumber;
  final DateTime date;
  final double distance;
  final int duration;
  final double? rating;
  final String? feedback;

  TripModel({
    required this.id,
    required this.emergencyType,
    required this.driverName,
    required this.vehicleNumber,
    required this.date,
    required this.distance,
    required this.duration,
    this.rating,
    this.feedback,
  });

  TripModel copyWith({
    String? id,
    EmergencyType? emergencyType,
    String? driverName,
    String? vehicleNumber,
    DateTime? date,
    double? distance,
    int? duration,
    double? rating,
    String? feedback,
  }) {
    return TripModel(
      id: id ?? this.id,
      emergencyType: emergencyType ?? this.emergencyType,
      driverName: driverName ?? this.driverName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      date: date ?? this.date,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }
}
