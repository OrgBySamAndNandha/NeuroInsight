import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/users/models/user_profile_analysis_model.dart';

import '../models/user_task_model.dart';

class TaskService {

  // This function determines the current time category
  TimeOfDayCategory _getCurrentTimeCategory() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return TimeOfDayCategory.morning;
    } else if (hour < 17) {
      return TimeOfDayCategory.afternoon;
    } else {
      return TimeOfDayCategory.evening;
    }
  }

  // This is the main function that gets the tasks
  // In a real app, you would pass the user's profile here
  // Future<List<TaskModel>> getTasksForCurrentUser(ProfileAnalysisModel userProfile) async { ... }
  List<TaskModel> getTasksForCurrentUser() {
    final currentTimeCategory = _getCurrentTimeCategory();
    List<TaskModel> tasks = [];

    // Base tasks that are always recommended
    final allTasks = [
      TaskModel(
        title: "Take Medication",
        description: "It's important to take your prescribed medication, such as Donepezil, at the scheduled time. This helps manage symptoms and slow progression.",
        icon: Icons.medication,
        timeCategory: TimeOfDayCategory.morning, id: '', verificationPrompt: '',
      ),
      TaskModel(
        title: "Read a Book",
        description: "Reading stimulates the mind and helps maintain cognitive function. Choose a book or a newspaper for at least 20-30 minutes.",
        icon: Icons.book,
        timeCategory: TimeOfDayCategory.morning, id: '', verificationPrompt: '',
      ),
      TaskModel(
        title: "Have a Healthy Meal",
        description: "A balanced diet is crucial for brain health. Focus on fruits, vegetables, and whole grains. Avoid processed foods.",
        icon: Icons.restaurant,
        timeCategory: TimeOfDayCategory.afternoon, id: '', verificationPrompt: '',
      ),
      TaskModel(
        title: "Go for a Walk",
        description: "Light physical activity like a short walk outdoors improves blood flow to the brain and can boost your mood. Aim for 15-20 minutes.",
        icon: Icons.directions_walk,
        timeCategory: TimeOfDayCategory.afternoon, id: '', verificationPrompt: '',
      ),
      TaskModel(
        title: "Connect with Family",
        description: "Social interaction is a powerful tool against cognitive decline. Call a friend or spend time with family.",
        icon: Icons.people,
        timeCategory: TimeOfDayCategory.evening, id: '', verificationPrompt: '',
      ),
      TaskModel(
        title: "Listen to Music",
        description: "Listen to some of your favorite old songs. Music can evoke memories and create a calming and positive emotional state.",
        icon: Icons.music_note,
        timeCategory: TimeOfDayCategory.evening, id: '', verificationPrompt: '',
      ),
    ];

    // Filter tasks based on the current time of day
    tasks = allTasks.where((task) => task.timeCategory == currentTimeCategory).toList();

    // Here you would add personalization based on the user's profile
    // For example:
    // if (userProfile.exerciseFrequency == 'Never') {
    //   tasks.add(TaskModel(... for starting light exercise));
    // }

    return tasks;
  }
}