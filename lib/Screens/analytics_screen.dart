import 'package:flutter/material.dart';
import '../Widgets/shimmer.dart';
import '../Services/api_service.dart';
import '../Models/goat_model.dart';
import '../Models/expense_model.dart';
import '../Models/health_model.dart';
import '../theme_helper.dart';
import '../Widgets/hover_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String? _error;

  List<GoatModel> _goats = [];
  List<Expense> _expenses = [];
  List<SalesModel> _sales = [];
  List<HealthRecord> _healthRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // Fetch sequentially to avoid Future.wait generic type issues on web
      final goats       = await ApiService.fetchGoats();
      final expenses    = await ApiService.fetchExpenses();
      final sales       = await ApiService.fetchSales();
      final healthRecs  = await ApiService.fetchHealthRecords();

      if (mounted) {
        setState(() {
          _goats        = goats;
          _expenses     = expenses;
          _sales        = sales;
          _healthRecords = healthRecs;
          _isLoading    = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // ── Computed stats ──────────────────────────────────────────────
  int get _totalGoats => _goats.length;
  int get _pregnantCount => _goats.where((g) => g.isPregnant).length;
  int get _healthyCount =>
      _goats.where((g) => g.healthStatus.toLowerCase() == 'healthy').length;
  int get _sickCount => _goats
      .where((g) => ['sick', 'under treatment'].contains(g.healthStatus.toLowerCase()))
      .length;

  double get _totalExpenses => _expenses.fold(0, (s, e) => s + e.amount);
  double get _totalRevenue  => _sales.fold(0, (s, e) => s + e.amountReceived);
  double get _netProfit     => _totalRevenue - _totalExpenses;

  Map<String, int> get _breedBreakdown {
    final map = <String, int>{};
    for (final g in _goats) map[g.breed] = (map[g.breed] ?? 0) + 1;
    return map;
  }

  Map<String, double> get _expenseByCategory {
    final map = <String, double>{};
    for (final e in _expenses) map[e.category] = (map[e.category] ?? 0) + e.amount;
    return map;
  }

  Color _breedColor(String b) {
    switch (b.toLowerCase()) {
      case 'boer':     return const Color(0xFF3B82F6);
      case 'kalahari': return const Color(0xFF8B5CF6);
      case 'savanna':  return const Color(0xFF0D9488);
      default:         return const Color(0xFFF97316);
    }
  }

  Color _catColor(String c) {
    switch (c.toUpperCase()) {
      case 'FEED':      return const Color(0xFFF97316);
      case 'VET':       return const Color(0xFF8B5CF6);
      case 'UPKEEP':    return const Color(0xFF3B82F6);
      case 'UTILITIES': return const Color(0xFF06B6D4);
      default:          return const Color(0xFF94A3B8);
    }
  }

  String _catLabel(String c) {
    switch (c.toUpperCase()) {
      case 'FEED':      return 'Feed & Nutrition';
      case 'VET':       return 'Medical & Vet';
      case 'UPKEEP':    return 'Infrastructure';
      case 'UTILITIES': return 'Water & Utilities';
      default:          return c;
    }
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final Color green = Colors.green.shade700;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppTheme.card(context),
        foregroundColor: AppTheme.textDark(context),
        title: const Text('Farm Analytics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh_rounded, color: AppTheme.textMid(context)),
              onPressed: _fetchAll),
        ],
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Shimmer(height: 90, borderRadius: BorderRadius.circular(16)),
                  const SizedBox(height: 16),
                  ShimmerList(count: 4, itemHeight: 100),
                ],
              ),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  color: green,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _headerBanner(green),
                        const SizedBox(height: 20),
                        _kpiRow(),
                        const SizedBox(height: 24),
                        _secLabel('BREED DISTRIBUTION'),
                        const SizedBox(height: 10),
                        _breedCard(),
                        const SizedBox(height: 24),
                        _secLabel('HERD HEALTH STATUS'),
                        const SizedBox(height: 10),
                        _healthCard(green),
                        const SizedBox(height: 24),
                        _secLabel('FINANCIAL OVERVIEW'),
                        const SizedBox(height: 10),
                        _financialCard(),
                        const SizedBox(height: 24),
                        _secLabel('EXPENSE BREAKDOWN'),
                        const SizedBox(height: 10),
                        _expenseCard(),
                        if (_pregnantCount > 0) ...[
                          const SizedBox(height: 24),
                          _secLabel('ACTIVE PREGNANCIES'),
                          const SizedBox(height: 10),
                          _pregnancyCard(),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load analytics:\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              onPressed: _fetchAll,
            ),
          ]),
        ),
      );

  Widget _headerBanner(Color green) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [green, Colors.green.shade900]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.analytics_outlined, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Performance Matrix',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Live: $_totalGoats goats · ${_sales.length} sales · ${_expenses.length} expenses',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ]),
          ),
        ]),
      );

  Widget _kpiRow() => Row(children: [
        _kpi('$_totalGoats', 'Total Goats', Icons.pets_rounded, const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        _kpi('$_pregnantCount', 'Pregnant', Icons.pregnant_woman_rounded, const Color(0xFFF57C00)),
        const SizedBox(width: 12),
        _kpi('$_sickCount', 'Sick/Tx', Icons.local_hospital_rounded, const Color(0xFFDC2626)),
      ]);

  Widget _kpi(String val, String lbl, IconData icon, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(val,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            Text(lbl,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                textAlign: TextAlign.center),
          ]),
        ),
      );

  Widget _breedCard() {
    final breakdown = _breedBreakdown;
    if (breakdown.isEmpty) return _emptyCard('No goats registered yet.');
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _whiteCard(Column(
      children: sorted.map((e) {
        final frac = _totalGoats > 0 ? e.value / _totalGoats : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _BarRow(
              label: e.key,
              count: '${e.value} goats',
              fraction: frac,
              color: _breedColor(e.key)),
        );
      }).toList(),
    ));
  }

  Widget _healthCard(Color green) {
    final healthy = _healthyCount;
    final sick    = _sickCount;
    final rate    = _totalGoats > 0
        ? (_healthyCount / _totalGoats * 100).toStringAsFixed(1)
        : '0';
    return _whiteCard(Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
        child: Icon(Icons.gpp_good_outlined, color: green),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$rate% Health Rate',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: [
            _hPill('$healthy Healthy', Colors.green),
            _hPill('$sick Sick/Tx', Colors.red),
            if (_totalGoats - healthy - sick > 0)
              _hPill('${_totalGoats - healthy - sick} Stable', Colors.orange),
          ]),
        ]),
      ),
    ]));
  }

  Widget _hPill(String lbl, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(lbl,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
      );

  Widget _financialCard() => _whiteCard(Column(children: [
        _finRow('Total Revenue', _totalRevenue, Colors.green.shade700,
            '${_sales.length} sales'),
        const Divider(height: 20, color: Color(0xFFF1F5F9)),
        _finRow('Total Expenses', _totalExpenses, Colors.red.shade600,
            '${_expenses.length} records'),
        const Divider(height: 20, color: Color(0xFFF1F5F9)),
        _finRow(
          'Net Profit', _netProfit,
          _netProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
          _netProfit >= 0 ? '▲ Positive margin' : '▼ Operating at loss',
          large: true,
        ),
      ]));

  Widget _finRow(String lbl, double amt, Color c, String sub, {bool large = false}) =>
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lbl,
                style: TextStyle(
                    fontSize: large ? 14 : 13,
                    fontWeight: large ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF0F172A))),
            Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ]),
        ),
        Text('UGX ${_fmt(amt)}',
            style: TextStyle(
                fontSize: large ? 16 : 14, fontWeight: FontWeight.w800, color: c)),
      ]);

  Widget _expenseCard() {
    final cats = _expenseByCategory;
    if (cats.isEmpty) return _emptyCard('No expenses recorded yet.');
    final total = _totalExpenses > 0 ? _totalExpenses : 1;
    return _whiteCard(Column(
      children: cats.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _BarRow(
            label: _catLabel(e.key),
            count: 'UGX ${_fmt(e.value)}',
            fraction: e.value / total,
            color: _catColor(e.key)),
      )).toList(),
    ));
  }

  Widget _pregnancyCard() {
    final pregnant = _goats.where((g) => g.isPregnant).toList();
    return _whiteCard(Column(
      children: pregnant.map((g) {
        final days     = g.gestationDaysRemaining ?? 75;
        final progress = ((150 - days) / 150).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(g.name.isNotEmpty ? g.name : g.tagNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              Text('$days days left',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700)),
            ]),
            const SizedBox(height: 4),
            Text('${g.breed} · ${g.tagNumber}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation(Colors.orange.shade600),
              ),
            ),
          ]),
        );
      }).toList(),
    ));
  }

  Widget _whiteCard(Widget child) => HoverCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0))),
          child: child,
        ),
      );

  Widget _emptyCard(String msg) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Center(
            child: Text(msg,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
      );

  Widget _secLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold,
          color: Color(0xFF64748B), letterSpacing: 0.5));
}

class _BarRow extends StatelessWidget {
  final String label, count;
  final double fraction;
  final Color color;
  const _BarRow(
      {required this.label, required this.count, required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            Text(count,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B))),
          ]),
          const SizedBox(height: 6),
          Stack(children: [
            Container(
                height: 8,
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ]),
        ],
      );
}
