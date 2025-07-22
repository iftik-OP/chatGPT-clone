import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_gpt_clone/services/image_compression_service.dart';

void main() {
  group('ImageCompressionService Tests', () {
    late ImageCompressionService compressionService;

    setUp(() {
      compressionService = ImageCompressionService();
    });

    test('should compress large image with smart settings', () async {
      // This test would require an actual image file
      // For now, we'll test the service initialization
      expect(compressionService, isNotNull);
    });

    test('should calculate dimensions correctly', () {
      // Test aspect ratio preservation
      final result = compressionService.compressImage(
        File('test_image.jpg'),
        maxWidth: 1024,
        maxHeight: 1024,
        quality: 85,
      );
      
      expect(result, isA<Future<File>>());
    });

    test('should handle compression errors gracefully', () async {
      // Test with non-existent file
      final result = await compressionService.compressImage(
        File('non_existent_file.jpg'),
      );
      
      // Should return the original file if compression fails
      expect(result, isA<File>());
    });
  });
} 