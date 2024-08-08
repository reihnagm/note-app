import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mynote/SQlite/db.dart';
import 'package:mynote/enum/enum.dart';

import 'package:flutter/material.dart';

class NoteNotifier with ChangeNotifier {

  static AndroidOptions getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  
  final storage = FlutterSecureStorage(aOptions: getAndroidOptions());

  Timer? debounce;
  late TextEditingController searchC;

  String progressCallbackImportMediaQuill = "0.0";

  bool loadingCallbackImportMediaQuill = false;

  ProviderState _providerState = ProviderState.idle;
  ProviderState get providerState => _providerState;

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> get notes => [..._notes];

  Map<String, dynamic> _note = {};
  Map<String, dynamic> get note => _note;

  void setStateLoading(bool isLoading) {
    loadingCallbackImportMediaQuill = isLoading;

    notifyListeners();
  }

  void setStateProgress(String progress) {
    progressCallbackImportMediaQuill = progress;

    notifyListeners();
  }

  void clearProgress() {
    progressCallbackImportMediaQuill = "0.0";

    notifyListeners();
  }

  Future<void> reset() async {
    _notes.clear();
    notifyListeners();
  }

  Future<void> getNotes() async {
    _providerState = ProviderState.loading;
    notifyListeners();

    try {

      String? userId = await getUserId();

      List<Map<String, dynamic>> dataNotes = await DB.getNotes(
        title: '', 
        userId: userId.toString()
      );
      
      _notes = [];
      _notes.addAll(dataNotes);

      _providerState = ProviderState.loaded;
      notifyListeners();

      if(notes.isEmpty) {
        _providerState = ProviderState.empty;
        notifyListeners();
      }
      
    } catch(e) {
      debugPrint(e.toString());

      _providerState = ProviderState.error;
      notifyListeners();
    }
  } 

  Future<void> getNote({
    required String noteId 
  }) async {
    _providerState = ProviderState.loading;
    notifyListeners();

    try {
      List<Map<String, dynamic>> dataNotes = await DB.getNote(noteId: noteId);

      _note = dataNotes[0];

      _providerState = ProviderState.loaded;
      notifyListeners();

      if(note.isEmpty) {
        _providerState = ProviderState.empty;
        notifyListeners();
      }

    } catch(e) {
      debugPrint(e.toString());
      
      _providerState = ProviderState.error;
      notifyListeners();
    }
  }

  Future<void> storeNote({
    required String id,
    required String noteId,
    required String contentId,
    required String title,
    required String content,
    required String contentJson,
    required String date,
    required String reminderDate
  }) async {

    String? userId = await getUserId();
    
    try {

      await DB.storeNote(
        id: noteId, 
        title: title, 
        date: date,
        reminderDate: reminderDate,
        userId: userId.toString()
      );

      await DB.storeContent(
        id: contentId, 
        content: content,
        contentJson: contentJson,
      );

      await DB.storeNoteContent(
        id: id, 
        noteId: noteId, 
        contentId: contentId,
      );

    } catch(e) {
      debugPrint(e.toString());
    }

  }

  Future<void> pinned({
    required String noteId
  }) async {
    try {

      await DB.pinned(noteId: noteId);

      getNotes();

    } catch(e) {
      debugPrint(e.toString());
    }
  }

  Future<void> unpinned({
    required String noteId
  }) async {
    try {

      await DB.unpinned(noteId: noteId);
      
      getNotes();

    } catch(e) {
      debugPrint(e.toString());
    }
  }

  Future<void> searchNote() async {
    _providerState = ProviderState.loading;
    notifyListeners();

    if (debounce?.isActive ?? false) debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 500), () async {

        String? userId = await getUserId();

        List<Map<String, dynamic>> dataNotes = await DB.getNotes(title: searchC.text, userId: userId.toString());
        
        _notes = [];
        _notes.addAll(dataNotes);

        _providerState = ProviderState.loaded;
        notifyListeners();

        if(notes.isEmpty) {
          _providerState = ProviderState.empty;
          notifyListeners();
        }

      });
  }

  Future<void> updateNote({
    required String noteId, 
    required String contentId,
    required String title, 
    required String content,
    required String contentJson
  }) async {

    try {

      await DB.updateNote(
        noteId: noteId, contentId: contentId, title: title, 
        content: content, contentJson: contentJson
      );

    } catch(e) {
      debugPrint(e.toString());
    }

  }

  Future<void> destroyNote({
    required String noteId,
    required String contentId,
  }) async {

    try {

      await DB.destoryNote(
        noteId: noteId, 
        contentId: contentId
      );
      
      getNotes();

    } catch(e) {
      debugPrint(e.toString());
    }

  }

  Future<String?> getUserId() async {
    return await storage.read(key: "user_id");
  }

}