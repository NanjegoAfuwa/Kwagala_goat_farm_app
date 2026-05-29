import 'package:flutter/material.dart';
import 'package:kwagala_farm/Services/api_service.dart';
import 'package:kwagala_farm/models/goat_model.dart';

class GoatsExplorerScreen extends StatefulWidget {
  const GoatsExplorerScreen({Key? key}) : super(key: key);

  @override
  State<GoatsExplorerScreen> createState() => _GoatsExplorerScreenState();
}

class _ResetPasswordVerifyScreenState extends State<GoatsExplorerScreen> {
  late Future<List<GoatModel>> _goatsFuture;

  @override
  void initState() {
    super.initState();
    // Fire the endpoint request immediately when screen initialises
    _goatsFuture = ApiService.fetchGoats();
  }

  // Refresh handler tool pulling latest server entries
  Future<void> _refreshGoatsData() async {
    setState(() {
      _goatsFuture = ApiService.fetchGoats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Goats Inventory", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshGoatsData,
          )
        ],
      ),
      body: FutureBuilder<List<GoatModel>>(
        future: _goatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Unable to synchronize with server context.\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No livestock assets registered in database registry yet!"),
            );
          }

          final goats = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshGoatsData,
            color: Colors.green,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goats.length,
              itemBuilder: (context, index) {
                final goat = goats[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade50,
                      child: Icon(Icons.pets_rounded, color: Colors.green.shade700),
                    ),
                    title: Text(
                      goat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Tag Number: ${goat.tagNumber} • Breed: ${goat.breed}"),
                        Text("Gender: ${goat.gender}", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: goat.healthStatus?.toLowerCase() == 'healthy' ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        goat.healthStatus ?? 'Stable',
                        style: TextStyle(
                          color: goat.healthStatus?.toLowerCase() == 'healthy' ? Colors.green.shade700 : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}