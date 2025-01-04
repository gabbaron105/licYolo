import 'package:flutter/material.dart';
import 'package:front/pages/profile_page.dart';
import '../components/tiles_component.dart';
import '../components/custom_navbar.dart'; // Import the custom navigation bar
import 'details_page.dart'; // Import the new details page
import 'search_page.dart'; // Import the new search page
import 'filtered_items_page.dart'; // Import the filtered items page
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<api.DetectedItem> allItems = [];
  bool isLoading = true;
  List<int> selectedClasses = [39, 65]; // Default selected classes

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final items = await api.ApiService.fetchAllItems();
      setState(() {
        allItems = items;
        isLoading = false;
      });
      print('Data fetched successfully: ${items.length} items');
    } catch (e) {
      print('Failed to load data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openClassSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ClassSelectionDialog(
          selectedClasses: selectedClasses,
          onSave: (newSelectedClasses) {
            setState(() {
              selectedClasses = newSelectedClasses;
              print('Selected classes updated: $selectedClasses'); // Debug print
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeContent(allItems: allItems, selectedClasses: selectedClasses),
      const SearchPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Objects'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openClassSelectionDialog,
        child: Icon(Icons.settings),
      ),
    );
  }
}

// Widget dla zawartości strony "Home"
class _HomeContent extends StatelessWidget {
  final List<api.DetectedItem> allItems;
  final List<int> selectedClasses;

  const _HomeContent({required this.allItems, required this.selectedClasses});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> categoryClassMap = {
      'umbrella': 25,
      'handbag': 26,
      'tie': 27,
      'suitcase': 28,
      'kite': 33,
      'sports ball': 32,
      'snowboard': 31,
      'skateboard': 36,
      'baseball glove': 35,
      'surfboard': 37,
      'tennis racket': 38,
      'bottle': 39,
      'wine glass': 40,
      'cup': 41,
      'fork': 42,
      'laptop': 63,
      'mouse': 64,
      'remote': 65,
      'keyboard': 66,
      'cell phone': 67,
      'microwave': 68,
      'clock': 74,
      'teddy bear': 77,
      'hair drier': 78,
      'toothbrush': 79,
    };

    final filteredCategories = categoryClassMap.entries
        .where((entry) => selectedClasses.contains(entry.value))
        .map((entry) => {'title': entry.key, 'subtitle': 'Icon: ${entry.key.toLowerCase()}'})
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 670, // Adjust the height as needed
              child: TilesComponent(
                tilesData: filteredCategories,
                onTileClick: (title, subtitle) {
                  final classNumber = categoryClassMap[title];
                  final filteredItems = allItems.where((item) => item.objectClass == classNumber).toList();
                  print('Filtered items for $title: ${filteredItems.length} items'); // Debug print
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilteredItemsPage(
                        title: title,
                        items: filteredItems,
                      ),
                    ),
                  );
                },
                widthPercentage: 0.5,
                displayIcons: true, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassSelectionDialog extends StatefulWidget {
  final List<int> selectedClasses;
  final Function(List<int>) onSave;

  const ClassSelectionDialog({super.key, required this.selectedClasses, required this.onSave});

  @override
  _ClassSelectionDialogState createState() => _ClassSelectionDialogState();
}

class _ClassSelectionDialogState extends State<ClassSelectionDialog> {
  late List<int> _selectedClasses;

  @override
  void initState() {
    super.initState();
    _selectedClasses = List.from(widget.selectedClasses);
  }

  @override
  Widget build(BuildContext context) {
    final classNames = {
      25: 'Umbrella',
      26: 'Handbag',
      27: 'Tie',
      28: 'Suitcase',
      31: 'Snowboard',
      32: 'Sports Ball',
      33: 'Kite',
      35: 'Baseball Glove',
      36: 'Skateboard',
      37: 'Surfboard',
      38: 'Tennis Racket',
      39: 'Bottle',
      40: 'Wine Glass',
      41: 'Cup',
      42: 'Fork',
      63: 'Laptop',
      64: 'Mouse',
      65: 'Remote',
      66: 'Keyboard',
      67: 'Cell Phone',
      68: 'Microwave',
      74: 'Clock',
      77: 'Teddy Bear',
      78: 'Hair Drier',
      79: 'Toothbrush',
    };

    return AlertDialog(
      title: Text('Select Classes'),
      content: SingleChildScrollView(
        child: Column(
          children: classNames.entries.map((entry) {
            return CheckboxListTile(
              title: Text(entry.value),
              value: _selectedClasses.contains(entry.key),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedClasses.add(entry.key);
                  } else {
                    _selectedClasses.remove(entry.key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSave(_selectedClasses);
          },
          child: Text('Save Changes'),
        ),
      ],
    );
  }
}
