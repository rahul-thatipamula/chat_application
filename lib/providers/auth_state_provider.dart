import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/providers/auth_provider.dart';

// This provider listens to the FirebaseAuth state changes (auth state stream)
final authStateProvider = StreamProvider<UserModel?>((ref) async* {
  // Listen to the authentication state changes in FirebaseAuth
  final authChanges = FirebaseAuth.instance.authStateChanges();

  // For each state change (logged in or logged out), fetch the corresponding user data
  await for (final user in authChanges) {
    if (user != null) {
      // If the user is logged in, fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // If the user document exists in Firestore, return the user model
        UserModel loggedInUser =UserModel.fromJson(userDoc.data() as Map<String, dynamic>); 
        yield loggedInUser;
      } else {
        // If no user document exists in Firestore, return null (or handle it accordingly)
        yield null;
      }
    } else {
      // If the user is logged out, return null
      yield null;
    }
  }
});
