import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  final VoidCallback? onBalanceUpdated;

  const WalletScreen({super.key, this.onBalanceUpdated});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with TickerProviderStateMixin {
  double balancePKR = 12000;
  double balanceUSD = 43.50;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Simulate adding money (in real app, integrate with payment gateway/Firestore)
  Future<void> _addMoney(String method, double amount, String currency) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.add_chart, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            const Text('Add Money'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Adding $amount $currency via $method...'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);

      setState(() {
        if (currency == 'PKR') {
          balancePKR += amount;
        } else {
          balanceUSD += amount;
        }
      });

      // Notify parent (e.g., Dashboard) to update portfolio
      widget.onBalanceUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $amount $currency successfully! 🎉'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Portfolio',
              textColor: Colors.white,
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ),
        );
      }
    }
  }

  // Input dialog for amount
  void _showAmountDialog(String method, String currency) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$method - Enter Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                Navigator.pop(context);
                _addMoney(method, amount, currency);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.indigo.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {}); // Refresh balances
              widget.onBalanceUpdated?.call();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 💰 Enhanced Wallet Summary Card with Animation
              Hero(
                tag: 'wallet-card',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.indigo.shade900, Colors.purple.shade900]
                          : [Colors.indigo.shade400, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.wallet, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Current Balances',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildBalanceRow('PKR', balancePKR.toStringAsFixed(0), Icons.currency_rupee),
                      const SizedBox(height: 12),
                      _buildBalanceRow('USD', balanceUSD.toStringAsFixed(2), Icons.currency_exchange),
                      const SizedBox(height: 8),
                      Text(
                        'Total: \$${ (balanceUSD + (balancePKR / 280)).toStringAsFixed(2) }', // Approx PKR to USD conversion
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 🔄 Add Money Section with Icons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.indigo, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add Money',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentButton('Bank Transfer', Icons.account_balance, Colors.indigo, () => _showAmountDialog('Bank Transfer', 'USD')),
                    _buildPaymentButton('Easypaisa', Icons.mobile_friendly, Colors.green, () => _showAmountDialog('Easypaisa', 'PKR')),
                    _buildPaymentButton('JazzCash', Icons.account_balance_wallet, Colors.orange, () => _showAmountDialog('JazzCash', 'PKR')),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 📊 Recent Transactions with ListView and Divider
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            // Navigate to full transaction history (placeholder)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Full history coming soon!')),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          label: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionTile('Easypaisa Deposit', '+ PKR 5,000', Icons.arrow_downward, Colors.green, textColor),
                    const Divider(height: 1, color: Colors.grey),
                    _buildTransactionTile('JazzCash Transfer', '- PKR 3,000', Icons.arrow_upward, Colors.red, textColor),
                    const Divider(height: 1, color: Colors.grey),
                    _buildTransactionTile('Bank Transfer', '+ PKR 2,000', Icons.arrow_downward, Colors.blue, textColor),
                    const Divider(height: 1, color: Colors.grey),
                    _buildTransactionTile('Stock Purchase (AAPL)', '- USD 1,200', Icons.trending_down, Colors.orange, textColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceRow(String currency, String amount, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currency, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, IconData icon, Color iconColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                Text('Completed • Today', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}