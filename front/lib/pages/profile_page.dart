import 'package:flutter/material.dart';
import 'package:front/components/custom_navbar.dart';
import '../api_conf/IgnoreClas.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0; // Set to a valid initial value
  List<int> ignoredClasses = [];
  final TextEditingController _newClassController = TextEditingController();
  final TextEditingController _removeClassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchIgnoredClasses();
  }

  Future<void> _fetchIgnoredClasses() async {
    try {
      final data = await IgnoreService.viewIgnoredClasses();
      setState(() {
        ignoredClasses = List<int>.from(data['ignored_classes']);
      });
    } catch (e) {
      print('Failed to load ignored classes: $e');
    }
  }

  Future<void> _addIgnoredClasses() async {
    try {
      final newClasses = _newClassController.text.split(',').map((e) => int.parse(e.trim())).toList();
      print('New classes: $newClasses'); // Debug print
      final response = await IgnoreService.editIgnoredClasses(newClasses, []);
      print('Add response: $response'); // Debug print
      _fetchIgnoredClasses();
      _newClassController.clear();
    } catch (e) {
      print('Failed to add ignored classes: $e');
    }
  }

  Future<void> _removeIgnoredClasses() async {
    try {
      final removeClasses = _removeClassController.text.split(',').map((e) => int.parse(e.trim())).toList();
      print('Remove classes: $removeClasses'); // Debug print
      final response = await IgnoreService.editIgnoredClasses([], removeClasses);
      print('Remove response: $response'); // Debug print
      _fetchIgnoredClasses();
      _removeClassController.clear();
    } catch (e) {
      print('Failed to remove ignored classes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ignored Classes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(ignoredClasses.join(', '), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newClassController,
                    decoration: const InputDecoration(
                      labelText: 'Add Classes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addIgnoredClasses,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _removeClassController,
                    decoration: const InputDecoration(
                      labelText: 'Remove Classes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _removeIgnoredClasses,
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
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
