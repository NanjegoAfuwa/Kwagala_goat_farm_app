import 'package:flutter/material.dart';
import 'add_goat.dart';
import '../Services/api_service.dart';
import '../Models/goat_model.dart';
import '../theme_helper.dart';
import '../Widgets/shimmer.dart';
import '../Widgets/hover_card.dart';

class GoatsScreen extends StatefulWidget {
  const GoatsScreen({Key? key}) : super(key: key);
  @override
  State<GoatsScreen> createState() => _GoatsScreenState();
}

class _GoatsScreenState extends State<GoatsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedBreed = 'All Breeds';
  String _selectedGroup = 'All Groups';
  String _searchQuery   = '';
  bool   _showSearch    = false;

  List<GoatModel> _goats     = [];
  bool            _isLoading = true;
  String?         _error;

  static const Color _green  = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFF57C00);

  final List<String> _breeds = [
    'All Breeds', 'Boer', 'Kalahari', 'Savanna', 'Local'
  ];
  final List<String> _groups = [
    'All Groups', 'Breeding', 'Milking', 'Fattening', 'Kids', 'Bucks'
  ];

  @override
  void initState() {
    super.initState();
    _fetchGoats();
    _searchController.addListener(
        () => setState(() => _searchQuery = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchGoats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final goats = await ApiService.fetchGoats();
      if (mounted) setState(() { _goats = goats; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<GoatModel> get _filtered => _goats.where((g) {
    final matchBreed  = _selectedBreed == 'All Breeds' || g.breed == _selectedBreed;
    final matchGroup  = _selectedGroup == 'All Groups' ||
        (_selectedGroup == 'Bucks'    && g.gender == 'Male') ||
        (_selectedGroup == 'Milking'  && g.gender == 'Female') ||
        (_selectedGroup == 'Breeding' && g.isPregnant) ||
        (_selectedGroup == 'Kids'     && g.age.contains('month'));
    final matchSearch = _searchQuery.isEmpty ||
        g.name.toLowerCase().contains(_searchQuery) ||
        g.tagNumber.toLowerCase().contains(_searchQuery) ||
        g.breed.toLowerCase().contains(_searchQuery);
    return matchBreed && matchGroup && matchSearch;
  }).toList();

  // ── EDIT SHEET ────────────────────────────────────────────────────────────
  void _showEditSheet(GoatModel goat) {
    final nameCtrl   = TextEditingController(text: goat.name);
    final weightCtrl = TextEditingController(text: goat.weight.toString());
    String breed  = goat.breed;
    String gender = goat.gender;
    String health = goat.healthStatus;
    bool pregnant = goat.isPregnant;

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
        child: StatefulBuilder(builder: (ctx, setM) => SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Edit Goat', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(goat.tagNumber, style: const TextStyle(
                    fontSize: 12, fontFamily: 'monospace',
                    color: Color(0xFF475569))),
              ),
            ]),
            const SizedBox(height: 20),
            _fld('Name', nameCtrl, 'e.g. Nalongo'),
            const SizedBox(height: 12),
            _fld('Weight (kg)', weightCtrl, 'e.g. 38.5',
                type: TextInputType.number),
            const SizedBox(height: 12),
            _dropFld('Breed', breed, _breeds.skip(1).toList(),
                (v) => setM(() => breed = v!)),
            const SizedBox(height: 12),
            _dropFld('Gender', gender, ['Female', 'Male'],
                (v) => setM(() => gender = v!)),
            const SizedBox(height: 12),
            _dropFld('Health Status', health,
                ['Healthy', 'Stable', 'Sick', 'Under Treatment'],
                (v) => setM(() => health = v!)),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Pregnant', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const Spacer(),
              Switch(value: pregnant, activeColor: _green,
                  onChanged: (v) => setM(() => pregnant = v)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await ApiService.updateGoat(goat.id, {
                    'name': nameCtrl.text.trim(),
                    'weight': double.tryParse(weightCtrl.text) ?? goat.weight,
                    'breed': breed, 'gender': gender,
                    'health_status': health, 'is_pregnant': pregnant,
                  });
                  if (ok) _fetchGoats();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? '✅ Goat updated!' : '❌ Update failed'),
                    backgroundColor: ok ? _green : Colors.red,
                  ));
                },
                child: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15, color: Colors.white)),
              ),
            ),
          ]),
        )),
      ),
    );
  }

  void _confirmDelete(GoatModel goat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Goat',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Remove ${goat.name.isNotEmpty ? goat.name : goat.tagNumber}? '
            'This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)), elevation: 0),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ApiService.deleteGoat(goat.id);
              if (ok) _fetchGoats();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? '🗑️ Goat removed' : '❌ Delete failed'),
                backgroundColor: ok ? Colors.grey.shade800 : Colors.red,
              ));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showGoatOptions(GoatModel goat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.edit_rounded, color: _green, size: 20),
            ),
            title: const Text('Edit Goat',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            onTap: () { Navigator.pop(ctx); _showEditSheet(goat); },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 20),
            ),
            title: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 15, color: Colors.red)),
            onTap: () { Navigator.pop(ctx); _confirmDelete(goat); },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),

      // ── APP BAR — green + orange underline ──────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Search goats...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              )
            : const Text('Goats',
                style: TextStyle(
                    color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: _orange, height: 3),
        ),
        // Only search icon — no PDF, no filter
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.white, size: 26),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                _searchQuery = '';
              }
            }),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Column(children: [

        // ── FILTER DROPDOWNS — All Breeds / All Groups ──────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(children: [
            Expanded(child: _filterDropdown(
              value: _selectedBreed,
              items: _breeds,
              arrowColor: _green,
              onChanged: (v) => setState(() => _selectedBreed = v!),
            )),
            const SizedBox(width: 12),
            Expanded(child: _filterDropdown(
              value: _selectedGroup,
              items: _groups,
              arrowColor: _orange,
              onChanged: (v) => setState(() => _selectedGroup = v!),
            )),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),

        // ── GOAT LIST ───────────────────────────────────────────────────
        Expanded(
          child: _isLoading
              ? Padding(
                padding: const EdgeInsets.all(12),
                child: Center(child: ShimmerList(count: 4, itemHeight: 78)))
              : _error != null
                  ? _errorView()
                  : filtered.isEmpty
                      ? _emptyView()
                      : RefreshIndicator(
                          onRefresh: _fetchGoats,
                          color: _green,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox.shrink(),
                            itemBuilder: (_, i) =>
                                _goatRow(filtered[i]),
                          ),
                        ),
        ),
      ]),

      // ── ORANGE + Add FAB ────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _orange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        elevation: 3,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddGoatScreen()));
          _fetchGoats();
        },
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text('Add',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.3)),
      ),
    );
  }

  // ── GOAT ROW — photo thumbnail | tag bold | name | gender | 3-dot ────────
  Widget _goatRow(GoatModel goat) {
    // Health badge colour
    Color hBadgeColor;
    switch (goat.healthStatus.toLowerCase()) {
      case 'sick':
      case 'under treatment': hBadgeColor = Colors.red.shade400; break;
      case 'stable':          hBadgeColor = _orange;             break;
      default:                hBadgeColor = _green;
    }

    return HoverCard(
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditSheet(goat),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── Goat photo / icon thumbnail ────────────────────────────
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0EE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Realistic goat icon using CustomPaint
                  CustomPaint(
                    size: const Size(64, 64),
                    painter: _RealisticGoatPainter(
                      bodyColor: goat.gender == 'Male'
                          ? const Color(0xFF2E7D32)  // green for bucks
                          : const Color(0xFFF57C00), // orange for does
                    ),
                  ),
                  // Small health dot in bottom-right corner
                  Positioned(
                    bottom: 4, right: 4,
                    child: Container(
                      width: 9, height: 9,
                      decoration: BoxDecoration(
                        color: hBadgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // ── Tag number (large bold) + name below ───────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    goat.tagNumber,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111111),
                        letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    goat.name.isNotEmpty ? goat.name : '—',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555)),
                  ),
                ],
              ),
            ),

            // ── Gender + 3-dot menu ────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showGoatOptions(goat),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_vert_rounded,
                        color: Color(0xFF999999), size: 24),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goat.gender,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF777777)),
                ),
              ],
            ),

          ],
        ),
        ),
      ),
      ),  // inner Container
    );   // HoverCard
  }

  Widget _errorView() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey),
    const SizedBox(height: 14),
    const Text('Could not load goats',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
            color: Colors.grey)),
    const SizedBox(height: 14),
    ElevatedButton(
      onPressed: _fetchGoats,
      style: ElevatedButton.styleFrom(backgroundColor: _green),
      child: const Text('Retry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  ]));

  Widget _emptyView() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.pets_rounded, size: 60, color: Color(0xFFCCCCCC)),
    const SizedBox(height: 14),
    const Text('No goats found',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
            color: Color(0xFFAAAAAA))),
  ]));

  // ── FILTER DROPDOWN ───────────────────────────────────────────────────────
  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required Color arrowColor,
    required ValueChanged<String?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: Icon(Icons.arrow_drop_down_rounded,
                color: arrowColor, size: 24),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A)),
            items: items.map((e) =>
                DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      );

  // ── FORM HELPERS ──────────────────────────────────────────────────────────
  Widget _fld(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl, keyboardType: type,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFF94A3B8), fontSize: 13),
            filled: true, fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF2E7D32), width: 1.5)),
          ),
        ),
      ]);

  Widget _dropFld(String label, String value, List<String> options,
      ValueChanged<String?> onChange) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF2E7D32), width: 1.5)),
          ),
          items: options.map((o) =>
              DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChange,
        ),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// REALISTIC GOAT PAINTER  — multi-toned, shaded, detailed anatomy
