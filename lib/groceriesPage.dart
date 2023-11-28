import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('Users'); // Adjust the reference path as needed
  @override
  void initState() {
    super.initState();
    // Call the function to fetch data when the page is opened
    _fetchGroceryItems();
  }
  // Function to fetch grocery items from Firebase
  void _fetchGroceryItems() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DatabaseReference itemsRef =
      _databaseReference.child(userId).child('GroceryItems');

      itemsRef.once().then((DatabaseEvent event) {
        if (event.snapshot.exists) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          List<GroceryItem> newItems = [];
          values.forEach((key, value) {
            double tmp= (value['amount'] as num).toDouble();
            if(value['unit']=='KG'){
              tmp=tmp/1000;
            }
            newItems.add(GroceryItem(
              value['name'],
              tmp,
              value['unit'],
            ));
          });
          setState(() {
            _groceryItems = newItems; // Update the grocery items list with new items
          });
        } else {
          setState(() {
            _groceryItems = []; // If snapshot doesn't exist, set grocery items to an empty list
          });
        }
      }).catchError((error) {
        print("Failed to fetch items: $error");
      });
    }
  }


  Future<void> _deleteGroceryItem(GroceryItem item) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DatabaseReference itemsRef = FirebaseDatabase.instance.reference().child('Users').child(userId).child('GroceryItems');

      // Query to find the item with the name
      Query query = itemsRef.orderByChild('name').equalTo(item.name);
      await query.once().then((DatabaseEvent event) async {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> items = event.snapshot.value as Map<dynamic, dynamic>;
          String itemKey = items.keys.first; // Assuming there's only one item with this name

          // Delete the item
          await itemsRef.child(itemKey).remove();
          _fetchGroceryItems() ; // Refresh the list after deletion
        }
      }).catchError((error) {
        print("Failed to delete item: $error");
      });
    }
  }


  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionScreen()),
    );

    if (result != null) {
      setState(() {
        _uploadGroceryItem(result); // This will update the Firebase database
        _fetchGroceryItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Grocery List', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchGroceryItems(); // Refresh the grocery items list
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (context, index) {
              final item = _groceryItems[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    '${item.name} - ${item.amount.toStringAsFixed(2)} ${item.unit}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteGroceryItem(item); // Call the delete function
                    },
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
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.green,
      ),
    );
  }
}


Future<void> _uploadGroceryItem(GroceryItem item) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userId = user.uid;
    DatabaseReference itemsRef = FirebaseDatabase.instance.reference().child('Users').child(userId).child('GroceryItems');

    // Query to check if item with the same name already exists
    Query query = itemsRef.orderByChild('name').equalTo(item.name);
    await query.once().then((DatabaseEvent event) async {
      if (event.snapshot.exists) {
        // If item exists, update its amount
        print("HERE\n");
        Map<dynamic, dynamic> items = event.snapshot.value as Map<dynamic, dynamic>;
        String itemKey = items.keys.first; // Assuming there's only one item with this name
        var amount = items[itemKey]['amount'];
        double existingAmount = (amount is int) ? amount.toDouble() : amount as double;
        double newAmount = existingAmount + item.amount.toDouble();

        await itemsRef.child(itemKey).update({
          'amount': newAmount,
        });
      } else {
        // If item does not exist, create a new one
        String itemKey = itemsRef.push().key ?? 'default-key'; // Add a default key or handle null as needed
        if(item.unit=='KG'){
          item.amount=item.amount*1000;
        }
        await itemsRef.child(itemKey).set({
          'name': item.name,
          'amount': item.amount,
          'unit': item.unit,
        });
      }
    }).catchError((error) {
      print("Failed to add or update item: $error");
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
  final List<String> items = [
    'Milk',
    'Bread',
    'Potatoes',
    'Tomatoes',
    'Egg',
    'Wheat Flour',
    'Ghee',
    'Vegetable oil',
    'Egg White',
    'All Purpose Flour',
    'Mayonnaise',
    'Cucumber',
    'Green Chilli',
    'Onion',
    'Chicken',
    'Cheese',
    // ... Add more items here
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Items'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            onTap: () async {
              final item = await _showAddItemDialog(context, items[index]);
              if (item != null) {
                Navigator.pop(context, item);
              }
            },
          );
        },
      ),
    );
  }
}
