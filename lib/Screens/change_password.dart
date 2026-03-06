import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _savePassword() {
    if (_formKey.currentState!.validate()) {
      String current = _currentPasswordController.text;
      String newPass = _newPasswordController.text;

      print("Current Password: $current");
      print("New Password: $newPass");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password updated successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.orange,
            height: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.lock_reset,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 10),

              const Text(
                "Update Your Password",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              _buildPasswordField(
                controller: _currentPasswordController,
                label: "Current Password",
                obscureText: _obscureCurrent,
                toggleObscure: () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                },
              ),

              const SizedBox(height: 20),

              _buildPasswordField(
                controller: _newPasswordController,
                label: "New Password",
                obscureText: _obscureNew,
                toggleObscure: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter new password";
                  }
                  if (val.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "Confirm New Password",
                obscureText: _obscureConfirm,
                toggleObscure: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please confirm password";
                  }
                  if (val != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator ??
          (val) {
            if (val == null || val.isEmpty) {
              return "Please enter $label";
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,

        // 🔥 Label colors
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),

        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.green,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.green,
          ),
          onPressed: toggleObscure,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
      ),
    );
  }
}