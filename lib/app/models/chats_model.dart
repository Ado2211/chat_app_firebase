import 'dart:convert';

Chats chatsFromJson(String str) => Chats.fromJson(json.decode(str));

String chatsToJson(Chats data) => json.encode(data.toJson());

class Chats {
  Chats({
    this.connections,
    this.chat,
  });

  List<String>? connections;
  List<Chat>? chat;

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        connections: List<String>.from(json["connections"].map((x) => x)),
        chat: List<Chat>.from(json["chat"].map((x) => Chat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "connections": List<dynamic>.from(connections!.map((x) => x)),
        "chat": List<dynamic>.from(chat!.map((x) => x.toJson())),
      };
}

class Chat {
  Chat({
    this.posiljaoc,
    this.primatelj,
    this.poruka,
    this.time,
    this.isRead,
  });

  String? posiljaoc;
  String? primatelj;
  String? poruka;
  String? time;
  bool? isRead;

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        posiljaoc: json["posiljaoc"],
        primatelj: json["primatelj"],
        poruka: json["poruka"],
        time: json["time"],
        isRead: json["isRead"],
      );

  Map<String, dynamic> toJson() => {
        "posiljaoc": posiljaoc,
        "primatelj": primatelj,
        "poruka": poruka,
        "time": time,
        "isRead": isRead,
      };
}