import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meal_recommender/globals.dart';
import 'package:meal_recommender/home.dart';
import 'package:meal_recommender/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final FirebaseAuth _auth = FirebaseAuth.instance; // Moved _auth to _LoginState
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  bool _isLoading = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff6aa84f),
                      Color(0xff6aa84f),
                      Color(0xff6aa84f),
                      Color(0xff6aa84f),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 50),
                      buildEmail(),
                      SizedBox(height: 20),
                      buildPassword(),
                      SizedBox(height: 20),
                      buildForgotPasswordButton(context),
                      SizedBox(height: 20),
                      buildLoginBtn(context),
                      SizedBox(height: 20),
                      createNewUser(context),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Email',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]),
            height: 60,
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 14),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.email, color: Color(0xff6aa84f)),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.black38)),
            ))
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Password',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]),
            height: 60,
            child: TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 14),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.lock, color: Color(0xff6aa84f)),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.black38)),
            ))
      ],
    );
  }

  Widget buildLoginBtn(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(vertical:20),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : () async {
              setState(() {
                _isLoading = true;
              });
             // print("HERE");

              try {
                UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );
                if (userCredential.user != null) {
                  // Navigate to HomePage
                  if(emailController.text=='admin@gmail.com'){
                    isAdmin=true;
                  }
                  else isAdmin=false;
                  Fluttertoast.showToast(msg: "Logged in successfully!");
                  mealtype='breakfast';
                  eatenBreakfast='Recommended 255 - 383 kcal';
                  eatenCarbs=0.0;
                  eatenFat=0.0;
                  eatenProtein=0.0;
                  kcalEatenValue=0.0;
                  kcalLeftValue=0.0;
                  PreferencesService().saveData(
                    mealType: mealtype,
                    eatenBreakfast: eatenBreakfast,
                    eatenDinner: eatenDinner,
                    eatenLunch: eatenLunch,
                    eatenCarbs: eatenCarbs,
                    eatenFat: eatenFat,
                    eatenProtein: eatenProtein,
                    kcalEatenValue: kcalEatenValue,
                    kcalLeftValue: kcalLeftValue,
                  );
                  _navigateToHomePage(context);
                }else {
                  Fluttertoast.showToast(msg: "Wrong user credentials! Please try again.");
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  Fluttertoast.showToast(msg: "No user found for that email.");
                } else if (e.code == 'wrong-password') {
                  Fluttertoast.showToast(msg: "Wrong password provided for that user.");
                } else {
                  Fluttertoast.showToast(msg: "Login failed: ${e.message}");
                }
              } catch (e) {
                print(e);
                // You can show a dialog or snackbar here to inform the user about the error
              }
              finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff3ba80b), // Button color
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              )
            ),
            child: Text(
              'LogIn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))  // This is the progress bar
        ],
      ),
    );
  }
  Widget buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showResetPasswordDialog(context),
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }


  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent")),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending password reset email")),
      );
    }
  }


  void _navigateToHomePage(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential.user != null) {
        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text);
        await prefs.setBool('isAdmin', emailController.text == 'admin@gmail.com');

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      print(e);
      // You can show a dialog or snackbar here to inform the user about the error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _navigateToRegisterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  Widget createNewUser(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToRegisterPage(context);
      },
      child: Text(
        'Are you a new user? SignUp',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: "Email"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Send'),
              onPressed: () {
                // Call a method to send reset password email
                _resetPassword(emailController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
