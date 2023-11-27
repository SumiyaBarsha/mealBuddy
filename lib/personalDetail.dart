import 'package:flutter/material.dart';
import 'package:meal_recommender/actvitylevel.dart';
import 'package:meal_recommender/profile_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';


class personalDetail extends StatefulWidget {
  const personalDetail({Key? key}) : super(key: key);

  @override
  State<personalDetail> createState() => _personalDetailState();
}

enum Gender { Male, Female }
enum Goal { gain, maintain, lose }


class _personalDetailState extends State<personalDetail> {
  DateTime selectedDate = DateTime(2000, 8, 9);
   Gender? _selectedGender;
   Goal? _selectedGoal;

  String? name;
  String? weight;
  String? height;
  String? goalWeight;

  Future<void> saveData() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name ?? '');
    await prefs.setString('weight', weight ?? '');
    await prefs.setString('height', height ?? '');
    await prefs.setString('goalWeight', goalWeight ?? '');
    await prefs.setString('selectedDate', selectedDate.toIso8601String());
    await prefs.setString('gender', _selectedGender?.index.toString() ?? '');
    await prefs.setString('goal', _selectedGoal?.index.toString() ?? '');
  }

  Future<void> loadData() async {
    final databaseReference = FirebaseDatabase.instance.ref();

    databaseReference.child("Users/user_id").once().then((DatabaseEvent event) {
      var userData = event.snapshot.value;
      if (userData != null && userData is Map) {
        setState(() {
          name = userData['name'] ?? 'Your Name';
          weight = userData['weight'] ?? 'Weight';
          height = userData['Select height'] ?? 'Select Height';
          goalWeight = userData['goalWeight'] ?? 'Select Goal Weight';
          String? dateString = userData['selectedDate'];
          if (dateString != null) {
            selectedDate = DateTime.parse(dateString);
          }
          String? genderString = userData['gender'];
          if (genderString != null) {
            _selectedGender = Gender.values[int.parse(genderString)];
          }
          String? goalString = userData['goal'];
          if (goalString != null && goalString.isNotEmpty) {
            _selectedGoal = Goal.values.firstWhere((e) => e.toString() == 'Goal.$goalString');
          }
        });
      } else {
        // Handle the case where userData is null
        // For example, set default values
      }
    });
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? 'Your Name';
    weight = prefs.getString('weight') ?? 'Select Weight';
    height = prefs.getString('height') ?? 'Select Height';
    goalWeight = prefs.getString('goalWeight') ?? '';
    String? dateString = prefs.getString('selectedDate');
    if (dateString != null) {
      selectedDate = DateTime.parse(dateString);
    }
    String? genderString = prefs.getString('gender');
    if (genderString != null) {
      _selectedGender = Gender.values[int.parse(genderString)];
    }
    String? goalString = prefs.getString('goal');
    if (goalString != null) {
      _selectedGoal = Goal.values[int.parse(goalString)];
    }
  }


  @override
  void initState() {
    super.initState();
    loadData();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Your UI building logic here
          return buildProfileSettings();
        } else {
          // Show a loading indicator while the data is loading
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
  Widget buildProfileSettings() {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Settings', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(padding: const EdgeInsets.only(left: 8.0),
              child: Text("YOUR GOAL",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Goal'),
                    trailing: Text(_goalText(_selectedGoal) + ' >'),
                    onTap: _selectGoal,
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Goal weight'),
                    trailing: Text((goalWeight ?? 'Select Goal weight') + ' Kg' +' >'),
                    onTap: () => _showDialog(context, 'Goal Weight','Goal Weight'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(padding: const EdgeInsets.only(left: 8.0),
              child: Text("DETAILS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Name'),
                    trailing: Text((name ?? 'Your Name') + ' >'),
                    onTap: () => _showDialog(context, 'First name', 'First name'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Current weight'),
                    trailing: Text((weight ?? 'Select Weight')+ ' Kg >'),
                    onTap: () => _showDialog(context, 'Weight in kg', 'Weight in kg'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Height'),
                    trailing: Text((height ?? 'Select Height')+' cm >'),
                    onTap: () => _showDialog(context, 'Height in cm', 'Height in cm'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Date of birth'),
                    trailing: Text(
                        '${selectedDate.toLocal()}'.split(' ')[0] + ' >'),
                    onTap: () {
                      _selectDate(context);
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Gender'),
                    trailing: Text((_selectedGender == Gender.Male ? 'Male' : 'Female') + ' >'),
                    onTap: _selectGender,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDialog(BuildContext context, String title, String field) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
            ),
            onChanged: (text) {
              print("Text field: $text");
            },
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(width: 3.0),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  if (field == 'First name') {
                    name = _controller.text;
                  } else if (field == 'Weight in kg') {
                    weight = _controller.text;
                  } else if (field == 'Height in cm') {
                    height = _controller.text;
                  } else if (field == 'Goal Weight') {
                    goalWeight = _controller.text; // Make sure this matches the string you pass
                  }
                  // Add call to saveData here
                  saveData();
                }); // Optionally, print it for debugging purposes
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

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
        saveData();
      });
    }
  }

  Future<void> _selectGender() async {
    Gender? selected = await showDialog<Gender>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Gender'),
          children: <Widget>[
            ListTile(
              title: Text('Male'),
              leading: Radio<Gender>(
                value: Gender.Male,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ),
            ListTile(
              title: Text('Female'),
              leading: Radio<Gender>(
                value: Gender.Female,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedGender = selected;
        saveData();
      });
    }
  }

  Future<void> _selectGoal() async {
    Goal? selected = await showDialog<Goal>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Goal'),
          children: <Widget>[
            ListTile(
              title: Text('Gain Weight'),
              leading: Radio<Goal>(
                value: Goal.gain,
                groupValue: _selectedGoal,
                onChanged: (Goal? value) {
                  Navigator.of(context).pop(value);

                },
              ),
            ),
            ListTile(
              title: Text('Maintain Weight'),
              leading: Radio<Goal>(
                value: Goal.maintain,
                groupValue: _selectedGoal,
                onChanged: (Goal? value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ),
            ListTile(
              title: Text('Lose Weight'),
              leading: Radio<Goal>(
                value: Goal.lose,
                groupValue: _selectedGoal,
                onChanged: (Goal? value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedGoal = selected;
        saveData(); // Call saveData here
      });
    }
  }

  String _goalText(Goal? goal) {
    switch (goal) {
      case Goal.gain:
        return 'Gain Weight';
      case Goal.maintain:
        return 'Maintain Weight';
      case Goal.lose:
        return 'Lose Weight';
      default:
        return 'Select Goal';  // Default text if goal is null or not set
    }
  }

}






