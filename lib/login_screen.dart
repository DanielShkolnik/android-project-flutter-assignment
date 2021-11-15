import 'package:flutter/material.dart';
import 'package:flutter_app_ex1/auth_repository.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';
import 'database.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatelessWidget{

  const LoginScreen({Key? key}) :  super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    return Consumer<AuthRepository> (builder: (context, auth, child){
      return Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 120.0,
                  width: 270.0,
                  padding: const EdgeInsets.only(top: 40),
                  child: const Center(
                    child: Text("Welcome to Startup Names Generator, please login below", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  height: 30.0,
                  width: 190.0,
                  padding: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Name',
                        hintText: 'Enter valid mail id as abc@gmail.com'
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter your secure password'
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                        color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () async {
                        bool isSignIn = await auth.signIn(usernameController.text, passwordController.text);
                        if(isSignIn == true){
                          List<WordPair> savedListFromCloud = await DatabaseService().pullSavedSuggestionsFromCloud(Provider.of<AuthRepository>(context, listen: false).user?.uid);
                          Navigator.of(context).pop(savedListFromCloud);
                        }
                        else{
                          const snackBar = SnackBar(content: Text('There was an error logging into the app'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: auth.status == Status.Authenticating ? CircularProgressIndicator() : const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                        color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () async {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              color: Colors.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Please confirm your password below:'),
                                    ),
                                    TextField(
                                      controller: confirmPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Password',
                                          hintText: 'Enter your secure password',
                                        errorText: (passwordController.text != confirmPasswordController.text) ? "Passwords must match" : null,
                                      ),
                                    ),
                                    ElevatedButton(
                                      child: const Text('Confirm'),
                                      onPressed: () async {
                                        if(passwordController.text == confirmPasswordController.text){
                                          UserCredential? userCredential = await auth.signUp(usernameController.text, passwordController.text);
                                          if(userCredential != null){
                                            List<WordPair> savedListFromCloud = await DatabaseService().pullSavedSuggestionsFromCloud(Provider.of<AuthRepository>(context, listen: false).user?.uid);
                                            Navigator.pop(context);
                                            Navigator.of(context).pop(savedListFromCloud);
                                          }
                                          else{
                                            const snackBar = SnackBar(content: Text('There was an error signing up'));
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('New user? Click to sign up', style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
          )
      );
    });
  }
}



