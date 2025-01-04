import 'package:flutter/material.dart';

class TilesComponent extends StatelessWidget {
  final List<Map<String, String>> tilesData; // Lista danych przekazywana do kafelków
  final Function(String, String) onTileClick; // Callback for tile clicks
  final double widthPercentage; // Width percentage for the tiles
  final bool displayIcons; // Flag to determine if icons should be displayed

  // Konstruktor przyjmuje dane
  const TilesComponent({super.key, required this.tilesData, required this.onTileClick, required this.widthPercentage, this.displayIcons = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Adjust the height as needed
      child: GridView.builder(
        physics: ClampingScrollPhysics(), // Enable scrolling within the grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: tilesData.length,
        itemBuilder: (context, index) {
          final tile = tilesData[index];
          return GestureDetector(
            onTap: () => onTileClick(tile['title']!, tile['subtitle']!),
            child: Container(
              width: MediaQuery.of(context).size.width * widthPercentage,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Center(
                child: displayIcons
                    ? Icon(
                        _getIconData(tile['title']!),
                        size: 48, // Adjust the icon size as needed
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tile['title']!,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            tile['subtitle']!,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String title) {
    switch (title.toLowerCase()) {
      case 'umbrella':
        return Icons.beach_access;
      case 'handbag':
        return Icons.shopping_bag;
      case 'tie':
        return Icons.accessibility_new;
      case 'suitcase':
        return Icons.work;
      case 'kite':
        return Icons.toys;
      case 'sports ball':
        return Icons.sports_soccer;
      case 'snowboard':
        return Icons.snowboarding;
      case 'baseball glove':
        return Icons.sports_baseball;
      case 'surfboard':
        return Icons.surfing;
      case 'tennis racket':
        return Icons.sports_tennis;
      case 'bottle':
        return Icons.local_drink;
      case 'wine glass':
        return Icons.wine_bar;
      case 'cup':
        return Icons.coffee;
      case 'fork':
        return Icons.restaurant;
      case 'laptop':
        return Icons.laptop;
      case 'mouse':
        return Icons.mouse;
      case 'remote':
        return Icons.tv;
      case 'keyboard':
        return Icons.keyboard;
      case 'cell phone':
        return Icons.phone_android;
      case 'clock':
        return Icons.access_time;
      case 'teddy bear':
        return Icons.toys;
      case 'hair drier':
        return Icons.bathroom;
      case 'toothbrush':
        return Icons.brush;
      default:
        return Icons.help_outline;
    }
  }
}
