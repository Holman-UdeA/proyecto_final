import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  final String? chatId;

  const MessagesPage({this.chatId, Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState(chatId);
}

class _MessagesPageState extends State<MessagesPage> {
  final String? chatId;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _messageController = TextEditingController();

  _MessagesPageState(this.chatId);

  @override
  Widget build(BuildContext context) {
    return chatId == null ? _buildChatsList() : _buildChatDetail();
  }

  Widget _buildChatsList() {
    return Scaffold(
      appBar: AppBar(title: Text("Mensajes"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("chats")
                .where("users", arrayContains: _currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No tienes chats aún."));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final idChat = chatData["idChat"];
              final lastMessage = chatData["lastMessage"] ?? "";
              final lastTimestamp = chatData["lastTimestamp"];
              final users = List<String>.from(chatData["users"] ?? []);

              final otherUserId = users.firstWhere(
                (uid) => uid != _currentUserId,
                orElse: () => "Desconocido",
              );

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(otherUserId)
                        .get(),
                builder: (context, userSnapshot) {
                  String name = "No data";
                  String? photoUrl;

                  if (userSnapshot.hasData && userSnapshot.data != null) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>?;
                    name = userData?["name"] ?? "Desconocido";
                    photoUrl = userData?["ulrPicture"];
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : const AssetImage(
                                    "assets/images/default_profile.jpg",
                                  )
                                  as ImageProvider,
                    ),
                    title: Text(name),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        lastTimestamp != null
                            ? Text(
                              _formatTimestamp(lastTimestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessagesPage(chatId: idChat),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /*Widget _buildChatDetail() {
    return Scaffold(
      appBar: AppBar(title: Text("Chat"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("chats")
                      .doc(chatId)
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final text = data["text"];
                    final senderId = data["senderId"];
                    final isMe = senderId == _currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF0F8555).withAlpha(100) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0F8555),),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }*/

  Widget _buildChatDetail() {
    return FutureBuilder<DocumentSnapshot>(
      future: _getOtherUserData(),
      builder: (context, snapshot) {
        String title = "Chat";
        String? photoUrl;

        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          title = userData?["name"] ?? "Chat";
          photoUrl = userData?["ulrPicture"];
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : const AssetImage("assets/images/default_profile.jpg") as ImageProvider,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    //style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            titleSpacing: -5,
          ),
          body: Column(
            children: [
              const Divider(height: 0.5, thickness: 1, color: Colors.grey),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .doc(chatId)
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index].data() as Map<String, dynamic>;
                        final text = data["text"];
                        final senderId = data["senderId"];
                        final isMe = senderId == _currentUserId;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Color(0xFF0F8555).withAlpha(100) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(text),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Escribe un mensaje...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF0F8555),size: 30,),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot> _getOtherUserData() async {
    final chatDoc = await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .get();

    final chatData = chatDoc.data() as Map<String, dynamic>;
    final users = List<String>.from(chatData["users"]);
    final otherUserId = users.firstWhere((uid) => uid != _currentUserId);

    return FirebaseFirestore.instance
        .collection("users")
        .doc(otherUserId)
        .get();
  }


  String _formatTimestamp(Timestamp ts) {
    final date = ts.toDate();
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();

    _messageController.clear();

    if (text.isEmpty) return;

    final docRef =
        FirebaseFirestore.instance
            .collection("chats")
            .doc(chatId)
            .collection("messages")
            .doc();

    final message = {
      "idMessage": docRef.id,
      "text": text,
      "senderId": _currentUserId,
      "timestamp": FieldValue.serverTimestamp(),
    };

    //Guardamos en firestore
    await docRef.set(message);

    //Actualizamos la colección chat
    await FirebaseFirestore.instance.collection("chats").doc(chatId).update({
      "lastMessage": text,
      "lastSenderId": _currentUserId,
      "lastTimestamp": FieldValue.serverTimestamp(),
    });
  }
}
