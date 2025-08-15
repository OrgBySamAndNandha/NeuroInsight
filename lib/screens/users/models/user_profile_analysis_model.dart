// l_ib/screens/models/user_profile_analysis_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileAnalysisModel {
  final String uid;
  final String gender;
  final int birthYear;
  final String currentCondition;
  final String exerciseFrequency;
  final String eatingHabits;
  final Timestamp lastUpdated;

  ProfileAnalysisModel({
    required this.uid,
    required this.gender,
    required this.birthYear,
    required this.currentCondition,
    required this.exerciseFrequency,
    required this.eatingHabits,
    required this.lastUpdated,
  });

  /// Converts the model instance to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'gender': gender,
      'birthYear': birthYear,
      'currentCondition': currentCondition,
      'exerciseFrequency': exerciseFrequency,
      'eatingHabits': eatingHabits,
      'lastUpdated': lastUpdated,
    };
  }
}