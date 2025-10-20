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
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Current Balances', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('PKR ${balancePKR.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, color: Colors.indigo)),
                    Text('USD ${balanceUSD.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Add Money', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentButton('Bank Transfer', Icons.account_balance, Colors.indigo),
            _buildPaymentButton('Easypaisa', Icons.mobile_friendly, Colors.green),
            _buildPaymentButton('JazzCash', Icons.account_balance_wallet, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title method selected!')),
          );
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
