import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../utils/image_utils.dart';

/// Widget untuk Image Picker Overlay dengan pinch gesture untuk zoom dan pan
class ImagePickerOverlay extends StatefulWidget {
  final File? selectedImageFile;
  final VoidCallback onChangeTap;
  final Function(Matrix4 transformMatrix)? onConfirm;
  final VoidCallback onCancel;

  const ImagePickerOverlay({
    super.key,
    required this.selectedImageFile,
    required this.onChangeTap,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ImagePickerOverlay> createState() => _ImagePickerOverlayState();
}

class _ImagePickerOverlayState extends State<ImagePickerOverlay> {
  late TransformationController _transformationController;
  Size? _imageSize;
  bool _isLoadingSize = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
    _loadImageSize();
  }

  void _onTransformationChanged() {
    // Listener untuk transform changes
  }

  Future<void> _loadImageSize() async {
    if (widget.selectedImageFile == null) {
      setState(() {
        _isLoadingSize = false;
      });
      return;
    }
    
    setState(() {
      _isLoadingSize = true;
    });
    
    try {
      final size = await ImageUtils.getImageSize(widget.selectedImageFile!);
      if (mounted) {
        setState(() {
          _imageSize = size;
          _isLoadingSize = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSize = false;
        });
      }
    }
  }
  
  void _applyBoundaries(double displaySize) {
    if (!mounted || _imageSize == null || _isLoadingSize) return;
    
    final Matrix4 matrix = _transformationController.value;
    final double scale = matrix.getMaxScaleOnAxis().clamp(0.5, 3.0);
    
    // Calculate display size (circular crop area)
    final double displayWidth = displaySize;
    final double displayHeight = displaySize;
    
    // Calculate actual image display dimensions based on BoxFit.cover
    final double imageAspectRatio = _imageSize!.width / _imageSize!.height;
    final double displayAspectRatio = displayWidth / displayHeight;
    
    double imageDisplayWidth;
    double imageDisplayHeight;
    
    if (imageAspectRatio > displayAspectRatio) {
      // Image is wider - fit to height
      imageDisplayHeight = displayHeight;
      imageDisplayWidth = imageDisplayHeight * imageAspectRatio;
    } else {
      // Image is taller - fit to width
      imageDisplayWidth = displayWidth;
      imageDisplayHeight = imageDisplayWidth / imageAspectRatio;
    }
    
    // Calculate maximum translation based on image bounds
    // Gambar tidak boleh keluar dari resolusi aslinya
    final double scaledImageWidth = imageDisplayWidth * scale;
    final double scaledImageHeight = imageDisplayHeight * scale;
    
    // Maximum pan distance - image should not go outside its original bounds
    final double maxPanX = (scaledImageWidth > displayWidth) 
        ? (scaledImageWidth - displayWidth) / 2 
        : 0;
    final double maxPanY = (scaledImageHeight > displayHeight) 
        ? (scaledImageHeight - displayHeight) / 2 
        : 0;
    
    // Get current translation
    final Offset translation = Offset(
      matrix.getTranslation().x,
      matrix.getTranslation().y,
    );
    
    // Clamp translation within image bounds
    Offset clampedTranslation = Offset(
      translation.dx.clamp(-maxPanX, maxPanX),
      translation.dy.clamp(-maxPanY, maxPanY),
    );
    
    // If scale <= 1.0, no panning allowed
    if (scale <= 1.0) {
      clampedTranslation = Offset.zero;
    }
    
    // Create new matrix with boundaries
    final Matrix4 newMatrix = Matrix4.identity()
      ..translate(clampedTranslation.dx, clampedTranslation.dy)
      ..scale(scale);
    
    // Update if different
    if ((matrix.getTranslation().x - clampedTranslation.dx).abs() > 0.1 ||
        (matrix.getTranslation().y - clampedTranslation.dy).abs() > 0.1 ||
        (matrix.getMaxScaleOnAxis() - scale).abs() > 0.01) {
      Future.microtask(() {
        if (mounted) {
          _transformationController.value = newMatrix;
        }
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImagePickerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset transform jika gambar berubah
    if (oldWidget.selectedImageFile != widget.selectedImageFile) {
      _transformationController.value = Matrix4.identity();
      _loadImageSize();
    }
  }

  void _handleConfirm() {
    if (widget.selectedImageFile != null) {
      // Pass transform matrix to parent
      widget.onConfirm?.call(_transformationController.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = Responsive.value(
      context,
      mobile: 280.0,
      tablet: 320.0,
      desktop: 360.0,
    );
    
    return Container(
      height: Responsive.heightPercent(context, 85),
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // Light grey background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: Responsive.spacing(context, 24)),
            // Profile picture area dengan light blue background
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Responsive.paddingHorizontal(context),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F3FF), // Light blue background
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: widget.selectedImageFile != null
                      ? ClipOval(
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: InteractiveViewer(
                              transformationController: _transformationController,
                              minScale: 0.5,
                              maxScale: 3.0,
                              boundaryMargin: EdgeInsets.zero,
                              panEnabled: true,
                              scaleEnabled: true,
                              // Improve gesture handling
                              panAxis: PanAxis.free,
                              alignment: Alignment.center,
                              onInteractionUpdate: (details) {
                                // Apply boundaries saat interaksi
                                _applyBoundaries(imageSize);
                              },
                              onInteractionEnd: (details) {
                                // Final boundary check setelah interaksi selesai
                                _applyBoundaries(imageSize);
                              },
                              child: Image.file(
                                widget.selectedImageFile!,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: imageSize / 2,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 32)),
            // Tombol Done, Cancel, dan Change
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.paddingHorizontal(context),
              ),
              child: Column(
                children: [
                  // Done button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.selectedImageFile != null ? _handleConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C89B8), // New color
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.selectedImageFile != null ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25BDF0), // New color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Change button - konsisten
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onChangeTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Change',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9183DE), // Purple konsisten
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 32)),
          ],
        ),
      ),
    );
  }
}
