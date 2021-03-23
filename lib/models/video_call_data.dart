class VideoCallData {
  bool calling;
  String userName, userId, userPhotoURL;
  String conversationId;
  String messageId;
  String roomName;

  VideoCallData(
      {this.calling,
      this.userId,
      this.userName,
      this.userPhotoURL,
      this.roomName,
      this.conversationId,
      this.messageId});
}