// ─────────────────────────────────────────────────────────────────────────────
class _RealisticGoatPainter extends CustomPainter {
  final Color bodyColor;
  const _RealisticGoatPainter({required this.bodyColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Derive a full palette from the single brand colour
    final base    = bodyColor;
    final light   = Color.lerp(base, Colors.white, 0.45)!;
    final lighter = Color.lerp(base, Colors.white, 0.70)!;
    final dark    = Color.lerp(base, Colors.black, 0.35)!;
    final darker  = Color.lerp(base, Colors.black, 0.55)!;
    final belly   = Color.lerp(base, Colors.white, 0.82)!;
    final hoofClr = Color.lerp(base, Colors.black, 0.75)!;

    double x(double v) => v / 100 * w;
    double y(double v) => v / 100 * h;

    Paint fill(Color c) => Paint()..color = c..style = PaintingStyle.fill..isAntiAlias = true;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));

    // ── BACK LEGS (drawn first, behind body) ─────────────────────────────
    // Back-right leg (slightly behind)
    final blegR = Path()
      ..moveTo(x(72), y(60))
      ..cubicTo(x(74), y(65), x(75), y(72), x(75), y(80))
      ..cubicTo(x(75), y(85), x(73), y(88), x(71), y(88))
      ..cubicTo(x(69), y(88), x(67), y(85), x(67), y(80))
      ..cubicTo(x(67), y(72), x(68), y(65), x(70), y(60))
      ..close();
    canvas.drawPath(blegR, fill(dark));
    // hoof
    final bhoofR = Path()
      ..moveTo(x(67), y(84))..lineTo(x(75), y(84))
      ..lineTo(x(75), y(88))..lineTo(x(67), y(88))..close();
    canvas.drawPath(bhoofR, fill(hoofClr));

