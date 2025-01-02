import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  // Fetch all items and parse to DetectedItem objects
  static Future<List<DetectedItem>> fetchAllItems() async {
    final response = await http.get(Uri.parse('$baseUrl/get-all'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return parseDetectedItems(jsonData);
    } else {
      throw Exception('Failed to load items');
    }
  }

  // Fetch items by class name and parse to DetectedItem objects
  static Future<List<DetectedItem>> fetchItemsByClass(String className) async {
    final response = await http.get(Uri.parse('$baseUrl/get-by-class/$className'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return parseDetectedItems(jsonData);
    } else {
      throw Exception('Failed to load items by class');
    }
  }

  // Fetch frame image by frame number
  static Future<String> fetchFrameImage(int frameNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/get-frame/$frameNumber'));
    if (response.statusCode == 200) {
      return '$baseUrl/get-frame/$frameNumber';
    } else {
      throw Exception('Failed to load frame image');
    }
  }

  // Helper function to parse JSON into DetectedItem objects
  static List<DetectedItem> parseDetectedItems(Map<String, dynamic> json) {
    return json.entries.map((entry) {
      return DetectedItem.fromJson(entry.key, entry.value);
    }).toList();
  }
}

class DetectedItem {
  final String id;
  final Bbox bbox;
  final Center center;
  final int objectClass;
  final String color;
  final double confidence;
  final int frame;
  final String name;
  final DateTime timestamp;

  DetectedItem({
    required this.id,
    required this.bbox,
    required this.center,
    required this.objectClass,
    required this.color,
    required this.confidence,
    required this.frame,
    required this.name,
    required this.timestamp,
  });

  factory DetectedItem.fromJson(String id, Map<String, dynamic> json) {
    return DetectedItem(
      id: id,
      bbox: Bbox.fromJson(json['bbox']),
      center: Center.fromJson(json['center']),
      objectClass: json['class'],
      color: json['color'],
      confidence: json['confidence'],
      frame: json['frame'],
      name: json['name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Bbox {
  final int xmin;
  final int xmax;
  final int ymin;
  final int ymax;

  Bbox({
    required this.xmin,
    required this.xmax,
    required this.ymin,
    required this.ymax,
  });

  factory Bbox.fromJson(Map<String, dynamic> json) {
    return Bbox(
      xmin: json['xmin'],
      xmax: json['xmax'],
      ymin: json['ymin'],
      ymax: json['ymax'],
    );
  }
}

class Center {
  final int x;
  final int y;

  Center({
    required this.x,
    required this.y,
  });

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
      x: json['x'],
      y: json['y'],
    );
  }
}
