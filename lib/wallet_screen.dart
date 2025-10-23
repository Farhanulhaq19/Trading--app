import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balancePKR = 12000;
  double balanceUSD = 43.50;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgCard = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: isDark ? Colors.indigo.shade700 : Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 💰 Wallet Summary Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.indigo.shade900, Colors.blueGrey.shade800]
                      : [Colors.indigo.shade400, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Current Balances',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PKR ${balancePKR.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'USD ${balanceUSD.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Money Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Money',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentButton('Bank Transfer', Icons.account_balance, Colors.indigo, isDark),
            _buildPaymentButton('Easypaisa', Icons.mobile_friendly, Colors.green, isDark),
            _buildPaymentButton('JazzCash', Icons.account_balance_wallet, Colors.orange, isDark),

            const SizedBox(height: 30),

            // 📜 Recent Transactions Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 10),
            _buildTransactionTile('Easypaisa Deposit', 'PKR 5000', Icons.arrow_downward, Colors.green),
            _buildTransactionTile('JazzCash Transfer', 'PKR 3000', Icons.arrow_upward, Colors.red),
            _buildTransactionTile('Bank Transfer', 'PKR 2000', Icons.arrow_downward, Colors.blue),
          ],
        ),
      ),
    );
  }
 //                   Payment
  Widget _buildPaymentButton(String title, IconData icon, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title method selected!')),
          );
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: color.withOpacity(0.4),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, IconData icon, Color iconColor) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: const Text('Completed'),
        trailing: Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
        ),
      ),
    );
  }
}