    // Back-left leg
    final blegL = Path()
      ..moveTo(x(78), y(60))
      ..cubicTo(x(80), y(65), x(81), y(72), x(81), y(80))
      ..cubicTo(x(81), y(85), x(79), y(88), x(77), y(88))
      ..cubicTo(x(75), y(88), x(73), y(85), x(73), y(80))
      ..cubicTo(x(73), y(72), x(74), y(65), x(76), y(60))
      ..close();
    canvas.drawPath(blegL, fill(base));
    final bhoofL = Path()
      ..moveTo(x(73), y(84))..lineTo(x(81), y(84))
      ..lineTo(x(81), y(88))..lineTo(x(73), y(88))..close();
    canvas.drawPath(bhoofL, fill(hoofClr));

    // ── BODY — large realistic oval torso with gradient shading ──────────
    final bodyPath = Path()
      ..moveTo(x(22), y(55))
      ..cubicTo(x(20), y(38), x(28), y(28), x(48), y(26))
      ..cubicTo(x(68), y(24), x(84), y(30), x(88), y(42))
      ..cubicTo(x(92), y(52), x(88), y(64), x(78), y(68))
      ..cubicTo(x(68), y(72), x(50), y(72), x(36), y(70))
      ..cubicTo(x(22), y(68), x(22), y(62), x(22), y(55))
      ..close();

