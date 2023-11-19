import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';
import '../providers/authentication_provider.dart';
import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;
  AuthenticationProvider _auth;
  ScrollController _messageListViewController;
  String _chatId;
  List<ChatMessage>? messages;
  late StreamSubscription _messageStream;
  late StreamSubscription _keyboardVisibilityStream;
  late KeyboardVisibilityController _keyboardVisibilityController;
  String? _message;
  bool _isDeleting = false;

  bool get isDeleting => _isDeleting;

  String get message {
    return message;
  }

  set message(String _value) {
    _message = _value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messageListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();
    ListenToMessage();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _messageStream.cancel();
    _keyboardVisibilityStream.cancel();
    super.dispose();
  }

  void ListenToMessage() {
    try {
      _messageStream = _db.streamMessageForChat(_chatId).listen(
            (_snapshot) {
          List<ChatMessage> _messages = _snapshot.docs.map(
                (_m) {
              Map<String, dynamic> _messageData =
              _m.data() as Map<String, dynamic>;
              return ChatMessage.fromJSON(_messageData);
            },
          ).toList();
          messages = _messages;
          notifyListeners();
          WidgetsBinding.instance!.addPostFrameCallback(
                (_) {
              if (_messageListViewController.hasClients) {
                _messageListViewController.jumpTo(
                    _messageListViewController.position.maxScrollExtent);
              }
            },
          );
        },
      );
    } catch (e) {
      print("getting Error");
      print(e);
    }
  }

  void listenToKeyboardChanges() {
    _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
          (_event) {
        _db.updateChatData(_chatId, {"is_activity": _event});
      },
    );
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.TEXT,
        senderID: _auth.user.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, _messageToSend);
    }
  }

  Future<void> sendImageMessage() async {
    try {
      File? _file = await _media.pickImageFromLibrary();
      if (_file != null) {
        String? _downloadURl = await _storage.saveChatImageToStorage(
            _chatId, _auth.user.uid, _file);
        ChatMessage _messageToSend = ChatMessage(
          senderID: _auth.user.uid,
          type: MessageType.IMAGE,
          content: _downloadURl!,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(_chatId, _messageToSend);
      }
    } catch (e) {
      print("error Sending Image Message");
      print(e);
    }
  }

  void deleteChatWithProgress() async {
    try {
      // Set the state to indicate that deletion is in progress
      _isDeleting = true;
      notifyListeners();

      // Perform the delete operation
      await deleteChat();


    } catch (e) {
      print("Error deleting chat: $e");
    } finally {
      // Reset the state after deletion (success or failure)
      _isDeleting = false;
      notifyListeners();
    }
  }


  Future<void> deleteChat() async {
    goBack();
    await _db.deleteChat(_chatId);
  }


  void goBack() {
    _navigation.goBack();
  }
}
