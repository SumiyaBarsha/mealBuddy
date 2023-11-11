import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RecipesPage extends StatefulWidget {
  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  int _selectedIndex = 0;
  final DatabaseReference _recipesRef = FirebaseDatabase.instance.ref().child('recipes');

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
  }

  void showRecipeDetails(Map recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use as little space as necessary
            children: <Widget>[
              Image.network(
                recipe['image'] ?? 'https://via.placeholder.com/150',
                height: 200, // Fixed height for the image
                width: double.infinity, // Image takes the full width of the dialog
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      recipe['title'] ?? 'Recipe Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Carbohydrates: ${recipe['carbs'] ?? 'N/A'}g'),
                    SizedBox(height: 4),
                    Text('Protein: ${recipe['protein'] ?? 'N/A'}g'),
                    SizedBox(height: 4),
                    Text('Fat: ${recipe['fat'] ?? 'N/A'}g'),
                    SizedBox(height: 10),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(recipe['recipe'] ?? 'No description provided.'),
                  ],
                ),
              ),
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('MealBuddy',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          // Your header section here
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Recipes',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16.00,
              ),
            ),
          ),
          // Horizontally scrollable cards
          Container(
            height: 220, // Adjust the height to fit your design
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Breakfast', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _recipesRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Display a loading indicator while waiting
                      }
                      if (snapshot.data?.snapshot.value != null) {
                      // Assuming your data is a Map
                      Map recipes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                      List items = recipes.entries.map((e) => e.value).where((item) {
                      // Filter items where 'mealType' is 'breakfast'
                      return item['mealType'] == 'breakfast';
                      }).toList();

                      // Assuming your data is a Map

                      return Container(
                        height: 220, // Adjust the height to fit your design
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            Map recipe = items[index];
                            return buildCard(
                              recipe['image'] ?? 'https://via.placeholder.com/150', // Provide a default image in case 'image' is null
                              recipe['title'] ?? 'Recipe Title',
                              'Carbs' + recipe['carbs'],
                            );
                          },
                        ),
                      );
                      } else {
                        // If the snapshot data is null, display a placeholder or a message
                        return Center(
                          child: Text('No breakfast recipes found.'),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 220, // Adjust the height to fit your design
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Lunch', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _recipesRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Display a loading indicator while waiting
                      }
                      if (snapshot.data?.snapshot.value != null) {
                        // Assuming your data is a Map
                        Map recipes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                        List items = recipes.entries.map((e) => e.value).where((item) {
                          // Filter items where 'mealType' is 'breakfast'
                          return item['mealType'] == 'lunch';
                        }).toList();

                        // Assuming your data is a Map

                        return Container(
                          height: 220, // Adjust the height to fit your design
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              Map recipe = items[index];
                              return buildCard(
                                recipe['image'] ?? 'https://via.placeholder.com/150', // Provide a default image in case 'image' is null
                                recipe['title'] ?? 'Recipe Title',
                                'Carbs' + recipe['carbs'],
                              );
                            },
                          ),
                        );
                      } else {
                        // If the snapshot data is null, display a placeholder or a message
                        return Center(
                          child: Text('No breakfast recipes found.'),
                        );
                      }
                    },
                  ),

                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 220, // Adjust the height to fit your design
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Dinner', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child:StreamBuilder(
                    stream: _recipesRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Display a loading indicator while waiting
                      }
                      if (snapshot.data?.snapshot.value != null) {
                        // Assuming your data is a Map
                        Map recipes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                        List items = recipes.entries.map((e) => e.value).where((item) {
                          // Filter items where 'mealType' is 'breakfast'
                          return item['mealType'] == 'dinner';
                        }).toList();

                        // Assuming your data is a Map

                        return Container(
                          height: 220, // Adjust the height to fit your design
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              Map recipe = items[index];
                              return buildCard(
                                recipe['image'] ?? 'https://via.placeholder.com/150', // Provide a default image in case 'image' is null
                                recipe['title'] ?? 'Recipe Title',
                                'Carbs' + recipe['carbs'],
                              );
                            },
                          ),
                        );
                      } else {
                        // If the snapshot data is null, display a placeholder or a message
                        return Center(
                          child: Text('No breakfast recipes found.'),
                        );
                      }
                    },
                  ),

                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget buildCard(String imageUrl, String title, String subtitle) {
    return InkWell(
      onTap: () {
        // You would need to pass the actual recipe Map data here
        showRecipeDetails({
          'image': imageUrl,
          'title': title,
          // Add other recipe details here as needed
        });
        print('Card tapped!');
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Container(
          width: 160, // Adjust the width to fit your design
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network(
                imageUrl,
                height: 120, // Adjust the height to fit your design
                width: 160,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(subtitle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
