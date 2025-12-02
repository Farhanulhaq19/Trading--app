// lib/widgets/dashboard_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock.dart';
import '../services/stock_service.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const DashboardScreen({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  double portfolioValue = 0;
  double previousPortfolioValue = 0;
  double dayChange = 0;
  double dayChangePercent = 0;

  double balancePKR = 12000;
  double balanceUSD = 43.50;
  static const double pkrToUsdRate = 278.0;
  static const double sharesPerStock = 80.0;

  late ValueNotifier<List<Stock>> stocksNotifier;

  @override
  void initState() {
    super.initState();
    stocksNotifier = ValueNotifier([
      Stock(symbol: 'AAPL', name: 'Apple Inc.', price: 220.0, change: 0, changePercent: 0),
      Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', price: 180.0, change: 0, changePercent: 0),
      Stock(symbol: 'TSLA', name: 'Tesla Inc.', price: 250.0, change: 0, changePercent: 0),
      Stock(symbol: 'MSFT', name: 'Microsoft Corp.', price: 420.0, change: 0, changePercent: 0),
      Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', price: 185.0, change: 0, changePercent: 0),
    ]);
    _calculatePortfolio(stocksNotifier.value);
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    stocksNotifier.dispose();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _updatePrices());
    _updatePrices();
  }

  double _calculateTotalValue(List<Stock> stocks) {
    final stocksValue = stocks.fold(0.0, (sum, s) => sum + s.price * sharesPerStock);
    final cashValue = balanceUSD + (balancePKR / pkrToUsdRate);
    return stocksValue + cashValue;
  }

  void _calculatePortfolio(List<Stock> stocks) {
    final current = _calculateTotalValue(stocks);
    dayChange = current - previousPortfolioValue;
    dayChangePercent = previousPortfolioValue > 0 ? (dayChange / previousPortfolioValue) * 100 : 0;
    portfolioValue = current;
    previousPortfolioValue = current;
  }

  Future<void> _updatePrices() async {
    List<Stock> updated = List.from(stocksNotifier.value);
    bool success = false;
    for (var stock in updated) {
      try {
        final data = await StockService.fetchStockQuote(stock.symbol);
        if (data != null && data.isNotEmpty) {
          stock.price = double.tryParse(data["05. price"] ?? "0") ?? stock.price;
          stock.change = double.tryParse(data["09. change"] ?? "0") ?? 0;
          stock.changePercent = double.tryParse((data["10. change percent"] ?? "0%").replaceAll('%', '')) ?? 0;
          success = true;
        } else {
          _simulateChange(stock);
        }
      } catch (e) {
        _simulateChange(stock);
      }
      await Future.delayed(const Duration(seconds: 12));
    }
    _calculatePortfolio(updated);
    stocksNotifier.value = updated;
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stocks updated live!'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _simulateChange(Stock stock) {
    final random = Random();
    final percent = (random.nextDouble() - 0.5) * 4;
    stock.changePercent = percent;
    stock.change = stock.price * (percent / 100);
    stock.price += stock.change;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('lib/images/2.jpg', fit: BoxFit.cover),
          Container(color: isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.3)),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(isDark),
                        const SizedBox(height: 20),
                        _buildPortfolioCard(isDark),
                        const SizedBox(height: 24),
                        _buildStocksList(isDark),
                        const SizedBox(height: 24),
                        _buildPortfolioTrendChart(isDark), // NEW LINE CHART
                        const SizedBox(height: 24),
                        _buildPortfolioPieChart(isDark),  // NEW PIE CHART
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AnalyticsScreen(stocksNotifier: stocksNotifier)),
                            ),
                            icon: const Icon(Icons.analytics, color: Colors.black),
                            label: const Text('View Analytics', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildFooter(isDark), // NEW RESPONSIVE FOOTER
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────── UI WIDGETS ──────────────────────

  Widget _buildAppBar(bool isDark) { /* same as before – omitted for brevity */
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Trady Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        Row(children: [
          IconButton(icon: const Icon(Icons.account_balance_wallet), color: isDark ? Colors.white : Colors.black, onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(onBalanceUpdated: () => setState(() => _calculatePortfolio(stocksNotifier.value)))));
          }),
          IconButton(icon: const Icon(Icons.person), color: isDark ? Colors.white : Colors.black, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), color: isDark ? Colors.white : Colors.black, onPressed: widget.onThemeToggle),
        ]),
      ],
    );
  }

  Widget _buildPortfolioCard(bool isDark) { /* same as before – shortened */
    return Card(
      color: isDark ? Colors.grey[900]!.withOpacity(0.9) : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Portfolio Value', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700])),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${portfolioValue.toStringAsFixed(2)}', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: dayChange >= 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(dayChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward, color: dayChange >= 0 ? Colors.green : Colors.red, size: 18),
                const SizedBox(width: 4),
                Text('${dayChange >= 0 ? '+' : ''}\$${dayChange.abs().toStringAsFixed(2)} (${dayChangePercent.toStringAsFixed(2)}%)',
                    style: TextStyle(color: dayChange >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildStocksList(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Watchlist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      const SizedBox(height: 12),
      ValueListenableBuilder<List<Stock>>(
        valueListenable: stocksNotifier,
        builder: (context, stocks, _) {
          _calculatePortfolio(stocks);
          return Column(children: stocks.map((s) => _buildStockTile(s, isDark)).toList());
        },
      ),
    ]);
  }

  Widget _buildStockTile(Stock stock, bool isDark) {
    return Card(
      color: isDark ? Colors.grey[850]!.withOpacity(0.9) : Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Text(stock.symbol[0], style: const TextStyle(fontWeight: FontWeight.bold))),
        title: Text(stock.symbol, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(stock.name, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[800])),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${stock.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          Text('${stock.change >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%', style: TextStyle(fontSize: 12, color: stock.change >= 0 ? Colors.green : Colors.red)),
        ]),
      ),
    );
  }

  // ─────── PORTFOLIO TREND CHART (exactly like your screenshot) ───────
  Widget _buildPortfolioTrendChart(bool isDark) {
    final spots = <FlSpot>[];
    final random = Random();
    final base = portfolioValue;
    for (int i = 0; i < 13; i++) {
      final variation = (random.nextDouble() - 0.5) * 0.4;
      final value = base * (0.6 + variation + 0.04 * i);
      spots.add(FlSpot(i.toDouble(), value));
    }

    return Card(
      color: isDark ? Colors.grey[900]!.withOpacity(0.9) : Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Portfolio Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.cyan.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Text('€225k/MW/Year', style: TextStyle(color: Colors.cyan.shade900, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 50000),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(spots: spots, isCurved: true, color: Colors.pink.shade600, barWidth: 3, dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.pink.shade100.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _legendItem(Colors.pink.shade200, 'Performance distribution across all assets'),
              const SizedBox(width: 20),
              _legendItem(Colors.grey.shade400, 'Average portfolio performance'),
              const SizedBox(width: 20),
              _legendItem(Colors.pink.shade600, 'Max portfolio performance'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(children: [
      Container(width: 16, height: 3, color: color),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 11)),
    ]);
  }

  // ─────── PORTFOLIO PIE CHART ───────
  Widget _buildPortfolioPieChart(bool isDark) {
    final stocks = stocksNotifier.value;
    final cashUSD = balanceUSD + balancePKR / pkrToUsdRate;
    final sections = <PieChartSectionData>[];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.cyan];

    for (int i = 0; i < stocks.length; i++) {
      final value = stocks[i].price * sharesPerStock;
      sections.add(PieChartSectionData(value: value, color: colors[i], title: '${(value / portfolioValue * 100).toStringAsFixed(1)}%', radius: 60, titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)));
    }
    sections.add(PieChartSectionData(value: cashUSD, color: Colors.grey, title: '${(cashUSD / portfolioValue * 100).toStringAsFixed(1)}%', radius: 60, titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)));

    return Card(
      color: isDark ? Colors.grey[900]!.withOpacity(0.9) : Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Portfolio Allocation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 40))),
            const SizedBox(height: 16),
            Wrap(spacing: 16, runSpacing: 8, children: [
              ...stocks.asMap().entries.map((e) => _pieLegend(colors[e.key], e.value.symbol)),
              _pieLegend(Colors.grey, 'Cash'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _pieLegend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }

  // ─────── RESPONSIVE FOOTER (White in Light, Dark in Dark) ───────
  Widget _buildFooter(bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.grey.shade800;
    final titleColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _footerColumn('Info', ['Invest', 'SIP Calculator', 'Pricing', 'FAQs', 'Blog'], titleColor, textColor),
              _footerColumn('Getting Started', ['How to Invest', 'Taxation', 'Recharge', 'Withdraw', 'Guides'], titleColor, textColor),
              _footerColumn('Resources', ['API', 'Help & Support', 'Financial Literacy', 'Referral', 'Contact Us'], titleColor, textColor),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Newsletter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 12),
                Text('Subscribe to get latest offers', style: TextStyle(color: textColor)),
                const SizedBox(height: 12),
                Row(children: [
                  SizedBox(width: 180, child: TextField(decoration: InputDecoration(hintText: 'Your email', contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () {}, child: const Text('Subscribe'), style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black)),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Icon(Icons.facebook, color: textColor),
                  const SizedBox(width: 16),
                  Icon(Icons.camera_alt, color: textColor),
                  const SizedBox(width: 16),
                  Icon(Icons.code, color: textColor),
                  const SizedBox(width: 16),
                  const Text('Pakistan flag', style: TextStyle(fontSize: 24)),
                ]),
              ]),
            ],
          ),
          const Divider(height: 40),
          Text('© 2025 Trady App • Made with Pakistan in Pakistan', style: TextStyle(color: textColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items, Color titleColor, Color textColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
      const SizedBox(height: 16),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(item, style: TextStyle(color: textColor)))),
    ]);
  }
}
