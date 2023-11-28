import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealSuggestionPage extends StatefulWidget {
  @override
  _MealSuggestionPageState createState() => _MealSuggestionPageState();
}

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

class GroceryItem {
  String name;
  double amount;
  String unit;

  GroceryItem(this.name, this.amount, this.unit);
}

bool isIngredientSufficient(GroceryItem item, Map ingredient) {
  if(ingredient['name']=='Vegetable Oil'){
    print(item.name);
  }
  if (item.name == ingredient['name']) {
    double requiredAmount = double.tryParse(ingredient['amount']) ?? 0;
    if(item.name=='Vegetable Oil'){
      print('HERE');
      print(item.amount);
      print(requiredAmount);
    }
    return item.amount >= requiredAmount;
  }
  return false;
}

bool areAllIngredientsSufficient(List<GroceryItem> userGroceryItems, Map recipe) {

  print(recipe['title']);
  if (recipe['ingredients'] is! List || (recipe['ingredients'] as List).any((item) => item is! Map)) {
    print('Error: Ingredients are not in the expected format '+recipe['title']);
    return false;
  }
  List<Map> ingredients = List<Map>.from(recipe['ingredients']);
  for (var ingredient in ingredients) {
    bool foundAndSufficient = false;
    for (var item in userGroceryItems) {
      if (isIngredientSufficient(item, ingredient)) {
        foundAndSufficient = true;
        break;
      }
    }
    if(recipe['title']=='Egg Omelette'){
      print(foundAndSufficient);
      print(ingredient);
    }
    if (!foundAndSufficient) {
      return false;
    }
  }
  return true;
}

void checkRecipe(Map recipe, List<GroceryItem> userGroceryItems) {
  bool sufficient = areAllIngredientsSufficient(userGroceryItems, recipe);
  if (sufficient) {
    print("All ingredients for the recipe '${recipe['title']}' are sufficient.");
  } else {
    print("Ingredients for the recipe '${recipe['title']}' are not sufficient.");
  }
}

