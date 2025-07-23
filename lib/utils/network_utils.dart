import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<bool> canReachOpenAI() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openai.com'),
        headers: {'User-Agent': 'ChatGPT-Clone/1.0'},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('[NetworkUtils] Cannot reach OpenAI API: $e');
      return false;
    }
  }

  static String getNetworkErrorMessage(String originalError) {
    if (originalError.contains('SocketException') || 
        originalError.contains('Failed host lookup') ||
        originalError.contains('No address associated with hostname')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (originalError.contains('timeout') || originalError.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (originalError.contains('401')) {
      return 'Invalid API key. Please check your OpenAI API key configuration.';
    } else if (originalError.contains('429')) {
      return 'Rate limit exceeded. Please try again in a few moments.';
    } else {
      return 'Connection error. Please check your internet connection and try again.';
    }
  }
} 