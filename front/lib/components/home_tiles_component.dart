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
    final switcher = {
      'cat' : Icons.pets,
      'dog': Icons.pets,
      'umbrella': Icons.beach_access,
      'handbag': Icons.shopping_bag,
      'tie': Icons.accessibility_new,
      'suitcase': Icons.work,
      'kite': Icons.toys,
      'sports ball': Icons.sports_soccer,
      'snowboard': Icons.snowboarding,
      'baseball bat': Icons.sports_cricket,
      'baseball glove': Icons.sports_baseball,
      'skateboard': Icons.directions_run,
      'surfboard': Icons.surfing,
      'tennis racket': Icons.sports_tennis,
      'bottle': Icons.local_drink,
      'wine glass': Icons.wine_bar,
      'cup': Icons.local_cafe,
      'fork': Icons.restaurant,
      'knife': Icons.restaurant_menu,
      'spoon': Icons.restaurant,
      'bowl': Icons.ramen_dining,
      'banana': Icons.eco,
      'apple': Icons.apple,
      'sandwich': Icons.lunch_dining,
      'orange': Icons.eco,
      'broccoli': Icons.grass,
      'carrot': Icons.emoji_food_beverage,
      'hot dog': Icons.fastfood,
      'pizza': Icons.local_pizza,
      'donut': Icons.donut_large,
      'cake': Icons.cake,
      'laptop': Icons.laptop,
      'mouse': Icons.mouse,
      'remote': Icons.tv,
      'keyboard': Icons.keyboard,
      'cell phone': Icons.phone_android,
      'book': Icons.menu_book,
      'clock': Icons.access_time,
      'scissors': Icons.cut,
      'teddy bear': Icons.child_care,
      'hair drier': Icons.bathroom,
      'toothbrush': Icons.brush
    };
    return switcher[title.toLowerCase()] ?? Icons.help_outline;
  }
}
