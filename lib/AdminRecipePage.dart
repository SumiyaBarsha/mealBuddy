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

  @override
  void dispose() {
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _recipeController.dispose();
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
    if (_uploadedFileURL == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload an image first")),
      );
      return;
    }
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('recipes').push();
    await dbRef.set({
      'carbs': _carbsController.text,
      'protein': _proteinController.text,
      'fat': _fatController.text,
      'recipe': _recipeController.text,
      'image': _uploadedFileURL,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Recipe added successfully")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Recipe Upload',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            _image != null
                ? Image.file(File(_image!.path))
                : Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity),
            ElevatedButton(
              child: Text('Choose Image',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // background
                onPrimary: Colors.green,
              ),
              onPressed: chooseFile,
            ),
            ElevatedButton(
              child: Text('Upload Image',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // background
                onPrimary: Colors.green,
              ),
              onPressed: uploadFile,
            ),
            TextFormField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Carbohydrates (g)'),
            ),
            TextFormField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Protein (g)'),
            ),
            TextFormField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Fat (g)'),
            ),
            TextFormField(
              controller: _recipeController,
              decoration: InputDecoration(labelText: 'Recipe Description'),
            ),
            ElevatedButton(
              child: Text('Add Recipe',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // background
                onPrimary: Colors.green,
              ),
              onPressed: addRecipe,
            ),
            SizedBox(height: 20.00,)
          ],
        ),
      ),
    );
  }
}
