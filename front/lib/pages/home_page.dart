import 'package:flutter/material.dart';
import '../components/tiles_component.dart';
import '../components/custom_navbar.dart'; // Import the custom navigation bar
import 'details_page.dart'; // Import the new details page
import 'search_page.dart'; // Import the new search page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    _HomeContent(), // Strona z kafelkami jako komponenty
    SearchPage(), // Strona z wyszukiwaniem
    Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Objects'),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
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

// Widget dla zawartości strony "Home"
class _HomeContent extends StatelessWidget {
  final List<Map<String, String>> allItems = [
    {'title': 'Item 1', 'subtitle': 'All Data'},
    {'title': 'Item 2', 'subtitle': 'All Data'},
    {'title': 'Item 3', 'subtitle': 'All Data'},
    {'title': 'Item 4', 'subtitle': 'All Data'},
    {'title': 'Item 5', 'subtitle': 'All Data'},
    {'title': 'Item 6', 'subtitle': 'All Data'},
  ];

  final List<Map<String, String>> recentItems = [
    {'title': 'Recent 1', 'subtitle': 'Recently Viewed'},
    {'title': 'Recent 2', 'subtitle': 'Recently Viewed'},
    {'title': 'Recent 3', 'subtitle': 'Recently Viewed'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wszystkie przedmioty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TilesComponent(
              tilesData: allItems,
              onTileClick: (title, subtitle) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(title: title, subtitle: subtitle),
                  ),
                );
              },
            ), // Wszystkie przedmioty
            SizedBox(height: 20),
            Text(
              'Ostatnio przeglądane',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TilesComponent(
              tilesData: recentItems,
              onTileClick: (title, subtitle) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(title: title, subtitle: subtitle),
                  ),
                );
              },
            ), // Ostatnio przeglądane
          ],
        ),
      ),
    );
  }
}
