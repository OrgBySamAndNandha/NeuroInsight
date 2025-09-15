import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/users/views/task_detail_view.dart';

import '../controllers/user_task_controller.dart';
import '../models/user_task_model.dart';

class DailyTasksCarousel extends StatefulWidget {
  const DailyTasksCarousel({super.key});

  @override
  State<DailyTasksCarousel> createState() => _DailyTasksCarouselState();
}

class _DailyTasksCarouselState extends State<DailyTasksCarousel> {
  final TaskService _taskService = TaskService();
  late List<TaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _taskService.getTasksForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140, // Height of the carousel
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          // Add padding to the first and last items for visual spacing
          final horizontalPadding = index == 0 || index == _tasks.length -1 ? 16.0 : 8.0;

          return Padding(
            padding: EdgeInsets.only(left: horizontalPadding, right: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskDetailView(task: task)),
                );
              },
              child: Container(
                width: 150, // Width of each card
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(task.icon, size: 28),
                    const Spacer(),
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}