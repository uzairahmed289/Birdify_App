import 'package:birdify_flutter/constants/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'chatpage.dart';

class Inboxpage extends StatefulWidget {
  const Inboxpage({super.key});

  @override
  State<Inboxpage> createState() => _InboxpageState();
}

class _InboxpageState extends State<Inboxpage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        title: Text("Inbox"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('users', arrayContains: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final conversations = snapshot.data!.docs;

          if (conversations.isEmpty) {
            return Center(child: Text("No conversations yet."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final doc = conversations[index];
              final isCurrentUserSeller = doc['sellerId'] == currentUserId;
              final otherUserName = isCurrentUserSeller ? doc['buyerName'] : doc['sellerName'];
              final lastMessage = doc['lastMessage'] ?? '';
              final timestamp = doc['timestamp'] as Timestamp?;

              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 0,
                          offset: const Offset(0, 0)),
                    ],
                  ),
                  child:  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      otherUserName.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      timestamp != null ? formatTimestamp(timestamp) : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            conversationId: doc.id,
                            sellerName: otherUserName,
                          ),
                        ),
                      );
                    },
                  ));
            },
          );
        },
      ),
    );
  }
  String formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final formatter = DateFormat('MMM dd hh:mm a'); // e.g., Jun 25 03:15 PM
    return formatter.format(dt);
  }
}