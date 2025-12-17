import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String displayName;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.displayName,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isVerified = await _authService.checkEmailVerification();
      setState(() {
        _isLoading = false;
      });

      if (isVerified) {
        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.sendEmailVerification();
      setState(() {
        _successMessage = 'Verification email sent! Please check your inbox.';
        _isResending = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.paddingHorizontal(context),
            vertical: Responsive.spacing(context, 32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Responsive.spacing(context, 60)),
              // Email icon
              Container(
                width: Responsive.value(
                  context,
                  mobile: 120.0,
                  tablet: 140.0,
                  desktop: 160.0,
                ),
                height: Responsive.value(
                  context,
                  mobile: 120.0,
                  tablet: 140.0,
                  desktop: 160.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 1.0],
                    colors: [
                      Color(0xFFFFB6C1), // Soft pink
                      Color(0xFFDDA0DD), // Light purple
                    ],
                  ),
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: Responsive.value(
                    context,
                    mobile: 60.0,
                    tablet: 70.0,
                    desktop: 80.0,
                  ),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 40)),
              // Title
              Text(
                'Verify Your Email',
                style: GoogleFonts.jost(
                  fontSize: Responsive.fontSize(context, 28),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 16)),
              // Description
              Text(
                'We\'ve sent a verification link to',
                style: GoogleFonts.darkerGrotesque(
                  fontSize: Responsive.fontSize(context, 16),
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 8)),
              // Email address
              Text(
                widget.email,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9183DE),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 8)),
              Text(
                'Please check your email and click the verification link to activate your account.',
                style: GoogleFonts.darkerGrotesque(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 40)),
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(Responsive.spacing(context, 12)),
                  margin: EdgeInsets.only(bottom: Responsive.spacing(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      SizedBox(width: Responsive.spacing(context, 8)),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: Responsive.fontSize(context, 14),
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Success message
              if (_successMessage != null)
                Container(
                  padding: EdgeInsets.all(Responsive.spacing(context, 12)),
                  margin: EdgeInsets.only(bottom: Responsive.spacing(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                      SizedBox(width: Responsive.spacing(context, 8)),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: Responsive.fontSize(context, 14),
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Check verification button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkEmailVerification,
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
                          'I\'ve Verified My Email',
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 12)),
              // Resend email button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.spacing(context, 16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF25BDF0),
                      width: 1.5,
                    ),
                  ),
                  child: _isResending
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF25BDF0)),
                          ),
                        )
                      : Text(
                          'Resend Verification Email',
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF25BDF0),
                          ),
                        ),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 24)),
              // Info text
              Text(
                'After verifying, you can sign in to your account.',
                style: GoogleFonts.darkerGrotesque(
                  fontSize: Responsive.fontSize(context, 12),
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

