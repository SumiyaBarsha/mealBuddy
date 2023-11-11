import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  runApp(MyGroceryApp());
}

class MyGroceryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyGroceryPage(),
    );
  }
}

class MyGroceryPage extends StatefulWidget {
  @override
  _MyGroceryPageState createState() => _MyGroceryPageState();
}

class GroceryItem {
  String name;
  double amount; // Changed to double to handle numerical values
  String unit;

  GroceryItem(this.name, this.amount, this.unit);
}



class _MyGroceryPageState extends State<MyGroceryPage> {
  List<GroceryItem> _groceryItems = [];

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionScreen()),
    );

    if (result != null) {
      setState(() {
        _groceryItems.add(result);
      });
      // After adding to the local list, also upload to Firebase
      _uploadGroceryItem(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/groceries.jpg"), // Make sure you have an images folder in your assets directory
                fit: BoxFit.cover, // This will fill the background with the image
              ),
            ),
          ),
          ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (context, index) {
              final item = _groceryItems[index];
              return Card(
                elevation: 3, // Add some elevation for a card-like effect
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add margin for spacing
                child: ListTile(
                  title: Text(
                    '${item.name} - ${item.amount.toStringAsFixed(2)} ${item.unit}',
                    style: TextStyle(
                      fontSize: 18, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // Add bold for emphasis
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateAndDisplaySelection(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

Future<void> _uploadGroceryItem(GroceryItem item) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userId = user.uid;
    DatabaseReference itemsRef = FirebaseDatabase.instance.reference().child('Users').child(userId).child('GroceryItems');

    // Create a unique key for a new grocery item. If `push().key` is null, an error will be thrown.
    String itemKey = itemsRef.push().key ?? 'default-key'; // Add a default key or handle null as needed

    // Set the data at the new location
    await itemsRef.child(itemKey).set({
      'name': item.name,
      'amount': item.amount,
      'unit': item.unit,
    }).catchError((error) {
      print("Failed to add item: $error");
    });
  }
}



Future<GroceryItem?> _showAddItemDialog(BuildContext context, String itemName) async {
  final TextEditingController amountController = TextEditingController();
  String? selectedUnit;

  // Function to show a dialog for entering the amount
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Amount'),
        content: TextField(
          controller: amountController,
          autofocus: true,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: 'Enter amount'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Next'),
            onPressed: () {
              Navigator.of(context).pop(amountController.text);
            },
          ),
        ],
      );
    },
  );

  // Only proceed if an amount was entered
  if (amountController.text.isNotEmpty) {
    // Function to show a dialog for selecting a unit
    selectedUnit = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Unit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: const Text('L'),
                  onTap: () => Navigator.pop(context, 'L'),
                ),
                ListTile(
                  title: const Text('KG'),
                  onTap: () => Navigator.pop(context, 'KG'),
                ),
                ListTile(
                  title: const Text('pcs'),
                  onTap: () => Navigator.pop(context, 'pcs'),
                ),
                // ... Add more ListTiles for other units
              ],
            ),
          ),
        );
      },
    );

    // If a unit was selected, return the new GroceryItem
    if (selectedUnit != null) {
      double amount = double.tryParse(amountController.text) ?? 0;
      return GroceryItem(itemName, amount, selectedUnit);
    }
  }

  // Return null if the process was not completed
  return null;
}


class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Items'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Milk'),
            onTap: () async {
              final item = await _showAddItemDialog(context, 'Milk');
              if (item != null) {
                Navigator.pop(context, item);
              }
            },
          ),
          ListTile(
            title: Text('Bread'),
            onTap: () async {
              final item = await _showAddItemDialog(context, 'Bread');
              if (item != null) {
                Navigator.pop(context, item);
              }
            },
          ),
          ListTile(
            title: Text('Potatoes'),
            onTap: () async {
              final item = await _showAddItemDialog(context, 'Potatoes');
              if (item != null) {
                Navigator.pop(context, item);
              }
            },
          ),
          ListTile(
            title: Text('Tomatoes'),
            onTap: () async {
              final item = await _showAddItemDialog(context, 'Tomatoes');
              if (item != null) {
                Navigator.pop(context, item);
              }
            },
          ),
          ListTile(
            title: Text('Eggs'),
            onTap: () async {
              final item = await _showAddItemDialog(context, 'Eggs');
              if (item != null) {
                Navigator.pop(context, item);
              }
            },
          ),
          // ... Add more ListTiles for other items
        ],
      ),
    );
  }
}

