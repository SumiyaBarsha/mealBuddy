import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart' as Path;

class AdminRecipePage extends StatefulWidget {
  @override
  _AdminRecipePageState createState() => _AdminRecipePageState();
}

class _AdminRecipePageState extends State<AdminRecipePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _uploadedFileURL;
  TextEditingController _carbsController = TextEditingController();
  TextEditingController _proteinController = TextEditingController();
  TextEditingController _fatController = TextEditingController();
  TextEditingController _recipeController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _recipeController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future chooseFile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  Future uploadFile() async {
    if (_image == null) return;
    final fileName = Path.basename(_image!.path);
    final destination = 'recipes/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      final task = ref.putFile(File(_image!.path));
      final snapshot = await task.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedFileURL = urlDownload;
      });
      print('Download-Link: $urlDownload');
    } catch (e) {
      print('error occured');
    }
  }

  Future addRecipe() async {
    if (_uploadedFileURL == null || selectedMealType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload an image and select a meal type")),
      );
      return;
    }
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('recipes').push();
    await dbRef.set({
      'title': _titleController.text,
      'mealType': selectedMealType,
      'carbs': _carbsController.text,
      'protein': _proteinController.text,
      'fat': _fatController.text,
      'recipe': _recipeController.text,
      'image': _uploadedFileURL,
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Recipe added successfully")),
    );
  }

  List<Ingredient> ingredients = [];
  void addIngredient() {
    setState(() {
      ingredients.add(Ingredient(name: '', amount: ''));
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }


  List<String> mealTypes = ['breakfast', 'lunch', 'dinner'];
  String? selectedMealType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Recipe Upload',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0), // Added padding to the sides
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            _image != null
                ? Image.file(
              File(_image!.path),
              width: double.infinity,
              // Set image width to match the screen width
              height: 200,
              // Fixed height for the image
              fit: BoxFit.cover, // Cover the entire widget area
            )
                : Placeholder(
                fallbackHeight: 200, fallbackWidth: double.infinity),
            SizedBox(height: 20), // Added some space before the button
            ElevatedButton(
              child: Text(
                  'Choose Image', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // background
                onPrimary: Colors.white, // text color
              ),
              onPressed: chooseFile,
            ),
            SizedBox(height: 10), // Added some space between buttons
            ElevatedButton(
              child: Text(
                  'Upload Image', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // background
                onPrimary: Colors.white, // text color
              ),
              onPressed: uploadFile,
            ),
            SizedBox(height: 20), // Added some space before the form fields
            DropdownButtonFormField<String>(
              value: selectedMealType,
              hint: Text('Select Meal Type'),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: mealTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMealType = newValue;
                });
              },
            ),
            SizedBox(height: 10),
            buildTextFormField(
                _titleController, // Use the new controller here
                'Title', // Label text for the new field
                TextInputType.text // Set the keyboard type to text
            ),
            buildTextFormField(
                _carbsController, 'Carbohydrates (g)', TextInputType.number),
            buildTextFormField(
                _proteinController, 'Protein (g)', TextInputType.number),
            buildTextFormField(_fatController, 'Fat (g)', TextInputType.number),
            buildTextFormField(
                _recipeController, 'Recipe Description', TextInputType.text),
            SizedBox(height: 20),
            ...ingredients.map((ingredient) {
              int index = ingredients.indexOf(ingredient);
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: ingredient.name,
                      onChanged: (newName) {
                        ingredient.name = newName;
                      },
                      decoration: InputDecoration(
                        labelText: 'Ingredient Name',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: ingredient.amount,
                      onChanged: (newAmount) {
                        ingredient.amount = newAmount;
                      },
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () => removeIngredient(index),
                  ),
                ],
              );
            }).toList(),

            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: addIngredient,
            ),// Added some space before the button
            ElevatedButton(
              child: Text('Add Recipe', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // background
                onPrimary: Colors.white, // text color
              ),
              onPressed: addRecipe,
            ),
            SizedBox(height: 20), // Added space at the bottom
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(TextEditingController controller, String label,
      TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        // Added padding inside the text field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              10.0), // Rounded corners for the input border
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
class Ingredient {
  String name;
  String amount;

  Ingredient({required this.name, required this.amount});

  Map<String, String> toJson() => {
    'name': name,
    'amount': amount,
  };
}
