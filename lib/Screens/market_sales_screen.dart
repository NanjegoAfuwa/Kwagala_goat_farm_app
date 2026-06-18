import 'package:flutter/material.dart';
import '../Widgets/shimmer.dart';
import '../Services/api_service.dart';
import '../theme_helper.dart';
import '../Widgets/hover_card.dart';

class MarketSalesScreen extends StatefulWidget {
  const MarketSalesScreen({Key? key}) : super(key: key);
  @override
  State<MarketSalesScreen> createState() => _MarketSalesScreenState();
}

class _MarketSalesScreenState extends State<MarketSalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<SalesModel> _sales = [];
  bool _loading = true;
  String? _error;

  static const Color _green = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFF57C00);

  // Market reference prices (UGX — these are local market benchmarks)
  final List<Map<String, dynamic>> _marketPrices = [
    {'breed': 'Boer Goat (Adult)', 'min': 350000, 'max': 600000, 'trend': 'up', 'note': 'High demand — Eid season'},
    {'breed': 'Kalahari Red (Adult)', 'min': 280000, 'max': 480000, 'trend': 'stable', 'note': 'Stable — consistent demand'},
    {'breed': 'Savanna (Adult)', 'min': 250000, 'max': 420000, 'trend': 'up', 'note': 'Rising — quality meat breed'},
    {'breed': 'Local Breed (Adult)', 'min': 120000, 'max': 220000, 'trend': 'down', 'note': 'Slight dip — market saturated'},
    {'breed': 'Kid (Any breed)', 'min': 80000, 'max': 150000, 'trend': 'stable', 'note': 'Steady — restocking demand'},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _fetchSales();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _fetchSales() async {
    setState(() { _loading = true; _error = null; });
    try {
      final s = await ApiService.fetchSales();
      if (mounted) setState(() { _sales = s; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  double get _totalRevenue => _sales.fold(0, (s, e) => s + e.amountReceived);

  void _showAddSaleDialog() {
    final buyerCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String method = 'CASH';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(builder: (ctx, setM) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Record New Sale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _field('Buyer Name', buyerCtrl, 'e.g. Nakibinge Peter'),
            const SizedBox(height: 12),
            _field('Amount (UGX)', amountCtrl, 'e.g. 450000',
                type: TextInputType.number),
            const SizedBox(height: 12),
            const Text('Payment Method',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B))),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: method,
              decoration: _dropDeco(),
              items: const [
                DropdownMenuItem(value: 'CASH', child: Text('💵 Cash')),
                DropdownMenuItem(value: 'MOBILE_MONEY', child: Text('📱 Mobile Money')),
                DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('🏦 Bank Transfer')),
              ],
              onChanged: (v) => setM(() => method = v!),
            ),
            const SizedBox(height: 12),
            _field('Notes (optional)', notesCtrl, 'e.g. Boer male, 45kg'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (buyerCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await ApiService.recordSale(SalesModel(
                    id: 0,
                    buyerName: buyerCtrl.text.trim(),
                    amountReceived: double.tryParse(amountCtrl.text) ?? 0,
                    paymentMethod: method,
                    dateSold: DateTime.now().toIso8601String().split('T').first,
                    notes: notesCtrl.text.trim(),
                  ));
                  if (ok) _fetchSales();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? '✅ Sale recorded!' : '❌ Failed to record sale'),
                      backgroundColor: ok ? _green : Colors.red,
                    ));
                  }
                },
                child: const Text('Record Sale',
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
        title: const Text('Market & Sales',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: _orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [Tab(text: 'Sales Records'), Tab(text: 'Market Prices')],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchSales),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _orange,
        onPressed: _showAddSaleDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Record Sale',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_salesTab(), _marketTab()],
      ),
    );
  }

  Widget _salesTab() {
    if (_loading) return Padding(
      padding: const EdgeInsets.all(16),
      child: ShimmerList(count: 5, itemHeight: 80),
    );
    if (_error != null) return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
      const SizedBox(height: 12),
      Text('Could not load sales', style: TextStyle(color: Colors.grey.shade500)),
      TextButton(onPressed: _fetchSales, child: const Text('Retry')),
    ]));

    return RefreshIndicator(
      onRefresh: _fetchSales,
      color: _green,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Revenue summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_green, const Color(0xFF1B5E20)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    const Icon(Icons.trending_up_rounded,
                        color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total Revenue',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('UGX ${_fmt(_totalRevenue)}',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      Text('${_sales.length} transactions recorded',
                          style: const TextStyle(color: Colors.white60,
                              fontSize: 11)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                if (_sales.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Center(
                      child: Column(children: [
                        Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No sales recorded yet.\nTap + to add your first sale.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final s = _sales[i];
                  return HoverCard(child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.shopping_cart_rounded,
                            color: Color(0xFF2E7D32), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.buyerName,
                              style: const TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 14, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(s.dateSold,
                              style: const TextStyle(fontSize: 11,
                                  color: Color(0xFF94A3B8))),
                          if (s.notes.isNotEmpty)
                            Text(s.notes,
                                style: const TextStyle(fontSize: 11,
                                    color: Color(0xFF64748B))),
                        ],
                      )),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('UGX ${_fmt(s.amountReceived)}',
                            style: const TextStyle(fontWeight: FontWeight.w800,
                                fontSize: 15, color: Color(0xFF15803D))),
                        const SizedBox(height: 4),
                        _payBadge(s.paymentMethod),
                      ]),
                    ]),
                  ),);  // HoverCard
                },
                childCount: _sales.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _marketTab() => ListView(
    padding: const EdgeInsets.all(16),
    physics: const BouncingScrollPhysics(),
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100)),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFF57C00), size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(
            'Reference prices for Kampala region markets. Actual prices may vary.',
            style: TextStyle(fontSize: 12, color: Color(0xFFF57C00),
                fontWeight: FontWeight.w500),
          )),
        ]),
      ),
      const SizedBox(height: 16),
      ..._marketPrices.map((m) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🐐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text(m['breed'],
                style: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 14, color: Color(0xFF0F172A)))),
            _trendBadge(m['trend']),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text('UGX ${_fmtI(m['min'])} – ${_fmtI(m['max'])}',
                style: const TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 15, color: Color(0xFF15803D))),
          ]),
          const SizedBox(height: 4),
          Text(m['note'],
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ]),
      )),
      const SizedBox(height: 80),
    ],
  );

  Widget _trendBadge(String trend) {
    if (trend == 'up') return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(6)),
      child: const Text('↑ Rising', style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D))));
    if (trend == 'down') return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(6)),
      child: const Text('↓ Falling', style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(6)),
      child: const Text('→ Stable', style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF57C00))));
  }

  Widget _payBadge(String method) {
    String label;
    Color bg, fg;
    if (method == 'MOBILE_MONEY') { label = '📱 Mobile'; bg = const Color(0xFFFFF7ED); fg = const Color(0xFFF57C00); }
    else if (method == 'BANK_TRANSFER') { label = '🏦 Bank'; bg = const Color(0xFFEFF6FF); fg = const Color(0xFF1D4ED8); }
    else { label = '💵 Cash'; bg = const Color(0xFFDCFCE7); fg = const Color(0xFF15803D); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
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
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
  );

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  String _fmtI(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toString();
  }
}
