import 'package:flutter/material.dart';

class BMICalculatorPage extends StatefulWidget {
  @override
  _BMICalculatorPageState createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _bmiResult = "";

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      double height = double.parse(_heightController.text) / 100;
      double weight = double.parse(_weightController.text);
      double bmi = weight / (height * height);

      String healthAssessment;
      if (bmi < 18.5) {
        healthAssessment = 'Underweight';
      } else if (bmi >= 18.5 && bmi <= 24.9) {
        healthAssessment = 'Healthy Weight';
      } else if (bmi >= 25 && bmi <= 29.9) {
        healthAssessment = 'Overweight';
      } else {
        healthAssessment = 'Obese';
      }

      setState(() {
        _bmiResult = "Your BMI is ${bmi.toStringAsFixed(2)}\n"
            "This is considered: $healthAssessment";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator',
        style: TextStyle(
          color: Colors.white,
        ),
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
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.height, color: Colors.green,),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.monitor_weight, color: Colors.green,),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _calculateBMI,
                child: Text('Calculate BMI',style: TextStyle(
                    color: Colors.white,
                ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
          Visibility(
            visible: _bmiResult.isNotEmpty,
            child: Column(
              children: [
                Text(
                  _bmiResult.split('\n').first, // Splitting the result to show the BMI value on a separate line
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _bmiResult.split('\n').last, // Splitting the result to show the health assessment on a separate line
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getColor(_bmiResult), // We'll create this method below
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getColor(String bmiResult) {
  if (bmiResult.contains('Underweight')) {
    return Colors.blue;
  } else if (bmiResult.contains('Healthy Weight')) {
    return Colors.green;
  } else if (bmiResult.contains('Overweight')) {
    return Colors.amber;
  } else {
    return Colors.red;
  }
}
