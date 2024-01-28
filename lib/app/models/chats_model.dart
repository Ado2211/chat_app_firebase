class ChatMessage {
  final String senderEmail;
  final String messageContent;
  final DateTime timestamp;
  final bool isRead;
  bool isSentByCurrentUser;

  ChatMessage({
    required this.senderEmail,
    required this.messageContent,
    required this.timestamp,
    required this.isRead,
    required this.isSentByCurrentUser,
  });
}