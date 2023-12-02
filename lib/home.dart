import 'package:flutter/material.dart';
import 'package:meal_recommender/BMIcalc.dart';
import 'package:meal_recommender/notificationpage.dart';
import 'package:meal_recommender/profile_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meal_recommender/groceriesPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_recommender/recipes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mealSuggestion.dart';
import 'globals.dart';
import 'AdminRecipePage.dart';
import 'DRIcalc.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Method to sign in a user using email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      // Handle exceptions, e.g., wrong password
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('isAdmin');
    return _firebaseAuth.signOut();
  }

// Method to check if the currently signed-in user is an admin
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
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref().child("DRI");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  void initState() {
    super.initState();
    fetchUserData();
  }
  double? weight, height, age;
  double eatenValue = 0.0; // Initialize with actual values from DRI Tool
// Initialize with actual values from DRI Tool
  double burnedValue = 0.0; // Initialize with actual values from DRI Tool


  void fetchUserData() async {

    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;

      DatabaseReference userRef = _database.reference().child('Users').child(userId);

      try {

        DatabaseEvent event = await userRef.once();
        DataSnapshot dataSnapshot = event.snapshot;
        // You can access the data using dataSnapshot.value
        if (dataSnapshot.value != null) {
          Map<dynamic, dynamic> userData = dataSnapshot.value as Map<dynamic, dynamic>;
          // Parse the values
          double? weight = _parseDouble(userData['weight']);
          double? height = _parseDouble(userData['height']);
          double? age = _parseDouble(userData['age']);
          String? gender=userData['gender'];
          // Calculate kcalTotalValue and update state
          setState(() {
            kcalTotalValue = _calculateTotalKcalValue(weight, height, age, gender);
            totalProtein = weight*.9;
            print(totalProtein);
          });
          print(kcalTotalValue);
        } else {
          print("User data not found.");
        }
      } catch (error) {
        print("Error fetching user data: $error");
      }
    } else {
      print("No user is signed in.");
    }
  }


  DateTime selectedDate = DateTime.now();


  static const int totalGlasses = 8;
  static const double volumePerGlass = 0.25;

  int _currentIndex = 0;




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
  double _parseDouble(String? value) {
    return value != null ? double.tryParse(value) ?? 0.0 : 0.0;
  }

  double _calculateTotalKcalValue(double? weight, double? height, double? age,String? gender) {
    if (gender == 'male') {
      return 66.5 + (13.8 * (weight ?? 0)) + (5 * (height ?? 0)) - (6.8 * (age ?? 0));
    }
    else{
      return 655.1 + (9.6 * (weight ?? 0)) + (1.9 * (height ?? 0)) - (4.7 * (age ?? 0));
    }
  }
  void refreshHomePage() async {
    // Add logic to refresh the data
    // For example:
    // fetchDataFromDatabase();
    // You might also need to call setState to update the UI
    print("Button Pressed");
    print(kcalEatenValue);



    Map<String, dynamic> savedData = await PreferencesService().loadData();
    mealtype = savedData['mealType'];
    eatenBreakfast = savedData['eatenBreakfast'];
    eatenLunch=savedData['eatenLunch'];
    eatenDinner=savedData['eatenDinner'];
    eatenCarbs= savedData['eatenCarbs'];
    eatenFat= savedData['eatenFat'];
    eatenProtein= savedData['eatenProtein'];
    kcalEatenValue= savedData['kcalEatenValue'];
    kcalLeftValue=savedData['kcalLeftValue'];
    filledGlasses=savedData['filledGlasses'];


    setState(() {
      // Update state variables if necessary
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
                              builder: (context) => notificationpage()),
                        );
                      },
                    ),

                    isAdmin == false
                        ? IconButton(
                      icon: Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: () {
                        // Call the method to refresh the page
                        refreshHomePage();
                      },
                    )
                        : Container(), // Empty container if isAdmin is true
                  ],
                ),

                // Second Row: Eaten, Kcal Left, Burned (calculated from DRI Tool)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircleValue(
                      label: 'Kcal Left',
                      value: kcalTotalValue-kcalEatenValue,
                    ),
                    CircleValue(
                      label: 'Total Kcal',
                      value: kcalTotalValue,
                    ),
                    CircleValue(
                      label: 'Kcal Eaten',
                      value: kcalEatenValue,
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
                        NutritionInfo(
                          title: 'Carbs',
                          value1: eatenCarbs, // Replace with actual double value
                          value2: kcalTotalValue/7, // Replace with actual double value
                        ),
                        Divider(),
                        NutritionInfo(
                          title: 'Protein',
                          value1: eatenProtein, // Replace with actual double value
                          value2: totalProtein, // Replace with actual double value
                        ),
                        Divider(),
                        NutritionInfo(
                          title: 'Fat',
                          value1: eatenFat, // Replace with actual double value
                          value2: kcalTotalValue/30, // Replace with actual double value
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
                                    PreferencesService().saveData(
                                      mealType: mealtype,
                                      eatenBreakfast: eatenBreakfast,
                                      eatenDinner: eatenDinner,
                                      eatenLunch: eatenLunch,
                                      eatenCarbs: eatenCarbs,
                                      eatenFat: eatenFat,
                                      eatenProtein: eatenProtein,
                                      kcalEatenValue: kcalEatenValue,
                                      kcalLeftValue: kcalLeftValue,
                                      isAdmin: isAdmin,
                                      filledGlasses: filledGlasses,
                                    );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Recommended For You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Seventh Row: Meal Cards (Breakfast, Lunch, Snacks, Dinner with Kcal calculation)
                Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          // Action when Breakfast card is tapped
                          mealtype = 'breakfast';
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MealSuggestionPage()),
                          );
                        },
                        child: MealCard(
                          title: 'Breakfast',
                          imageUrl: 'images/breakfast.png',
                          calorieRange: eatenBreakfast,
                        ),
                      ),
                      Divider(),
                      InkWell(
                        onTap: () {
                          // Action when Lunch card is tapped
                          print('Lunch tapped');
                          mealtype = 'lunch';
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MealSuggestionPage()),
                          );
                        },
                        child: MealCard(
                          title: 'Lunch',
                          imageUrl: 'images/lunchbox.png',
                          calorieRange: eatenLunch,
                        ),
                      ),
                      Divider(),
                      InkWell(
                        onTap: () {
                          // Action when Dinner card is tapped
                          print('Dinner tapped');
                          mealtype = 'dinner';
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MealSuggestionPage()),
                          );
                        },
                        child: MealCard(
                          title: 'Dinner',
                          imageUrl: 'images/meal.png',
                          calorieRange: eatenDinner,
                        ),
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
              onTap: () => _showHealthOptions(context),
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
                      builder: (context) => MyGroceryPage() ),
                );
              },
              child: Icon(Icons.shopping_basket_outlined),
            ),
            label: 'Groceries',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipesPage()),
                );
              },
              child: Icon(Icons.restaurant_menu),
            ),
            label: 'Recipes',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminRecipePage()),
                    );
                },
              child: Icon(Icons.add),
              ),
              label: 'Add',
            ),
        ],
      ),
    );
  }


}

void _showHealthOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.calculate_outlined),
              title: Text('BMI Calculator'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BMICalculatorPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.food_bank_outlined),
              title: Text('DRI Calculator'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DRICalculatorPage()),
                );
              },
            ),
          ],
        ),
      );
    },
  );
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
  final double value1;
  final double value2;

  NutritionInfo({
    required this.title,
    required this.value1,
    required this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          "${value1.toStringAsFixed(2)} / ${value2.toStringAsFixed(2)}",
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