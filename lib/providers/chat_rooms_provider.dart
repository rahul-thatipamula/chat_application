import 'dart:developer';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for fetching chat rooms for a user
final chatRoomsProvider = StreamProvider.family<QuerySnapshot, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('chatrooms')
      .where('users', arrayContains: userId)
      // .orderBy('createdAt') // Uncomment if you have a 'createdAt' field
      .snapshots();
});

// Provider for fetching user by ID
final userByIdProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  try {
    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (docSnap.exists) {
      return UserModel.fromJson(docSnap.data() as Map<String, dynamic>);
    }
  } catch (e) {
    log('Error fetching user by ID: $e');
  }
  return null; // Return null if there's an issue
});
