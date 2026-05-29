import 'package:flutter/material.dart';
import 'add_goat.dart';

class GoatsScreen extends StatefulWidget {
  const GoatsScreen({Key? key}) : super(key: key);

  @override
  State<GoatsScreen> createState() => _GoatsScreenState();
}

class _GoatsScreenState extends State<GoatsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedBreed = "All Breeds";
  String selectedGender = "All";
  String searchQuery = "";

  final List<String> breeds = ["All Breeds", "Boer", "Kalahari", "Savanna", "Local"];
  final List<String> genders = ["All", "Male", "Female"];

  final List<Map<String, String>> goats = [
    {
      "id": "GT001",
      "name": "Lucky",
      "breed": "Boer",
      "gender": "Male",
      "age": "14 months",
      "weight": "32 kg",
      "dateAdded": "12 Jan 2026",
      "tag": "A101"
    },
    {
      "id": "GT002",
      "name": "Daisy",
      "breed": "Kalahari",
      "gender": "Female",
      "age": "8 months",
      "weight": "24 kg",
      "dateAdded": "18 Feb 2026",
      "tag": "B204"
    }
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green.shade700;

    final filteredGoats = goats.where((goat) {
      final matchesBreed = selectedBreed == "All Breeds" || 
          (goat["breed"]?.toLowerCase() == selectedBreed.toLowerCase());
          
      final matchesGender = selectedGender == "All" || 
          (goat["gender"]?.toLowerCase() == selectedGender.toLowerCase());

      final matchesSearch = goat["name"]!.toLowerCase().contains(searchQuery) ||
          goat["id"]!.toLowerCase().contains(searchQuery) ||
          goat["tag"]!.toLowerCase().contains(searchQuery);

      return matchesBreed && matchesGender && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          "Goat Inventory",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: primaryGreen, size: 26),
            onPressed: () async {
              // Navigates to form screen and awaits new map input parameters safely
              final Map<String, String>? newlyCreatedGoat = await Navigator.push<Map<String, String>>(
                context,
                MaterialPageRoute(builder: (_) => const AddGoatScreen()),
              );

              if (newlyCreatedGoat != null) {
                setState(() {
                  goats.insert(0, newlyCreatedGoat); // Inserts at the top of the inventory array list
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${newlyCreatedGoat['name']} added to inventory successfully!"),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by Name, ID, or Ear Tag...",
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: _buildDropdownFilter("Breed", selectedBreed, breeds, (v) => setState(() => selectedBreed = v!))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdownFilter("Gender", selectedGender, genders, (v) => setState(() => selectedGender = v!))),
              ],
            ),
          ),

          Expanded(
            child: filteredGoats.isEmpty
                ? Center(
                    child: Text(
                      "No records matching search parameters.",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredGoats.length,
                    itemBuilder: (context, index) {
                      final goat = filteredGoats[index];
                      return _buildGoatItemCard(goat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String currentVal, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGoatItemCard(Map<String, String> goat) {
    final bool isMale = (goat['gender'] ?? 'Male').toLowerCase() == 'male';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isMale ? Colors.blue.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.pets_rounded, color: isMale ? Colors.blue.shade700 : Colors.orange.shade700, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${goat['name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isMale ? Colors.blue.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text("${goat['gender']}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMale ? Colors.blue.shade700 : Colors.orange.shade700)),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.tag_rounded, "Ear Tag: ${goat['tag']}"),
                _buildInfoRow(Icons.layers_outlined, "Breed Group: ${goat['breed']}"),
                Row(
                  children: [
                    Expanded(child: _buildInfoRow(Icons.calendar_today_rounded, "Age: ${goat['age']}")),
                    Expanded(child: _buildInfoRow(Icons.scale_rounded, "Weight: ${goat['weight']}")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}