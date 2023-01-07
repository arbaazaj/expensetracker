import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/helper/gravatar.dart';
import 'package:expensetracker/models/user_model.dart';
import 'package:expensetracker/pages/homepage.dart';
import 'package:expensetracker/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController authController = Get.find();
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> firestoreUser = Rxn<UserModel>();
  final RxBool admin = false.obs;

  @override
  void onReady() {
    super.onReady();
    ever(firebaseUser, handleAuthChanged);
    firebaseUser.bindStream(user);
  }

  handleAuthChanged(firebaseUser) async {
    if (firebaseUser?.uid != null) {
      firestoreUser.bindStream(streamFirestoreUser());
      // await isAdmin();
    }

    if (firebaseUser == null) {
      Get.offAll(const LoginPage());
    } else {
      Get.offAll(const HomePage());
    }
  }

  // Firebase user one-time fetch
  Future<User> get getUser async => _auth.currentUser!;

  // Firebase user a realtime stream
  Stream<User?> get user => _auth.authStateChanges();

  // Streams the firestore user from the firestore collection
  Stream<UserModel> streamFirestoreUser() {
    return _db
        .doc('/users/${firebaseUser.value!.uid}')
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot.data()!));
  }

  // Get the firestore user from the firestore collection
  Future<UserModel> getFirestoreUser() {
    return _db.doc('/users/${firebaseUser.value!.uid}').get().then(
        (documentSnapshot) => UserModel.fromMap(documentSnapshot.data()!));
  }

  register(BuildContext context) async {
    // showLoadingIndicator();
    try {
      await _auth
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((result) async {
        Gravatar gravatar = Gravatar(emailController.text);
        String gravatarUrl = gravatar.imageUrl(
            size: 200,
            defaultImage: GravatarImage.retro,
            rating: GravatarRating.pg,
            fileExtension: true);

        UserModel newUser = UserModel(
          uid: result.user!.uid,
          email: result.user!.email!,
          name: nameController.text,
          photoUrl: gravatarUrl
        );

        // _createUserFirestore(newUser, result.user!);
        // emailController.clear();
        // passwordController.clear();
        // hideLoadingIndicator();
      });
    } on FirebaseAuthException catch (error) {
      //hideLoadingIndicator();
      Get.snackbar("About User", error.message!,
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text(
            "Account creation failed",
            style: TextStyle(color: Colors.white),
          ),
          messageText:
              Text(error.toString(), style: const TextStyle(color: Colors.white)));
    }
  }

  login(BuildContext context) async {
    //showLoadingIndicator();
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      emailController.clear();
      passwordController.clear();
      //hideLoadingIndicator();
    } catch (error) {
      //hideLoadingIndicator();
      Get.snackbar("About Login", "Login message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text(
            "Login failed",
            style: TextStyle(color: Colors.white),
          ),
          messageText: Text(error.toString(),
              style: const TextStyle(color: Colors.white)));
    }
  }

  void logout() async {
    await _auth.signOut();
  }
}
