import 'package:flutter/material.dart';

class DRICalculatorPage extends StatefulWidget {
  @override
  _DRICalculatorPageState createState() => _DRICalculatorPageState();
}

enum Gender { male, female }

class _DRICalculatorPageState extends State<DRICalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isMale = true; // Default gender
  String _driResult = "";

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateDRI() {
    if (_formKey.currentState!.validate()) {
      int age = int.parse(_ageController.text);
      double weight = double.parse(_weightController.text);
      double height = double.parse(_heightController.text);

      double dri;
      print(_isMale);
      if (_isMale) {
        dri = 66.5 + (13.8 * (weight ?? 0)) + (5 * (height ?? 0)) - (6.8 * (age ?? 0));
      } else {
        dri = 655.1 + (9.6 * (weight ?? 0)) + (1.9 * (height ?? 0)) - (4.7 * (age ?? 0));
      }

      setState(() {
        _driResult = "Your Daily Caloric Intake (DRI) is ${dri.toStringAsFixed(0)} calories";
      });
    }
  }
  Gender _selectedGender = Gender.male; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DRI Calculator',
          style: TextStyle(color: Colors.white), // Set the AppBar title text color to white
        ),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Gender switch
              RadioListTile<Gender>(
                title: const Text('Male'),
                value: Gender.male,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value!;
                    _isMale=true;
                  });
                },
              ),
              // Female radio button
              RadioListTile<Gender>(
                title: const Text('Female'),
                value: Gender.female,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value!;
                    _isMale=false;
                  });
                },
              ),

              // Age input
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age (years)'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your age' : null,
              ),
              // Height input
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Height (cm)'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your height' : null,
              ),
              // Weight input
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your weight' : null,
              ),
              // Calculate button
              ElevatedButton(
                onPressed: _calculateDRI,
                child: Text(
                  'Calculate DRI',
                  style: TextStyle(color: Colors.white), // Set the button text color to white
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Set the button color to green
                ),
              ),
              // Display result
              Visibility(
                visible: _driResult.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _driResult,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
