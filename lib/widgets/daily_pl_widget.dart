import 'package:flutter/material.dart';

class DailyPLWidget extends StatelessWidget {
  const DailyPLWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stocks = [
      {"symbol": "AAPL", "change": 1.3},
      {"symbol": "GOOG", "change": -0.8},
      {"symbol": "TSLA", "change": 2.1},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Performance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...stocks.map((s) {
              return ListTile(
                leading: Icon(
                  s['change'] > 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: s['change'] > 0 ? Colors.green : Colors.red,
                ),
                title: Text(s['symbol']),
                trailing: Text(
                  '${s['change']}%',
                  style: TextStyle(
                    color: s['change'] > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
