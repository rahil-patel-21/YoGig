import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:path/path.dart' as path;

class UserRepository {
  final FirebaseFirestore _firestore;
  DocumentReference _userDocRef;
  String _uid;
  FirebaseStorage _storage;

  UserRepository()
      : _firestore = FirebaseFirestore.instance,
        _storage = FirebaseStorage.instance;

  setUserId(String id) {
    _uid = id;
    _userDocRef = _firestore.collection('users').doc(_uid);
  }

  Future<bool> isNewUser() async {
    try {
      var snapshot = await _userDocRef.get();
      return !snapshot.exists;
    } catch (e) {
      print(
          'error while checking new user code - ${e.code} message - ${e.message}');
      throw e;
    }
  }

  Future<String> uploadUserImage(File userImage) async {
    try {
      var uploadTask = _storage
          .ref()
          .child('$_uid.${path.extension(userImage.path)}')
          .putFile(userImage);
      var snapshot = await uploadTask;
      return (await snapshot.ref.getDownloadURL()).toString();
    } catch (e) {
      throw e;
    }
  }

  Future<UserModel> getUserFromFirebase() async {
    DocumentSnapshot userSnapshot = await _userDocRef.get();
    print(userSnapshot.data);
    final user = UserModel.fromDocumentSnapshot(userSnapshot.data());

    await _saveUserDataToLocalStorage(user);

    return user;
  }

  Future<void> updateUserInfo(UserModel user) async {
    await _userDocRef
        .set(user.toDocument(), SetOptions(merge: true))
        .catchError((error) {
      print(error);
      throw error;
    });

    //Updating HIVE(local database)
    await _saveUserDataToLocalStorage(user);
  }

  Future _saveUserDataToLocalStorage(UserModel user) async {
    Box userBox = await Hive.openBox('userBox');
    await userBox.put(user.userId, user).catchError((error) {
      print('Error saving user to HIVE ${error.toString()}');
    });
  }

  Future<UserModel> getUserFromLocalStorage() async {
    Box userBox = await Hive.openBox('userBox');
    if (userBox.isNotEmpty) {
      final user = userBox.get(_uid) as UserModel;
      return user;
    } else
      return null;
  }
}
