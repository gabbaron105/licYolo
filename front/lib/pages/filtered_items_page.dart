import 'package:flutter/material.dart';
import '../components/tiles_component.dart';
import 'details_page.dart'; // Import the details page
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias

class FilteredItemsPage extends StatelessWidget {
  final String title;
  final List<api.DetectedItem> items;

  const FilteredItemsPage({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    print('Displaying ${items.length} items for category $title'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TilesComponent(
          tilesData: items.map((item) {
            return {
              'title': item.name,
              'subtitle': item.color,
            };
          }).toList(),
          onTileClick: (title, subtitle) {
            final clickedItem = items.firstWhere((item) => item.name == title);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  title: title,
                  subtitle: 'Confidence: ${clickedItem.confidence.toStringAsFixed(2)}',
                  itemDetails: clickedItem,
                ),
              ),
            );
          },
          widthPercentage: 0.5,
        ),
      ),
    );
  }
}
