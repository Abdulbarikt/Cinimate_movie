import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../services/api/apikey.dart';
import '../../../../utils/colors.dart';

class WishList extends StatelessWidget {
  const WishList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.kBlackColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBlackColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Wishlist",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.kWhite,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('wishlist')
            .doc(user!.uid)
            .collection("spwish")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];
                return WishListCard(
                  onRemove: () {
                    deleteWishListCard(user.uid, data.id);
                  },
                  title: data['movie'],
                  subtitle: data['description'],
                  imageUrl: data['image'],
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}

Future<void> deleteWishListCard(String userId, String docId) async {
  try {
    await FirebaseFirestore.instance
        .collection('wishlist')
        .doc(userId)
        .collection("spwish")
        .doc(docId)
        .delete();
    print('Wishlist card deleted successfully');
  } catch (error) {
    print('Error deleting wishlist card: $error');
  }
}

class WishListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onRemove;

  const WishListCard({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      color: AppColors.kWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              "${ApiKey.imagePath}$imageUrl",
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              subtitle!,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            trailing: IconButton(
              onPressed: onRemove,
              icon: const Icon(
                CupertinoIcons.delete,
                color: AppColors.kPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
