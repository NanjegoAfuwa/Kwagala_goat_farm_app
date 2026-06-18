import 'package:flutter/material.dart';
import '../Widgets/shimmer.dart';
import '../Services/api_service.dart';
import '../Models/health_model.dart';
import '../theme_helper.dart';
import '../Widgets/hover_card.dart';

class HealthVaccinationScreen extends StatefulWidget {
  const HealthVaccinationScreen({Key? key}) : super(key: key);
  @override
  State<HealthVaccinationScreen> createState() => _HealthVaccinationScreenState();
}

class _HealthVaccinationScreenState extends State<HealthVaccinationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<HealthRecord> _records = [];
  bool _loading = true;
  String? _error;

  static const Color _green  = Color(0xFF2E7D32);
  static const Color _purple = Color(0xFF2E7D32);

  // Vaccination schedule template
  final List<Map<String, dynamic>> _vaccineSchedule = [
    {'name': 'PPR Vaccine', 'frequency': 'Every 3 years', 'due': '2026-08-15',
     'status': 'due_soon', 'description': 'Peste des Petits Ruminants', 'goats': 'All goats'},
    {'name': 'Foot & Mouth (FMD)', 'frequency': 'Every 6 months', 'due': '2026-06-20',
     'status': 'overdue', 'description': 'FMD vaccination', 'goats': 'Boer group'},
    {'name': 'Brucellosis Vaccine', 'frequency': 'Annual', 'due': '2026-09-01',
     'status': 'upcoming', 'description': 'Female goats above 4 months', 'goats': 'All females'},
    {'name': 'Clostridial (8-in-1)', 'frequency': 'Annual', 'due': '2026-07-10',
     'status': 'due_soon', 'description': 'Clostridial disease protection', 'goats': 'All goats'},
    {'name': 'Anthrax Vaccine', 'frequency': 'Annual', 'due': '2026-10-05',
     'status': 'upcoming', 'description': 'Annual anthrax prevention', 'goats': 'All goats'},
    {'name': 'Deworming (Valbazen)', 'frequency': 'Every 3 months', 'due': '2026-06-30',
     'status': 'due_soon', 'description': 'Broad-spectrum anthelmintic', 'goats': 'All goats'},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _fetchRecords();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _fetchRecords() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiService.fetchHealthRecords();
      if (mounted) setState(() { _records = r; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _showAddRecordDialog() {
    final treatCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final goatCtrl = TextEditingController();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Health Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _field('Goat ID / Tag', goatCtrl, 'e.g. KF-2024-007'),
            const SizedBox(height: 12),
            _field('Treatment / Procedure', treatCtrl,
                'e.g. Dewormer (Valbazen 10ml)'),
            const SizedBox(height: 12),
            _field('Notes', notesCtrl, 'e.g. Post-treatment observation notes'),
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
                  if (treatCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  final goatId = int.tryParse(goatCtrl.text) ?? 0;
                  final ok = await ApiService.addHealthRecord(
                    goatId: goatId,
                    treatment: treatCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                  );
                  if (ok) _fetchRecords();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? '✅ Health record saved!' : '❌ Failed to save'),
                      backgroundColor: ok ? _green : Colors.red,
                    ));
                  }
                },
                child: const Text('Save Record',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text('Health & Vaccinations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFFF57C00),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [Tab(text: 'Health Records'), Tab(text: 'Vaccine Schedule')],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchRecords),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        onPressed: _showAddRecordDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Treatment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_healthTab(), _scheduleTab()],
      ),
    );
  }

  Widget _healthTab() {
    if (_loading) return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SizedBox(height: 8),
        ShimmerList(count: 4, itemHeight: 78),
      ]),
    );
    if (_error != null) return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
      const SizedBox(height: 12),
      Text('Could not load records', style: TextStyle(color: Colors.grey.shade500)),
      TextButton(onPressed: _fetchRecords, child: const Text('Retry')),
    ]));

    return RefreshIndicator(
      onRefresh: _fetchRecords,
      color: _green,
      child: _records.isEmpty
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.health_and_safety_outlined, size: 64,
                  color: AppTheme.textMid(context)),
              const SizedBox(height: 16),
              Text('No health records yet.\nTap + to log a treatment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMid(context))),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              itemCount: _records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = _records[i];
                return HoverCard(
                  child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border(context))),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: AppTheme.accentTint(context),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.medical_services_rounded,
                          color: Color(0xFF2E7D32), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.treatment,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 14, color: AppTheme.textDark(context))),
                      const SizedBox(height: 2),
                      Text('Goat ID: ${r.goatId}',
                          style: TextStyle(fontSize: 11,
                              color: AppTheme.textMid(context))),
                      if (r.notes.isNotEmpty)
                        Text(r.notes, style: TextStyle(fontSize: 11,
                            color: AppTheme.textLight(context))),
                    ])),
                    Text(
                      '${r.date.day}/${r.date.month}/${r.date.year}',
                      style: TextStyle(fontSize: 11,
                          color: AppTheme.textLight(context)),
                    ),
                  ]),
                  ),  // inner Container
                );   // HoverCard
              },
            ),
    );
  }

  Widget _scheduleTab() => ListView(
    padding: const EdgeInsets.all(16),
    physics: const BouncingScrollPhysics(),
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppTheme.accentTint(context), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentTint(context).withOpacity(0.9))),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded, color: Color(0xFF2E7D32), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Upcoming vaccination and deworming schedule for your herd.',
            style: TextStyle(fontSize: 12, color: AppTheme.textDark(context),
                fontWeight: FontWeight.w500),
          )),
        ]),
      ),
      const SizedBox(height: 16),
      ..._vaccineSchedule.map((v) {
        final status = v['status'] as String;
        Color statusBg, statusFg;
        String statusLabel;
        if (status == 'overdue') {
          statusBg = const Color(0xFFFEF2F2); statusFg = const Color(0xFFDC2626);
          statusLabel = '⚠ Overdue';
        } else if (status == 'due_soon') {
          statusBg = const Color(0xFFFFF7ED); statusFg = const Color(0xFFF57C00);
          statusLabel = '⏰ Due Soon';
        } else {
          statusBg = const Color(0xFFF0FDF4); statusFg = const Color(0xFF15803D);
          statusLabel = '✓ Upcoming';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: status == 'overdue'
                      ? const Color(0xFFFECACA)
                      : AppTheme.border(context))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.vaccines_rounded, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(v['name'],
                  style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 14, color: AppTheme.textDark(context)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBg,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(statusLabel,
                    style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.bold, color: statusFg)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(v['description'],
                style: TextStyle(fontSize: 12, color: AppTheme.textMid(context))),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textLight(context)),
              const SizedBox(width: 4),
              Text('Due: ${v['due']}',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMid(context))),
              const SizedBox(width: 12),
              Icon(Icons.pets_rounded, size: 12, color: AppTheme.textLight(context)),
              const SizedBox(width: 4),
              Text(v['goats'],
                  style: TextStyle(fontSize: 11, color: AppTheme.textMid(context))),
              const SizedBox(width: 12),
              Icon(Icons.repeat_rounded, size: 12, color: AppTheme.textLight(context)),
              const SizedBox(width: 4),
              Text(v['frequency'],
                  style: TextStyle(fontSize: 11, color: AppTheme.textMid(context))),
            ]),
          ]),
        );
      }),
      const SizedBox(height: 80),
    ],
  );

  Widget _field(String label, TextEditingController ctrl, String hint) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: AppTheme.textMid(context))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: TextStyle(color: AppTheme.textDark(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textLight(context), fontSize: 13),
            filled: true, fillColor: AppTheme.inputFill(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.inputBorder(context))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.inputBorder(context))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
          ),
        ),
      ]);
}
