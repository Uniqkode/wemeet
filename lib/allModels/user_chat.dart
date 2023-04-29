import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/allConstants/firestore_constants.dart';

class UserChat {
  String id;
  String nickname;
  String photoUrl;
  String aboutMe;
  String phoneNumber;

  UserChat({
    required this.id,
    required this.aboutMe,
    required this.nickname,
    required this.photoUrl,
    required this.phoneNumber,
  });
  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.id: id,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.phoneNumber: phoneNumber,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    String phoneNumber = "";
    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      phoneNumber = doc.get(FirestoreConstants.phoneNumber);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    return UserChat(
        id: doc.id,
        aboutMe: aboutMe,
        nickname: nickname,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber);
  }
}
