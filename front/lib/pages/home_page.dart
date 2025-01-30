import 'package:flutter/material.dart';
import 'package:front/pages/profile_page.dart';
import '../components/home_tiles_component.dart'; // Import the new home tiles component
import '../components/custom_navbar.dart'; // Import the custom navigation bar
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

class _HomeContent extends StatelessWidget {
  final List<api.DetectedItem> allItems;
  final List<int> selectedClasses;

  const _HomeContent({required this.allItems, required this.selectedClasses});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> categoryClassMap = {
    'cat': 15,
    'umbrella': 25,
    'handbag': 26,
    'tie': 27,
    'suitcase': 28,
    'frisbee': 30,
    'skis': 29,
    'snowboard': 31,
    'sports ball': 32,
    'kite': 33,
    'baseball bat': 34,
    'baseball glove': 35,
    'skateboard': 36,
    'surfboard': 37,
    'tennis racket': 38,
    'bottle': 39,
    'wine glass': 40,
    'cup': 41,
    'fork': 42,
    'knife': 43,
    'spoon': 44,
    'bowl': 45,
    'banana': 46,
    'apple': 47,
    'sandwich': 48,
    'orange': 49,
    'broccoli': 50,
    'carrot': 51,
    'hot dog': 52,
    'pizza': 53,
    'donut': 54,
    'cake': 55,
    'laptop': 63,
    'mouse': 64,
    'remote': 65,
    'keyboard': 66,
    'cell phone': 67,
    'book': 73,
    'clock': 74,
    'scissors': 76,
    'teddy bear': 77,
    'hair drier': 78,
    'toothbrush': 79
    };

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
              height: 670, 
              child: HomeTilesComponent(
                tilesData: allItems.where((item) => selectedClasses.contains(item.objectClass)).toList(), // Use DetectedItem objects
                onTileClick: (title) {  
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
    final classNames =  {
    15: 'cat',
    25: 'umbrella',
    26: 'handbag',
    27: 'tie',
    28: 'suitcase',
    30: 'frisbee',
    29: 'skis',
    31: 'snowboard',
    32: 'sports ball',
    33: 'kite',
    34: 'baseball bat',
    35: 'baseball glove',
    36: 'skateboard',
    37: 'surfboard',
    38: 'tennis racket',
    39: 'bottle',
    40: 'wine glass',
    41: 'cup',
    42: 'fork',
    43: 'knife',
    44: 'spoon',
    45: 'bowl',
    46: 'banana',
    47: 'apple',
    48: 'sandwich',
    49: 'orange',
    50: 'broccoli',
    51: 'carrot',
    52: 'hot dog',
    53: 'pizza',
    54: 'donut',
    55: 'cake',
    63: 'laptop',
    64: 'mouse',
    65: 'remote',
    66: 'keyboard',
    67: 'cell phone',
    73: 'book',
    74: 'clock',
    76: 'scissors',
    77: 'teddy bear',
    78: 'hair drier',
    79: 'toothbrush'
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
