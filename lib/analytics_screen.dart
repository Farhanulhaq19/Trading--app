import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/stock.dart';

class AnalyticsScreen extends StatefulWidget {
  final ValueNotifier<List<Stock>> stocksNotifier;

  const AnalyticsScreen({Key? key, required this.stocksNotifier})
      : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Fake historical data (replace with real history later)
  final List<double> portfolioHistory = [
    98500, 99200, 101200, 100800, 103500, 105200, 107800, 109500, 112000, 115000,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.indigo,
          labelColor: Colors.indigo,
          unselectedLabelColor: isDark ? Colors.grey : Colors.black54,
          tabs: const [
            Tab(text: 'Portfolio', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
            Tab(text: 'Win/Loss', icon: Icon(Icons.analytics)),
            Tab(text: 'Daily P&L', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<Stock>>(
        valueListenable: widget.stocksNotifier,
        builder: (context, stocks, child) {
          final totalValue = _calculatePortfolioValue(stocks);
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPortfolioTab(totalValue, isDark),
              _buildPerformanceTab(isDark),
              _buildWinLossTab(isDark),
              _buildDailyPLTab(stocks, isDark),
            ],
          );
        },
      ),
      // Footer completely REMOVED
    );
  }

  double _calculatePortfolioValue(List<Stock> stocks) {
    const sharesPerStock = 80.0;
    const pkrBalance = 12000.0;
    const usdBalance = 43.50;
    const pkrToUsd = 278.0;

    final stockValue = stocks.fold(0.0, (sum, s) => sum + s.price * sharesPerStock);
    final cashValue = usdBalance + (pkrBalance / pkrToUsd);
    return stockValue + cashValue;
  }

  // Tab 1: Portfolio Growth Line Chart
  Widget _buildPortfolioTab(double currentValue, bool isDark) {
    final spots = portfolioHistory
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Portfolio Growth", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Today'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(days[value.toInt()], style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.indigo,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.indigo.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _insightCard("Current Value", "\$${currentValue.toStringAsFixed(0)}", Icons.trending_up, Colors.green),
          _insightCard("30-Day Gain", "+15.2%", Icons.arrow_upward, Colors.green),
          _insightCard("Risk Level", "Moderate", Icons.speed, Colors.orange),
        ],
      ),
    );
  }

  // Tab 2: Performance
  Widget _buildPerformanceTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("30-Day Performance", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineTouchData: const LineTouchData(enabled: false),
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 100000), FlSpot(5, 102000), FlSpot(10, 108000),
                      FlSpot(15, 105000), FlSpot(20, 112000), FlSpot(25, 115000), FlSpot(30, 115000),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _insightCard("Best Week", "+8.4%", Icons.emoji_events, Colors.amber),
          _insightCard("Average Daily", "+0.42%", Icons.show_chart, Colors.blue),
        ],
      ),
    );
  }

  // Tab 3: Win/Loss Pie Chart
  Widget _buildWinLossTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Trading Win Rate", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 30),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 64, color: Colors.green, title: '64% Win', radius: 80, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 36, color: Colors.red, title: '36% Loss', radius: 70, titleStyle: const TextStyle(color: Colors.white)),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 4,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _insightCard("Total Trades", "54", Icons.swap_horiz, Colors.indigo),
          _insightCard("Profit Factor", "1.36", Icons.trending_up, Colors.green),
        ],
      ),
    );
  }

  // Tab 4: Daily P&L Bar Chart
  Widget _buildDailyPLTab(List<Stock> stocks, bool isDark) {
    final sorted = List.from(stocks)..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    final bars = sorted.asMap().entries.map((e) => BarChartGroupData(
      x: e.key,
      barRods: [BarChartRodData(toY: e.value.changePercent, color: e.value.changePercent >= 0 ? Colors.green : Colors.red, width: 20)],
    )).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Gainers & Losers", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: bars,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => value.toInt() < sorted.length
                        ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(sorted[value.toInt()].symbol, style: const TextStyle(fontSize: 12)))
                        : const Text(''),
                  )),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}%'))),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ...sorted.take(3).map((s) => _insightCard(
            "${s.changePercent > 0 ? "Top Gainer" : "Top Loser"}: ${s.symbol}",
            "${s.changePercent > 0 ? '+' : ''}${s.changePercent.toStringAsFixed(2)}%",
            s.changePercent > 0 ? Icons.trending_up : Icons.trending_down,
            s.changePercent > 0 ? Colors.green : Colors.red,
          )),
        ],
      ),
    );
  }

  Widget _insightCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ),
    );
  }
}