class _MealSuggestionPageState  extends State<MealSuggestionPage> {
  List<GroceryItem> _userGroceryItems = [];
  int _selectedIndex = 0;
  final DatabaseReference _recipesRef = FirebaseDatabase.instance.ref().child('recipes');
  List<Pair<double, String>> vectorOfPairs = [] , vectorOfPairsL = [] ,vectorOfPairsG = [];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
  }
  @override
  void initState() {
    super.initState();
    loadDataFromFirebase();
    _fetchUserGroceryItems();
    print("2");
    for (var pair in vectorOfPairs) {
      print("${pair.first} -> ${pair.second}");
    }

  }


  void _fetchUserGroceryItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    print('HERE1');
    if (user != null) {
      DatabaseReference itemsRef = FirebaseDatabase.instance.ref('Users/${user.uid}/GroceryItems');
      print('HERE2');
      print(itemsRef);
      // Fetch the grocery items
      DatabaseEvent event = await itemsRef.once();
      if (event.snapshot.exists) {
        List<GroceryItem> fetchedItems = [];
        Map<dynamic, dynamic> items = event.snapshot.value as Map<dynamic, dynamic>;

        items.forEach((key, value) {
          // Ensure that 'amount' is a number and 'name' and 'unit' are strings
          double amount = 0;
          String name = '';
          String unit = '';

          if (value['amount'] is int) {
            amount = (value['amount'] as int).toDouble();
          } else if (value['amount'] is double) {
            amount = value['amount'];
          } else {
            print('Amount is not a number');
          }

          if (value['name'] is String) {
            name = value['name'];
          } else {
            print('Name is not a string');
          }

          if (value['unit'] is String) {
            unit = value['unit'];
          } else {
            print('Unit is not a string');
          }

          fetchedItems.add(GroceryItem(name, amount, unit));
        });

        setState(() {
          _userGroceryItems = fetchedItems;
          print(fetchedItems);
        });
      } else {
        print("No grocery items found for user: ${user.uid}");
      }
    } else {
      print("No user logged in");
    }
  }


  void loadDataFromFirebase() async {
    _recipesRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> recipes = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          vectorOfPairs = recipes.entries
              .where((e) => e.value['mealType'] == mealtype) // Filter for breakfast recipes
              .map((e) {
            var recipe = e.value as Map<dynamic, dynamic>;
            double kcal;
            if (recipe['kcal'] is int) {
              kcal = (recipe['kcal'] as int).toDouble();
            } else if (recipe['kcal'] is double) {
              kcal = recipe['kcal'];
              print(kcal);
            } else {
              print('Unexpected type for kcal in recipe ${recipe['title']}');
              kcal = 0.0; // Default value for unexpected type
            }
            kcal=kcalLeftValue*4/15-kcal;
            if(kcal<0){
              kcal=-kcal;
            }
            return Pair<double, String>(kcal, recipe['title'] as String);
          }).toList();
          print("0");
          vectorOfPairs.sort((a, b) => a.first.compareTo(b.first));

          vectorOfPairsL = recipes.entries
              .where((e) => e.value['mealType'] == mealtype) // Filter for breakfast recipes
              .map((e) {
            var recipe = e.value as Map<dynamic, dynamic>;
            double kcal;
            if (recipe['kcal'] is int) {
              kcal = (recipe['kcal'] as int).toDouble();
            } else if (recipe['kcal'] is double) {
              kcal = recipe['kcal'];
              print(kcal);
            } else {
              print('Unexpected type for kcal in recipe ${recipe['title']}');
              kcal = 0.0; // Default value for unexpected type
            }
            kcal=kcalLeftValue*3/15-kcal;
            if(kcal<0){
              kcal=-kcal;
            }

            return Pair<double, String>(kcal, recipe['title'] as String);
          }).toList();
          print("0");
          vectorOfPairsL.sort((a, b) => a.first.compareTo(b.first));

          vectorOfPairsG = recipes.entries
              .where((e) => e.value['mealType'] == mealtype) // Filter for breakfast recipes
              .map((e) {
            var recipe = e.value as Map<dynamic, dynamic>;
            double kcal;
            if (recipe['kcal'] is int) {
              kcal = (recipe['kcal'] as int).toDouble();
            } else if (recipe['kcal'] is double) {
              kcal = recipe['kcal'];
              print(kcal);
            } else {
              print('Unexpected type for kcal in recipe ${recipe['title']}');
              kcal = 0.0; // Default value for unexpected type
            }
            kcal=kcalLeftValue*5/15-kcal;
            if(kcal<0){
              kcal=-kcal;
            }
            return Pair<double, String>(kcal, recipe['title'] as String);
          }).toList();
          print("0");
          vectorOfPairsG.sort((a, b) => a.first.compareTo(b.first));

        });
      }
    }).catchError((error) {
      print('Error fetching data: $error');
    });
    print("1");
    for (var pair in vectorOfPairs) {
      print("${pair.first} -> ${pair.second}");
    }
  }

  void showRecipeDetails(Map recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView( // Wrap the content in a SingleChildScrollView
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
                      Text(recipe['description'] ?? 'No description provided.'),
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
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    for (var pair in vectorOfPairs) {
      print("${pair.first} -> ${pair.second}");
    }
    for (var pair in vectorOfPairsL) {
      print("${pair.first} -> ${pair.second}");
    }
    for (var pair in vectorOfPairsG) {
      print("${pair.first} -> ${pair.second}");
    }
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
                  child: Text('Maintain Weight', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Map recipes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                        // Filter items based on whether their title matches any in vectorOfPairs
                        List items = recipes.entries.map((e) => e.value).where((item) {
                          return vectorOfPairs.any((pair) => pair.second == item['title']);
                        }).toList();

                        // Sort the items to match the order in vectorOfPairs
                        items.sort((a, b) {
                          int indexA = vectorOfPairs.indexWhere((pair) => pair.second == a['title']);
                          int indexB = vectorOfPairs.indexWhere((pair) => pair.second == b['title']);
                          return indexA.compareTo(indexB);
                        });

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
                                recipe['carbs'],
                                recipe['kcal'].toString(),
                                recipe['fat'],
                                recipe['protein'],
                                recipe['recipe'],
                                recipe,

                              );
                            },
                          ),
                        );
                      } else {
                        // If the snapshot data is null, display a placeholder or a message
                        return Center(
                          child: Text('No matching recipes found.'),
                        );
                      }
                    },
                  ),
                )
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
                  child: Text('Loose Weight', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Map recipes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                        // Filter items based on whether their title matches any in vectorOfPairs
                        List items = recipes.entries.map((e) => e.value).where((item) {
                          return vectorOfPairsL.any((pair) => pair.second == item['title']);
                        }).toList();

                        // Sort the items to match the order in vectorOfPairs
                        items.sort((a, b) {
                          int indexA = vectorOfPairsL.indexWhere((pair) => pair.second == a['title']);
                          int indexB = vectorOfPairsL.indexWhere((pair) => pair.second == b['title']);
                          return indexA.compareTo(indexB);
                        });

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
                                recipe['carbs'],
                                recipe['kcal'].toString(),
                                recipe['fat'],
                                recipe['protein'],
                                recipe['recipe'],
                                recipe,

                              );
                            },
                          ),
                        );
                      } else {
                        // If the snapshot data is null, display a placeholder or a message
                        return Center(
                          child: Text('No matching recipes found.'),
                        );
                      }
                    },
                  ),
                )
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
                  child: Text('Gain Weight', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Map recipes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                        // Filter items based on whether their title matches any in vectorOfPairs
                        List items = recipes.entries.map((e) => e.value).where((item) {
                          return vectorOfPairsG.any((pair) => pair.second == item['title']);
                        }).toList();

                        // Sort the items to match the order in vectorOfPairs
                        items.sort((a, b) {
                          int indexA = vectorOfPairsG.indexWhere((pair) => pair.second == a['title']);
                          int indexB = vectorOfPairsG.indexWhere((pair) => pair.second == b['title']);
                          return indexA.compareTo(indexB);
                        });

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
                                recipe['carbs'],
                                recipe['kcal'].toString(),
                                recipe['fat'],
                                recipe['protein'],
                                recipe['recipe'],
                                recipe,

                              );
                            },
                          ),
                        );
                      } else {
                        // If the snapshot data is null, display a placeholder or a message
                        return Center(
                          child: Text('No matching recipes found.'),
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

  Widget buildCard(String imageUrl, String title, String carbs, String kcal, String fat, String protein, String sub, Map recipe) {
    print(recipe['title']);
    bool isSufficient = areAllIngredientsSufficient(_userGroceryItems, recipe);
    print(_userGroceryItems);

    // Determine the card color based on ingredient sufficiency
    Color cardColor = isSufficient ? Colors.white : Colors.redAccent;

    return InkWell(
      onTap: () {
        showRecipeDetails({
          'image': imageUrl,
          'title': title,
          'kcal': kcal,
          'fat': fat,
          'protein': protein,
          'carbs': carbs,
          'description': sub,
        });
        print('Card tapped!');
      },
      child: Card(
        color: cardColor,  // Use the cardColor determined by ingredient sufficiency
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
                child: Text(isSufficient ? 'Ingredients sufficient' : 'Ingredients insufficient',
                  style: TextStyle(color: isSufficient ? Colors.black : Colors.white), // Change text color based on sufficiency
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
