import 'package:flutter/material.dart';
import '../components/tiles_component.dart';
import 'details_page.dart'; // Import the details page
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias
import '../components/custom_navbar.dart'; // Import the custom navigation bar

class FilteredItemsPage extends StatefulWidget {
  final String title;
  final List<api.DetectedItem> items;

  const FilteredItemsPage({super.key, required this.title, required this.items});

  @override
  _FilteredItemsPageState createState() => _FilteredItemsPageState();
}

class _FilteredItemsPageState extends State<FilteredItemsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('Displaying ${widget.items.length} items for category ${widget.title}'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 500, // Adjust the height as needed
          child: TilesComponent(
            tilesData: widget.items.map((item) {
              return {
                'title': item.name,
                'subtitle': item.color,
              };
            }).toList(),
            onTileClick: (title, subtitle) {
              final clickedItem = widget.items.firstWhere((item) => item.name == title);
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
}
