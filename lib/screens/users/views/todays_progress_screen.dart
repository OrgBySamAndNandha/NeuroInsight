import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'info_card.dart';

class TodaysProgressWidget extends StatelessWidget {
  const TodaysProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // This is using mocked data for demonstration
    int totalTasks = 8;
    int completedTasks = 2;
    double percent = completedTasks / totalTasks;
    const accentColor = Color(0xFF2DB8A1);

    return InfoCard(
      title: "PROGRESS",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Tasks",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                "$completedTasks of $totalTasks completed",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 35.0,
            lineWidth: 8.0,
            animation: true,
            percent: percent,
            center: Text(
              "${(percent * 100).toInt()}%",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: accentColor,
            backgroundColor: accentColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}