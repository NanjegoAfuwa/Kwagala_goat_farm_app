import 'dart:io';
import 'package:flutter/material.dart';
import '../theme_helper.dart';
import 'package:image_picker/image_picker.dart';

class EditFarmScreen extends StatefulWidget {
  const EditFarmScreen({Key? key}) : super(key: key);

  @override
  State<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends State<EditFarmScreen> {
  final _formKey = GlobalKey<FormState>();

  // Existing farm info
  String existingName = "Kwagala Goat Farm";
  String existingLog =
      "Leading goat farm in Uganda, focusing on quality breeding and care.";
  String existingLocation = "Kampala, Uganda";
  int existingGoats = 25;
  String existingHealthStatus = "Healthy";

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _logController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _goatsController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();

  File? _farmImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = existingName;
    _logController.text = existingLog;
    _locationController.text = existingLocation;
    _goatsController.text = existingGoats.toString();
    _healthController.text = existingHealthStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logController.dispose();
    _locationController.dispose();
    _goatsController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _farmImage = File(image.path);
      });
    }
  }

  void _saveFarmInfo() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String log = _logController.text;
      String location = _locationController.text;
      int goats = int.tryParse(_goatsController.text) ?? 0;
      String health = _healthController.text;

      // Parameters extracted safely and ready for api_service updates
      print("Farm Name: $name");
      print("Log: $log");
      print("Location: $location");
      print("Number of Goats: $goats");
      print("Health Status: $health");
      print("Image: ${_farmImage?.path ?? 'No image changed'}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Farm profile details updated successfully!"),
          backgroundColor: const Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final Color primaryGreen = Colors.green.shade700;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.card(context),
        foregroundColor: AppTheme.textDark(context),
        elevation: 0,
        title: const Text(
          "Edit Farm Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        // FIXED: Applied the border via the shape parameter
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= Top Farm Image Hero Card =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: width * 0.13,
                              backgroundColor: const Color(0xFFF1F5F9),
                              backgroundImage: _farmImage != null
                                  ? FileImage(_farmImage!)
                                  : const AssetImage('assets/farm_placeholder.jpg') as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : existingName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _locationController.text.isNotEmpty ? _locationController.text : existingLocation,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  "FARM INFORMATION DETAILS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 20),

                // ================= Editable Form Fields =================
                _buildFieldLabel("FARM NAME"),
                _buildFormInput(
                  controller: _nameController,
                  hint: "Enter farm official branding name",
                  icon: Icons.home_work_outlined,
                  validator: (val) => (val == null || val.isEmpty) ? "Farm identity name is required" : null,
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("METRIC OR LOG PROFILE STATEMENT"),
                _buildFormInput(
                  controller: _logController,
                  hint: "Describe summary parameters or farm milestones",
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (val) => (val == null || val.isEmpty) ? "Please supply a brief summary profile statement" : null,
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("OPERATIONAL BASE LOCATION"),
                _buildFormInput(
                  controller: _locationController,
                  hint: "District, City or Sector region boundaries",
                  icon: Icons.location_on_outlined,
                  validator: (val) => (val == null || val.isEmpty) ? "Regional location parameter is required" : null,
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("TOTAL HERD COUNT RECORD"),
                _buildFormInput(
                  controller: _goatsController,
                  hint: "Active live animals in inventory registers",
                  icon: Icons.pets_outlined,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please state your overall herd capacity size";
                    if (int.tryParse(val) == null) return "Provide a valid numerical quantity digit";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("GENERAL SANITARY & HEALTH SUMMARY"),
                _buildFormInput(
                  controller: _healthController,
                  hint: "Optimal, Quarantine Active, Vet Inspection pending",
                  icon: Icons.health_and_safety_outlined,
                  validator: (val) => (val == null || val.isEmpty) ? "Specify status condition thresholds" : null,
                ),
                const SizedBox(height: 36),

                // ================= Save Changes Action =================
                ElevatedButton(
                  onPressed: _saveFarmInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Save Profiles Changes",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        labelText,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFormInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?)? validator,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final bool hasFocus = Focus.of(context).hasFocus;
          return TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: (text) => setState(() {}),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                icon,
                color: hasFocus ? Colors.orange.shade700 : const Color(0xFF64748B),
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }
}