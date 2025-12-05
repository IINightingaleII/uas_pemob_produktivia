import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/home_drawer.dart';
import '../widgets/image_picker_overlay.dart';
import '../screens/login_screen.dart';
import '../screens/change_profile_screen.dart';
import '../screens/change_password_screen.dart';
import '../utils/responsive.dart';
import '../utils/image_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _imagePicker = ImagePicker();
  final AuthService _authService = AuthService();
  File? _profileImageFile;
  File? _selectedImageFile; // Untuk preview di overlay
  String? _profileImageUrl; // URL dari Firestore

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData != null && userData.profileImageUrl != null) {
        setState(() {
          _profileImageUrl = userData.profileImageUrl;
        });
      }
    } catch (e) {
      // Ignore error, akan menggunakan default icon
    }
  }

  ImageProvider? _getProfileImageProvider() {
    // Prioritas: file lokal (baru diupload) > URL dari Firestore
    if (_profileImageFile != null) {
      return FileImage(_profileImageFile!);
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
        // Notify overlay bahwa gambar berubah
        _notifyOverlayImageChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
        // Notify overlay bahwa gambar berubah
        _notifyOverlayImageChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  StateSetter? _overlayStateSetter;
  
  void _notifyOverlayImageChanged() {
    _overlayStateSetter?.call(() {});
  }

  Future<void> _confirmImageSelection(Matrix4 transformMatrix) async {
    if (_selectedImageFile == null) return;
    
    _overlayStateSetter = null; // Reset StateSetter
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Get display size for crop (ukuran circular crop area di overlay)
      final double displaySize = Responsive.value(
        context,
        mobile: 280.0,
        tablet: 320.0,
        desktop: 360.0,
      );
      
      // Get final crop size (2x untuk kualitas lebih baik)
      final double cropSize = displaySize * 2;
      
      // Crop image dengan transform
      final File? croppedFile = await ImageUtils.cropImageCircular(
        sourceFile: _selectedImageFile!,
        transformMatrix: transformMatrix,
        cropSize: cropSize,
        displaySize: displaySize,
      );
      
      if (!mounted) return;
      
      Navigator.pop(context); // Close loading dialog
      
      if (croppedFile != null) {
        // Upload to Firebase Storage
        try {
          final downloadUrl = await _authService.uploadProfileImage(croppedFile);
          
          setState(() {
            _profileImageFile = croppedFile; // Tampilkan file lokal dulu
            _profileImageUrl = downloadUrl; // Simpan URL untuk reload nanti
            _selectedImageFile = null;
          });
          
          // Reload profile image dari Firestore untuk memastikan konsistensi
          await _loadProfileImage();
          
          // Close overlay
          Navigator.pop(context);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          Navigator.pop(context); // Close overlay
          if (mounted) {
            String errorMessage = 'Error uploading image: ${e.toString()}';
            // Tambahkan instruksi jika error terkait Storage
            if (e.toString().contains('Storage bucket') || e.toString().contains('object-not-found')) {
              errorMessage += '\n\nPlease enable Firebase Storage in Firebase Console:\n1. Go to Storage section\n2. Click "Get Started"\n3. Set Storage Rules';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        // Close overlay
        Navigator.pop(context);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close overlay
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChangeImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library, color: Color(0xFF9183DE)),
                    title: const Text('Choose from Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt, color: Color(0xFF9183DE)),
                    title: const Text('Take Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePickerOverlay() {
    // Set initial image untuk preview jika belum ada
    if (_selectedImageFile == null && _profileImageFile != null) {
      setState(() {
        _selectedImageFile = _profileImageFile;
      });
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext bottomSheetContext) {
        return GestureDetector(
          onTap: () {
            // Tap di luar overlay akan dismiss (cancel)
            if (mounted) {
              _overlayStateSetter = null;
              setState(() {
                _selectedImageFile = null;
              });
              Navigator.pop(context);
            }
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: GestureDetector(
              onTap: () {
                // Prevent tap from propagating (tap di dalam overlay)
              },
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setOverlayState) {
                  // Simpan StateSetter untuk rebuild overlay ketika gambar berubah
                  _overlayStateSetter = setOverlayState;
                  
                  return ImagePickerOverlay(
                    key: ValueKey(_selectedImageFile?.path ?? 'overlay'),
                    selectedImageFile: _selectedImageFile ?? _profileImageFile,
                    onChangeTap: _showChangeImageOptions,
                    onConfirm: _confirmImageSelection,
                    onCancel: () {
                      if (mounted) {
                        _overlayStateSetter = null; // Reset StateSetter
                        setState(() {
                          _selectedImageFile = null;
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _authService.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final currentUser = _authService.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: HomeDrawer(currentUser: currentUser),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan hamburger menu dan title Profile
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.paddingHorizontal(context),
                vertical: Responsive.spacing(context, 12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Nav icon (hamburger menu) di kiri
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      child: Image.asset(
                        'assets/icons2/Nav.png',
                        width: Responsive.iconSize(context, 24),
                        height: Responsive.iconSize(context, 24),
                      ),
                    ),
                  ),
                  // Title "Edit Profile" di tengah
                  Text(
                    'Edit Profile',
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
                child: Column(
                  children: [
                    SizedBox(height: Responsive.spacing(context, 40)),
                    // Profile Picture dengan camera icon overlay
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: Responsive.value(
                            context,
                            mobile: 70.0,
                            tablet: 85.0,
                            desktop: 100.0,
                          ),
                          backgroundColor: const Color(0xFF9183DE).withOpacity(0.2),
                          backgroundImage: _getProfileImageProvider(),
                          child: _getProfileImageProvider() == null
                              ? Icon(
                                  Icons.person,
                                  size: Responsive.value(
                                    context,
                                    mobile: 70.0,
                                    tablet: 85.0,
                                    desktop: 100.0,
                                  ),
                                  color: const Color(0xFF9183DE),
                                )
                              : null,
                        ),
                        // Camera icon button di pojok kanan bawah dengan gradasi seperti date calendar
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerOverlay,
                            child: Container(
                              width: Responsive.value(
                                context,
                                mobile: 56.0,
                                tablet: 64.0,
                                desktop: 72.0,
                              ),
                              height: Responsive.value(
                                context,
                                mobile: 56.0,
                                tablet: 64.0,
                                desktop: 72.0,
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: Responsive.value(
                                  context,
                                  mobile: 24.0,
                                  tablet: 28.0,
                                  desktop: 32.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 24)),
                    // Name
                    Text(
                      currentUser?.displayName ?? 'Produktivia',
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: Responsive.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9183DE),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 8)),
                    // Email
                    Text(
                      currentUser?.email ?? 'phillip@example.com',
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: Responsive.fontSize(context, 16),
                        color: const Color(0xFF9183DE).withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 48)),
                    // Menu Options
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.value(
                          context,
                          mobile: 24.0,
                          tablet: Responsive.widthPercent(context, 15),
                          desktop: Responsive.widthPercent(context, 20),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildMenuOption(
                            icon: 'assets/icons2/change_profile.png',
                            title: 'Change Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChangeProfileScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: Responsive.spacing(context, 16)),
                          _buildMenuOption(
                            icon: 'assets/icons2/change_password.png',
                            title: 'Change Password',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: Responsive.spacing(context, 16)),
                          _buildMenuOption(
                            icon: 'assets/icons2/Logout.png',
                            title: 'Logout',
                            isLogout: true,
                            onTap: _handleLogout,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 32)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(context, 20),
          vertical: Responsive.spacing(context, 18),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLogout ? Colors.red.withOpacity(0.3) : const Color(0xFF9183DE).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon dengan background circle
            Container(
              width: Responsive.value(
                context,
                mobile: 48.0,
                tablet: 52.0,
                desktop: 56.0,
              ),
              height: Responsive.value(
                context,
                mobile: 48.0,
                tablet: 52.0,
                desktop: 56.0,
              ),
              decoration: BoxDecoration(
                color: isLogout 
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF9183DE).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: Responsive.iconSize(context, 24),
                  height: Responsive.iconSize(context, 24),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 16)),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: Responsive.iconSize(context, 16),
              color: isLogout ? Colors.red : const Color(0xFF9183DE),
            ),
          ],
        ),
      ),
    );
  }
}

