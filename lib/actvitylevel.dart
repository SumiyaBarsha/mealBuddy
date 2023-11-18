import 'package:flutter/material.dart';


enum ActivityLevel {
  low,
  moderate,
  high,
  veryHigh,
}


class ActivityLevelDialog extends StatefulWidget {
  @override
  _ActivityLevelDialogState createState() => _ActivityLevelDialogState();
}

class _ActivityLevelDialogState extends State<ActivityLevelDialog> {
  ActivityLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('ACTIVITY LEVEL', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _activityTile(ActivityLevel.low, 'Low', 'Little to no daily activity. Bank teller, desk job. Reading, playing video games watching tv in spare time.'),
        _activityTile(ActivityLevel.moderate, 'Moderate', 'Light daily activity. Teacher, sales clerk. Walking or cycling to work and do light chores in spare time.'),
        _activityTile(ActivityLevel.high, 'High', 'Physical activity throughout the day. Postal worker, waitstaff. Being active in spare time.'),
        _activityTile(ActivityLevel.veryHigh, 'Very high', 'Physically demanding daily activity. Construction work, bike messenger. Intense daily activity in spare time.'),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _selectedLevel);
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        )
      ],
      ),
      ),
    );
  }

  ListTile _activityTile(ActivityLevel level, String title, String subTitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subTitle),
      leading: Radio<ActivityLevel>(
        value: level,
        groupValue: _selectedLevel,
        onChanged: (ActivityLevel? value) {
          setState(() {
            _selectedLevel = value;
          });
        },
      ),
    );
  }
}
