import 'package:flutter/material.dart';
import 'package:meal_recommender/actvitylevel.dart';
import 'package:meal_recommender/profile_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    );
  }
}

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
  String? savedText;
  String? savedWeight;
  String? savedHeight;

  @override
  Widget build(BuildContext context) {
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
                    trailing: Text('Select Weight >'),
                    onTap: () => _showDialog(context, 'Goal Weight'),
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
                    onTap: () => _showDialog(context, 'First name'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Current weight'),
                    trailing: Text((weight ?? 'Select Weight')+ ' Kg >'),
                    onTap: () => _showDialog(context, 'Weight in kg'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Height'),
                    trailing: Text((height ?? 'Select Height')+' cm >'),
                    onTap: () => _showDialog(context, 'Height in cm'),
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
                  Divider(),
                  ListTile(
                    title: Text('Activity Level'),
                    trailing: Text('Moderate >'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityLevelDialog()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDialog(BuildContext context, String title) {
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
                  savedText = _controller.text;
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






