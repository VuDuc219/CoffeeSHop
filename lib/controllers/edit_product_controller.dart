import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:path/path.dart';

class EditProductController extends GetxController {
  var isloading = false.obs;
  late String docId;

  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController sizeController;
  late TextEditingController saleController;

  var isFeatured = false.obs;
  var pImagesList = Rx<List<XFile>>([]); 
  var pImagesLinks = [].obs; 

  EditProductController(DocumentSnapshot doc) {
    docId = doc.id;
    final data = doc.data() as Map<String, dynamic>;

    nameController = TextEditingController(text: data['p_name'] ?? '');
    descController = TextEditingController(text: data['p_desc'] ?? '');
    priceController = TextEditingController(text: (data['p_price'] as List?)?.join(', ') ?? '');
    quantityController = TextEditingController(text: data['p_quantity'] ?? '');
    sizeController = TextEditingController(text: (data['p_size'] as List?)?.join(', ') ?? '');
    saleController = TextEditingController(text: data['p_sale'] ?? '');
    isFeatured.value = data['is_featured'] ?? false;
    pImagesLinks.value = List<String>.from(data['p_imgs'] ?? []);
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    quantityController.dispose();
    sizeController.dispose();
    saleController.dispose();
    super.onClose();
  }

  pickImages() async {
    try {
      final List<XFile>? images = await ImagePicker().pickMultiImage();
      if (images != null) {
        pImagesList.value = [...pImagesList.value, ...images];
      }
    } on PlatformException catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  uploadImages() async {
    List<String> newImageLinks = [];
    for (var image in pImagesList.value) {
      var filename = basename(image.path);
      var destination = 'images/products/${DateTime.now().millisecondsSinceEpoch}_$filename';
      Reference ref = FirebaseStorage.instance.ref().child(destination);

      if (kIsWeb) {
        await ref.putData(await image.readAsBytes());
      } else {
        await ref.putFile(File(image.path));
      }
      
      var n = await ref.getDownloadURL();
      newImageLinks.add(n);
    }
    return newImageLinks;
  }

  updateProduct(BuildContext context) async {
    isloading(true);
    try {
      List<String> newUploadedLinks = await uploadImages();

      var product = {
        'is_featured': isFeatured.value,
        'p_desc': descController.text,
        'p_imgs': [...pImagesLinks, ...newUploadedLinks], 
        'p_name': nameController.text,
        'p_price': priceController.text.split(',').map((e) => e.trim()).toList(),
        'p_quantity': quantityController.text,
        'p_sale': saleController.text,
        'p_size': sizeController.text.split(',').map((e) => e.trim()).toList(),
      };

      await firestore.collection(productsCollection).doc(docId).update(product);

      isloading(false);
      Get.snackbar('Success', 'Product updated successfully!');
      Get.back();

    } catch (e) {
      isloading(false);
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
    }
  }

  void removeNewImage(int index) {
    var newList = List<XFile>.from(pImagesList.value);
    newList.removeAt(index);
    pImagesList.value = newList;
  }

  void removeOldImage(int index) {
    pImagesLinks.removeAt(index);
  }
}
