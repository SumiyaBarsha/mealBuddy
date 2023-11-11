import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dietary Preferences',
      theme: ThemeData(primarySwatch: Colors.green),
      home: DietaryPreferencesPage(),
    );
  }
}

class DietaryPreferencesPage extends StatefulWidget {
  @override
  _DietaryPreferencesPageState createState() => _DietaryPreferencesPageState();
}

class _DietaryPreferencesPageState extends State<DietaryPreferencesPage> {
  Map<String, bool> preferences = {
    'Vegan': false,
    'Vegetarian': false,
    'Pescetarian': false,
    'Allergic to nuts': false,
    'Allergic to fish': false,
    'Allergic to shellfish': false,
    'Allergic to egg': false,
    'Allergic to milk': false,
    'Lactose intolerant': false,
    'Gluten intolerant': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DIETARY NEEDS & PREFERENCES', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('FOOD PREFERENCES', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...preferences.keys.take(3).map((key) => _preferenceTile(key))
                ],
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('ALLERGIES', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...preferences.keys.skip(3).map((key) => _preferenceTile(key))
                ],
              ),
            ),
            SizedBox(height: 20),  // Added this to replace the Spacer
            ElevatedButton(
              onPressed: () {
                // Handle saving preferences here
              },
              child: Text('SAVE'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green)
            ),
            SizedBox(height: 20),  // Added some bottom padding for better visual
          ],
        ),
      ),
    );
  }

  Widget _preferenceTile(String key) {
    return ListTile(
      title: Text(key),
      trailing: Switch(
        value: preferences[key]!,
        onChanged: (bool value) {
          setState(() {
            preferences[key] = value;
          });
        },
      ),
    );
  }
}
