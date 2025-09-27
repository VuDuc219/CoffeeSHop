import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:path/path.dart';

class AddProductController extends GetxController {
  var isloading = false.obs;

  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController sizeController;
  late TextEditingController saleController;

  var isFeatured = false.obs;
  var pImagesList = Rx<List<XFile>>([]);
  List<String> pImagesLinks = [];

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    descController = TextEditingController();
    priceController = TextEditingController();
    quantityController = TextEditingController();
    sizeController = TextEditingController();
    saleController = TextEditingController();
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
        pImagesList.value = images;
      }
    } on PlatformException catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  uploadImages() async {
    pImagesLinks.clear();
    for (var image in pImagesList.value) {
      var filename = basename(image.path);
      var destination = 'images/products/${DateTime.now().millisecondsSinceEpoch}_$filename';
      Reference ref = FirebaseStorage.instance.ref().child(destination);

      if (kIsWeb) {
        // For web, use putData with bytes read from the XFile
        await ref.putData(await image.readAsBytes());
      } else {
        // For mobile, use putFile with the file path
        await ref.putFile(File(image.path));
      }
      
      var n = await ref.getDownloadURL();
      pImagesLinks.add(n);
    }
  }

  uploadProduct(BuildContext context, String category) async {
    isloading(true);
    try {
      await uploadImages();

      var product = {
        'is_featured': isFeatured.value,
        'p_category': category,
        'p_desc': descController.text,
        'p_imgs': pImagesLinks,
        'p_name': nameController.text,
        'p_price': priceController.text.split(',').map((e) => e.trim()).toList(),
        'p_quantity': quantityController.text,
        'p_rating': "",
        'p_sale': saleController.text,
        'p_size': sizeController.text.split(',').map((e) => e.trim()).toList(),
        'p_wishlist': [],
      };

      await firestore.collection(productsCollection).add(product);

      isloading(false);
      Get.snackbar(
        'Success',
        'Product added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(seconds: 1));
      Get.back();

    } catch (e) {
      isloading(false);
      Get.snackbar('Error', 'Failed to upload product: ${e.toString()}');
    }
  }
  
  void removeImage(int index) {
    var newList = List<XFile>.from(pImagesList.value);
    newList.removeAt(index);
    pImagesList.value = newList;
  }
}
