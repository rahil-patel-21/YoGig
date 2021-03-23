import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  String userEmail;

  @HiveField(4)
  String userPhoneNumber;

  @HiveField(5)
  String userPhotoURL;

  @HiveField(6)
  String membershipId;

  @HiveField(7)
  String userAddress;

  bool emailVerified;

  @HiveField(8)
  bool phoneNumberVerified;

  @HiveField(9)
  DateTime userBirthday;

  @HiveField(10)
  DateTime dateJoined;

  UserModel(this.userId,
      {this.firstName,
      this.lastName,
      this.userEmail,
      this.userPhoneNumber,
      this.userPhotoURL,
      this.userAddress,
      this.userBirthday,
      this.dateJoined,
      this.emailVerified});

  UserModel.fromFirebaseUser(User user)
      : this.userId = user.uid,
        this.emailVerified = user.emailVerified,
        this.userEmail = user.email,
        this.userPhoneNumber = user.phoneNumber,
        this.userPhotoURL = user.photoURL;

  UserModel.fromDocumentSnapshot(Map<String, dynamic> data)
      : this.userId = data['userId'],
        this.firstName = data['firstName'],
        this.lastName = data['lastName'],
        this.userEmail = data['userEmail'],
        this.userAddress = data['userAddress'],
        this.userBirthday = (data['userBirthday'] as Timestamp).toDate(),
        this.userPhoneNumber = data['userPhoneNumber'],
        this.userPhotoURL = data['userPhotoURL'],
        this.dateJoined = (data['dateJoined'] as Timestamp).toDate(),
        this.membershipId = data['membershipId'];

  Map<String, Object> toDocument() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'userEmail': userEmail,
      'userPhoneNumber': userPhoneNumber,
      'userAddress': userAddress,
      'userBirthday': Timestamp.fromDate(userBirthday),
      'dateJoined':FieldValue.serverTimestamp(),
      'userPhotoURL': userPhotoURL
    };
  }
}
