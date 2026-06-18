import 'package:flutter/material.dart';
import '../Services/api_service.dart';
import '../Models/goat_model.dart';
import '../theme_helper.dart';
import '../Widgets/hover_card.dart';


class AddGoatScreen extends StatefulWidget {
  const AddGoatScreen({Key? key}) : super(key: key);

  @override
  State<AddGoatScreen> createState() => _AddGoatScreenState();
}

class _AddGoatScreenState extends State<AddGoatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedBreed = "Boer";
  String _selectedGender = "Female";

  final List<String> _breeds = ["Boer", "Kalahari", "Savanna", "Local"];
  final List<String> _genders = ["Female", "Male"];

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );

    final double parsedWeight = double.tryParse(_weightController.text.trim()) ?? 0.0;
         final GoatModel newGoat = GoatModel(
  id: 0, // Backend will auto-generate the ID
  name: _nameController.text.trim(),
  tagNumber: _tagController.text.trim().toUpperCase(),
  breed: _selectedBreed,
  gender: _selectedGender,
  age: _ageController.text.trim(),
  weight: parsedWeight,
  isPregnant: false, // Newly registered goats default to not pregnant
  breedingDate: null,
  gestationDaysRemaining: null,
  dateAdded: DateTime.now(),
  healthStatus: "Healthy", // Default status
);
    

    final bool success = await ApiService.addGoat(newGoat);

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading spinner

    if (success) {
      Navigator.pop(context, true); // Pop screen, return success indicator
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to register new goat. Please check tag ID uniqueness or backend connectivity."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green.shade700;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text("Register New Goat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppTheme.card(context),
        foregroundColor: AppTheme.textDark(context),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.border(context), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Identity Metrics"),
                const SizedBox(height: 12),
                _buildInputField(
                  label: "Goat Name / Alias",
                  hint: "e.g., Lucky, Bella",
                  icon: Icons.badge_outlined,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: "Ear Tag Code",
                  hint: "e.g., A102, B305",
                  icon: Icons.tag_rounded,
                  controller: _tagController,
                ),
                
                const SizedBox(height: 28),
                _buildSectionHeader("Categorization"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: "Breed Selection",
                        value: _selectedBreed,
                        options: _breeds,
                        onChanged: (v) => setState(() => _selectedBreed = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: "Gender / Sex",
                        value: _selectedGender,
                        options: _genders,
                        onChanged: (v) => setState(() => _selectedGender = v!),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                _buildSectionHeader("Growth Parameters"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: "Age Description",
                        hint: "e.g., 12 months",
                        icon: Icons.calendar_today_outlined,
                        controller: _ageController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: "Live Weight (KG)",
                        hint: "e.g., 34",
                        icon: Icons.scale_outlined,
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size.fromHeight(54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Save Goat Profile",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.3),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          validator: (v) => (v == null || v.trim().isEmpty) ? "Field cannot be left blank" : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade700, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}