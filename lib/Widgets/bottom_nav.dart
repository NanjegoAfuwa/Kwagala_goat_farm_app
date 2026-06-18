import 'package:flutter/material.dart';
import '../Screens/home_screen.dart';
import '../Screens/goat_records.dart';
import '../Screens/farm_chat_screen.dart';
import '../Screens/settings_screen.dart';
import '../Screens/weather_screen.dart';
import '../Screens/market_sales_screen.dart';
import '../Screens/health_vaccination_screen.dart';
import '../Screens/financial_reports_screen.dart';
import '../theme_helper.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _idx = 0;
  static const Color _green = Color(0xFF2E7D32);

  final List<Widget> _pages = const [
    HomeScreen(),
    GoatsScreen(),
    FarmChatScreen(),
    SettingsScreen(),
    _MoreHub(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, -3))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _idx,
          selectedItemColor: _green,
          unselectedItemColor: AppTheme.textMid(context),
          selectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          backgroundColor: AppTheme.card(context),
          elevation: 0,
          onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.home_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.home_rounded)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.pets_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.pets_rounded)),
              label: 'My Goats',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.forum_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.forum_rounded)),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.settings_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.settings_rounded)),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.apps_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.apps_rounded)),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MORE HUB  —  clean, no duplication
// ─────────────────────────────────────────────────────────────────────────────
class _MoreHub extends StatelessWidget {
  const _MoreHub();

  static const Color _green  = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFF57C00);
  static const Color _purple = Color(0xFF7C3AED);

  void _go(BuildContext ctx, Widget screen) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(children: [

          // ── Green app bar ──────────────────────────────────────────
          Container(
            color: _green,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Image.asset('Assets/farm.png', height: 50, width: 50,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.apps_rounded, color: Colors.white, size: 24)),
                  const SizedBox(width: 10),
                  const Text('More',
                      style: TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
          ),

          // Thin orange underline
          Container(color: _orange, height: 3),

          // ── Content ───────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              physics: const BouncingScrollPhysics(),
              children: [

                // ── Section 1: Farm Management ─────────────────────
                _sectionLabel(context, 'FARM MANAGEMENT'),
                const SizedBox(height: 10),

                // 2 wide list tiles — each unique, different sub-text
                _featureTile(
                  context,
                  icon: Icons.cloud_rounded,
                  iconColor: _green,
                  bg: const Color(0xFFDCFCE7),
                  title: 'Weather Forecast',
                  sub: 'Live 7-day Kampala conditions\n'
                      'Rain, wind & farm activity advisories',
                  badge: null,
                  screen: const WeatherScreen(),
                ),
                const SizedBox(height: 10),
                _featureTile(
                  context,
                  icon: Icons.health_and_safety_rounded,
                  iconColor: _purple,
                  bg: const Color(0xFFF3E8FF),
                  title: 'Health & Vaccination',
                  sub: 'Treatment logs · Vaccine schedule\n'
                      'Overdue & upcoming reminders',
                  badge: 'Records',
                  screen: const HealthVaccinationScreen(),
                ),

                const SizedBox(height: 24),

                // ── Section 2: Finance ─────────────────────────────
                _sectionLabel(context, 'FINANCE'),
                const SizedBox(height: 10),

                _featureTile(
                  context,
                  icon: Icons.storefront_rounded,
                  iconColor: _orange,
                  bg: const Color(0xFFFFF0D6),
                  title: 'Market & Sales',
                  sub: 'Record goat sales · Buyer details\n'
                      'Kampala region market price guide',
                  badge: 'Prices',
                  screen: const MarketSalesScreen(),
                ),
                const SizedBox(height: 10),
                _featureTile(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: _green,
                  bg: const Color(0xFFDCFCE7),
                  title: 'Financial Reports',
                  sub: 'Income vs expenses · P&L summary\n'
                      'Add expenses · Track revenue',
                  badge: 'Reports',
                  screen: const FinancialReportsScreen(),
                ),

                const SizedBox(height: 24),

                // ── Section 3: Info cards (no nav duplication) ─────
                _sectionLabel(context, 'FARM INSIGHTS'),
                const SizedBox(height: 10),

                // Horizontal insight cards — informational, not nav
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(children: [
                    _insightCard(context, '🌿', 'Feed Tip',
                        'Supplement Boer goats with\nmaize bran during dry months\nfor optimal weight gain.',
                        _green),
                    const SizedBox(width: 12),
                    _insightCard(context, '💊', 'Health Tip',
                        'Deworm every 3 months.\nValbazen (Albendazole) works\nbest for mixed infections.',
                        _purple),
                    const SizedBox(width: 12),
                    _insightCard(context, '🐐', 'Breeding Tip',
                        'Introduce the buck 45 days\nbefore your target kidding\ndate for best results.',
                        _orange),
                    const SizedBox(width: 12),
                    _insightCard(context, '💰', 'Market Tip',
                        'Boer prices peak during\nEid and Christmas.\nPlan sales accordingly.',
                        _green),
                  ]),
                ),

              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── Wide feature tile — rich detail, no duplication ──────────────────────
  Widget _featureTile(
    BuildContext ctx, {
    required IconData icon,
    required Color iconColor,
    required Color bg,
    required String title,
    required String sub,
    required String? badge,
    required Widget screen,
  }) =>
      InkWell(
        onTap: () => _go(ctx, screen),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card(ctx),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border(ctx)),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.isDark(ctx)
                      ? Colors.white12
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            // Icon square
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: bg,
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: AppTheme.textDark(ctx))),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(badge, style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold,
                          color: iconColor)),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(sub, style: TextStyle(
                    fontSize: 12, color: AppTheme.textMid(ctx), height: 1.45)),
              ],
            )),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: iconColor, size: 22),
          ]),
        ),
      );

  // ── Insight card — informational only, not a nav tile ────────────────────
  Widget _insightCard(BuildContext context, String emoji, String title, String body, Color color) =>
      Container(
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [BoxShadow(
              color: AppTheme.isDark(context)
                  ? Colors.white12
                  : Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ]),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(
              fontSize: 11, color: AppTheme.textMid(context), height: 1.5)),
        ]),
      );

  Widget _sectionLabel(BuildContext context, String t) => Text(t,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.textMid(context), letterSpacing: 0.9));
}
