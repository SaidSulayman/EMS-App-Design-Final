import 'package:flutter/material.dart';

enum EmergencyType {
  cardiac,
  respiratory,
  trauma,
  stroke,
  allergic,
  other,
}

extension EmergencyTypeExtension on EmergencyType {
  String get title {
    switch (this) {
      case EmergencyType.cardiac:
        return 'Cardiac Emergency';
      case EmergencyType.respiratory:
        return 'Respiratory Distress';
      case EmergencyType.trauma:
        return 'Trauma/Injury';
      case EmergencyType.stroke:
        return 'Stroke Symptoms';
      case EmergencyType.allergic:
        return 'Allergic Reaction';
      case EmergencyType.other:
        return 'Other Emergency';
    }
  }

  String get description {
    switch (this) {
      case EmergencyType.cardiac:
        return 'Heart attack, chest pain, irregular heartbeat';
      case EmergencyType.respiratory:
        return 'Difficulty breathing, asthma attack';
      case EmergencyType.trauma:
        return 'Serious injury, bleeding, broken bones';
      case EmergencyType.stroke:
        return 'Face drooping, arm weakness, speech difficulty';
      case EmergencyType.allergic:
        return 'Severe allergic reaction, anaphylaxis';
      case EmergencyType.other:
        return 'Other medical emergency';
    }
  }

  IconData get icon {
    switch (this) {
      case EmergencyType.cardiac:
        return Icons.favorite;
      case EmergencyType.respiratory:
        return Icons.air;
      case EmergencyType.trauma:
        return Icons.local_hospital;
      case EmergencyType.stroke:
        return Icons.psychology;
      case EmergencyType.allergic:
        return Icons.warning;
      case EmergencyType.other:
        return Icons.medical_services;
    }
  }

  Color get color {
    switch (this) {
      case EmergencyType.cardiac:
        return Colors.red;
      case EmergencyType.respiratory:
        return Colors.blue;
      case EmergencyType.trauma:
        return Colors.orange;
      case EmergencyType.stroke:
        return Colors.purple;
      case EmergencyType.allergic:
        return Colors.amber;
      case EmergencyType.other:
        return Colors.grey;
    }
  }
}
