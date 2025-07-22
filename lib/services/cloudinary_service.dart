import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'dmouqqpu3';
  final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'ml_default';

  Future<String> uploadImage(File imageFile) async {
    try {
      print('[Cloudinary] Starting upload for image: ${imageFile.path}');
      print('[Cloudinary] Using cloud name: $cloudName, upload preset: $uploadPreset');
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      print('[Cloudinary] Sending request to: $url');
      final response = await request.send();
      final res = await http.Response.fromStream(response);

      print('[Cloudinary] Response status: ${res.statusCode}');
      print('[Cloudinary] Response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final secureUrl = data['secure_url'] as String;
        print('[Cloudinary] Upload successful, URL: $secureUrl');
        return secureUrl;
      } else {
        print('[Cloudinary] Upload failed with status: ${res.statusCode}');
        print('[Cloudinary] Error response: ${res.body}');
        throw Exception('Cloudinary upload failed: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      print('[Cloudinary] Exception during upload: $e');
      rethrow;
    }
  }

  bool isConfigured() {
    final hasCloudName = cloudName.isNotEmpty && cloudName != 'dmouqqpu3';
    final hasUploadPreset = uploadPreset.isNotEmpty && uploadPreset != 'ml_default';
    
    print('[Cloudinary] Configuration check:');
    print('[Cloudinary] - Cloud name: $cloudName (${hasCloudName ? 'configured' : 'using default'})');
    print('[Cloudinary] - Upload preset: $uploadPreset (${hasUploadPreset ? 'configured' : 'using default'})');
    
    return hasCloudName && hasUploadPreset;
  }
} 