// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';

final uuid = Uuid();

class ConnectionsProvider {
  Future<ChatRoomModel?> getChatRoomModel(UserModel currentUser, UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${currentUser.id}', isEqualTo: true)
        .where('participants.${targetUser.id}', isEqualTo: true)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel chatRoomModel =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = chatRoomModel;
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          currentUser.id.toString(): true,
          targetUser.id.toString(): true,
        },
        users: [currentUser.id.toString(), targetUser.id.toString()],
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }
}
