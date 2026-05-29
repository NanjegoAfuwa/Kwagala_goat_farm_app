import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  // Modular data structures collection list to map items safely
  final List<Map<String, dynamic>> _analyticsSummary = const [
    {"label": "Boer Group", "fraction": 0.65, "count": "54", "color": Colors.blue},
    {"label": "Kalahari", "fraction": 0.40, "count": "32", "color": Colors.purple},
    {"label": "Savanna", "fraction": 0.25, "count": "18", "color": Colors.teal},
    {"label": "Locals", "fraction": 0.15, "count": "11", "color": Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text("Farm Analytics Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Header Visual block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryGreen, Colors.green.shade900]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 40, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Performance Matrix", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Realtime analytical data metrics calculated over current cycles.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("BREED REPARTITION OUTPUTS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
            const SizedBox(height: 10),

            // Functional loop generation maps widgets smoothly dynamically
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                children: _analyticsSummary.map((data) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AnalyticsBarRow(
                    label: data["label"],
                    fraction: data["fraction"],
                    count: data["count"],
                    color: data["color"],
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 24),
            const Text("HEALTH RECOVERY INDEX RATIO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
            const SizedBox(height: 10),

            // Operational Financial and Structural split segment info boxes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.gpp_good_outlined, color: primaryGreen),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("94.4% Overall Safe Rating", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                        SizedBox(height: 4),
                        Text("Stable condition margin metrics across entire herds.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsBarRow extends StatelessWidget {
  final String label;
  final double fraction;
  final String count;
  final Color color;

  const AnalyticsBarRow({
    Key? key,
    required this.label,
    required this.fraction,
    required this.count,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            Text("$count Goats", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ],
        ),
      ],
    );
  }
}