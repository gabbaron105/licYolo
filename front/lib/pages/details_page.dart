import 'package:flutter/material.dart';
import '../components/custom_navbar.dart'; // Import the custom navigation bar
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias

class DetailsPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final api.DetectedItem itemDetails;

  const DetailsPage({super.key, required this.title, required this.subtitle, required this.itemDetails});

  Future<String> _fetchFrameImageUrl(int frameNumber) async {
    return '${api.ApiService.baseUrl}/get-frame/$frameNumber';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title at the top
            Center(
              child: Text(
                title,
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
            // Image with bounding box inside a border
            FutureBuilder<String>(
              future: _fetchFrameImageUrl(itemDetails.frame),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load image'));
                } else {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1), // 10% margin
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      // Adjusting the height to extend as per your requirement
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
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation if needed
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

    // Calculate the scaling factors based on the actual dimensions of the displayed image
    final double scaleX = size.width / 640; // Assuming original image width is 640
    final double scaleY = size.height / 360; // Assuming original image height is 360

    // Scale the bounding box coordinates
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
