import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/models/category_model.dart';
import 'package:myapp/views/category_screen/category_details.dart';
import 'dart:developer' as developer;

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  Future<List<Category>> _loadCategories() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/services/category_model.json',
      );
      final categoryModel = categoryModelFromJson(jsonString);
      return categoryModel.categories;
    } catch (e) {
      developer.log("Error loading categories: $e", name: "CategoryScreen");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(fontFamily: bold, color: darkFontGrey, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Category>>(
        future: _loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Could not load categories.", style: TextStyle(color: darkFontGrey)),
            );
          }

          final categories = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: InkWell(
                    onTap: () {
                      Get.to(() => CategoryDetails(title: category.name));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            'assets/images/${category.name.toLowerCase().replaceAll(' ', '_')}.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                category.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: semibold,
                                  color: darkFontGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
