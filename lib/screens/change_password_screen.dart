import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleDone() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Update password
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan back button dan title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.paddingHorizontal(context),
                vertical: Responsive.spacing(context, 16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back button di kiri
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: Responsive.iconSize(context, 20),
                        color: const Color(0xFF9183DE),
                      ),
                    ),
                  ),
                  // Title "Change Password" di tengah
                  Text(
                    'Change Password',
                    style: GoogleFonts.jost(
                      fontSize: Responsive.fontSize(context, 20),
                      color: const Color(0xFF9183DE),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.paddingHorizontal(context),
                  vertical: Responsive.spacing(context, 24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Old Password field
                      Text(
                        'Old Password',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: !_isOldPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: GoogleFonts.darkerGrotesque(
                            fontSize: Responsive.fontSize(context, 16),
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context, 16),
                            vertical: Responsive.spacing(context, 16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9183DE),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isOldPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _isOldPasswordVisible = !_isOldPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Old password is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      // New Password field
                      Text(
                        'New Password',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: GoogleFonts.darkerGrotesque(
                            fontSize: Responsive.fontSize(context, 16),
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context, 16),
                            vertical: Responsive.spacing(context, 16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9183DE),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      // Confirm Password field
                      Text(
                        'Confirm Password',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: GoogleFonts.darkerGrotesque(
                            fontSize: Responsive.fontSize(context, 16),
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context, 16),
                            vertical: Responsive.spacing(context, 16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9183DE),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, 48)),
                      // Done button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C89B8),
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.spacing(context, 16),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Done',
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 12)),
                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25BDF0),
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.spacing(context, 16),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

