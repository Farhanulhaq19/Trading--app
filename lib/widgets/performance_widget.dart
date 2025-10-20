import 'package:flutter/material.dart';

class PerformanceWidget extends StatelessWidget {
  const PerformanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Performance Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("7-Day Return: +3.5%"),
            const Text("Best Day: Wednesday (+1.1%)"),
            const Text("Worst Day: Monday (-0.7%)"),
            const SizedBox(height: 16),
            Image.asset(
              'assets/images/performance_graph.png',
              height: 160,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
