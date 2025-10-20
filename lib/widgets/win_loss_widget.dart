import 'package:flutter/material.dart';

class WinLossWidget extends StatelessWidget {
  const WinLossWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Win/Loss Ratio",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green, size: 40),
                    Text("Wins: 31"),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.red, size: 40),
                    Text("Losses: 16"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text("Win Rate: 65%", style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
