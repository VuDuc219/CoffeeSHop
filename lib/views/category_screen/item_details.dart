import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/product_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myapp/consts/firebase_consts.dart';

class ItemDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const ItemDetails({Key? key, required this.data}) : super(key: key);

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  late final ProductController controller;
  bool isWishlist = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductController());
    controller.initData(widget.data['p_price'] as List<dynamic>? ?? []);

    // Check if the item is already in the wishlist
    List<dynamic> wishlist = widget.data['p_wishlist'] ?? [];
    isWishlist = wishlist.contains(auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final String productName = widget.data['p_name'] as String? ?? 'No Name';
    final List<dynamic> imageUrls =
        widget.data['p_imgs'] as List<dynamic>? ?? [];
    final List<dynamic> sizes = widget.data['p_size'] as List<dynamic>? ?? [];
    final String description =
        widget.data['p_desc'] as String? ?? 'No description available.';
    final int availableStock =
        int.tryParse(widget.data['p_quantity'].toString()) ?? 0;
    final String docId = widget.data['id'] as String;

    String detailImageUrl = (imageUrls.length > 1)
        ? imageUrls[1]
        : (imageUrls.isNotEmpty ? imageUrls[0] : '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          productName,
          style: const TextStyle(color: darkFontGrey, fontFamily: bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWishlist ? Icons.favorite : Icons.favorite_border,
              color: isWishlist ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isWishlist = !isWishlist;
              });
              if (isWishlist) {
                controller.addToWishlist(docId, context);
              } else {
                controller.removeFromWishlist(docId, context);
              }
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                child: Center(
                  child: detailImageUrl.isNotEmpty
                      ? Image.network(detailImageUrl, fit: BoxFit.contain)
                      : const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                productName,
                style: const TextStyle(
                  fontFamily: bold,
                  fontSize: 24,
                  color: darkFontGrey,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Rating',
                style: TextStyle(
                  fontFamily: bold,
                  fontSize: 18,
                  color: darkFontGrey,
                ),
              ),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  controller.updateUserRating(rating);
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Review Submitted',
                    'You rated this product ${controller.userRating.value} stars.',
                  );
                },
                child: const Text('Submit Review'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sizes',
                style: TextStyle(
                  fontFamily: bold,
                  fontSize: 18,
                  color: darkFontGrey,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(sizes.length, (index) {
                    return ChoiceChip(
                      label: Text(
                        sizes[index].toString(),
                        style: TextStyle(
                          color: controller.sizeIndex.value == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      selected: controller.sizeIndex.value == index,
                      onSelected: (selected) {
                        if (selected) {
                          controller.changeSizeIndex(index);
                        }
                      },
                      selectedColor: Colors.deepPurple,
                      backgroundColor: Colors.grey[200],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontFamily: bold,
                      fontSize: 18,
                      color: darkFontGrey,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.decreaseQuantity,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Obx(
                    () => Text(
                      '${controller.quantity.value}',
                      style: const TextStyle(fontSize: 18, fontFamily: bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        controller.increaseQuantity(availableStock),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  fontFamily: bold,
                  fontSize: 18,
                  color: darkFontGrey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: regular,
                  fontSize: 16,
                  color: fontGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                '${controller.totalPrice.value} VND',
                style: const TextStyle(
                  fontFamily: bold,
                  fontSize: 24,
                  color: redColor,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final String selectedSize = sizes.isNotEmpty
                      ? sizes[controller.sizeIndex.value].toString()
                      : 'Default Size';
                  controller.addToCart(
                    title: productName,
                    img: detailImageUrl,
                    size: selectedSize,
                    qty: controller.quantity.value,
                    tprice: controller.totalPrice.value,
                    context: context,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: golden,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontFamily: bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
