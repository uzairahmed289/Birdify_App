import 'package:birdify_flutter/screens/addbirdlisting.dart';
import 'package:birdify_flutter/screens/addcagelisting.dart';
import 'package:birdify_flutter/screens/addfeedlisting.dart';
import 'package:birdify_flutter/screens/chatpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:birdify_flutter/screens/sellerprofilepage.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'bird_detail_page.dart';

class Marketplace extends StatefulWidget {
  @override
  _MarketplaceState createState() => _MarketplaceState();
}

class _MarketplaceState extends State<Marketplace> {


  final currentUser = FirebaseAuth.instance.currentUser;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  String? _sortOption; // 'lowToHigh' or 'highToLow'
  
final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Birdify Marketplace')),
      body: Column(
  children: [
    SizedBox(height: 10),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
      Expanded(
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by title',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
          },
        ),
      ),
      SizedBox(width: 8),
      IconButton(
        icon: Icon(Icons.filter_list_outlined),
        onPressed: () {
          showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Sort by Price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text("Low to High"),
              leading: Radio<String>(
                value: 'lowToHigh',
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            ListTile(
              title: Text("High to Low"),
              leading: Radio<String>(
                value: 'highToLow',
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ],
        ),
      );
    },
  );
        },
      ),
        ],
      ),
    ),


    SizedBox(height: 10),

    // 🟢 Filter Buttons
    _buildFilterButtons(),

    SizedBox(height: 10),

    // 📦 Listings Grid
    Expanded(
      child: StreamBuilder<List<QueryDocumentSnapshot>>(
  stream: _getFilteredListingsStream(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No listings were found!'));
    }

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

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(data['uid']).get(),
                builder: (context, userSnapshot) {
                  final sellerName = userSnapshot.hasData
                      ? (userSnapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
                      : 'Loading...';

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
                                  '${data['name'] ?? data['title']} (${data['species'] ?? data['size'] ?? data['type']})',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (data['gender'] != null) Text('Gender: ${data['gender']}'),
                                Text(data['price'].toString(), style: TextStyle(color: Colors.green)),
                                Text('Seller: $sellerName', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
          );
        },
      ),
    ),
  ],
),

      floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
  child: FloatingActionButton(
    onPressed: () {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.bird),
                title: Text('Add Bird Listing'),
                onTap: () {
                  Navigator.pop(context); // auto-close
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NewBirdListing()));
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.package),
                title: Text('Add Cage Listing'),
                onTap: () {
                  Navigator.pop(context); // auto-close
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NewCageListing()));
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.utensils),
                title: Text('Add Feed Listing'),
                onTap: () {
                  Navigator.pop(context); // auto-close
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NewFeedListing()));
                },
              ),
            ],
          ),
        ),
      );
    },
    tooltip: 'Post a Listing',
    child: Icon(Icons.add),
  ),
),


    );
  }

 Stream<List<QueryDocumentSnapshot>> _getFilteredListingsStream() {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  // If "All" filter is selected, use collectionGroup
  if (_selectedFilter == 'all') {
    Query query = FirebaseFirestore.instance
        .collectionGroup('listings')
        .where('uid', isNotEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(100);

    return query.snapshots().map((snapshot) {
      final lowerSearch = _searchQuery.toLowerCase();

      List<QueryDocumentSnapshot> filtered = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name']?.toString().toLowerCase() ?? '';
        final title = data['title']?.toString().toLowerCase() ?? '';
        return name.contains(lowerSearch) || title.contains(lowerSearch);
      }).toList();

      if (_sortOption == 'lowToHigh') {
        filtered.sort((a, b) =>
            (a.data() as Map<String, dynamic>)['price']
                .compareTo((b.data() as Map<String, dynamic>)['price']));
      } else if (_sortOption == 'highToLow') {
        filtered.sort((a, b) =>
            (b.data() as Map<String, dynamic>)['price']
                .compareTo((a.data() as Map<String, dynamic>)['price']));
      }
      return filtered;
    });
  }

  // Otherwise, use specific sub-collection
  String collectionPath;
  switch (_selectedFilter) {
    case 'bird':
      collectionPath = 'listings/bird/listings';
      break;
    case 'cage':
      collectionPath = 'listings/cages/listings';
      break;
    case 'feed':
      collectionPath = 'listings/feed/listings';
      break;
    default:
      collectionPath = 'listings/bird/listings';
  }

  Query query = FirebaseFirestore.instance
      .collection(collectionPath)
      .where('uid', isNotEqualTo: uid)
      .orderBy('createdAt', descending: true);

  return query.snapshots().map((snapshot) {
    final lowerSearch = _searchQuery.toLowerCase();

    List<QueryDocumentSnapshot> filtered = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title']?.toString().toLowerCase() ?? '';
      return title.contains(lowerSearch);
    }).toList();

    if (_sortOption == 'lowToHigh') {
      filtered.sort((a, b) =>
          (a.data() as Map<String, dynamic>)['price']
              .compareTo((b.data() as Map<String, dynamic>)['price']));
    } else if (_sortOption == 'highToLow') {
      filtered.sort((a, b) =>
          (b.data() as Map<String, dynamic>)['price']
              .compareTo((a.data() as Map<String, dynamic>)['price']));
    }
    return filtered;
  });
}
  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFilterButton('All', 'all'),
        _buildFilterButton('Birds', 'bird'),
        _buildFilterButton('Cages', 'cage'),
        _buildFilterButton('Feeds', 'feed'),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }
}
