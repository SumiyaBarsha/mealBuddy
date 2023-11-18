import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              print("HERE");

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
                  print(isAdmin);
                  _navigateToHomePage(context);
                }
              } catch (e) {
                print(e);
                // You can show a dialog or snackbar here to inform the user about the error
              } finally {
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
}
