import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/add_product_controller.dart';
import 'package:myapp/models/category_model.dart';

class AddProductScreen extends StatelessWidget {
  final Category category;

  const AddProductScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final AddProductController controller = Get.put(AddProductController());

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: const Text('Add New Product', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.brown,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              controller.isloading.value
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : TextButton(
                      onPressed: () {
                        controller.uploadProduct(context, category.name);
                      },
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
                    )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(hintText: 'e.g., Iced Cappuccino', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.descController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'A refreshing and cool sensation', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Price (comma-separated)', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.priceController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'e.g., 40000, 50000, 60000', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sizes (comma-separated)', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.sizeController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'e.g., S, M, L', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g., 100', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sale Percentage', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.saleController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g., 15 for 15%', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Featured Product', style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() => Switch(
                              value: controller.isFeatured.value,
                              onChanged: (value) {
                                controller.isFeatured.value = value;
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Obx(() => Column(
                          children: [
                            if (controller.pImagesList.value.isNotEmpty)
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.pImagesList.value.length,
                                  itemBuilder: (context, index) {
                                    final image = controller.pImagesList.value[index];
                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(4),
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: kIsWeb
                                                  ? NetworkImage(image.path) // For web
                                                  : FileImage(File(image.path)) as ImageProvider, // For mobile
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                          onPressed: () => controller.removeImage(index),
                                          splashRadius: 20,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => controller.pickImages(),
                                icon: const Icon(Icons.cloud_upload_outlined),
                                label: const Text('Upload Images'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown.shade100,
                                  foregroundColor: Colors.brown,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
