import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final uid = Uuid();

class MessageBubble extends StatefulWidget {
  final UserModel targetUser;
  final UserModel currentUser;
  final ChatRoomModel chatRoom;

  MessageBubble({
    super.key,
    required this.targetUser,
    required this.currentUser,
    required this.chatRoom,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final messageController = TextEditingController();

  void sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    final chatRoomId = widget.chatRoom.chatRoomId;

    MessageModel newMessage = MessageModel(
      id: uid.v1(),
      sender: widget.currentUser.id,
      time: DateTime.now(),
      text: message,
    );

    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(newMessage.id)
        .set(newMessage.toMap());
    messageController.clear();

    widget.chatRoom.lastMessage = message;
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .set(widget.chatRoom.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 20),
            Text(widget.targetUser.username!),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatrooms')
                    .doc(widget.chatRoom.chatRoomId)
                    .collection('messages')
                    .orderBy('time', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatMessages = snapshot.data!;
                      return ListView.builder(
                        reverse: true,
                        itemCount: chatMessages.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                            chatMessages.docs[index].data() as Map<String, dynamic>,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: currentMessage.sender == widget.currentUser.id
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    bottom: 6,
                                    right: currentMessage.sender == widget.currentUser.id ? 10 : 0,
                                    left: currentMessage.sender != widget.currentUser.id ? 10 : 0,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: currentMessage.sender == widget.currentUser.id
                                        ? Colors.blue[200]
                                        : Colors.green[200],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    currentMessage.text!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: currentMessage.sender == widget.currentUser.id
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    } else {
                      return Center(child: Text('Say hi to your new friend'));
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
