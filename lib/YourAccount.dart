import 'package:flutter/material.dart';


class AccountSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACCOUNT SETTINGS',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingCard(
              title: 'Email',
              content: 'a@gmail.com',
            ),
            SettingCard(
              title: 'First name',
              content: 'Your Name',
            ),
            SettingCard(
              title: 'Password',
              content: '********',
            ),
            ListTile(
              title: Text('Delete account', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Handle delete account logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingCard extends StatelessWidget {
  final String title;
  final String content;

  SettingCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(content),
      ),
    );
  }
}
