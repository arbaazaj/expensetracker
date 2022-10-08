import 'package:expensetracker/utils/error_string_interpolation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Textfield controllers.
  final _textEditingControllerEmail = TextEditingController();
  final _textEditingControllerPassword = TextEditingController();

  // Form GlobalKey to manage state of registration and login in.
  final _formKey = GlobalKey<FormState>();

  // Firebase Auth error code variables.
  late bool _authAccountAlreadyExists;
  bool _authUserNotFound = false;
  bool _authWrongPassword = false;

  // Create account with email and password.
  Future<void> createEmailPasswordSignIn(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        Navigator.of(context).pop();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == authFirebaseEmailExist) {
        _authAccountAlreadyExists = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Login using existing email password credentials.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        Navigator.of(context).pop();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == authFirebaseUserNotFound) {
        _authUserNotFound = true;
      } else if (e.code == authFirebaseWrongPassword) {
        _authWrongPassword = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> checkIfSignedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _textEditingControllerEmail,
                    decoration: const InputDecoration(hintText: 'E-mail'),
                    validator: (valueEmail) {
                      if (valueEmail == null || valueEmail.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _textEditingControllerPassword,
                    decoration: const InputDecoration(hintText: 'Password'),
                    validator: (valuePassword) {
                      if (valuePassword == null || valuePassword.isEmpty) {
                        return 'Please enter password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => onPressedLogin(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Login'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => onPressedRegister(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Register',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onPressedLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Processing Data...'),
          duration: Duration(milliseconds: 350)));
      signInWithEmailAndPassword(_textEditingControllerEmail.text,
              _textEditingControllerPassword.text)
          .then((value) {
        if (_authUserNotFound) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'User does not exist. Click register button to create an account!')));
        } else if (_authWrongPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wrong Password, try again!')));
        }
      });
    }
  }

  void onPressedRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Creating Account...'),
          duration: Duration(milliseconds: 500)));
      // Calling create email method.
      createEmailPasswordSignIn(_textEditingControllerEmail.text,
              _textEditingControllerPassword.text)
          .then((value) {
        if (_authAccountAlreadyExists) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Account already exists with that email!')));
        }
      });
    }
  }
}
