import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// UserProvider class for handling user authentication and user-related data
class AuthProvider extends StateNotifier<UserModel?> {
  AuthProvider() : super(null);

  // Sign-in method
  Future<bool> signIn(String email, String password,BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // Fetch user data from Firestore based on the authenticated user
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
   
      if (userDoc.exists) {
        UserModel user = UserModel.fromJson(userDoc as Map<String, dynamic>); // Create a UserModel from the user document
        state = user; // Update the state with the signed-in user
        return true;
      } else {
        // Handle case where user document does not exist
        state = null;
        return false;
      }
    } catch (e) {
   
      state = null;
      return false;
    }
  }

  // Sign-out method
  Future<void> signOut(BuildContext context)async {
    try {
      await FirebaseAuth.instance.signOut();
      state = null; // Clear user state
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign-out error: ${e.toString()}'),
        ));
    }
  }

  // Register method
  Future<bool> register(String email, String password, String username, String mobileNumber,BuildContext context)async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'mobileNumber': mobileNumber,
        'id': userCredential.user!.uid,
    
      });

      UserModel user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        username: username,
        mobileNumber: mobileNumber,
    
      );

      state = user; // Update state with the newly registered user
      return true;
    } catch (e) {
      // Handle registration error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration error: ${e.toString()}'),
      ));
           state = null;
      return false;
    }
  }
}

// UserProvider StateNotifierProvider
final authProvider = StateNotifierProvider<AuthProvider, UserModel?>((ref) {
  return AuthProvider();
});
