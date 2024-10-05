import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/connections_provider.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConnectionsScreen extends StatefulWidget {
  final UserModel currentUser;

  const ConnectionsScreen({super.key, required this.currentUser});

  @override
  State<ConnectionsScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionsScreen> {
  final ConnectionsProvider chatRoomProvider = ConnectionsProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        centerTitle: true,
        title: const Text('All Users'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where("email", isNotEqualTo: FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('An error occurred'),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              if (data.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> userMap =
                        data.docs[index].data() as Map<String, dynamic>;
                    UserModel user = UserModel.fromJson(userMap);

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        onTap: () async {
                          ChatRoomModel? chatRoomModel = await chatRoomProvider.getChatRoomModel(widget.currentUser, user);
                          if (chatRoomModel != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MessageBubble(
                                  targetUser: user,
                                  currentUser: widget.currentUser,
                                  chatRoom: chatRoomModel,
                                ),
                              ),
                            );
                          }
                        },
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: CupertinoTheme.of(context).primaryColor.withOpacity(0.3),
                          child: Text(
                            user.username != null && user.username!.isNotEmpty 
                              ? user.username![0].toUpperCase() 
                              : '?',
                            style: const TextStyle(fontSize: 24, color: Colors.black),
                          ),
                        ),
                        title: Text(
                          user.username ?? 'No name',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Mobile Number: ${user.mobileNumber ?? 'No mobile number'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // Handle message icon press if needed
                          },
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No users available'),
                );
              }
            } else {
              return const Center(
                child: Text('No data'),
              );
            }
          },
        ),
      ),
    );
  }
}
