import 'package:flutter/material.dart';
import 'package:meal_recommender/DRIcalc.dart';
import 'package:meal_recommender/YourAccount.dart';
import 'package:meal_recommender/dietneedsPage.dart';
import 'package:meal_recommender/dritool.dart';
import 'package:meal_recommender/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meal_recommender/notificationpage.dart';
import 'package:meal_recommender/personalDetail2.dart';
import 'dart:io';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';

enum Goal { Gain, Maintain, Lose }

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class RowData extends StatelessWidget {
  final String title;
  final String value;

  const RowData({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

String? name,height,weight,age,goal,diet;
class _ProfilePageState extends State<ProfilePage> {
  String? _profileImageUrl;
  bool reminderSet = false;
  @override

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  void initState() {
    super.initState();
    fetchUserData();
  }


  void fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('Users/${user.uid}');
      try {
        DatabaseEvent event = await userRef.once();
        Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null) {
          setState(() {
            name = userData['name'] as String?;
            weight = userData['weight'] as String?;
            goal =  userData['goal'] as String?;
            age = userData['age'] as String?;
            _profileImageUrl = userData['profileImageUrl'] as String?;
          });
        } else {
          print("User data not found.");
        }
      } catch (error) {
        print("Error fetching user data: $error");
      }
    } else {
      print("No user is signed in.");
    }
  }



  Future<void> _editProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload to Firebase Storage
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('userProfileImages')
            .child(_auth.currentUser!.uid + '.jpg');

        await ref.putFile(imageFile);

        // Get the download URL
        final url = await ref.getDownloadURL();

        // Update the profile image URL in the database
        await _database.ref().child('Users').child(_auth.currentUser!.uid).update({
          'profileImageUrl': url,
        });

        setState(() {
          _profileImageUrl = url;
        });

      } catch (error) {
        print('Error uploading profile image: $error');
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Sign out from FirebaseAuth
    await FirebaseAuth.instance.signOut();

    // Clear user session data
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('isAdmin');
    await AuthService().signOut();
    // Redirect to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false, // Removes all previous routes
    );
  }



  Widget build(BuildContext context) {

    if (FirebaseAuth.instance.currentUser == null) {

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Login(),
        ));
      });
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('PROFILE', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 1.0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.white),
            onSelected: (String result) async {
              if (result == 'account') {
                // Go to your account page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountSettingsPage()),
                );
              } else if (result == 'logout') {
                await _logout(context);
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
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                            ),

                            Positioned(
                              bottom: -10,
                              child: IconButton(
                                icon: Icon(Icons.add_a_photo), // Changed icon for better context
                                color: Colors.green,
                                onPressed: () async { // Make this an async function
                                  await _editProfileImage(); // Wait for the edit profile image process to complete
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name ?? "Name",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                                (age ?? "--") + " years old"
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(thickness: 2, color: Colors.grey[300]), // Divider for differentiation
                    SizedBox(height: 8),
                    RowData(
                      title: "Current weight",
                      value: "${weight ?? "Not set"} Kg",
                    ),

                    RowData(
                      title: "Goal",
                      value: "${goal ?? "Not set"} Weight",
                    ),
                  ],
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
                          MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
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
                          MaterialPageRoute(builder: (context) => DRICalculatorPage()),
                        );
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey[300]), // Divider for differentiation
                    ListTile(
                      leading: Icon(Icons.circle, color: Colors.green, size: 20),
                      title: Text('Daily Meal Reminder'),
                      subtitle: Text('Schedule your notification'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => notificationpage()),
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

class AuthService {
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final FirebaseDatabase _database = FirebaseDatabase.instance;


Future<void> signOut() async {
// Clear user session data when signing out
final prefs = await SharedPreferences.getInstance();
await prefs.remove('userEmail');
await prefs.remove('isAdmin');
// Add any other prefs keys that you use in the app

return _firebaseAuth.signOut();
}

// Method to check if the currently signed-in user is an admin
// ... rest of the AuthService class ...
}
