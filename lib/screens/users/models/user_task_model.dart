import 'package:flutter/material.dart';

enum TimeOfDayCategory { morning, afternoon, evening }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final TimeOfDayCategory timeCategory;
  final String verificationPrompt; // Prompt for Gemini
  String status; // 'pending' or 'completed'

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.timeCategory,
    required this.verificationPrompt,
    this.status = 'pending',
  });
}