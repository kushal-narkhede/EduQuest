import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../main.dart' show getBackgroundForTheme;
class PortfolioCompaniesScreen extends StatefulWidget {
  final String currentTheme;
  const PortfolioCompaniesScreen({super.key, required this.currentTheme});

  @override
  State<PortfolioCompaniesScreen> createState() => _PortfolioCompaniesScreenState();
}

class _PortfolioCompaniesScreenState extends State<PortfolioCompaniesScreen> {
  final List<Map<String, String>> companies = const [
    {'symbol': 'AAPL', 'name': 'Apple Inc.'},
    {'symbol': 'MSFT', 'name': 'Microsoft Corp.'},
    {'symbol': 'GOOGL', 'name': 'Alphabet Inc.'},
    {'symbol': 'AMZN', 'name': 'Amazon.com Inc.'},
    {'symbol': 'NVDA', 'name': 'NVIDIA Corp.'},
    {'symbol': 'TSLA', 'name': 'Tesla Inc.'},
    {'symbol': 'META', 'name': 'Meta Platforms Inc.'},
    {'symbol': 'BRK.B', 'name': 'Berkshire Hathaway Inc.'},
    {'symbol': 'JPM', 'name': 'JPMorgan Chase & Co.'},
    {'symbol': 'V', 'name': 'Visa Inc.'},
    {'symbol': 'MA', 'name': 'Mastercard Inc.'},
    {'symbol': 'WMT', 'name': 'Walmart Inc.'},
    {'symbol': 'HD', 'name': 'Home Depot Inc.'},
    {'symbol': 'XOM', 'name': 'Exxon Mobil Corp.'},
    {'symbol': 'CVX', 'name': 'Chevron Corp.'},
    {'symbol': 'PG', 'name': 'Procter & Gamble Co.'},
    {'symbol': 'KO', 'name': 'Coca-Cola Co.'},
    {'symbol': 'PEP', 'name': 'PepsiCo Inc.'},
    {'symbol': 'JNJ', 'name': 'Johnson & Johnson'},
    {'symbol': 'UNH', 'name': 'UnitedHealth Group'},
    {'symbol': 'DIS', 'name': 'Walt Disney Co.'},
    {'symbol': 'NFLX', 'name': 'Netflix Inc.'},
    {'symbol': 'ORCL', 'name': 'Oracle Corp.'},
    {'symbol': 'IBM', 'name': 'IBM Corp.'},
    {'symbol': 'INTC', 'name': 'Intel Corp.'},
    {'symbol': 'ADBE', 'name': 'Adobe Inc.'},
    {'symbol': 'CRM', 'name': 'Salesforce Inc.'},
    {'symbol': 'PYPL', 'name': 'PayPal Holdings'},
    {'symbol': 'BAC', 'name': 'Bank of America Corp.'},
    {'symbol': 'C', 'name': 'Citigroup Inc.'},
    {'symbol': 'GS', 'name': 'Goldman Sachs Group'},
    {'symbol': 'MS', 'name': 'Morgan Stanley'},
    {'symbol': 'BA', 'name': 'Boeing Co.'},
    {'symbol': 'NKE', 'name': 'Nike Inc.'},
    {'symbol': 'SBUX', 'name': 'Starbucks Corp.'},
    {'symbol': 'MCD', 'name': 'McDonald’s Corp.'},
    {'symbol': 'T', 'name': 'AT&T Inc.'},
    {'symbol': 'VZ', 'name': 'Verizon Communications'},
    {'symbol': 'AMD', 'name': 'Advanced Micro Devices'},
    {'symbol': 'QCOM', 'name': 'Qualcomm Inc.'},
    {'symbol': 'AMAT', 'name': 'Applied Materials'},
    {'symbol': 'COST', 'name': 'Costco Wholesale Corp.'},
    {'symbol': 'LOW', 'name': 'Lowe’s Cos.'},
    {'symbol': 'TGT', 'name': 'Target Corp.'},
    {'symbol': 'ABBV', 'name': 'AbbVie Inc.'},
    {'symbol': 'PFE', 'name': 'Pfizer Inc.'},
    {'symbol': 'MRK', 'name': 'Merck & Co.'},
    {'symbol': 'LLY', 'name': 'Eli Lilly and Co.'},
    {'symbol': 'RTX', 'name': 'RTX Corp.'},
    {'symbol': 'LMT', 'name': 'Lockheed Martin Corp.'},
    {'symbol': 'CAT', 'name': 'Caterpillar Inc.'},
  ];
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = companies
        .where((c) => _search.isEmpty || c['name']!.toLowerCase().contains(_search.toLowerCase()) || c['symbol']!.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Portfolio Companies'),
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search companies or tickers',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() => _search = val.trim()),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                      itemBuilder: (ctx, i) {
                        final c = filtered[i];
                        return ListTile(
                          title: Text(c['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: Text(c['symbol']!, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CompanyDetailScreen(symbol: c['symbol']!, name: c['name']!, currentTheme: widget.currentTheme),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyDetailScreen extends StatefulWidget {
  final String symbol;
  final String name;
  final String currentTheme;
  const CompanyDetailScreen({super.key, required this.symbol, required this.name, required this.currentTheme});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  List<FlSpot> _spots = [];
  bool _loading = true;
  String? _error;
  String _range = '1M';
  double? _latestClose;
  double? _prevClose;
  DateTime? _latestDate;
  double? _latestVolume;
  Map<String, String> _quote = {};

  String _formatNum(num? value, {int decimals = 2}) => value == null ? '-' : value.toStringAsFixed(decimals);
  Future<String> _loadFinnhubKey() async {
    // Use the provided Finnhub API key (per user request).
    const key = 'd4tq9nhr01qnn6lmfqtgd4tq9nhr01qnn6lmfqu0';
    debugPrint('[Finnhub] Using provided token (hardcoded)');
    return key;
  }

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env');
        debugPrint('[Finnhub] dotenv loaded inside detail screen');
      } catch (e) {
        debugPrint('[Finnhub] dotenv load failed in detail screen: $e');
      }
    }
    await _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _fetchTimeSeries(),
      _fetchQuote(),
    ]);
  }

  Future<void> _fetchTimeSeries() async {
    try {
      final apiKey = await _loadFinnhubKey();
      if (apiKey.isEmpty) {
        setState(() {
          _error = 'Missing Finnhub API key.';
          _loading = false;
        });
        return;
      }

      final now = DateTime.now().toUtc();
      String resolution;
      Duration window;
      switch (_range) {
        case '1D':
          resolution = '5';
          window = const Duration(days: 1);
          break;
        case '1W':
          resolution = '30';
          window = const Duration(days: 7);
          break;
        case '3M':
          resolution = 'D';
          window = const Duration(days: 90);
          break;
        default:
          resolution = 'D';
          window = const Duration(days: 30);
      }

      final to = now.millisecondsSinceEpoch ~/ 1000;
      final from = now.subtract(window).millisecondsSinceEpoch ~/ 1000;

      final uri = Uri.parse('https://finnhub.io/api/v1/stock/candle?symbol=${widget.symbol}&resolution=$resolution&from=$from&to=$to&token=$apiKey');
      var res = await http.get(uri);
      if (res.statusCode != 200) {
        debugPrint('[Finnhub] candle ${res.statusCode} body: ${res.body}');
        setState(() {
          _error = res.statusCode == 403
              ? 'Finnhub denied request (403). Check token/plan or try again later.'
              : 'Network error: ${res.statusCode}';
          _loading = false;
        });
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['s'] != 'ok') {
        setState(() {
          _error = 'No data available for ${widget.symbol} ($_range).';
          _loading = false;
        });
        return;
      }

      final closes = (data['c'] as List<dynamic>?)?.cast<num>();
      final times = (data['t'] as List<dynamic>?)?.cast<num>();
      final volumes = (data['v'] as List<dynamic>?)?.cast<num>();
      if (closes == null || times == null || closes.isEmpty) {
        setState(() {
          _error = 'No candle data returned for ${widget.symbol} ($_range).';
          _loading = false;
        });
        return;
      }

      final len = closes.length;
      final spots = <FlSpot>[];
      for (var i = 0; i < len; i++) {
        spots.add(FlSpot(i.toDouble(), closes[i].toDouble()));
      }

      final latestClose = closes.isNotEmpty ? closes.last.toDouble() : null;
      final prevClose = closes.length >= 2 ? closes[len - 2].toDouble() : null;
      final latestDate = times.isNotEmpty ? DateTime.fromMillisecondsSinceEpoch((times.last * 1000).toInt(), isUtc: true) : null;
      final lastVolume = volumes != null && volumes.isNotEmpty ? volumes.last.toDouble() : null;

      setState(() {
        _spots = spots;
        _latestClose = latestClose;
        _prevClose = prevClose;
        _latestDate = latestDate;
        _latestVolume = lastVolume;
        if (lastVolume != null) {
          _quote = {..._quote, 'volume': lastVolume.toStringAsFixed(0)};
        }
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchQuote() async {
    try {
      final apiKey = await _loadFinnhubKey();
      if (apiKey.isEmpty) return;

      final quoteUri = Uri.parse('https://finnhub.io/api/v1/quote?symbol=${widget.symbol}&token=$apiKey');
      final metricUri = Uri.parse('https://finnhub.io/api/v1/stock/metric?symbol=${widget.symbol}&metric=price&token=$apiKey');

      var quoteRes = await http.get(quoteUri);
      var metricRes = await http.get(metricUri);

      if (quoteRes.statusCode != 200) {
        debugPrint('[Finnhub] quote ${quoteRes.statusCode} body: ${quoteRes.body}');
      }
      if (metricRes.statusCode != 200) {
        debugPrint('[Finnhub] metric ${metricRes.statusCode} body: ${metricRes.body}');
      }

      final q = jsonDecode(quoteRes.body) as Map<String, dynamic>;
      final metricData = jsonDecode(metricRes.body) as Map<String, dynamic>;
      final metrics = metricData['metric'] as Map<String, dynamic>?;

      setState(() {
        _quote = {
          'price': _formatNum(q['c'] as num?),
          'change': _formatNum(q['d'] as num?),
          'changePct': q['dp'] == null ? '-' : '${_formatNum(q['dp'] as num?)}%',
          'volume': _latestVolume != null ? _latestVolume!.toStringAsFixed(0) : (_quote['volume'] ?? '-'),
          'bid': _formatNum(q['o'] as num?), // open as a proxy for bid
          'ask': _formatNum(q['pc'] as num?), // prev close as a proxy for ask
          'dayHigh': _formatNum(q['h'] as num?),
          'dayLow': _formatNum(q['l'] as num?),
          '52High': _formatNum(metrics?['52WeekHigh'] as num?),
          '52Low': _formatNum(metrics?['52WeekLow'] as num?),
        };
      });
    } catch (e) {
      // keep silent; chart already loads, and quote fields stay empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.name} (${widget.symbol})'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.45))),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        Row(
                          children: [
                            for (final r in ['1D', '1W', '1M', '3M'])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: SizedBox(
                                    width: 44,
                                    height: 28,
                                    child: Center(
                                      child: Text(
                                        r,
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  shape: const StadiumBorder(),
                                  selected: _range == r,
                                  selectedColor: Colors.amber.shade200,
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: _range == r ? Colors.amber : Colors.black26,
                                    width: 1.5,
                                  ),
                                  onSelected: (sel) {
                                    if (sel) {
                                      setState(() {
                                        _range = r;
                                        _loading = true;
                                      });
                                      _fetchTimeSeries();
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Quote summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Price', style: TextStyle(color: Colors.black54)),
                                      Text(_quote['price'] ?? '-', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Change', style: TextStyle(color: Colors.black54)),
                                      Text(_quote['change'] ?? '-', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                      Text(_quote['changePct'] ?? '-', style: const TextStyle(color: Colors.black87)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _quoteItem('Volume', _quote['volume']),
                                  _quoteItem('Bid', _quote['bid']),
                                  _quoteItem('Ask', _quote['ask']),
                                  _quoteItem('Day High', _quote['dayHigh']),
                                  _quoteItem('Day Low', _quote['dayLow']),
                                  _quoteItem('52W High', _quote['52High']),
                                  _quoteItem('52W Low', _quote['52Low']),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                          child: Text(_range == '1D' ? 'Intraday (5 min) close' : 'Daily close prices', style: const TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white12, strokeWidth: 1)),
                              borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Colors.white24), left: BorderSide(color: Colors.white24))),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54)))),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _spots,
                                  isCurved: true,
                                  color: Colors.amber,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: const LineTouchTooltipData(
                                  // fl_chart 0.69.x does not support tooltipBgColor parameter
                                  // Styling is handled internally; we only provide items
                                ),
                                getTouchedSpotIndicator:
                                    (barData, spots) => spots.map((s) => TouchedSpotIndicatorData(
                                          FlLine(color: Colors.white24, strokeWidth: 1),
                                          FlDotData(show: true),
                                        )).toList(),
                                touchCallback: (event, response) {
                                  // No-op; default tooltip rendering
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white, // switch to light surface for black text
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Latest Close', style: TextStyle(color: Colors.black54)),
                                  Text(_latestClose != null ? _latestClose!.toStringAsFixed(2) : '-', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Change', style: TextStyle(color: Colors.black54)),
                                  Builder(builder: (context) {
                                    double? chg;
                                    double? pct;
                                    if (_latestClose != null && _prevClose != null && _prevClose! != 0) {
                                      chg = _latestClose! - _prevClose!;
                                      pct = (chg / _prevClose!) * 100;
                                    }
                                    final color = Colors.black; // numbers in black per request
                                    final text = (chg == null || pct == null) ? '-' : '${chg >= 0 ? '+' : ''}${chg.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)';
                                    return Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600));
                                  }),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('As of', style: TextStyle(color: Colors.black54)),
                                  Text(_latestDate != null ? _latestDate!.toLocal().toString().split(' ').first : '-', style: const TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        ],
      ),
    );
  }
}

Widget _quoteItem(String label, String? value) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      const SizedBox(height: 2),
      Text(value ?? '-', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
    ],
  );
}
