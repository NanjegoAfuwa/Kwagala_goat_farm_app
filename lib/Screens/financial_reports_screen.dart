import 'package:flutter/material.dart';
import '../Widgets/shimmer.dart';
import '../Services/api_service.dart';
import '../Models/expense_model.dart';
import '../theme_helper.dart';
import '../Widgets/hover_card.dart';
// Note: Added explicit import to ensure SalesModel resolves properly
// import '../Models/sales_model.dart'; 

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({Key? key}) : super(key: key);
  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  List<Expense> _expenses = [];
  List<SalesModel> _sales = [];
  bool _loading = true;
  String? _error;

  static const Color _green = Color(0xFF2E7D32);
  static const Color _red   = Color(0xFFDC2626);
  static const Color _blue  = Color(0xFF1D4ED8); // Fixed: Pointed to clear blue instead of duplicating green

  @override
  void initState() { super.initState(); _fetchAll(); }

  Future<void> _fetchAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      final expenses = await ApiService.fetchExpenses();
      final sales    = await ApiService.fetchSales();
      if (mounted) setState(() { _expenses = expenses; _sales = sales; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  double get _totalRevenue  => _sales.fold(0.0, (s, e) => s + e.amountReceived);
  double get _totalExpenses => _expenses.fold(0.0, (s, e) => s + e.amount);
  double get _netProfit     => _totalRevenue - _totalExpenses;

  Map<String, double> get _byCategory {
    final m = <String, double>{};
    for (final e in _expenses) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }

  Map<String, double> get _byPayment {
    final m = <String, double>{};
    for (final s in _sales) {
      m[s.paymentMethod] = (m[s.paymentMethod] ?? 0) + s.amountReceived;
    }
    return m;
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

  Color _catColor(String c) {
    switch (c.toUpperCase()) {
      case 'FEED':      return const Color(0xFFF97316);
      case 'VET':       return const Color(0xFF8B5CF6);
      case 'UPKEEP':    return const Color(0xFF3B82F6);
      case 'UTILITIES': return const Color(0xFF06B6D4);
      default:          return const Color(0xFF94A3B8);
    }
  }

  void _showAddExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amtCtrl   = TextEditingController();
    String category = 'FEED';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(builder: (ctx, setM) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Record Expense',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _fld('Title', titleCtrl, 'e.g. Monthly feed supplies'),
            const SizedBox(height: 12),
            _fld('Amount (UGX)', amtCtrl, 'e.g. 450000',
                type: TextInputType.number),
            const SizedBox(height: 12),
            const Text('Category', style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: category,
              decoration: _dropDeco(),
              items: const [
                DropdownMenuItem(value: 'FEED',      child: Text('🌾 Feed & Nutrition')),
                DropdownMenuItem(value: 'VET',       child: Text('💊 Medical & Vet')),
                DropdownMenuItem(value: 'UPKEEP',    child: Text('🔧 Infrastructure')),
                DropdownMenuItem(value: 'UTILITIES', child: Text('💧 Water & Utilities')),
              ],
              onChanged: (v) => setM(() => category = v!),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (titleCtrl.text.isEmpty || amtCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await ApiService.addExpense(
                    title: titleCtrl.text.trim(),
                    amount: double.tryParse(amtCtrl.text) ?? 0,
                    category: category,
                  );
                  if (ok) _fetchAll();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? '✅ Expense recorded!' : '❌ Failed to save'),
                      backgroundColor: ok ? _green : Colors.red,
                    ));
                  }
                },
                child: const Text('Record Expense',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text('Financial Reports',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchAll),
        ], // Fixed: Removed the floating stray comma right below this marker
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            color: _green,
            height: 3,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _red,
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white),
        label: const Text('Add Expense',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Shimmer(height: 110, borderRadius: BorderRadius.circular(16)),
                  const SizedBox(height: 16),
                  ShimmerList(count: 3, itemHeight: 90),
                ],
              ),
            )
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  TextButton(onPressed: _fetchAll, child: const Text('Retry')),
                ]))
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  color: _green,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    children: [
                      HoverCard(child: _plCard()),
                      const SizedBox(height: 16),
                      HoverCard(child: _revenueCard()),
                      const SizedBox(height: 16),
                      HoverCard(child: _expenseCard()),
                      const SizedBox(height: 16),
                      HoverCard(child: _expenseListCard()),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
    );
  }

  Widget _plCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [_green, const Color(0xFF86EFAC)]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.15),
          blurRadius: 16, offset: const Offset(0, 6))],
    ),
    child: Column(children: [
      const Row(children: [
        Icon(Icons.account_balance_wallet_rounded,
            color: Colors.white70, size: 18),
        SizedBox(width: 8),
        Text('Profit & Loss Summary',
            style: TextStyle(color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        _plTile('Revenue',  _totalRevenue,  const Color(0xFF86EFAC)),
        Container(width: 1, height: 50, color: Colors.white24),
        _plTile('Expenses', _totalExpenses, const Color(0xFFFCA5A5)),
        Container(width: 1, height: 50, color: Colors.white24),
        _plTile('Net Profit', _netProfit,
            _netProfit >= 0 ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
      ]),
    ]),
  );

  Widget _plTile(String label, double val, Color color) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(color: Colors.white60,
          fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Text('UGX ${_fmt(val.abs())}',
          style: TextStyle(color: color, fontSize: 13,
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.center),
    ]),
  );

  Widget _revenueCard() {
    final byPay = _byPayment;
    final widgets = <Widget>[];
    if (byPay.isEmpty) {
      widgets.add(const Padding(padding: EdgeInsets.all(16),
          child: Text('No sales yet.', style: TextStyle(color: Colors.grey))));
    } else {
      for (final entry in byPay.entries) {
        String label;
        Color color;
        if (entry.key == 'MOBILE_MONEY') {
          label = '📱 Mobile Money'; color = const Color(0xFFF57C00);
        } else if (entry.key == 'BANK_TRANSFER') {
          label = '🏦 Bank Transfer'; color = const Color(0xFF1D4ED8);
        } else {
          label = '💵 Cash'; color = const Color(0xFF15803D);
        }
        final pct = _totalRevenue > 0 ? entry.value / _totalRevenue : 0.0;
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _barRow(label, entry.value, pct, color),
        ));
      }
    }
    return _card('💰 Revenue by Payment Method', Column(children: widgets));
  }

  Widget _expenseCard() {
    final cats = _byCategory;
    final widgets = <Widget>[];
    if (cats.isEmpty) {
      widgets.add(const Padding(padding: EdgeInsets.all(16),
          child: Text('No expenses yet.', style: TextStyle(color: Colors.grey))));
    } else {
      for (final entry in cats.entries) {
        final pct = _totalExpenses > 0 ? entry.value / _totalExpenses : 0.0;
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _barRow(_catLabel(entry.key), entry.value, pct,
              _catColor(entry.key)),
        ));
      }
    }
    return _card('💸 Expenses by Category', Column(children: widgets));
  }

  Widget _expenseListCard() {
    final widgets = <Widget>[];
    if (_expenses.isEmpty) {
      widgets.add(const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No expenses recorded.',
            style: TextStyle(color: Colors.grey)),
      ));
    } else {
      final shown = _expenses.length > 10 ? _expenses.sublist(0, 10) : _expenses;
      for (final e in shown) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: _catColor(e.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.receipt_long_rounded,
                  color: _catColor(e.category), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.title, style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              Text(_catLabel(e.category), style: const TextStyle(
                  fontSize: 11, color: Color(0xFF94A3B8))),
            ])),
            Text('-UGX ${_fmt(e.amount)}',
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
          ]),
        ));
      }
    }
    return _card('📋 Recent Expenses', Column(children: widgets));
  }

  Widget _card(String title, Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      const SizedBox(height: 14),
      child,
    ]),
  );

  Widget _barRow(String label, double val, double pct, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w500, color: Color(0xFF334155))),
          Text('UGX ${_fmt(val)}', style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ]),
        const SizedBox(height: 5),
        Stack(children: [
          Container(height: 7, decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4))),
          FractionallySizedBox(
            widthFactor: pct.clamp(0.0, 1.0),
            child: Container(height: 7, decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
          ),
        ]),
      ]);

  Widget _fld(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true, fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _green, width: 1.5)),
          ),
        ),
      ]);

  InputDecoration _dropDeco() => InputDecoration(
    filled: true, fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _green, width: 1.5)),
  );

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}