import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color backgroundColor;
  final Color titleColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor = Colors.white, // Changed default to white
    this.titleColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12.0),
          child,
        ],
      ),
    );
  }
}