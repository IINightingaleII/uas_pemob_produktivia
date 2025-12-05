import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Utility class untuk image processing
class ImageUtils {
  /// Crop gambar menjadi lingkaran berdasarkan transform matrix
  static Future<File?> cropImageCircular({
    required File sourceFile,
    required Matrix4 transformMatrix,
    required double cropSize,
    required double displaySize,
  }) async {
    try {
      // Baca file gambar
      final Uint8List imageBytes = await sourceFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) return null;
      
      final int imageWidth = originalImage.width;
      final int imageHeight = originalImage.height;
      
      // Hitung display size berdasarkan BoxFit.cover (displaySize x displaySize)
      final double imageAspectRatio = imageWidth / imageHeight;
      final double displayAspectRatio = 1.0; // Circular (1:1)
      
      // Calculate how image is displayed with BoxFit.cover
      double imageDisplayWidth;
      double imageDisplayHeight;
      double imageDisplayOffsetX = 0;
      double imageDisplayOffsetY = 0;
      
      if (imageAspectRatio > displayAspectRatio) {
        // Image lebih lebar - fit ke height
        imageDisplayHeight = displaySize;
        imageDisplayWidth = imageDisplayHeight * imageAspectRatio;
        imageDisplayOffsetX = (imageDisplayWidth - displaySize) / 2;
      } else {
        // Image lebih tinggi - fit ke width
        imageDisplayWidth = displaySize;
        imageDisplayHeight = imageDisplayWidth / imageAspectRatio;
        imageDisplayOffsetY = (imageDisplayHeight - displaySize) / 2;
      }
      
      // Extract transform values dari InteractiveViewer
      final double scale = transformMatrix.getMaxScaleOnAxis();
      final Offset translation = Offset(
        transformMatrix.getTranslation().x,
        transformMatrix.getTranslation().y,
      );
      
      // Convert display coordinates to image coordinates
      final double imageToDisplayRatioX = imageWidth / imageDisplayWidth;
      final double imageToDisplayRatioY = imageHeight / imageDisplayHeight;
      
      // Calculate center point in display coordinates (center of circular crop area)
      final double displayCenterX = displaySize / 2;
      final double displayCenterY = displaySize / 2;
      
      // Transform center point: InteractiveViewer menggeser gambar, jadi kita perlu
      // menghitung posisi gambar yang terlihat di center crop area
      // Translation adalah offset dari center, jadi kita perlu inverse
      final double imageCenterInDisplayX = displayCenterX - translation.dx;
      final double imageCenterInDisplayY = displayCenterY - translation.dy;
      
      // Convert dari display coordinates ke image coordinates
      // Pertama, convert ke image display coordinates (sebelum BoxFit.cover)
      double imageCenterInImageDisplayX = imageCenterInDisplayX + imageDisplayOffsetX;
      double imageCenterInImageDisplayY = imageCenterInDisplayY + imageDisplayOffsetY;
      
      // Convert ke actual image coordinates
      final double imageCenterX = imageCenterInImageDisplayX * imageToDisplayRatioX;
      final double imageCenterY = imageCenterInImageDisplayY * imageToDisplayRatioY;
      
      // Calculate crop radius in image coordinates
      // Radius di display adalah displaySize/2, tapi karena scale, kita perlu adjust
      final double cropRadiusInDisplay = displaySize / 2;
      // Radius di image display coordinates (sebelum scale)
      final double cropRadiusInImageDisplay = cropRadiusInDisplay / scale;
      // Convert ke actual image coordinates
      final double cropRadiusInImage = cropRadiusInImageDisplay * imageToDisplayRatioX;
      
      // Calculate crop bounds
      final int cropX = (imageCenterX - cropRadiusInImage).clamp(0, imageWidth).toInt();
      final int cropY = (imageCenterY - cropRadiusInImage).clamp(0, imageHeight).toInt();
      final int cropW = (cropRadiusInImage * 2).clamp(0, imageWidth - cropX).toInt();
      final int cropH = (cropRadiusInImage * 2).clamp(0, imageHeight - cropY).toInt();
      
      // Ensure minimum size
      if (cropW < 10 || cropH < 10) {
        // Fallback: crop dari center
        final int minSize = (imageWidth < imageHeight ? imageWidth : imageHeight);
        final int cropSizeInt = (minSize * 0.9).toInt();
        final int cropX = (imageWidth - cropSizeInt) ~/ 2;
        final int cropY = (imageHeight - cropSizeInt) ~/ 2;
        
        img.Image croppedImage = img.copyCrop(
          originalImage,
          x: cropX,
          y: cropY,
          width: cropSizeInt,
          height: cropSizeInt,
        );
        
        // Resize to final size
        final int finalSize = cropSize.toInt();
        croppedImage = img.copyResize(
          croppedImage,
          width: finalSize,
          height: finalSize,
          interpolation: img.Interpolation.cubic,
        );
        
        // Convert to circular (apply mask)
        croppedImage = _makeCircular(croppedImage);
        
        // Save to temp file
        final Uint8List pngBytes = Uint8List.fromList(img.encodePng(croppedImage));
        final String tempPath = '${sourceFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
        final File croppedFile = File(tempPath);
        await croppedFile.writeAsBytes(pngBytes);
        
        return croppedFile;
      }
      
      // Crop image
      img.Image croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );
      
      // Resize to final size
      final int finalSize = cropSize.toInt();
      croppedImage = img.copyResize(
        croppedImage,
        width: finalSize,
        height: finalSize,
        interpolation: img.Interpolation.cubic,
      );
      
      // Convert to circular (apply mask)
      croppedImage = _makeCircular(croppedImage);
      
      // Save to temp file
      final Uint8List pngBytes = Uint8List.fromList(img.encodePng(croppedImage));
      final String tempPath = '${sourceFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final File croppedFile = File(tempPath);
      await croppedFile.writeAsBytes(pngBytes);
      
      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }
  
  /// Make image circular by applying alpha mask
  static img.Image _makeCircular(img.Image image) {
    final int size = image.width; // Assuming square image
    // Create image with alpha channel support
    final img.Image circular = img.Image(width: size, height: size, numChannels: 4);
    
    final int centerX = size ~/ 2;
    final int centerY = size ~/ 2;
    final int radius = size ~/ 2;
    
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final int dx = x - centerX;
        final int dy = y - centerY;
        final int distanceSquared = dx * dx + dy * dy;
        
        if (distanceSquared <= radius * radius) {
          // Keep original pixel with alpha
          final originalPixel = image.getPixel(x, y);
          final r = originalPixel.r.toInt();
          final g = originalPixel.g.toInt();
          final b = originalPixel.b.toInt();
          // Check if image has alpha channel by checking numChannels
          final int a = image.numChannels >= 4 ? originalPixel.a.toInt() : 255;
          circular.setPixelRgba(x, y, r, g, b, a);
        } else {
          // Make transparent (set alpha to 0)
          circular.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }
    
    return circular;
  }
  
  /// Get image dimensions
  static Future<Size?> getImageSize(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return null;
    }
  }
}
