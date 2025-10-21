import 'package:flutter/material.dart';

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF161B22) : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Portfolio Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Center(
              child: Image.asset(
                'lib/images/portfolio.jpg',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const Text("Total Balance: \$12,400",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text("Profit/Loss: +\$540 (+4.3%)",
                style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
