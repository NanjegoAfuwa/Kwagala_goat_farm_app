import 'dart:async';
import 'package:flutter/material.dart';
import '../Services/api_service.dart';
import '../Models/goat_model.dart';
import '../Models/dashboard_models.dart';
import '../theme_helper.dart';
import '../Widgets/shimmer.dart';
import 'goat_records.dart';
import 'health_vaccination_screen.dart';
import 'market_sales_screen.dart';
import 'financial_reports_screen.dart';
import 'weather_screen.dart';
import '../Widgets/hover_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _tickerScrollController = ScrollController();
  Timer? _tickerTimer;

  bool _isLoadingDashboard = true;
  String? _networkError;
  bool _isFirstAlertFetch = true;

  List<GoatModel> _allGoats      = [];
  List<GoatModel> _pregnantGoats = [];
  List<Map<String, String>> _tickerAlerts = [];
  List<Map<String, dynamic>> _dailyTasks  = [
    {'id': null, 'task': 'Clean Paddock B water troughs',                 'done': true},
    {'id': null, 'task': 'Administer Dewormer to Boer group',             'done': false},
    {'id': null, 'task': 'Confirm evening feed mix ratios',               'done': false},
    {'id': null, 'task': 'Review flock health optimization variance logs', 'done': false},
  ];

  static const Color _green  = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFF57C00);

  // Notification overlay entry
  OverlayEntry? _notifOverlay;

  late final List<_HubItem> _hubItems;

  @override
  void initState() {
    super.initState();
    _hubItems = [
      _HubItem('My Goats',         _GoatIcon(),                            () => _push(const GoatsScreen())),
      _HubItem('Health & Vaccines', const Icon(Icons.health_and_safety_rounded, size: 72, color: _orange), () => _push(const HealthVaccinationScreen())),
      _HubItem('Breeding Records',  const Icon(Icons.favorite_rounded,          size: 72, color: _green),  () {}),
      _HubItem('Sales & Market',    const Icon(Icons.swap_horiz_rounded,        size: 72, color: _orange), () => _push(const MarketSalesScreen())),
      _HubItem('Financial Reports', const Icon(Icons.bar_chart_rounded,         size: 72, color: _green),  () => _push(const FinancialReportsScreen())),
      _HubItem('Weather',           const Icon(Icons.wb_sunny_rounded,          size: 72, color: _orange), () => _push(const WeatherScreen())),
    ];
    _syncDashboardWithBackend();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTickerAnimation());
  }

  void _push(Widget w) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => w));

  Future<void> _syncDashboardWithBackend() async {
    setState(() { _isLoadingDashboard = true; _networkError = null; });
    try {
      final alerts = await ApiService.fetchLiveAlerts();
      final tasks  = await ApiService.fetchTasks();
      final goats  = await ApiService.fetchGoats();
      final prev   = _tickerAlerts.length;

      setState(() {
        _allGoats      = goats;
        _pregnantGoats = goats.where((g) => g.isPregnant).toList()
          ..sort((a, b) => (a.gestationDaysRemaining ?? 999)
              .compareTo(b.gestationDaysRemaining ?? 999));

        if (alerts.isNotEmpty) {
          final mapped = <Map<String, String>>[];
          for (final a in alerts) {
            final p = a.severity.toLowerCase() == 'critical' ? '⚠️ CRITICAL: '
                    : a.severity.toLowerCase() == 'warning'  ? '🔔 Warning: '
                    : 'ℹ️ ';
            mapped.add({'display': '$p${a.message}', 'task': a.message});
          }
          _tickerAlerts = mapped; _isFirstAlertFetch = false;
        } else if (_isFirstAlertFetch) {
          _tickerAlerts = [
            {'display': '⚠️ Alert: Severe rainfall towards Kampala this evening — secure shelters.', 'task': 'Secure shelters for severe rainfall alert'},
            {'display': '💉 Vet: 4 Kalahari breeders due for booster inoculations tomorrow.', 'task': 'Administer booster inoculations to Kalahari breeders'},
            {'display': '📈 Herd health rating holding steady at 96% variance capacity.', 'task': 'Review flock health optimization variance logs'},
          ];
          _isFirstAlertFetch = false;
        }

        if (tasks.isNotEmpty) {
          final mapped = <Map<String, dynamic>>[];
          for (final t in tasks) mapped.add({'id': t.id, 'task': t.title, 'done': t.isDone});
          _dailyTasks = mapped;
        }
        _isLoadingDashboard = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tickerScrollController.hasClients &&
            _tickerAlerts.length != prev) {
          _tickerTimer?.cancel();
          _tickerScrollController.jumpTo(0);
          _startTickerAnimation();
        }
      });
    } catch (e) {
      setState(() { _networkError = e.toString(); _isLoadingDashboard = false; });
    }
  }

  void _toggleTask(int i, Map<String, dynamic> task) async {
    if (task['id'] == null) {
      setState(() => _dailyTasks[i]['done'] = !task['done']); return;
    }
    final was = task['done'] as bool;
    setState(() => _dailyTasks[i]['done'] = !was);
    final ok = await ApiService.toggleTaskStatus(task['id'] as int, was);
    if (!ok && mounted) {
      setState(() => _dailyTasks[i]['done'] = was);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('❌ Failed to sync task.'), backgroundColor: Colors.red));
    }
  }

  void _startTickerAnimation() {
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (_tickerScrollController.hasClients) {
        final pos = _tickerScrollController.position;
        if (pos.maxScrollExtent <= 0) return;
        final next = pos.pixels + 1.5;
        _tickerScrollController.jumpTo(next >= pos.maxScrollExtent ? 0 : next);
      }
    });
  }

  void _convertAlertToTask(String title, String display) {
    if (_dailyTasks.any((t) => t['task'] == title)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("ℹ️ '$title' already in checklist."),
          backgroundColor: Colors.amber.shade800,
          behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _dailyTasks.add({'id': null, 'task': title, 'done': false}));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.playlist_add_check_rounded, color: Colors.white),
          SizedBox(width: 10),
          Text('Alert converted to task!',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating));
  }

  // ── DROPDOWN NOTIFICATION PANEL (top-right corner, not bottom sheet) ───────
  void _showNotifDropdown(BuildContext context) {
    _dismissNotif(); // close if already open

    final RenderBox button =
        context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    _notifOverlay = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // Tap outside to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismissNotif,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          // The dropdown panel — anchored top-right
          Positioned(
            top: position.top + button.size.height + 4,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                constraints: const BoxConstraints(maxHeight: 340),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: _green,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.notifications_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Live Alerts',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        GestureDetector(
                          onTap: _dismissNotif,
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white70, size: 18),
                        ),
                      ]),
                    ),
                    // Alert list
                    Flexible(
                      child: _tickerAlerts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('No active alerts.',
                                  style: TextStyle(color: AppTheme.textMid(ctx))))
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _tickerAlerts.length,
                              separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: AppTheme.isDark(ctx)
                                      ? Colors.white.withOpacity(0.08)
                                      : const Color(0xFFF1F5F9)),
                              itemBuilder: (_, i) {
                                final a = _tickerAlerts[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(a['display']!,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textDark(ctx),
                                            fontWeight: FontWeight.w500,
                                            height: 1.4)),
                                    const SizedBox(height: 6),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          _dismissNotif();
                                          _convertAlertToTask(
                                              a['task']!, a['display']!);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: _orange.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: _orange
                                                      .withOpacity(0.3))),
                                          child: const Text('⚡ Add to Tasks',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: _orange,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ]),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_notifOverlay!);
  }

  void _dismissNotif() {
    _notifOverlay?.remove();
    _notifOverlay = null;
  }

  @override
  void dispose() {
    _dismissNotif();
    _tickerTimer?.cancel();
    _tickerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),

      // ── APP BAR ─────────────────────────────────────────────────────────
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        titleSpacing: 20,
        title: Row(children: [
          Image.asset('Assets/farm.png', height: 50, width: 50,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.agriculture_rounded,
                      color: Colors.white, size: 24)),
          const SizedBox(width: 10),
          const Text('Kwagala Goat Farm',
              style: TextStyle(color: Colors.white, fontSize: 17,
                  fontWeight: FontWeight.bold)),
        ]),
        // Thin orange underline separator
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: _orange, height: 3),
        ),
        actions: [
          // Orange notification bell — dropdown at corner
          Builder(builder: (btnCtx) => IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_rounded,
                    color: _orange, size: 28),
                if (_tickerAlerts.isNotEmpty)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showNotifDropdown(btnCtx),
          )),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _syncDashboardWithBackend,
          color: _green,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── HERO IMAGE ──────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    width: double.infinity,
                    height: 155,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                      image: const DecorationImage(
                          image: AssetImage('Assets/main1.jpg'),
                          fit: BoxFit.cover),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.80),
                            Colors.black.withOpacity(0.15),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nurturing Healthier Farms, One Animal at a Time',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingDashboard
                                ? 'Loading farm data...'
                                : '${_allGoats.length} goats · '
                                  '${_pregnantGoats.length} pregnant · '
                                  '${_dailyTasks.where((t) => t["done"] == false).length} tasks pending',
                            style: const TextStyle(
                                color: Color(0xFFE2E8F0), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── LIVE TICKER (original style, dark bg) ─────────────
                if (_tickerAlerts.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: _orange,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
                          alignment: Alignment.center,
                          child: const Row(children: [
                            Icon(Icons.sensors, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('LIVE FEED',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5)),
                          ]),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _tickerScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _tickerAlerts.length * 2,
                            itemBuilder: (_, i) {
                              final a = _tickerAlerts[i % _tickerAlerts.length];
                              return InkWell(
                                onTap: () =>
                                    _convertAlertToTask(a['task']!, a['display']!),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, right: 48),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    Text(a['display']!,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade800
                                            .withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.orange.shade600,
                                            width: 0.5),
                                      ),
                                      child: const Text('⚡ Convert to Task',
                                          style: TextStyle(
                                              color: Colors.orangeAccent,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ]),
                                ),
                              );
                            },
                          ),
                        ),
                      ]),
                    ),
                  ),

                // ── GRID CARDS (3 rows × 2 cols like screenshot) ──────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _hubItems.length,
                    itemBuilder: (_, i) => _buildHubCard(_hubItems[i]),
                  ),
                ),

                // ── GESTATION TRACKER ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('ACTIVE GESTATION TRACKING'),
                      const SizedBox(height: 12),
                      if (_isLoadingDashboard)
                        Center(child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Shimmer(width: 220, height: 14, borderRadius: BorderRadius.circular(6))))
                      else if (_pregnantGoats.isNotEmpty)
                        ..._pregnantGoats.take(3).map((g) {
                          final days = g.gestationDaysRemaining ?? 75;
                          final prog =
                              ((150 - days) / 150).clamp(0.0, 1.0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _gestationCard(
                              label: g.name.isNotEmpty
                                  ? '${g.tagNumber} (${g.name})'
                                  : g.tagNumber,
                              breed: g.breed,
                              daysRemaining: days,
                              progress: prog,
                            ),
                          );
                        })
                      else ...[
                        _gestationCard(
                            label: 'GT-042 (Daisy)',
                            breed: 'Pure Boer',
                            daysRemaining: 34,
                            progress: 0.77),
                        const SizedBox(height: 12),
                        _gestationCard(
                            label: 'GT-089 (Flora)',
                            breed: 'Kalahari Red',
                            daysRemaining: 112,
                            progress: 0.25),
                      ],
                    ],
                  ),
                ),

                // ── DAILY CHECKLIST ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('DAILY OPERATIONS CHECKLIST'),
                      const SizedBox(height: 12),
                        _isLoadingDashboard
                          ? Center(child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Shimmer(width: 220, height: 14, borderRadius: BorderRadius.circular(6))))
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                              ),
                              child: _dailyTasks.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Center(
                                          child: Text(
                                              'No tasks. Add from admin panel.',
                                              style: TextStyle(
                                                  color: Color(0xFF94A3B8)))))
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _dailyTasks.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(
                                              height: 1,
                                              color: Color(0xFFE2E8F0)),
                                      itemBuilder: (_, i) {
                                        final task = _dailyTasks[i];
                                        final done =
                                            task['done'] as bool;
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 4),
                                          leading: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: () =>
                                                _toggleTask(i, task),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4),
                                              child: Icon(
                                                done
                                                    ? Icons
                                                        .check_circle_rounded
                                                    : Icons
                                                        .radio_button_unchecked_rounded,
                                                color: done
                                                    ? _green
                                                    : const Color(
                                                        0xFF94A3B8),
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            task['task'] as String,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: done
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF0F172A),
                                              decoration: done
                                                  ? TextDecoration
                                                      .lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),

      // ── SYNC DATA FAB ────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _orange,
        onPressed: _syncDashboardWithBackend,
        icon: const Icon(Icons.sync_rounded, color: Colors.white),
        label: const Text('Sync data',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 3,
      ),
    );
  }

  // ── LARGE HUB CARD ──────────────────────────────────────────────────────────
  Widget _buildHubCard(_HubItem item) {
    return StatefulBuilder(
      builder: (context, setHover) {
        bool _hovered = false;
        return MouseRegion(
          onEnter: (_) => setHover(() => _hovered = true),
          onExit:  (_) => setHover(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..scale(_hovered ? 1.04 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(_hovered ? 0.14 : 0.07),
                    blurRadius: _hovered ? 18 : 10,
                    offset: Offset(0, _hovered ? 6 : 3)),
              ],
            ),
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item.iconWidget,
                  const SizedBox(height: 14),
                  Text(item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
          color: Color(0xFF64748B), letterSpacing: 0.8));

  Widget _gestationCard({
    required String label,
    required String breed,
    required int daysRemaining,
    required double progress,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text('$daysRemaining days left',
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: _orange)),
          ]),
          const SizedBox(height: 4),
          Text('Breed group: $breed',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress, minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(_green),
            ),
          ),
        ]),
      );
}

