import 'package:flutter/material.dart';
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias

class HomeTilesComponent extends StatelessWidget {
  final List<api.DetectedItem> tilesData; // Use DetectedItem class for tilesData
  final Function(String) onTileClick; // Callback for tile clicks
  final double widthPercentage; // Width percentage for the tiles

  const HomeTilesComponent({super.key, required this.tilesData, required this.onTileClick, required this.widthPercentage});

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByName(tilesData);

    return SizedBox(
      height: 300, // Adjust the height
      child: GridView.builder(
        physics: ClampingScrollPhysics(), // Enable scrolling within the grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: groupedItems.length,
        itemBuilder: (context, index) {
          final group = groupedItems[index];
          final name = group['name'];
          print('Group name: $name'); 
          return GestureDetector(
            onTap: () => onTileClick(name), 
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconData(name),
                      size: 48,
                    ),
                    SizedBox(height: 4),
                    Text(
                      name[0].toUpperCase() + name.substring(1),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
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

  List<Map<String, dynamic>> _groupItemsByName(List<api.DetectedItem> items) {
    final Map<String, List<api.DetectedItem>> groupedMap = {};
    for (var item in items) {
      if (!groupedMap.containsKey(item.name)) {
        groupedMap[item.name] = [];
      }
      groupedMap[item.name]!.add(item);
    }
    return groupedMap.entries.map((entry) => {'name': entry.key, 'items': entry.value}).toList();
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
