import 'package:flutter/material.dart';
import 'package:meal_recommender/YourAccount.dart';
import 'package:meal_recommender/dietneedsPage.dart';
import 'package:meal_recommender/dritool.dart';
import 'package:meal_recommender/login.dart';
import 'package:meal_recommender/personalDetail.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('PROFILE', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 1.0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.white),
            onSelected: (String result) {
              if (result == 'account') {
                // Go to your account page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountSettingsPage()),
                );
              } else if (result == 'logout') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'account',
                child: Text('Your Account'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Row(
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            // Background image for the profile can be added here.
                          ),
                          Positioned(
                            bottom: -10,  // adjust this value to move the icon up or down
                            child: IconButton(
                              icon: Icon(Icons.add_a_photo),
                              color: Colors.green,
                              onPressed: () {
                                // Handle notification button tap
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sumiya",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("23 years old"),
                          SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("CUSTOMIZATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.circle, color: Colors.green, size: 20),
                      title: Text('Personal details'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => personalDetail()),
                        );
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey[300]), // Divider for differentiation
                    ListTile(
                      leading: Icon(Icons.circle, color: Colors.green, size: 20),
                      title: Text('Adjust macronutrients'),
                      subtitle: Text('Carbs, fat, and protein'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DRIToolPage()),
                        );
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey[300]), // Divider for differentiation
                    ListTile(
                      leading: Icon(Icons.circle, color: Colors.green, size: 20),
                      title: Text('Dietary needs & preferences'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DietaryPreferencesPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}