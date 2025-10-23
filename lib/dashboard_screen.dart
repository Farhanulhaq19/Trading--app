import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';
import 'widgets/footer_widget.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const DashboardScreen({Key? key, required this.onThemeToggle})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  final Random _random = Random();

  double portfolioValue = 100000;
  double dayChange = 0;
  double dayChangePercent = 0;

  List<Stock> stocks = [
    Stock('AAPL', 'Apple Inc.', 150.0, 0, 0),
    Stock('GOOGL', 'Alphabet Inc.', 2800.0, 0, 0),
    Stock('TSLA', 'Tesla Inc.', 750.0, 0, 0),
    Stock('MSFT', 'Microsoft Corp.', 350.0, 0, 0),
    Stock('AMZN', 'Amazon.com Inc.', 3300.0, 0, 0),
  ];

  @override
  void initState() {
    super.initState();
    _startPriceSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPriceSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        for (var stock in stocks) {
          double changePercent = (_random.nextDouble() - 0.5) * 2;
          stock.changePercent = changePercent;
          stock.change = stock.price * changePercent / 100;
          stock.price += stock.change;
        }

        dayChange = stocks.fold(0, (sum, stock) => sum + stock.change * 100);
        dayChangePercent = dayChange / portfolioValue * 100;
        portfolioValue += dayChange;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 👇 Background image
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/images/2.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(isDark),
                  const SizedBox(height: 20),
                  _buildPortfolioCard(),
                  const SizedBox(height: 20),
                  _buildStocksList(),
                ],
              ),
            ),
          ),

        ],
      ),

    );
  }

  Widget _buildAppBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          ' Trady App Dashboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              tooltip: 'Wallet',
              color: isDark ? Colors.white : Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
              color: isDark ? Colors.white : Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: 'Toggle Theme',
              color: isDark ? Colors.white : Colors.black,
              onPressed: widget.onThemeToggle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Portfolio Value',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '\$${portfolioValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: dayChange >= 0
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          dayChange >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: dayChange >= 0 ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${dayChange >= 0 ? '+' : ''}\$${dayChange.abs().toStringAsFixed(2)} (${dayChangePercent.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color: dayChange >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStocksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Watchlist',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...stocks.map((stock) => _buildStockTile(stock)).toList(),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsScreen(stocks: stocks),
                ),
              );
            },
            icon: const Icon(Icons.analytics, color: Colors.black),
            label: const Text(
              'View Analytics',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
              elevation: 4,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockTile(Stock stock) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            stock.symbol[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title:
        Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(stock.name, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${stock.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${stock.change >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 12,
                color: stock.change >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Stock {
  final String symbol;
  final String name;
  double price;
  double change;
  double changePercent;

  Stock(this.symbol, this.name, this.price, this.change, this.changePercent);
}
