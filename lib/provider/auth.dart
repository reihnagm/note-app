import 'package:mynote/SQlite/db.dart';
import 'package:mynote/common/global.dart';
import 'package:mynote/common/nanoid.dart';
import 'package:mynote/page/note/note.dart';

import 'package:mynote/shared/widgets/dialog.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthNotifier with ChangeNotifier {

  static AndroidOptions getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  
  final storage = FlutterSecureStorage(aOptions: getAndroidOptions());

  Future<void> login({
    required String username,
    required String password
  }) async {

    List<Map<String, dynamic>> login = await DB.login(
      username: username,
      password: password
    );

    if(login.isEmpty) {
      
      GDialog.customShowDialog(title: "User not found");
      return;

    } else {

      Map<String, dynamic> payload = {
        "username": username
      };

      String token = generateToken(payload);

      await saveToken(token);

      await saveUser(userId: login[0]["id"].toString());
            
      Navigator.pushReplacement(navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => const NotePage())
      );

    }
  }

  Future<void> register({
    required String username, 
    required String password
  }) async {

    String userId = NanoID.generate();

    List users = await DB.checkUser(username: username);

    if(users.isEmpty) {
      
      await DB.register(
        id: userId,
        username: username, 
        password: password
      );

      Map<String, dynamic> payload = {
        "username": username
      };

      String token = generateToken(payload);

      await saveToken(token);

      await saveUser(userId: userId);

      Navigator.pushReplacement(navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => const NotePage())
      );

    } else {
      GDialog.customShowDialog(
        title: "User already exist", 
        fontSizeTitle: 16
      );
    }
  }

  Future<bool> isLoggedIn() async {
    String? token = await storage.read(key: "token");
    
    if(token != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> saveUser({
    required String userId,
  }) async {
    storage.write(key: "user_id", value: userId);
  }

  Future<void> saveToken(String token) async {  
    storage.write(key: "token", value: token);
  }

  Future<void> destoryToken() async {
    storage.delete(key: "token");
  }

  String generateToken(Map<String, dynamic> payload) {
    final jwt = JWT(payload,
      issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
    );
    
    final token = jwt.sign(SecretKey("I'DN%_DY{sjR<jt}dQ{e}Ks]0JY+Tt"));

    return token;
  }

}