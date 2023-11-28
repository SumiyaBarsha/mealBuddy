import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_recommender/login.dart';

class AccountSettingsPage extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACCOUNT SETTINGS', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User's name setting card
            SettingCard(
              title: 'Your name',
              databaseKey: 'name',
            ),
            // Placeholder for email setting card
            // Assuming the email is stored under 'Users/uid/email' in the database
            SettingCard(
              title: 'Email',
              databaseKey: 'email',
            ),
            // Placeholder for password reset option
            ListTile(
              title: Text('Reset Password', style: TextStyle(color: Colors.blue)),
              onTap: () {
                _resetPassword(context);
              },
            ),
            // Placeholder for delete account option
            ListTile(
              title: Text('Delete Account', style: TextStyle(color: Colors.red)),
              onTap: () {
                _deleteAccount(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}


class SettingCard extends StatefulWidget {
  final String title;
  final String databaseKey;

  SettingCard({required this.title, required this.databaseKey});

  @override
  _SettingCardState createState() => _SettingCardState();
}

class _SettingCardState extends State<SettingCard> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _dbRef.child('Users/${currentUser?.uid}/${widget.databaseKey}').onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as String?;
          if (data != null && data.isNotEmpty) {
            setState(() {
              _controller.text = data;
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveInfo() {
    if (currentUser != null) {
      _dbRef.child('Users/${currentUser?.uid}/${widget.databaseKey}').set(_controller.text).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Information updated successfully')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating information: $error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(widget.title),
        subtitle: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.title}',
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.save),
          onPressed: _saveInfo,
        ),
      ),
    );
  }
}

Future<void> _deleteAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  // Show a confirmation dialog before deleting the account
  final confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );

  // If the user confirmed, proceed with account deletion
  if (confirmDelete == true) {
    await user?.delete();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
}
Future<void> _resetPassword(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null && user.email != null) {
    // User is signed in and email is not null
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  } else {
    // No user is signed in or the email is null
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No email address is associated with this account')),
    );
  }
}
