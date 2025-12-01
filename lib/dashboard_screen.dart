import 'dart:async';
import 'dart:math'; // For Random in simulation
import 'package:flutter/material.dart';
import 'models/stock.dart';
import 'services/stock_service.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const DashboardScreen({Key? key, required this.onThemeToggle})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  double portfolioValue = 100000;
  double dayChange = 0;
  double dayChangePercent = 0;

  // Use ValueNotifier for shared state (updates Analytics too)
  late ValueNotifier<List<Stock>> stocksNotifier;

  @override
  void initState() {
    super.initState();

    // Initialize stocks with real symbols
    stocksNotifier = ValueNotifier([
      Stock(symbol: 'AAPL', name: 'Apple Inc.', price: 150.0, change: 0, changePercent: 0),
      Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', price: 2800.0, change: 0, changePercent: 0),
      Stock(symbol: 'TSLA', name: 'Tesla Inc.', price: 750.0, change: 0, changePercent: 0),
      Stock(symbol: 'MSFT', name: 'Microsoft Corp.', price: 350.0, change: 0, changePercent: 0),
      Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', price: 3300.0, change: 0, changePercent: 0),
    ]);

    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    // Update every 60 seconds to respect API limits (5 calls/min free tier)
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updatePrices();
    });

    _updatePrices(); // Initial call
  }

  Future<void> _updatePrices() async {
    List<Stock> updatedStocks = List.from(stocksNotifier.value);
    bool apiSuccess = false;

    for (var stock in updatedStocks) {
      try {
        final data = await StockService.fetchStockQuote(stock.symbol);

        if (data != null && data.isNotEmpty) {
          // Real API update
          stock.price = double.tryParse(data["05. price"] ?? "0") ?? stock.price;
          stock.change = double.tryParse(data["09. change"] ?? "0") ?? 0;
          stock.changePercent = double.tryParse(
            (data["10. change percent"] ?? "0").replaceAll('%', ''),
          ) ?? 0;
          apiSuccess = true;
        } else {
          // Fallback: Simulate small random change (±0.5% to ±2%)
          _simulateChange(stock);
        }
      } catch (e) {
        // Network/error fallback: Simulate
        _simulateChange(stock);
        print('API error for ${stock.symbol}: $e'); // Debug log
      }

      // Small delay between calls to respect rate limits (total ~60s for 5 stocks)
      await Future.delayed(const Duration(seconds: 12));
    }

    // Recalculate portfolio (assuming 1 share per stock for demo; adjust as needed)
    dayChange = updatedStocks.fold(0.0, (sum, s) => sum + s.change);
    dayChangePercent = (dayChange / portfolioValue) * 100;
    portfolioValue += dayChange;

    // Trigger UI update
    stocksNotifier.value = updatedStocks;

    // Optional: Show snackbar on success
    if (apiSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Stocks updated from live market! 📈'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Fallback simulation: Small realistic changes
  void _simulateChange(Stock stock) {
    final random = Random();
    final percentChange = (random.nextDouble() - 0.5) * 4; // -2% to +2%
    stock.changePercent = percentChange;
    stock.change = stock.price * (percentChange / 100);
    stock.price += stock.change;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Your background image
          Image.asset('lib/images/2.jpg', fit: BoxFit.cover),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.85)
                : Colors.white.withOpacity(0.3),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(isDark),
                  const SizedBox(height: 20),
                  _buildPortfolioCard(isDark),
                  const SizedBox(height: 20),
                  _buildStocksList(isDark),
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
        Text(
          'Trady App Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
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
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white : Colors.black,
              ),
              tooltip: 'Toggle Theme',
              onPressed: widget.onThemeToggle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioCard(bool isDark) {
    return Card(
      color: isDark
          ? Colors.grey[900]!.withOpacity(0.9)
          : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio Value',
                style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '\$${portfolioValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          dayChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
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

  Widget _buildStocksList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Watchlist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        // Auto-updates with ValueNotifier
        ValueListenableBuilder<List<Stock>>(
          valueListenable: stocksNotifier,
          builder: (context, stocks, child) {
            return Column(
              children: stocks.map((stock) => _buildStockTile(stock, isDark)).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsScreen(stocksNotifier: stocksNotifier),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockTile(Stock stock, bool isDark) {
    return Card(
      color: isDark
          ? Colors.grey[850]!.withOpacity(0.9)
          : Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            stock.symbol[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          stock.symbol,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
        ),
        subtitle: Text(
          stock.name,
          style: TextStyle(
              fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[800]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${stock.price.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black),
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