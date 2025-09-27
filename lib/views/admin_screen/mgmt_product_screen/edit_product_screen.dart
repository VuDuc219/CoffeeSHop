import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/edit_product_controller.dart';

class EditProductScreen extends StatelessWidget {
  final DocumentSnapshot productData;

  const EditProductScreen({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    final EditProductController controller = Get.put(EditProductController(productData));

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Product', style: TextStyle(color: Colors.white)),
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
                        controller.updateProduct(context);
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
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.descController,
                      maxLines: 3,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Price (comma-separated)', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.priceController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sizes (comma-separated)', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.sizeController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sale Percentage', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: controller.saleController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
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
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.pImagesLinks.length + controller.pImagesList.value.length,
                                itemBuilder: (context, index) {
                                  bool isOldImage = index < controller.pImagesLinks.length;
                                  ImageProvider imageProvider;
                                  if (isOldImage) {
                                    imageProvider = NetworkImage(controller.pImagesLinks[index]);
                                  } else {
                                    final newImage = controller.pImagesList.value[index - controller.pImagesLinks.length];
                                    imageProvider = kIsWeb ? NetworkImage(newImage.path) : FileImage(File(newImage.path)) as ImageProvider;
                                  }
                                  
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(4),
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                        onPressed: () {
                                          if (isOldImage) {
                                            controller.removeOldImage(index);
                                          } else {
                                            controller.removeNewImage(index - controller.pImagesLinks.length);
                                          }
                                        },
                                        splashRadius: 20,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => controller.pickImages(),
                                icon: const Icon(Icons.add_a_photo),
                                label: const Text('Add New Images'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown.shade100,
                                  foregroundColor: Colors.brown,
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
