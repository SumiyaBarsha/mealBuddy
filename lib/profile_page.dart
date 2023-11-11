import 'package:flutter/material.dart';
import 'package:meal_recommender/YourAccount.dart';
import 'package:meal_recommender/dietneedsPage.dart';
import 'package:meal_recommender/dritool.dart';
import 'package:meal_recommender/login.dart';
import 'package:meal_recommender/personalDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';




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
  @override

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  void initState() {
    super.initState();
    fetchUserData();
  }


  void fetchUserData() async {

    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;

      DatabaseReference userRef = _database.reference().child('Users').child(userId);

      try {
        DatabaseEvent event = await userRef.once();
        DataSnapshot dataSnapshot = event.snapshot;
        // You can access the data using dataSnapshot.value
        if (dataSnapshot.value != null) {
          Map<dynamic, dynamic> userData = dataSnapshot.value as Map<dynamic, dynamic>;

          name = userData['name'];
          height = userData['height'];
          weight = userData['weight'];
          setState(() {
            _profileImageUrl = userData['profileImageUrl'];
          });

          // Access other user information as needed
          print("Name: $name");
          print("height: $height");
          print("weight: $weight");
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
        await _database.reference().child('Users').child(_auth.currentUser!.uid).update({
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
                                age ?? "-- years old"
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(thickness: 2, color: Colors.grey[300]), // Divider for differentiation
                    SizedBox(height: 8),
                    RowData(title: "Current weight", value: (weight ?? "55")+" Kg"),
                    RowData(title: "Goal", value: goal ?? "Maintain weight"),
                    RowData(title: "Active Diet", value: diet ?? "Standard"),
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