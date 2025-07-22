import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageCompressionService {
  static const int _defaultMaxWidth = 1024;
  static const int _defaultMaxHeight = 1024;
  static const int _defaultQuality = 85;

  /// Compresses an image file with specified parameters
  /// Returns a compressed File
  Future<File> compressImage(
    File imageFile, {
    int maxWidth = _defaultMaxWidth,
    int maxHeight = _defaultMaxHeight,
    int quality = _defaultQuality,
  }) async {
    try {
      print('[ImageCompression] Starting compression for: ${imageFile.path}');
      
      // Read the image file
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      print('[ImageCompression] Original image size: ${originalImage.width}x${originalImage.height}');
      print('[ImageCompression] Original file size: ${bytes.length} bytes');

      // Calculate new dimensions while maintaining aspect ratio
      final newDimensions = _calculateDimensions(
        originalImage.width,
        originalImage.height,
        maxWidth,
        maxHeight,
      );

      // Resize the image
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: newDimensions['width']!,
        height: newDimensions['height']!,
        interpolation: img.Interpolation.linear,
      );

      print('[ImageCompression] Resized to: ${resizedImage.width}x${resizedImage.height}');

      // Encode as JPEG with compression
      final Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: quality),
      );

      print('[ImageCompression] Compressed file size: ${compressedBytes.length} bytes');
      print('[ImageCompression] Compression ratio: ${(bytes.length / compressedBytes.length).toStringAsFixed(2)}x');

      // Save compressed image to temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);

      print('[ImageCompression] Compressed image saved to: $tempPath');
      return compressedFile;

    } catch (e) {
      print('[ImageCompression] Error compressing image: $e');
      // Return original file if compression fails
      return imageFile;
    }
  }

  /// Calculates new dimensions while maintaining aspect ratio
  Map<String, int> _calculateDimensions(
    int originalWidth,
    int originalHeight,
    int maxWidth,
    int maxHeight,
  ) {
    double aspectRatio = originalWidth / originalHeight;
    
    int newWidth = originalWidth;
    int newHeight = originalHeight;

    // If image is larger than max dimensions, resize it
    if (originalWidth > maxWidth || originalHeight > maxHeight) {
      if (aspectRatio > 1) {
        // Landscape image
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
        
        // If height is still too large, adjust
        if (newHeight > maxHeight) {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      } else {
        // Portrait or square image
        newHeight = maxHeight;
        newWidth = (maxHeight * aspectRatio).round();
        
        // If width is still too large, adjust
        if (newWidth > maxWidth) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        }
      }
    }

    return {
      'width': newWidth,
      'height': newHeight,
    };
  }

  /// Gets file size in human readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Compresses image with smart settings based on file size
  Future<File> compressImageSmart(File imageFile) async {
    final int fileSize = await imageFile.length();
    
    // Determine compression settings based on file size
    int maxWidth, maxHeight, quality;
    
    if (fileSize > 5 * 1024 * 1024) { // > 5MB
      maxWidth = 800;
      maxHeight = 800;
      quality = 70;
    } else if (fileSize > 2 * 1024 * 1024) { // > 2MB
      maxWidth = 1024;
      maxHeight = 1024;
      quality = 80;
    } else if (fileSize > 1024 * 1024) { // > 1MB
      maxWidth = 1200;
      maxHeight = 1200;
      quality = 85;
    } else {
      // Small file, minimal compression
      maxWidth = 1600;
      maxHeight = 1600;
      quality = 90;
    }

    print('[ImageCompression] Smart compression settings:');
    print('[ImageCompression] - Original size: ${_formatFileSize(fileSize)}');
    print('[ImageCompression] - Max dimensions: ${maxWidth}x${maxHeight}');
    print('[ImageCompression] - Quality: $quality%');

    return compressImage(
      imageFile,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
  }

  /// Cleans up temporary compressed files
  Future<void> cleanupTempFiles() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      
      for (final FileSystemEntity file in files) {
        if (file is File && file.path.contains('compressed_')) {
          await file.delete();
          print('[ImageCompression] Cleaned up: ${file.path}');
        }
      }
    } catch (e) {
      print('[ImageCompression] Error cleaning up temp files: $e');
    }
  }
} 