import 'package:flutter/material.dart';
import 'package:meal_recommender/BMIcalc.dart';
import 'package:meal_recommender/fixedDiet.dart';
import 'package:meal_recommender/notificationpage.dart';
import 'package:meal_recommender/profile_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meal_recommender/groceriesPage.dart';


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
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref().child("DRI");


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

  String? _carbsValue = '';
  String? _proteinValue = '';
  String? _fatValue = '';

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  void fetchDataFromDatabase() {
    _dbRef.child("DRI").onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        if (data['carbs'] != null) {
          setState(() {
            _carbsValue = '0/${data['carbs'].toStringAsFixed(2)} g';
          });
        }

        if (data['protein'] != null) {
          setState(() {
            _proteinValue = '0/ ${data['protein'].toStringAsFixed(2)} g';
          });
        }

        if (data['fat'] != null) {
          setState(() {
            _fatValue = ' 0/${data['fat'].toStringAsFixed(2)} g';
          });
        }
      }
    });
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
                    'images/back7.jpg'), // Replace with your image asset
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                // First Row: App Name, Profile Icon, Notification Icon
                Row(
                  children: <Widget>[
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'MealBuddy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.person),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationPage()),
                        );
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

                // Fifth Row: Calendar Date (Separate Section)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              color: Colors.white,
                              onPressed: () {
                                _selectDate(context);
                              },
                            ),
                            Text(
                              '${selectedDate.toLocal()}'.split(' ')[0],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        NutritionInfo(title: 'Carbs', value: _carbsValue ?? ''),
                        Divider(),
                        NutritionInfo(
                            title: 'Protein', value: _proteinValue ?? ''),
                        Divider(),
                        NutritionInfo(title: 'Fat', value: _fatValue ?? ''),
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
                            Text('${filledGlasses * volumePerGlass}L',
                                style: TextStyle(fontSize: 20)),
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
                                      ? Text('+',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white))
                                      : Icon(Icons.local_drink,
                                      color: index < filledGlasses
                                          ? Colors.blueAccent
                                          : Colors.redAccent),
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
                Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      MealCard(
                        title: 'Breakfast',
                        imageUrl: 'images/breakfast.png',
                        calorieRange: 'Recommended 255 - 383 kcal',
                      ),
                      Divider(),
                      MealCard(
                        title: 'Lunch',
                        imageUrl: 'images/lunchbox.png',
                        calorieRange: 'Recommended 383 - 510 kcal',
                      ),
                      Divider(),
                      MealCard(
                        title: 'Dinner',
                        imageUrl: 'images/meal.png',
                        calorieRange: 'Recommended 383 - 510 kcal',
                      ),
                      Divider(),
                      MealCard(
                        title: 'Snacks',
                        imageUrl: 'images/snacks.png',
                        calorieRange: 'Recommended 64 - 128 kcal',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.green,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Icon(Icons.home_outlined),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BMICalculatorPage() ),
                );
              },
              child: Icon(Icons.calculate_outlined),
            ),
            label: 'Health Monitor',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DietPlanPage() ),
                );
              },
              child: Icon(Icons.list_alt_outlined),
            ),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyGroceryPage() ),
                );
              },
              child: Icon(Icons.star_border),
            ),
            label: 'Premium',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DietPlanPage()),
                );
              },
              child: Icon(Icons.restaurant_menu),
            ),
            label: 'Recipes',
          ),
        ],
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
                bottom:
                2.5, // Adjust this value to control label's vertical positioning
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
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
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

  MealCard({
    required this.title,
    required this.imageUrl,
    required this.calorieRange,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}