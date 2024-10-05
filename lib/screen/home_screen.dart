import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/chat_rooms_provider.dart';
import 'package:chat_app/screen/connections.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.userData});
  final UserModel userData;

  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromJson(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsStream = ref.watch(chatRoomsProvider(userData.id!));

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        title: const Text('Chat App'),
        backgroundColor:CupertinoTheme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: chatRoomsStream.when(
          data: (chatRoomsSnapshot) {
            if (chatRoomsSnapshot.docs.isEmpty) {
              return const Center(child: Text('No chat rooms available'));
            }

            return ListView.builder(
              itemCount: chatRoomsSnapshot.docs.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRoomsSnapshot.docs[index];
                ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                    chatRoom.data() as Map<String, dynamic>);

                Map<String, dynamic> participants = chatRoomModel.participants!;
                List<String> participantKeys = participants.keys.toList();

                // Remove current user's ID
                participantKeys.remove(userData.id);

                if (participantKeys.isEmpty) {
                  return const Center(child: Text('No other participants found'));
                }

                // Fetch target user data using a provider
                return Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final userFuture = ref.watch(userByIdProvider(participantKeys[0]));
                        return userFuture.when(
                          data: (targetUser) {
                            if (targetUser == null) {
                              return const Center(child: Text('User not found'));
                            }
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return MessageBubble(
                                        targetUser: targetUser,
                                        currentUser: userData,
                                        chatRoom: chatRoomModel,
                                      );
                                    }),
                                  );
                                },
                                title: Text(
                                  targetUser.username ?? 'Unknown User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: chatRoomModel.lastMessage != null &&
                                        chatRoomModel.lastMessage!.isNotEmpty
                                    ? Text(
                                        chatRoomModel.lastMessage!,
                                        style: const TextStyle(color: Colors.grey),
                                      )
                                    : const Text(
                                        'Say hello to your friend',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, _) => const Center(child: Text('Error fetching user')),
                        );
                      },
                    ),
                  
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(child: Text('Something went wrong')),
        ),
      ),
      floatingActionButton: CupertinoButton.filled(

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConnectionsScreen(currentUser: userData),
            ),
          );
        },
        child: Text('new connections'),
      ),
    );
  }
}
