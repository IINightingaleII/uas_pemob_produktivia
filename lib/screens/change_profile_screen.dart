import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/responsive.dart';

class ChangeProfileScreen extends StatefulWidget {
  const ChangeProfileScreen({super.key});

  @override
  State<ChangeProfileScreen> createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends State<ChangeProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load current user data
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.displayName ?? '';
      _emailController.text = currentUser.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<String?> _requestPassword() async {
    final passwordController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Password',
            style: GoogleFonts.darkerGrotesque(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Enter your password',
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: GoogleFonts.darkerGrotesque(
              fontSize: Responsive.fontSize(context, 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.darkerGrotesque(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text.isNotEmpty) {
                  Navigator.of(context).pop(passwordController.text);
                }
              },
              child: Text(
                'Confirm',
                style: GoogleFonts.darkerGrotesque(
                  color: const Color(0xFF9183DE),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDone() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = _authService.currentUser;
        final currentEmail = currentUser?.email ?? '';
        final newEmail = _emailController.text.trim();
        final emailChanged = newEmail != currentEmail;

        // Request password if email is being changed
        String? password;
        if (emailChanged) {
          password = await _requestPassword();
          if (password == null || password.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return; // User cancelled password entry
          }
        }

        // Update nama profile dan email (jika berubah)
        await _authService.updateProfile(
          displayName: _nameController.text.trim(),
          email: emailChanged ? newEmail : null,
          password: password,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Show success message
        String successMessage = 'Profile name updated successfully';
        if (emailChanged) {
          successMessage = 'Profile name updated successfully.\n\nVerification email has been sent to: ${_emailController.text.trim()}\n\nPlease check your new email inbox (and spam folder) and click the verification link. Your email will be updated after verification.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
                  // Title "Change Profile" di tengah
                  Text(
                    'Change Profile',
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
                      // Name field (Profile Name)
                      Text(
                        'Profile Name',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Phillip Haase',
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
                        ),
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Profile name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      // Email field (bisa diubah, perlu verifikasi)
                      Text(
                        'Email',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'phillip@example.com',
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
                        ),
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Invalid email format';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      // Info text about email verification
                      Text(
                        'If email is changed, you need to verify the new email',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: Responsive.fontSize(context, 12),
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 48)),
                      // Done button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleDone,
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
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
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

