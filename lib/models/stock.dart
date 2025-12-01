// models/stock.dart
class Stock {
  final String symbol;      // e.g. "AAPL"
  final String name;        // e.g. "Apple Inc."
  double price;             // current price
  double change;            // price change
  double changePercent;     // change in percentage

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
  });
}
