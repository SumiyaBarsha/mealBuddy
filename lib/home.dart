import 'package:flutter/material.dart';
import 'package:meal_recommender/profile_page.dart';

import 'dritool.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double eatenValue = 0.0; // Initialize with actual values from DRI Tool
  double kcalLeftValue = 0.0; // Initialize with actual values from DRI Tool
  double burnedValue = 0.0; // Initialize with actual values from DRI Tool


  DateTime selectedDate = DateTime.now();


  int filledGlasses = 0;
  static const int totalGlasses = 8;
  static const double volumePerGlass = 0.25;

  int _currentIndex = 0;

  final List<Widget> _pages = [
  /*  NutritionPage(),
    RecipesPage(),
    ProfilePage(),
    SettingsPage(),*/
  ];

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

        child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'images/back2.jpeg'), // Replace with your image asset
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              // First Row: App Name, Profile Icon, Notification Icon
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'MealBuddy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.person),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    color: Colors.white,
                    onPressed: () {
                      // Handle notification button tap
                    },
                  ),
                ],
              ),

              // Second Row: Eaten, Kcal Left, Burned (calculated from DRI Tool)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleValue(
                    label: 'Eaten',
                    value: eatenValue,
                  ),
                  CircleValue(
                    label: 'Kcal Left',
                    value: kcalLeftValue,
                  ),
                  CircleValue(
                    label: 'Burned',
                    value: burnedValue,
                  ),
                ],
              ),

              // Fourth Row: Card for Carbs, Protein, Fat (Eaten and Left)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      NutritionInfo(title: 'Carbs', value: '0 / 160g'),
                      Divider(),
                      NutritionInfo(title: 'Protein', value: '0 / 64g'),
                      Divider(),
                      NutritionInfo(title: 'Fat', value: '0 / 43g'),
                    ],
                  ),
                ),
              ),

              // Fifth Row: Calendar Date (Separate Section)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Selected Date:',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${selectedDate.toLocal()}'.split(' ')[0],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            color: Colors.black26,
                            onPressed: () {
                              _selectDate(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Sixth Row: Water Section (Glasses of Water)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Water', style: TextStyle(fontSize: 20)),
                          Text('${filledGlasses * volumePerGlass}L', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        children: List.generate(totalGlasses, (index) {
                          return GestureDetector(
                            onTap: () {
                              if (index == filledGlasses) {
                                setState(() {
                                  filledGlasses++;
                                });
                              }
                            },
                            child: Container(
                              width: 30,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: index == filledGlasses
                                    ? Text('+', style: TextStyle(fontSize: 20, color: Colors.white))
                                    : Icon(Icons.local_drink, color: index < filledGlasses ? Colors.blue : Colors.blue[100]),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Seventh Row: Meal Cards (Breakfast, Lunch, Snacks, Dinner with Kcal calculation)
              MealCard(
                title: 'Breakfast',
                imageUrl: 'images/breakfast.png',
                calorieRange: 'Recommended 255 - 383 kcal',
              ),
              SizedBox(height: 10),
              MealCard(
                title: 'Lunch',
                imageUrl: 'images/lunchbox.png',
                calorieRange: 'Recommended 383 - 510 kcal',
              ),
              SizedBox(height: 10),
              MealCard(
                title: 'Dinner',
                imageUrl: 'images/meal.png',
                calorieRange: 'Recommended 383 - 510 kcal',
              ),
              SizedBox(height: 10),
              MealCard(
                title: 'Snacks',
                imageUrl: 'images/snacks.png',
                calorieRange: 'Recommended 64 - 128 kcal',
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class CircleValue extends StatelessWidget {
  final String label;
  final double value;

  CircleValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 100,
          height: 130, // Increased height to accommodate the label
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent, // Customize the circle's color
                    border: Border.all(
                      color: Colors.white30, // Make the border transparent
                      width: 2.0, // Set the border width to 0 to remove it
                    ),
                  ),
                  child: Center(
                    child: Text(
                      value.toStringAsFixed(2), // Format value as needed
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2.5, // Adjust this value to control label's vertical positioning
                left: 0,
                right: 0,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NutritionInfo extends StatelessWidget {
  final String title;
  final String value;

  NutritionInfo({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

class MealCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String calorieRange;

  MealCard({required this.title, required this.imageUrl, required this.calorieRange});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Image.asset(
          imageUrl, // replace with your image paths
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          calorieRange,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Icon(Icons.add, color: Colors.grey),
      ),
    );
  }
}
