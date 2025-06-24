import 'package:birdify_flutter/screens/sellerprofilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chatpage.dart';

class BirdDetailPage extends StatefulWidget {



  BirdDetailPage({required this.bird, required this.sellerName});

  final Map<String, dynamic> bird;
  final String sellerName;

  @override
  State<BirdDetailPage> createState() => _BirdDetailPageState();
}

class _BirdDetailPageState extends State<BirdDetailPage> {

  String getConversationId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return "${sortedIds[0]}_${sortedIds[1]}";
  }

  Future<String> createOrOpenConversation(String currentUserId, String sellerId) async {
    final conversationId = getConversationId(currentUserId, sellerId);
    final docRef = FirebaseFirestore.instance.collection('conversations').doc(conversationId);
    final doc = await docRef.get();

    if (!doc.exists) {
      final sellerSnapshot = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      final buyerSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();

      final sellerName = sellerSnapshot.data()?['name'] ?? 'Seller';
      final buyerName = buyerSnapshot.data()?['name'] ?? 'Buyer';

      await docRef.set({
        'users': [currentUserId, sellerId],
        'buyerId': currentUserId,
        'sellerId': sellerId,
        'buyerName': buyerName,
        'sellerName': sellerName,
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    return conversationId;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bird['name'] ?? widget.bird['title'] ?? 'Listing Detail')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.bird['imageUrl'] != null && widget.bird['imageUrl'].toString().isNotEmpty
                ? Image.network(
              widget.bird['imageUrl'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: Text('Image load error'),
              ),
            )
                : Container(
              height: 250,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text('No image available'),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.bird['title'] ?? widget.bird['name'] ?? widget.bird['species'] ?? widget.bird['size'] ?? widget.bird['type'] ?? ''}'
                        '${widget.bird['gender'] != null ? " • ${widget.bird['gender']}" : ""}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Price: ${widget.bird['price']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Seller: ${widget.sellerName}'),
                  SizedBox(height: 16),
                  if (widget.bird['description'] != null && widget.bird['description'].toString().isNotEmpty)
                    Text('Description:\n${widget.bird['description']}'),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                            final conversationId = await createOrOpenConversation(currentUserId, widget.bird['uid']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(conversationId: conversationId, sellerName: widget.sellerName,),
                              ),
                            );
                          },
                          icon: Icon(Icons.message),
                          label: Text('Contact Seller'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SellerProfilePage(sellerUid: widget.bird['uid']),
                              ),
                            );
                          },
                          icon: Icon(Icons.person),
                          label: Text('Seller Profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