    // Body gradient — lighter on top, darker on belly sides
    final bodyGrad = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lighter, base, dark],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x(20), y(24), x(72), y(50)));
    canvas.drawPath(bodyPath, bodyGrad);

    // Belly highlight — lighter patch underneath
    final bellyPath = Path()
      ..moveTo(x(32), y(68))
      ..cubicTo(x(32), y(60), x(38), y(58), x(56), y(58))
      ..cubicTo(x(70), y(58), x(76), y(60), x(78), y(66))
      ..cubicTo(x(70), y(72), x(50), y(74), x(36), y(72))
      ..close();
    canvas.drawPath(bellyPath, fill(belly));

    // Body sheen — top-left highlight
    final sheenPath = Path()
      ..moveTo(x(28), y(32))
      ..cubicTo(x(32), y(27), x(44), y(25), x(58), y(26))
      ..cubicTo(x(52), y(28), x(38), y(30), x(30), y(38))
      ..close();
    canvas.drawPath(sheenPath, fill(lighter.withOpacity(0.5)));

    // ── FRONT LEGS ────────────────────────────────────────────────────────
    // Front-right (back, slightly darker)
    final flegR = Path()
      ..moveTo(x(33), y(68))
      ..cubicTo(x(31), y(74), x(30), y(80), x(30), y(84))
      ..cubicTo(x(30), y(87), x(32), y(89), x(34), y(89))
      ..cubicTo(x(36), y(89), x(38), y(87), x(38), y(84))
      ..cubicTo(x(38), y(78), x(37), y(72), x(37), y(68))
      ..close();
    canvas.drawPath(flegR, fill(dark));
    final fhoofR = Path()
      ..moveTo(x(30), y(84))..lineTo(x(38), y(84))
      ..lineTo(x(38), y(89))..lineTo(x(30), y(89))..close();
    canvas.drawPath(fhoofR, fill(hoofClr));

    // Front-left (front, base colour)
    final flegL = Path()
      ..moveTo(x(42), y(68))
      ..cubicTo(x(40), y(74), x(39), y(80), x(39), y(84))
      ..cubicTo(x(39), y(87), x(41), y(89), x(43), y(89))
      ..cubicTo(x(45), y(89), x(47), y(87), x(47), y(84))
      ..cubicTo(x(47), y(78), x(46), y(72), x(46), y(68))
      ..close();
    canvas.drawPath(flegL, fill(base));
    final fhoofL = Path()
      ..moveTo(x(39), y(84))..lineTo(x(47), y(84))
      ..lineTo(x(47), y(89))..lineTo(x(39), y(89))..close();
    canvas.drawPath(fhoofL, fill(hoofClr));

    // Knee joints — small rounded bumps
    for (final cx in [x(34), x(43), x(71), x(77)]) {
      canvas.drawCircle(
        Offset(cx, y(76)),
        w * 0.035,
        fill(dark.withOpacity(0.5)),
      );
    }

    // ── TAIL ──────────────────────────────────────────────────────────────
    final tailPath = Path()
      ..moveTo(x(87), y(40))
      ..cubicTo(x(94), y(33), x(99), y(33), x(99), y(39))
      ..cubicTo(x(99), y(45), x(94), y(50), x(87), y(48))
      ..close();
    canvas.drawPath(tailPath, fill(light));
    // Tail tip — fluffy tuft
    canvas.drawCircle(Offset(x(97), y(38)), w * 0.05, fill(lighter));

    // ── NECK ──────────────────────────────────────────────────────────────
    final neckPath = Path()
      ..moveTo(x(26), y(36))
      ..cubicTo(x(22), y(28), x(20), y(18), x(20), y(12))
      ..cubicTo(x(20), y(7),  x(24), y(4),  x(28), y(5))
      ..cubicTo(x(32), y(6),  x(34), y(10), x(34), y(16))
      ..cubicTo(x(34), y(24), x(32), y(32), x(30), y(38))
      ..close();
    final neckGrad = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [dark, base, light],
      ).createShader(Rect.fromLTWH(x(19), y(4), x(16), y(36)));
    canvas.drawPath(neckPath, neckGrad);

    // Neck mane / fur line
    final mane = Paint()
      ..color = darker.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;
    final manePath = Path()
      ..moveTo(x(22), y(35))
      ..cubicTo(x(20), y(25), x(21), y(14), x(23), y(7));
    canvas.drawPath(manePath, mane);

    // ── HEAD ──────────────────────────────────────────────────────────────
    final headPath = Path()
      ..moveTo(x(20), y(8))
      ..cubicTo(x(14), y(5),  x(7),  y(7),  x(5),  y(13))
      ..cubicTo(x(3),  y(19), x(6),  y(26), x(12), y(27))
      ..cubicTo(x(18), y(28), x(24), y(24), x(26), y(18))
      ..cubicTo(x(28), y(12), x(25), y(8),  x(20), y(8))
      ..close();
    final headGrad = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [light, base, dark],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(x(3), y(5), x(26), y(25)));
    canvas.drawPath(headPath, headGrad);

    // Muzzle — lighter patch on front of face
    final muzzle = Path()
      ..moveTo(x(5),  y(20))
      ..cubicTo(x(4),  y(17), x(4),  y(23), x(6),  y(26))
      ..cubicTo(x(8),  y(28), x(12), y(28), x(14), y(26))
      ..cubicTo(x(16), y(24), x(15), y(19), x(13), y(18))
      ..cubicTo(x(10), y(17), x(6),  y(18), x(5),  y(20))
      ..close();
    canvas.drawPath(muzzle, fill(lighter));

    // ── EAR (large, drooping — Boer style) ────────────────────────────────
    final earPath = Path()
      ..moveTo(x(8),  y(10))
      ..cubicTo(x(2),  y(6),  x(-2), y(10), x(-1), y(17))
      ..cubicTo(x(0),  y(22), x(5),  y(24), x(9),  y(20))
      ..cubicTo(x(12), y(17), x(11), y(12), x(8),  y(10))
      ..close();
    canvas.drawPath(earPath, fill(base));
    // Inner ear
    final earInner = Path()
      ..moveTo(x(7),  y(12))
      ..cubicTo(x(3),  y(10), x(1),  y(14), x(2),  y(19))
      ..cubicTo(x(3),  y(22), x(7),  y(22), x(9),  y(18))
      ..cubicTo(x(10), y(15), x(9),  y(12), x(7),  y(12))
      ..close();
    canvas.drawPath(earInner, fill(Color.lerp(base, Colors.pink, 0.35)!));

    // ── HORN ──────────────────────────────────────────────────────────────
    final hornPath = Path()
      ..moveTo(x(18), y(6))
      ..cubicTo(x(17), y(1),  x(16), y(-2), x(15), y(-2))
      ..cubicTo(x(14), y(-2), x(13), y(1),  x(14), y(5))
      ..cubicTo(x(15), y(8),  x(17), y(9),  x(18), y(8))
      ..close();
    // Horn is always a warm ivory/cream
    canvas.drawPath(hornPath, fill(const Color(0xFFD4B896)));
    // Horn ridge lines
    final hornLine = Paint()
      ..color = const Color(0xFF8B7355).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..isAntiAlias = true;
    canvas.drawLine(Offset(x(15), y(6)), Offset(x(15), y(1)), hornLine);

    // Second horn (barely visible, other side)
    final horn2 = Path()
      ..moveTo(x(21), y(5))
      ..cubicTo(x(22), y(1), x(22), y(-1), x(21), y(-1))
      ..cubicTo(x(20), y(-1), x(19), y(2), x(20), y(5))
      ..close();
    canvas.drawPath(horn2, fill(const Color(0xFFC4A882)));

    // ── BEARD ─────────────────────────────────────────────────────────────
    final beardPath = Path()
      ..moveTo(x(7),  y(26))
      ..cubicTo(x(5),  y(29), x(5),  y(34), x(7),  y(36))
      ..cubicTo(x(9),  y(38), x(12), y(37), x(12), y(33))
      ..cubicTo(x(12), y(29), x(10), y(26), x(7),  y(26))
      ..close();
    canvas.drawPath(beardPath, fill(lighter));

    // ── EYE ───────────────────────────────────────────────────────────────
    // Eye white/sclera
    canvas.drawCircle(Offset(x(12), y(14)), w * 0.055,
        fill(const Color(0xFFFFF8F0)));
    // Iris — amber coloured (realistic goat eye)
    canvas.drawCircle(Offset(x(12), y(14)), w * 0.038,
        fill(const Color(0xFFB8860B)));
    // Pupil — horizontal rectangular (goat pupils are unique)
    final pupilRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x(12), y(14)),
          width: w * 0.045, height: w * 0.018),
      Radius.circular(w * 0.008),
    );
    canvas.drawRRect(pupilRect, fill(Colors.black));
    // Eye shine
    canvas.drawCircle(Offset(x(13), y(13)), w * 0.012,
        fill(Colors.white.withOpacity(0.8)));

    // ── NOSTRILS ──────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x(6), y(24)),
          width: w * 0.06, height: w * 0.04),
      fill(darker.withOpacity(0.5)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x(10), y(24.5)),
          width: w * 0.055, height: w * 0.035),
      fill(darker.withOpacity(0.5)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RealisticGoatPainter old) =>
      old.bodyColor != bodyColor;
}
