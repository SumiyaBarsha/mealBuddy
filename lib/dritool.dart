import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DRIToolPage extends StatefulWidget {
  @override
  _DRIToolPageState createState() => _DRIToolPageState();
}

class _DRIToolPageState extends State<DRIToolPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth

  String? _selectedGender;
  String? _selectedActivityLevel;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _estimatedCalories;
  double? _fat;
  double? _carbohydrate;
  double? _protein;


  void _calculateValues() {
    double age = double.tryParse(_ageController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;

    double calculatedCalories = weight * 15;
    double calculatedFat = calculatedCalories * 0.3;
    double calculatedCarbohydrate = calculatedCalories * 0.5;
    double calculatedProtein = weight * 0.8;

    setState(() {
      _estimatedCalories = calculatedCalories; // Replace with your calculation result.
      _fat = calculatedFat; // Replace with your calculation result.
      _carbohydrate = calculatedCarbohydrate; // Replace with your calculation result.
      _protein = calculatedProtein; // Replace with your calculation result.
    }); // Rebuild the widget to show updated values
  }

  void _saveDRIUnderUID() {
    User? currentUser = _auth.currentUser; // Get the current user
    if (currentUser != null) {
      String uid = currentUser.uid; // Get the user's UID
      // Set the DRI data under the user's UID
      _dbRef.child('Users/$uid/DRI').set({
        'calorie': _estimatedCalories,
        'fat': _fat,
        'carbs': _carbohydrate,
        'protein': _protein,
      }).then((_) {
        print('Data saved under user UID: $uid');
      }).catchError((error) {
        print('Error: $error');
      });
    } else {
      print('No user is currently signed in!');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
      Text('DRI Calculator',
          style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<String>(
                value: _selectedGender,
                hint: Text("Select Gender"),
                items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedActivityLevel,
                hint: Text("Select Activity Level"),
                items: [
                  'Sedentary',
                  'Lightly Active',
                  'Moderately Active',
                  'Very Active',
                  'Super Active'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedActivityLevel = newValue;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: ()  {
                _calculateValues();
                _saveDRIUnderUID();
                },
                child: Text('Calculate'),
              ),
              SizedBox(height: 24),
              if (_estimatedCalories != null)
                Text('Estimated Calorie/Day: $_estimatedCalories kcal'),
              if (_fat != null) Text('Fat: $_fat g'),
              if (_carbohydrate != null) Text('Carbohydrate: $_carbohydrate g'),
              if (_protein != null) Text('Protein: $_protein g'),
            ],
          ),
        ),
      ),
    );
  }
}
