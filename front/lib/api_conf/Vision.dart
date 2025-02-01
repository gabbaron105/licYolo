import 'dart:convert';
import 'package:http/http.dart' as http;

class VisionService {
  static const String baseUrl = 'http://192.168.50.182:5000';

  static Future<Map<String, dynamic>> analyzeImage(String objectName) async {
    final url = '$baseUrl/analyze/$objectName';
    print('Analyzing image for object: $objectName at: $url'); // Debug print
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Debug print
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze image');
    }
  }
}