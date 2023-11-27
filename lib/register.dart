import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("Users");

  // Controllers for input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Register',style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildEmailField(),
              SizedBox(height: 20),
              buildNameField(),
              SizedBox(height: 20),
              buildPasswordField(),
              SizedBox(height: 20),
              buildConfirmPasswordField(),
              SizedBox(height: 20),
              buildHeightField(),
              SizedBox(height: 20),
              buildWeightField(),
              SizedBox(height: 20),
              buildAgeField(),
              SizedBox(height: 20),
              buildGenderField(),
              SizedBox(height: 20),
              buildRegisterButton(),
              SizedBox(height: 10),
              buildHaveAccountText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
          ),
        ),
      ],
    );
  }

  Widget buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter your password',
          ),
        ),
      ],
    );
  }

  Widget buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirm your password',
          ),
        ),
      ],
    );
  }

  Widget buildHeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Height (cm)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: heightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your height in cm',
          ),
        ),
      ],
    );
  }

  Widget buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Weight (kg)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your weight in kg',
          ),
        ),
      ],
    );
  }
  Widget buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Age',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your age',
          ),
        ),
      ],
    );
  }

  Widget buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: genderController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Enter your gender',
          ),
        ),
      ],
    );
  }

  Widget buildRegisterButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (passwordController.text == confirmPasswordController.text) {
            try {
              UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              );

              // If registration is successful, save additional user data to Firebase Realtime Database
              if (userCredential.user != null) {
                _dbRef.child(userCredential.user!.uid).set({
                  'name': nameController.text,
                  'email': emailController.text,
                  'height': heightController.text,
                  'weight': weightController.text,
                  'age' : ageController.text,
                  'gender' : genderController.text,
                  'dob': DateTime(1990, 1, 1),
                });
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Registration'),
                      content: Text('Registration successful!'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );

                Navigator.pop(context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              }
            } catch (e) {
              print(e); // Print the exception for debugging
              // Display an error message to the user
            }
          } else {
            // Display an error message if passwords don't match
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff3ba80b), // Button color
          padding: EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget buildHaveAccountText() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Text(
        'Already have an account?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
