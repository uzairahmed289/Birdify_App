import 'package:birdify_flutter/screens/addnewlisting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Marketplace extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Birdify Marketplace')),
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
.collection('listings')
.where('uid', isNotEqualTo: currentUser?.uid)
.orderBy('uid')            // order by uid first
.orderBy('createdAt', descending: true)
.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No listings were found!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  ),
                ),
             );
          }

          final listings = snapshot.data!.docs;

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
                    MaterialPageRoute(builder: (_) => BirdDetailPage(bird: data)),
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
                                  child: Text('No image available'),
                                ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['name']} (${data['species']})',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Gender: ${data['gender']}'),
                            Text(data['price'], style: TextStyle(color: Colors.green)),
                            Text(
                              'Seller: ${data['sellerName'] ?? data['seller'] ?? 'Unknown'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewListing()));
        },
        child: Icon(Icons.add),
        tooltip: 'Post a Listing',
      ),
    );
  }
}

class BirdDetailPage extends StatelessWidget {
  final Map<String, dynamic> bird;
  BirdDetailPage({required this.bird});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bird['name'] ?? 'Bird Detail')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bird['imageUrl'] != null && bird['imageUrl'].toString().isNotEmpty
                ? Image.network(
                    bird['imageUrl'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
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
                  Text('${bird['species']} • ${bird['gender']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Price: ${bird['price']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Seller: ${bird['sellerName'] ?? bird['seller'] ?? 'Unknown'}'),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add contact seller logic
                    },
                    icon: Icon(Icons.message),
                    label: Text('Contact Seller'),
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
