import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/models/category_model.dart';
import 'dart:developer' as developer;

import 'package:myapp/views/admin_screen/mgmt_product_screen/product_list_screen.dart';

class MgmtProductScreen extends StatefulWidget {
  const MgmtProductScreen({super.key});

  @override
  State<MgmtProductScreen> createState() => _MgmtProductScreenState();
}

class _MgmtProductScreenState extends State<MgmtProductScreen> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
  }

  Future<List<Category>> _loadCategories() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/services/category_model.json',
      );
      final categoryModel = categoryModelFromJson(jsonString);
      return categoryModel.categories;
    } catch (e) {
      developer.log("Error loading categories: $e", name: "MgmtProductScreen");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Products by Category',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          final categories = snapshot.data!;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(category.name),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Get.to(() => ProductListScreen(category: category));
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
