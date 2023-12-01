import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

enum Gender { Male, Female }
enum Goal { Gain, Maintain, Lose }

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Gender? _selectedGender;
  Goal? _selectedGoal;

  String? name;
  String? weight;
  String? height;
  String? goalWeight;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _fetchProfileData();
    }
  }

  Future<void> _fetchProfileData() async {
    final profileRef = _dbRef.child('Users/${currentUser?.uid}');
    final snapshot = await profileRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        name = data['name'];
        weight = data['weight'];
        height = data['height'];
        goalWeight = data['goalWeight'];
        _selectedGender = Gender.values[data['gender']];
        _selectedGoal = Goal.values.firstWhere((e) => e.toString() == 'Goal.${data['goal']}');
      });
    }
  }

  Future<void> saveData() async {
    final profileRef = _dbRef.child('Users/${currentUser?.uid}');
    await profileRef.update({
      'name': name,
      'weight': weight,
      'height': height,
      'goalWeight': goalWeight,
      'gender': _selectedGender?.index,
      'goal': _selectedGoal?.toString().split('.').last,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved successfully")));
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                maximumSize: Size(200, 50),
              ),
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
                  //saveData();
                }); // Optionally, print it for debugging purposes
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
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
        //saveData();
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
                value: Goal.Gain,
                groupValue: _selectedGoal,
                onChanged: (Goal? value) {
                  Navigator.of(context).pop(value);

                },
              ),
            ),
            ListTile(
              title: Text('Maintain Weight'),
              leading: Radio<Goal>(
                value: Goal.Maintain,
                groupValue: _selectedGoal,
                onChanged: (Goal? value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ),
            ListTile(
              title: Text('Lose Weight'),
              leading: Radio<Goal>(
                value: Goal.Lose,
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
        //  saveData(); // Call saveData here
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20.00,),
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
                  title: Text('Gender'),
                  trailing: Text(_genText(_selectedGender) + ' >'),
                  onTap: _selectGender,
                ),
              ],
            ),
          ),
         SizedBox(height: 20.00,),

         ElevatedButton(
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                  primary: Colors.green, // background
                  onPrimary: Colors.white, // text color
                     ),
                         onPressed: saveData ,
    ),
  ],
      ),

    );
  }
  String _goalText(Goal? goal) {
    switch (goal) {
      case Goal.Gain:
        return 'Gain Weight';
      case Goal.Maintain:
        return 'Maintain Weight';
      case Goal.Lose:
        return 'Lose Weight';
      default:
        return 'Select Goal';  // Default text if goal is null or not set
    }
  }

  String _genText(Gender? gender) {
    switch (gender) {
      case Gender.Male:
        return 'Male';
      case Gender.Female:
        return 'Female';
      default:
        return 'Select Gender';  // Default text if goal is null or not set
    }
  }

}
