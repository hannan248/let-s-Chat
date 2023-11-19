import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

const String USER_COLLECTION = 'Users';

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CloudStorageService() {}

  Future<String?> saveUserImageToStorage(String _uid, File _file) async {
    try {
      String extension = _file.path
          .split('.')
          .last; // Extract the extension from the file's path
      Reference _ref =
          _storage.ref().child("images/users/$_uid/profile.$extension");
      UploadTask _task = _ref.putFile(_file);
      return await _task.then(
        (_result) => _result.ref.getDownloadURL(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<String?> saveChatImageToStorage(
      String _chatID, String _userID, File _file) async {
    try {
      String extension = _file.path
          .split('.')
          .last; // Extract the extension from the file's path
      Reference _ref = _storage.ref().child(
          "images/chats/$_chatID/${_userID} ${Timestamp.now().microsecondsSinceEpoch}.$extension");
      UploadTask _task = _ref.putFile(_file);
      return await _task.then(
        (_result) => _result.ref.getDownloadURL(),
      );
    } catch (e) {
      print(e);
    }
  }
}
