import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../utils/page_routes.dart';
import 'home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String displayName;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.displayName,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _authService = AuthService();

  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  // DISESUAIKAN: Karena AuthService Anda menggunakan Email Verification Link,
  // fungsi ini sekarang mengecek status verifikasi user di Firebase.
  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Menggunakan fungsi checkEmailVerification yang ada di AuthService Anda
      bool isVerified = await _authService.checkEmailVerification();

      if (!mounted) return;

      if (isVerified) {
        Navigator.of(
          context,
        ).pushReplacement(FadePageRoute(page: const HomeScreen()));
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Email belum diverifikasi. Silakan klik link di email Anda, lalu tekan tombol Verify lagi.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    try {
      await _authService.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link verifikasi baru telah dikirim!')),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB6C1), Color(0xFFDDA0DD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kami telah mengirimkan link verifikasi ke\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Info Box (Pengganti Input OTP karena AuthService Anda menggunakan Link)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Buka inbox email Anda dan klik link verifikasi yang tersedia. Setelah itu, kembali ke sini dan tekan tombol di bawah.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.yellow, fontSize: 14),
                  ),
                ],

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkVerificationStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52439A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'I Have Verified',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),

                TextButton(
                  onPressed: _isLoading ? null : _resendEmail,
                  child: const Text(
                    'Kirim Ulang Email',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
