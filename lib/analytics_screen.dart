import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'widgets/daily_pl_widget.dart';
import 'widgets/portfolio_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Stock> stocks;

  const AnalyticsScreen({Key? key, required this.stocks}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 👇 Set default tab to Win/Loss (index = 2)
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        elevation: 2,
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.indigo,
          labelColor: isDark ? Colors.white : Colors.indigo,
          tabs: const [
            Tab(text: 'Portfolio', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
            Tab(text: 'Win/Loss', icon: Icon(Icons.analytics)),
            Tab(text: 'Daily P&L', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChartPage(
            'Portfolio Allocation',
            'Your investments by sector and asset type',
            Icons.pie_chart,
            _buildPortfolioInsights(),
          ),
          _buildChartPage(
            'Performance Overview',
            'Weekly and Monthly portfolio performance',
            Icons.show_chart,
            _buildPerformanceInsights(),
          ),
          _buildChartPage(
            'Win/Loss Analysis',
            'Your trading accuracy and statistics',
            Icons.analytics,
            _buildWinLossInsights(),
          ),
          _buildChartPage(
            'Daily Gains & Losses',
            'Track top gainers and losers for today',
            Icons.bar_chart,
            _buildDailyPLInsights(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPage(
      String title, String subtitle, IconData icon, Widget insights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 100,
                  color:
                  Theme.of(context).colorScheme.primary.withOpacity(0.25),
                ),
              ),
            ),
            const SizedBox(height: 20),
            insights,
          ],
        ),
      ),
    );
  }

  // ---------------------- Portfolio Insights ----------------------

  Widget _buildPortfolioInsights() {
    return _buildInsightsCard('Portfolio Breakdown', [
      _insightRow('Total Value', '\$25,400'),
      _insightRow('Largest Sector', 'Technology (45%)'),
      _insightRow('Diversification', 'Good (6 sectors)'),
      _insightRow('Volatility', 'Moderate Risk'),
      _insightRow('Suggestion', 'Add Energy & Healthcare stocks'),
    ]);
  }

  // ---------------------- Performance Insights ----------------------

  Widget _buildPerformanceInsights() {
    return _buildInsightsCard('Performance Summary', [
      _insightRow('7-Day Return', '+2.5%'),
      _insightRow('30-Day Return', '+8.1%'),
      _insightRow('Best Day', 'Friday (+1.7%)'),
      _insightRow('Worst Day', 'Monday (-0.9%)'),
      _insightRow('Overall Trend', 'Upward Momentum 📈'),
    ]);
  }

  // ---------------------- Win/Loss Insights ----------------------

  Widget _buildWinLossInsights() {
    return _buildInsightsCard('Trading Statistics', [
      _insightRow('Total Trades', '54'),
      _insightRow('Winning Trades', '35 (64%)'),
      _insightRow('Losing Trades', '19 (36%)'),
      _insightRow('Average Win', '+\$245'),
      _insightRow('Average Loss', '-\$180'),
      _insightRow('Profit Factor', '1.36'),
    ]);
  }

  // ---------------------- Daily P&L Insights ----------------------

  Widget _buildDailyPLInsights() {
    final best = widget.stocks
        .reduce((a, b) => a.changePercent > b.changePercent ? a : b);
    final worst = widget.stocks
        .reduce((a, b) => a.changePercent < b.changePercent ? a : b);
    final gainers = widget.stocks.where((s) => s.changePercent > 0).length;

    return _buildInsightsCard('Today\'s Summary', [
      _insightRow('Best Performer',
          '${best.symbol} (${best.changePercent.toStringAsFixed(2)}%)'),
      _insightRow('Worst Performer',
          '${worst.symbol} (${worst.changePercent.toStringAsFixed(2)}%)'),
      _insightRow('Gainers', '$gainers/${widget.stocks.length}'),
      _insightRow('Market Mood',
          gainers > widget.stocks.length / 2 ? 'Bullish 🟢' : 'Bearish 🔴'),
    ]);
  }

  // ---------------------- Helper UI Widgets ----------------------

  Widget _buildInsightsCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}

