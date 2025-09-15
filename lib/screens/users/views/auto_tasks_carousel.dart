import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:neuroinsight/screens/users/views/task_detail_view.dart';

import '../controllers/user_task_controller.dart';
import '../models/user_task_model.dart';

class AutoTasksCarousel extends StatefulWidget {
  const AutoTasksCarousel({super.key});

  @override
  State<AutoTasksCarousel> createState() => _AutoTasksCarouselState();
}

class _AutoTasksCarouselState extends State<AutoTasksCarousel> {
  final TaskService _taskService = TaskService();
  late List<TaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _taskService.getTasksForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index, realIndex) {
        final task = _tasks[index];
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaskDetailView(task: task)));
          },
          child: Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2DB8A1), // Using the new accent color
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(task.icon, color: Colors.white, size: 28),
                  const Spacer(),
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 110,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.5,
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
      ),
    );
  }
}