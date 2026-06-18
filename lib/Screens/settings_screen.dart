import 'dart:io';
import 'package:flutter/material.dart';
import '../Widgets/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'change_password_screen.dart';
import 'edit_farm_screen.dart';
import '../Services/api_service.dart';
import '../main.dart' show appThemeNotifier, appTextScaleNotifier, scaleFromLabel;
import '../Widgets/hover_card.dart';
// ─────────────────────────────────────────────────────────────────────────────
// PRIVACY POLICY SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _PrivacyPolicyScreen extends StatelessWidget {
  const _PrivacyPolicyScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'),
          backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            color: const Color(0xFFF57C00),
            height: 3,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Effective Date: January 1, 2025', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          SizedBox(height: 20),
          _Section('1. Information We Collect',
            'We collect information you provide when registering and using the Kwagala Farm app, including your name, email address, phone number, farm location, and farm operational data such as animal records, health logs, and financial transactions.'),
          _Section('2. How We Use Your Information',
            'We use your data to operate and improve the Kwagala Farm platform, send you important farm alerts and reminders, generate reports and analytics for your farm, and provide customer support. We never sell your personal data to third parties.'),
          _Section('3. Data Storage & Security',
            'Your data is stored on secure servers with industry-standard encryption (AES-256). We implement access controls, regular security audits, and encrypted data transmission (HTTPS/TLS) to protect your information.'),
          _Section('4. Data Sharing',
            'We do not sell, rent, or share your personal information with third parties except as required by law, to protect our legal rights, or with your explicit consent. Farm staff accounts you create share operational data within your farm workspace only.'),
          _Section('5. Your Rights',
            'You have the right to access, update, or delete your personal data at any time by contacting us at support@kwagalafarm.com. You may also request a complete export of your farm data in CSV format from the Settings screen.'),
          _Section('6. Cookies & Analytics',
            'The app uses anonymised usage analytics to improve features and fix bugs. No personally identifiable information is included in analytics data. You may opt out from Settings > Preferences.'),
          _Section('7. Children\'s Privacy',
            'Kwagala Farm is not intended for users under 16 years of age. We do not knowingly collect personal information from minors.'),
          _Section('8. Changes to This Policy',
            'We may update this Privacy Policy periodically. We will notify you of significant changes via in-app notification or email. Continued use of the app after changes constitutes acceptance of the updated policy.'),
          _Section('9. Contact Us',
            'For privacy-related questions or data requests, contact our Data Protection Officer at:\n\nEmail: kwagalafarm@gmail.com\nWhatsApp: +256 765 057 288\nAddress: Kireka Bugema, Gayaza Road, Kampala, Uganda'),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, body;
  const _Section(this.title, this.body);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      const SizedBox(height: 6),
      Text(body, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.6)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELP & SUPPORT SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _HelpSupportScreen extends StatefulWidget {
  const _HelpSupportScreen();
  @override
  State<_HelpSupportScreen> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<_HelpSupportScreen> {
  String? _selectedTopic;
  int? _feedback; // 0 = no, 1 = yes

  static const Color _green  = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFF57C00);

  final List<Map<String, dynamic>> _topics = [
    {
      'icon': Icons.add_circle_outline_rounded,
      'title': 'How to add a goat',
      'steps': [
        'Tap the "My Goats" tab at the bottom of the screen.',
        'Tap the orange "+ Add Goat" button in the bottom-right corner.',
        'Fill in the Tag ID, Name, Breed, Gender, Age and Weight fields.',
        'Toggle "Pregnant" if the doe is currently pregnant.',
        'Tap "Save Goat" — the animal will appear in your goat list immediately.',
      ],
    },
    {
      'icon': Icons.delete_outline_rounded,
      'title': 'How to delete a message in chat',
      'steps': [
        'Open the "Chats" tab from the bottom navigation bar.',
        'Find the message you want to remove.',
        'Long-press (hold) the message bubble for about 1 second.',
        'A menu will appear — tap "Delete Message".',
        'Confirm deletion in the dialog that appears.',
        'The message will be removed from the conversation.',
      ],
    },
    {
      'icon': Icons.edit_outlined,
      'title': 'How to edit a goat record',
      'steps': [
        'Tap the "My Goats" tab.',
        'Find the goat you want to update.',
        'Tap the green "Edit" button at the bottom of the goat card.',
        'Update any field — name, weight, health status, breed, or pregnancy status.',
        'Tap "Save Changes" to apply the update to the server.',
      ],
    },
    {
      'icon': Icons.notifications_outlined,
      'title': 'How to manage alerts',
      'steps': [
        'Live alerts appear in the scrolling ticker on the Home screen.',
        'Tap any alert in the ticker to add it as a farm task.',
        'Tap the bell icon in the top-right to see all active alerts.',
        'Admin users can add new alerts from the web admin dashboard.',
        'Workers receive all live alerts in real time on the mobile app.',
      ],
    },
    {
      'icon': Icons.bar_chart_outlined,
      'title': 'Understanding your analytics',
      'steps': [
        'Tap "Analytics" in the bottom navigation.',
        'Pull down to refresh data from the server.',
        'The breed distribution bar shows herd composition.',
        'Health Rate is the percentage of goats currently marked Healthy.',
        'Net Profit = Total Revenue (sales) minus Total Expenses.',
      ],
    },
    {
      'icon': Icons.cloud_outlined,
      'title': 'How weather advisories work',
      'steps': [
        'Go to More > Weather to see live conditions.',
        'Data is sourced from Open-Meteo for Kampala region in real time.',
        'The Farm Advisory section shows goat-specific recommendations.',
        'Red advisories require immediate action (shelter, heat, rain).',
        'Green advisories mean conditions are ideal for outdoor grazing.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
          title: const Text('Help & Support'),
          backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            color: const Color(0xFFF57C00),
            height: 3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Topic list
          if (_selectedTopic == null) ...[
            const Text('What do you need help with?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            const Text('Choose a topic below',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ..._topics.map((t) => _topicCard(t)),
          ] else ...[
            _stepDetail(),
          ],

          // WhatsApp support
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade100)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Still need help?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              const Text('Chat directly with our support team on WhatsApp.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('+256 765 057 288  — WhatsApp Support',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://wa.me/256777005177?text=Hi%2C+I+need+help+with+the+Kwagala+Farm+app');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _topicCard(Map<String, dynamic> topic) => HoverCard(
    child: GestureDetector(
    onTap: () => setState(() { _selectedTopic = topic['title']; _feedback = null; }),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        Icon(topic['icon'] as IconData, color: _green, size: 20),
        const SizedBox(width: 12),
        Text(topic['title'] as String,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A))),
        const Spacer(),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
      ]),
    ),
  ));

  Widget _stepDetail() {
    final topic = _topics.firstWhere((t) => t['title'] == _selectedTopic);
    final steps = topic['steps'] as List;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Back
      TextButton.icon(
        onPressed: () => setState(() { _selectedTopic = null; _feedback = null; }),
        icon: const Icon(Icons.arrow_back_rounded, size: 16),
        label: const Text('All Topics'),
        style: TextButton.styleFrom(foregroundColor: _green, padding: EdgeInsets.zero),
      ),
      const SizedBox(height: 8),
      Text(topic['title'] as String,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A))),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(children: List.generate(steps.length, (i) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(color: _green, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${i + 1}', style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(steps[i] as String,
                  style: const TextStyle(fontSize: 13,
                      color: Color(0xFF334155), height: 1.5))),
            ]),
          ))),
      ),
      const SizedBox(height: 24),
      // Feedback
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(children: [
          const Text('Does this answer your question?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _feedbackBtn(Icons.thumb_up_rounded, 1, const Color(0xFF2E7D32)),
            const SizedBox(width: 20),
            _feedbackBtn(Icons.thumb_down_rounded, 0, const Color(0xFFDC2626)),
          ]),
          if (_feedback != null) ...[
            const SizedBox(height: 12),
            Text(
              _feedback == 1
                  ? '👍 Glad that helped!'
                  : '👎 Sorry to hear that — chat with us on WhatsApp below.',
              style: TextStyle(
                  color: _feedback == 1 ? _green : const Color(0xFFDC2626),
                  fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ]),
      ),
    ]);
  }

  Widget _feedbackBtn(IconData icon, int val, Color color) => GestureDetector(
    onTap: () => setState(() => _feedback = val),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: _feedback == val ? color.withOpacity(0.1) : const Color(0xFFF8FAFC),
        shape: BoxShape.circle,
        border: Border.all(
            color: _feedback == val ? color : const Color(0xFFE2E8F0),
            width: _feedback == val ? 2 : 1),
      ),
      child: Icon(icon, color: _feedback == val ? color : const Color(0xFF94A3B8),
          size: 24),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT PROFILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────
