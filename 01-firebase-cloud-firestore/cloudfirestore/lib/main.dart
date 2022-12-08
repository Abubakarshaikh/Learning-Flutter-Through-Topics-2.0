import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:cloudfirestore/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
            bodyText2: TextStyle(
          // color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        )),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade600),
        iconTheme: const IconThemeData(color: Colors.white),
        // cardColor: Colors.red.shade600,
      ),
      home: const ProductsScreen(),
    );
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Products")),
        body: StreamBuilder<QuerySnapshot?>(
          stream: FirebaseFirestore.instance.collection("products").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final docs = snapshot.data!.docs;
              return ProductsGrid(queryDocs: docs);
            } else {
              return const Center(
                child: Text("Loading .."),
              );
            }
          },
        ),
      );
}

class ProductsGrid extends StatelessWidget {
  final List<QueryDocumentSnapshot> queryDocs;
  const ProductsGrid({
    Key? key,
    required this.queryDocs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: MediaQuery.of(context).size.width >= 480
          ? const EdgeInsets.symmetric(horizontal: 32, vertical: 32)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: queryDocs.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220.0,
        crossAxisSpacing: MediaQuery.of(context).size.width >= 480 ? 16 : 12,
        mainAxisSpacing: MediaQuery.of(context).size.width >= 480 ? 16 : 12,
      ),
      itemBuilder: (context, index) {
        final product = Product.fromSnapshot(queryDocs.elementAt(index));
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Builder(builder: (context) {
                  return CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: product.imageUrl,
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("PKR ${product.price}"),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Product {
  final String imageUrl;

  final String name;

  final int price;
  Product({
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  factory Product.fromSnapshot(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    return Product(
      imageUrl: map['imageUrl'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toInt() ?? 0,
    );
  }
}
