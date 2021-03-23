// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  UserModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      userEmail: fields[3] as String,
      userPhoneNumber: fields[4] as String,
      userPhotoURL: fields[5] as String,
      userAddress: fields[7] as String,
      userBirthday: fields[9] as DateTime,
      dateJoined: fields[10] as DateTime,
    )
      ..membershipId = fields[6] as String
      ..phoneNumberVerified = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.userEmail)
      ..writeByte(4)
      ..write(obj.userPhoneNumber)
      ..writeByte(5)
      ..write(obj.userPhotoURL)
      ..writeByte(6)
      ..write(obj.membershipId)
      ..writeByte(7)
      ..write(obj.userAddress)
      ..writeByte(8)
      ..write(obj.phoneNumberVerified)
      ..writeByte(9)
      ..write(obj.userBirthday)
      ..writeByte(10)
      ..write(obj.dateJoined);
  }

  @override
  
  int get typeId => 0;
}
