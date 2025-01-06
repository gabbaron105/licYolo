import 'package:flutter/material.dart';
import '../components/custom_navbar.dart'; // Import the custom navigation bar
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias

class DetailsPage extends StatefulWidget {
  final String itemId;

  const DetailsPage({super.key, required this.itemId});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}


class _DetailsPageState extends State<DetailsPage> {
  late Future<api.DetectedItem> itemDetails;
  int _currentIndex = 0; // Define _currentIndex

  @override
  void initState() {
    super.initState();
    itemDetails = fetchItemDetails(widget.itemId);
  }

  Future<api.DetectedItem> fetchItemDetails(String itemId) async {
    try {
      // Pass the full item ID to the backend
      print('Fetching details for item ID: $itemId'); // Debug print
      final item = await api.ApiService.fetchItemDetails(itemId);
      return item;
    } catch (e) {
      print('Failed to fetch item details: $e'); // Debug print
      throw Exception('Failed to fetch item details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left_rounded, size: 32),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Details'),
      ),
      body: FutureBuilder<api.DetectedItem>(
        future: itemDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Debug print
            return Center(child: Text('Failed to load item details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Item not found'));
          } else {
            final itemDetails = snapshot.data!;
            print('Item details: $itemDetails'); // Debug print
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title at the top
                  Center(
                    child: Text(
                      itemDetails.name,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Information card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confidence: ${itemDetails.confidence}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              Text(
                                'Color: ${itemDetails.color}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getColorFromHex(itemDetails.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Timestamp: ${itemDetails.timestamp}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Frame: ${itemDetails.frame}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  FutureBuilder<String>(
                    future: _fetchFrameImageUrl(itemDetails.frame),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print('Error loading image: ${snapshot.error}');
                        return Center(child: Text('Failed to load image'));
                      } else {
                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.1), 
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                  
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                  ),
                                  CustomPaint(
                                    painter: BoundingBoxPainter(
                                      bbox: itemDetails.bbox,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.black;
  }

  Future<String> _fetchFrameImageUrl(int frameNumber) async {
    final url = '${api.ApiService.baseUrl}/get-frame/$frameNumber';
    print('Fetching frame image URL: $url'); // Debug print
    return url;
  }
}

class BoundingBoxPainter extends CustomPainter {
  final api.Bbox bbox;

  BoundingBoxPainter({required this.bbox});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double scaleX = size.width / 640; 
    final double scaleY = size.height / 360;  

    final double xmin = bbox.xmin.toDouble() * scaleX;
    final double ymin = bbox.ymin.toDouble() * scaleY;
    final double xmax = bbox.xmax.toDouble() * scaleX;
    final double ymax = bbox.ymax.toDouble() * scaleY;

    final bboxRect = Rect.fromLTRB(xmin, ymin, xmax, ymax);

    canvas.drawRect(bboxRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
