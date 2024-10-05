import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? sender;
  String? text;
  DateTime? time;
  String? id;

  MessageModel({this.id, this.sender, this.text, this.time});

  MessageModel.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    sender = data['sender'];
    text = data['text'];
    time:
    (data['time'] as Timestamp).toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': id,
      'sender': sender,
      'text': text,
      'time': Timestamp.fromDate(time!),
    };
  }
}