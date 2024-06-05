import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProviders with ChangeNotifier {
  bool _isLoggedIn = false;
  User? _user; // Declare a user variable

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user; // Define a getter for the user

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  final _prefs = SharedPreferences.getInstance();
  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isLoggedIn = true;
      await _saveLoginStatus(true);
      notifyListeners();
    } catch (error) {
      _isLoggedIn = false;
      await _saveLoginStatus(false);
      print('Login Error: $error');
      throw error;
    }
  }
  Future<void> _saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    if (isLoggedIn && _user != null) {
      await prefs.setString('uid', _user!.uid);
      await prefs.setString('displayName', _user!.displayName ?? '');
      await prefs.setString('photoURL', _user!.photoURL ?? '');
      await prefs.setString('phoneNumber', _user!.phoneNumber ?? '');
    } else {
      await prefs.remove('uid');
      await prefs.remove('displayName');
      await prefs.remove('photoURL');
      await prefs.remove('phoneNumber');
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set isLoggedIn to true after successful signup
      _isLoggedIn = true;
      // Update the user variable with the newly created user
      _user = userCredential.user;
      notifyListeners();
      await _saveLoginStatus(true);
    } catch (error) {
      // Handle signup errors, if any
      print('Signup Error: $error');
      throw error; // Rethrow the error to handle it in the UI
    }
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    await _auth.signOut();
    await prefs.remove('uid');
    await prefs.remove('displayName');
    await prefs.remove('photoURL');
    await prefs.remove('phoneNumber');
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _user = _auth.currentUser;
      // Listen to auth state changes to ensure real-time updates
      _auth.authStateChanges().listen((User? user) {
        if (user == null) {
          _isLoggedIn = false;
        } else {
          _isLoggedIn = true;
          _user = user;
        }
        notifyListeners();
      });

      // Retrieve user details from SharedPreferences
      if (_user != null) {
        await prefs.setString('uid', _user!.uid);
        await prefs.setString('displayName', _user!.displayName ?? '');
        await prefs.setString('photoURL', _user!.photoURL ?? '');
        await prefs.setString('phoneNumber', _user!.phoneNumber ?? '');
      }
    } else {
      _user = null;
    }

    notifyListeners();
    return _isLoggedIn;
  }

  Future<void> initialize() async {
    await checkAuthStatus();
  }
}
