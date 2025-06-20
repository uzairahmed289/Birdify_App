import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdify_flutter/screens/marketplace.dart';
import 'package:birdify_flutter/screens/editlistingpage.dart';


class MyListing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Listings')),
        body: Center(child: Text('You must be logged in to view your listings.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Listings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('listings')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No listings found.'));
          }

          final listings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final doc = listings[index];
              final data = doc.data() as Map<String, dynamic>;

              final parentCollection = doc.reference.parent.parent?.id ?? 'Unknown';
              final type = parentCollection == 'bird'
                  ? 'Bird'
                  : parentCollection == 'cages'
                      ? 'Cage'
                      : parentCollection == 'feed'
                          ? 'Feed'
                          : 'Unknown';

              final title = data['name'] ?? data['title'] ?? 'No Title';
              final price = data['price'] ?? 'N/A';

              return Card(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: ListTile(
    title: Text(title),
    subtitle: Text('Type: $type • Price: $price'),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditListingPage(listing: listings[index]),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Confirm Delete'),
                content: Text('Are you sure you want to delete this listing?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await listings[index].reference.delete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Listing deleted')),
              );
            }
          },
        ),
      ],
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BirdDetailPage(
            bird: data,
            sellerName: 'You',
          ),
        ),
      );
    },
  ),
);

            },
          );
        },
      ),
    );
  }
}
