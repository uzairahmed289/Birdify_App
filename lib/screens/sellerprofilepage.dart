import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:birdify_flutter/screens/marketplace.dart'; // Make sure to import your BirdDetailPage file

class SellerProfilePage extends StatelessWidget {
  final String sellerUid;

  SellerProfilePage({required this.sellerUid});

  Future<String> _getSellerName() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(sellerUid).get();
    return userDoc['name'] ?? 'Unknown';
  }

  Stream<List<QueryDocumentSnapshot>> _getSellerListings() {
    return FirebaseFirestore.instance
        .collectionGroup('listings')
        .where('uid', isEqualTo: sellerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getSellerName(),
      builder: (context, sellerSnapshot) {
        if (!sellerSnapshot.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));

        final sellerName = sellerSnapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text('$sellerName\'s Profile')),
          body: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: _getSellerListings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No listings found'));

              final listings = snapshot.data!;

              return GridView.builder(
                padding: EdgeInsets.all(10),
                itemCount: listings.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final data = listings[index].data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BirdDetailPage(bird: data, sellerName: sellerName),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                                  ? Image.network(
                                      data['imageUrl'],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Center(child: Text('Image load error')),
                                    )
                                  : Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      alignment: Alignment.center,
                                      child: Text('No image'),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data['name'] ?? data['title']} (${data['species'] ?? data['size'] ?? data['type'] ?? ''})',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (data['price'] != null)
                                  Text('${data['price']} PKR', style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