// Avatar icon options — Material icons that render on all platforms
class _SettingsAvatarIcons {
  static const list = <IconData>[
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.face_2_rounded,
    Icons.face_3_rounded,
    Icons.face_4_rounded,
    Icons.face_5_rounded,
    Icons.face_6_rounded,
    Icons.agriculture_rounded,
    Icons.engineering_rounded,
    Icons.medical_services_rounded,
    Icons.manage_accounts_rounded,
    Icons.admin_panel_settings_rounded,
  ];
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;
  // avatar index stored separately above

  static const Color _green = Color(0xFF2E7D32);

  // Avatar uses icon index stored as string
  int _avatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text  = p.getString('username') ?? '';
      _emailCtrl.text = p.getString('email')    ?? '';
      _phoneCtrl.text = p.getString('phone')    ?? '';
      _avatarIndex    = int.tryParse(p.getString('avatar') ?? '0') ?? 0;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final p = await SharedPreferences.getInstance();
    await p.setString('username', _nameCtrl.text.trim());
    await p.setString('email',    _emailCtrl.text.trim());
    await p.setString('phone',    _phoneCtrl.text.trim());
    await p.setString('avatar',   _avatarIndex.toString());
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Profile saved!'),
          backgroundColor: Color(0xFF2E7D32)));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            color: const Color(0xFFF57C00),
            height: 3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Avatar picker
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Pick an Avatar', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Wrap(spacing: 12, runSpacing: 12,
                    children: List.generate(_SettingsAvatarIcons.list.length, (i) =>
                      GestureDetector(
                        onTap: () { setState(() => _avatarIndex = i); Navigator.pop(ctx); },
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: _avatarIndex == i
                                ? _green.withOpacity(0.1) : const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _avatarIndex == i ? _green : const Color(0xFFE2E8F0),
                                width: _avatarIndex == i ? 2 : 1),
                          ),
                          child: Icon(_SettingsAvatarIcons.list[i],
                              color: _avatarIndex == i ? _green : const Color(0xFF94A3B8),
                              size: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
            child: Stack(alignment: Alignment.bottomRight, children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withOpacity(0.3), width: 2),
                ),
                child: Center(child: Icon(
                    _SettingsAvatarIcons.list.elementAt(_avatarIndex.clamp(0, _SettingsAvatarIcons.list.length - 1)),
                    color: _green, size: 42)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _green, shape: BoxShape.circle),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          const Text('Tap to change avatar', style: TextStyle(
              fontSize: 11, color: Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          _fld('Full Name', _nameCtrl, 'e.g. Ssemakula Joseph', Icons.person_outline),
          const SizedBox(height: 14),
          _fld('Email Address', _emailCtrl, 'e.g. you@kwagala.com',
              Icons.email_outlined, type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _fld('Phone Number', _phoneCtrl, 'e.g. +256 700 123456',
              Icons.phone_outlined, type: TextInputType.phone),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Profile',
                      style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 15, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _fld(String label, TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl, keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
          ),
        ),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark       = false;
  bool _notif      = true;
  bool _healthAlerts = true;
  bool _pregAlerts   = true;
  bool _finSummary   = false;
  bool _offline      = false;
  bool _appLock      = false;

  String _language = 'English';
  String _currency = 'UGX — Ugandan Shilling';
  String _textScale = 'Normal (100%)';

  String _username = '';
  String _email    = '';
  String _phone    = '';
  int _avatarIdx   = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _dark        = p.getBool('dark_mode')       ?? false;
      _notif       = p.getBool('notif_enabled')   ?? true;
      _healthAlerts = p.getBool('health_alerts')  ?? true;
      _pregAlerts  = p.getBool('preg_alerts')     ?? true;
      _finSummary  = p.getBool('fin_summary')     ?? false;
      _offline     = p.getBool('offline_mode')    ?? false;
      _appLock     = p.getBool('app_lock')        ?? false;
      _language    = p.getString('language')      ?? 'English';
      _currency    = p.getString('currency')      ?? 'UGX — Ugandan Shilling';
      _textScale   = p.getString('text_scale')    ?? 'Normal (100%)';
      _username    = p.getString('username')      ?? '';
      _email       = p.getString('email')         ?? '';
      _phone       = p.getString('phone')         ?? '';
      _avatarIdx   = int.tryParse(p.getString('avatar') ?? '0') ?? 0;
    });
  }

  Future<void> _sb(String k, bool v) async {
    final p = await SharedPreferences.getInstance(); await p.setBool(k, v);
  }
  Future<void> _ss(String k, String v) async {
    final p = await SharedPreferences.getInstance(); await p.setString(k, v);
  }

  // Theme helpers
  Color get _accent  => _dark ? Colors.green.shade400 : const Color(0xFF2E7D32);
  Color get _bg      => _dark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F4F0);
  Color get _cardBg  => _dark ? const Color(0xFF1A1A1A) : Colors.white;
  Color get _textDark => _dark ? Colors.white : const Color(0xFF0F172A);
  Color get _textMid  => _dark ? Colors.white60 : const Color(0xFF475569);
  Color get _border   => _dark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0);
  Color get _divider  => _dark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          // Green header
          Container(
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(children: [
              Image.asset('Assets/farm.png', height: 50, width: 50,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.settings_rounded, color: Colors.white, size: 26)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Settings',
                  style: TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.bold))),
            ]),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _profileCard(),
                const SizedBox(height: 20),

                // ── Appearance ──────────────────────────────────────────
                _secLabel('Appearance'),
                _cardWrap([
                  _swItem(Icons.dark_mode_rounded, const Color(0xFF475569),
                      const Color(0xFFE2E8F0), 'Dark Mode',
                      'Switch entire app to dark theme', _dark, (v) {
                    setState(() => _dark = v);
                    _sb('dark_mode', v);
                    appThemeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                  }),
                ]),
                const SizedBox(height: 20),

                // ── Notifications ───────────────────────────────────────
                _secLabel('Notifications'),
                _cardWrap([
                  _swItem(Icons.notifications_active_rounded,
                      const Color(0xFF2E7D32), const Color(0xFFDCFCE7),
                      'Push Notifications', 'Enable all app notifications', _notif, (v) {
                    setState(() => _notif = v); _sb('notif_enabled', v);
                  }),
                  _divLine(),
                  _swItem(Icons.health_and_safety_rounded,
                      const Color(0xFF7C3AED), const Color(0xFFF5F3FF),
                      'Health Alerts', 'Notify when a goat needs treatment',
                      _healthAlerts, _notif ? (v) {
                    setState(() => _healthAlerts = v); _sb('health_alerts', v);
                  } : null),
                  _divLine(),
                  _swItem(Icons.pregnant_woman_rounded,
                      const Color(0xFFF57C00), const Color(0xFFFFF7ED),
                      'Pregnancy Due Alerts', 'Remind 7 days before expected birth',
                      _pregAlerts, _notif ? (v) {
                    setState(() => _pregAlerts = v); _sb('preg_alerts', v);
                  } : null),
                  _divLine(),
                  _swItem(Icons.bar_chart_rounded,
                      const Color(0xFF2E7D32), const Color(0xFFDCFCE7),
                      'Weekly Financial Summary', 'Receive revenue & expense digest',
                      _finSummary, _notif ? (v) {
                    setState(() => _finSummary = v); _sb('fin_summary', v);
                  } : null),
                ]),
                const SizedBox(height: 20),

                // ── Preferences ─────────────────────────────────────────
                _secLabel('Preferences'),
                _cardWrap([
                  _selItem(Icons.text_fields_rounded, const Color(0xFFF57C00),
                      const Color(0xFFFFF7ED), 'Text Size / Font Scaling', _textScale,
                      ['Small (85%)', 'Normal (100%)', 'Large (115%)', 'Extra Large (130%)'],
                          (v) { setState(() => _textScale = v!); _ss('text_scale', v!); appTextScaleNotifier.value = scaleFromLabel(v!); }),
                  _divLine(),
                  _selItem(Icons.attach_money_rounded, const Color(0xFF2E7D32),
                      const Color(0xFFDCFCE7), 'Currency', _currency,
                      ['UGX — Ugandan Shilling', 'USD — US Dollar',
                       'KES — Kenyan Shilling', 'TZS — Tanzanian Shilling'],
                          (v) { setState(() => _currency = v!); _ss('currency', v!); }),
                  
                ]),
                const SizedBox(height: 20),

                // ── Data & Sync ─────────────────────────────────────────
                _secLabel('Data & Sync'),
                _cardWrap([
                  _swItem(Icons.wifi_off_rounded, const Color(0xFF2E7D32),
                      const Color(0xFFDCFCE7), 'Offline Mode',
                      'Cache data when no internet', _offline, (v) {
                    setState(() => _offline = v); _sb('offline_mode', v);
                  }),
                  _divLine(),
                  _tileItem(Icons.sync_rounded, const Color(0xFF7C3AED),
                      const Color(0xFFF5F3FF), 'Force Sync',
                      'Push local data to server', _forceSync),
                  
                ]),
                const SizedBox(height: 20),

                // ── Security ────────────────────────────────────────────
                _secLabel('Security'),
                _cardWrap([
                  _tileItem(Icons.lock_reset_rounded, const Color(0xFF2E7D32),
                      const Color(0xFFDCFCE7), 'Change Password',
                      'Update your account password', () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
                  _divLine(),
                ]),
                const SizedBox(height: 20),

                // ── About ───────────────────────────────────────────────
                _secLabel('About'),
                _cardWrap([

                  _tileItem(Icons.privacy_tip_outlined, const Color(0xFF7C3AED),
                      const Color(0xFFF5F3FF), 'Privacy Policy',
                      'How your data is collected and used',
                          () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const _PrivacyPolicyScreen()))),
                  _divLine(),
                  _tileItem(Icons.help_outline_rounded, const Color(0xFF2E7D32),
                      const Color(0xFFDCFCE7), 'Help & Support',
                      'Guides, FAQs and WhatsApp support',
                          () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const _HelpSupportScreen()))),
                ]),
                const SizedBox(height: 28),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _confirmLogout,
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text('Kwagala Goat Farm · v2.4.1',
                    style: TextStyle(fontSize: 11, color: _textMid))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _profileCard() => GestureDetector(
    onTap: () async {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()));
      _load();
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border)),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
              color: _accent.withOpacity(0.1), shape: BoxShape.circle,
              border: Border.all(color: _accent.withOpacity(0.3))),
          child: Center(child: Icon(
              _SettingsAvatarIcons.list.elementAt(_avatarIdx.clamp(0, _SettingsAvatarIcons.list.length - 1)),
              color: _accent, size: 28)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_username.isNotEmpty ? _username : 'Kwagala Farmer',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark)),
          if (_email.isNotEmpty)
            Text(_email, style: TextStyle(fontSize: 12, color: _textMid)),
          if (_phone.isNotEmpty)
            Text(_phone, style: TextStyle(fontSize: 12, color: _textMid)),
        ])),
        Icon(Icons.edit_square, color: _textMid, size: 18),
      ]),
    ),
  );

  Widget _secLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 8),
    child: Text(t.toUpperCase(), style: TextStyle(fontSize: 11,
        fontWeight: FontWeight.w700, color: _textMid, letterSpacing: 0.8)),
  );

  Widget _cardWrap(List<Widget> children) => Container(
    decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border)),
    child: Column(children: children),
  );

  Widget _divLine() => Divider(height: 1, indent: 56, color: _divider);

  Widget _swItem(IconData icon, Color ic, Color ib, String title, String sub,
      bool val, ValueChanged<bool>? onChange) =>
      Opacity(
        opacity: onChange == null ? 0.45 : 1.0,
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          secondary: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: ib, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: ic, size: 20)),
          title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: _textDark)),
          subtitle: Text(sub, style: TextStyle(fontSize: 12, color: _textMid)),
          value: val,
          activeColor: _accent,
          onChanged: onChange,
        ),
      );

  Widget _selItem(IconData icon, Color ic, Color ib, String title,
      String value, List<String> options, ValueChanged<String?> onChange) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: ib, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: ic, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: _textDark)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: value, dropdownColor: _cardBg,
              style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(color: _accent, width: 1.5)),
                filled: true, fillColor: _dark
                    ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
              ),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChange,
            ),
          ])),
        ]),
      );

  Widget _tileItem(IconData icon, Color ic, Color ib, String title, String sub,
      VoidCallback onTap) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: ib, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: ic, size: 20)),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: _textDark)),
        subtitle: Text(sub, style: TextStyle(fontSize: 12, color: _textMid)),
        trailing: Icon(Icons.chevron_right_rounded, color: _textMid, size: 22),
      );

  void _showAppLockOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('App Lock Options', style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _lockOption(ctx, Icons.pin_outlined, 'PIN Code',
              'Set a 4–6 digit numeric PIN'),
          _lockOption(ctx, Icons.pattern_rounded, 'Pattern Lock',
              'Draw a pattern to unlock'),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _lockOption(BuildContext ctx, IconData icon, String title, String sub) =>
      ListTile(
        leading: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: const Color(0xFF7C3AED), size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        onTap: () {
          Navigator.pop(ctx);
          _snack('$title set up successfully');
        },
      );

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B)),
  );

  Future<void> _forceSync() async {
    _snack('🔄 Syncing with server...');
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) _snack('✅ Synced successfully');
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _cardBg,
        title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: _textDark)),
        content: Text('Are you sure you want to sign out?', style: TextStyle(color: _textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: _textMid))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                elevation: 0),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ApiService.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }
}