// ── DATA CLASS FOR HUB ITEMS ─────────────────────────────────────────────────
class _HubItem {
  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;
  const _HubItem(this.label, this.iconWidget, this.onTap);
}

// ── GOAT SILHOUETTE ICON (matches screenshot exactly) ────────────────────────
// Drawn with CustomPainter to match the walking goat silhouette in the screenshot
class _GoatIcon extends StatelessWidget {
  const _GoatIcon();
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(80, 72),
        painter: _GoatPainter(),
      );
}

class _GoatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF57C00)
      ..style = PaintingStyle.fill;

    final s = size.width / 100; // scale factor

    final path = Path();

    // ── Body ─────────────────────────────────────────────────────────────────
    path.moveTo(25 * s, 42 * s);
    path.cubicTo(25 * s, 32 * s, 30 * s, 26 * s, 42 * s, 25 * s);
    path.cubicTo(54 * s, 24 * s, 70 * s, 26 * s, 76 * s, 30 * s);
    path.cubicTo(82 * s, 34 * s, 82 * s, 42 * s, 78 * s, 48 * s);
    path.cubicTo(74 * s, 54 * s, 66 * s, 56 * s, 55 * s, 56 * s);
    path.cubicTo(44 * s, 56 * s, 36 * s, 55 * s, 30 * s, 51 * s);
    path.cubicTo(25 * s, 47 * s, 25 * s, 42 * s, 25 * s, 42 * s);
    path.close();

    // ── Neck + Head ──────────────────────────────────────────────────────────
    final head = Path();
    head.moveTo(42 * s, 25 * s);
    head.cubicTo(40 * s, 18 * s, 38 * s, 14 * s, 36 * s, 11 * s);
    head.cubicTo(34 * s, 8 * s, 32 * s, 6 * s, 30 * s, 6 * s);
    head.cubicTo(24 * s, 6 * s, 19 * s, 10 * s, 18 * s, 16 * s);
    head.cubicTo(17 * s, 22 * s, 20 * s, 27 * s, 26 * s, 28 * s);
    head.cubicTo(32 * s, 29 * s, 38 * s, 27 * s, 42 * s, 25 * s);
    head.close();

    // ── Ear ─────────────────────────────────────────────────────────────────
    final ear = Path();
    ear.moveTo(18 * s, 14 * s);
    ear.cubicTo(14 * s, 10 * s, 10 * s, 11 * s, 9 * s, 15 * s);
    ear.cubicTo(8 * s, 19 * s, 11 * s, 22 * s, 15 * s, 21 * s);
    ear.cubicTo(18 * s, 20 * s, 19 * s, 17 * s, 18 * s, 14 * s);
    ear.close();

    // ── Horn ────────────────────────────────────────────────────────────────
    final horn = Path();
    horn.moveTo(28 * s, 6 * s);
    horn.cubicTo(27 * s, 2 * s, 25 * s, -1 * s, 24 * s, -1 * s);
    horn.cubicTo(23 * s, -1 * s, 22 * s, 1 * s, 22 * s, 4 * s);
    horn.cubicTo(22 * s, 7 * s, 23 * s, 9 * s, 25 * s, 9 * s);
    horn.cubicTo(27 * s, 9 * s, 28 * s, 8 * s, 28 * s, 6 * s);
    horn.close();

    // ── Front legs ──────────────────────────────────────────────────────────
    final fl1 = Path();
    fl1.moveTo(38 * s, 55 * s);
    fl1.lineTo(34 * s, 55 * s);
    fl1.lineTo(33 * s, 75 * s);
    fl1.lineTo(37 * s, 75 * s);
    fl1.close();

    final fl2 = Path();
    fl2.moveTo(46 * s, 56 * s);
    fl2.lineTo(42 * s, 56 * s);
    fl2.lineTo(41 * s, 76 * s);
    fl2.lineTo(45 * s, 76 * s);
    fl2.close();

    // ── Back legs ───────────────────────────────────────────────────────────
    final bl1 = Path();
    bl1.moveTo(62 * s, 55 * s);
    bl1.lineTo(58 * s, 55 * s);
    bl1.lineTo(57 * s, 75 * s);
    bl1.lineTo(61 * s, 75 * s);
    bl1.close();

    final bl2 = Path();
    bl2.moveTo(72 * s, 54 * s);
    bl2.lineTo(68 * s, 54 * s);
    bl2.lineTo(67 * s, 74 * s);
    bl2.lineTo(71 * s, 74 * s);
    bl2.close();

    // ── Tail ─────────────────────────────────────────────────────────────────
    final tail = Path();
    tail.moveTo(78 * s, 30 * s);
    tail.cubicTo(83 * s, 26 * s, 88 * s, 24 * s, 89 * s, 28 * s);
    tail.cubicTo(90 * s, 32 * s, 86 * s, 36 * s, 80 * s, 36 * s);
    tail.close();

    // ── Beard ────────────────────────────────────────────────────────────────
    final beard = Path();
    beard.moveTo(19 * s, 22 * s);
    beard.cubicTo(17 * s, 24 * s, 16 * s, 28 * s, 18 * s, 30 * s);
    beard.cubicTo(20 * s, 32 * s, 23 * s, 30 * s, 22 * s, 26 * s);
    beard.close();

    // Draw all parts
    canvas.save();
    // Clip to avoid horn going out of bounds at top
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path,  paint);
    canvas.drawPath(head,  paint);
    canvas.drawPath(ear,   paint);
    canvas.drawPath(horn,  paint);
    canvas.drawPath(fl1,   paint);
    canvas.drawPath(fl2,   paint);
    canvas.drawPath(bl1,   paint);
    canvas.drawPath(bl2,   paint);
    canvas.drawPath(tail,  paint);
    canvas.drawPath(beard, paint);
    canvas.restore();

    // Eye — small dark circle
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(22 * s, 14 * s), 1.8 * s, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
