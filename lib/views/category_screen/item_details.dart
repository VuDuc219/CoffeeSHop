import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/product_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/controllers/item_details_controller.dart';

class ItemDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const ItemDetails({super.key, required this.data});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  late final ProductController productController;
  late final ItemDetailsController ratingController;
  bool isWishlist = false;
  double _currentRating = 0.0;

  @override
  void initState() {
    super.initState();
    productController = Get.put(ProductController());
    productController.initData(
      widget.data['p_price'] as List<dynamic>? ?? [],
      widget.data['p_sale'],
    );

    ratingController = Get.put(ItemDetailsController(productId: widget.data['id']));

    List<dynamic> wishlist = widget.data['p_wishlist'] ?? [];
    if (auth.currentUser != null) {
      isWishlist = wishlist.contains(auth.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String productName = widget.data['p_name'] as String? ?? 'No Name';
    final List<dynamic> imageUrls = widget.data['p_imgs'] as List<dynamic>? ?? [];
    final List<dynamic> sizes = widget.data['p_size'] as List<dynamic>? ?? [];
    final String description = widget.data['p_desc'] as String? ?? 'No description available.';
    final int availableStock = int.tryParse(widget.data['p_quantity'].toString()) ?? 0;
    final String docId = widget.data['id'] as String;

    String detailImageUrl = (imageUrls.length > 1) ? imageUrls[1] : (imageUrls.isNotEmpty ? imageUrls[0] : '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(productName, style: const TextStyle(color: darkFontGrey, fontFamily: bold)),
        actions: [
          IconButton(
            icon: Icon(isWishlist ? Icons.favorite : Icons.favorite_border, color: isWishlist ? Colors.red : Colors.black),
            onPressed: () {
              if (auth.currentUser == null) {
                Get.snackbar("Login Required", "You must be logged in to manage your wishlist.");
                return;
              }
              setState(() {
                isWishlist = !isWishlist;
              });
              if (isWishlist) {
                productController.addToWishlist(docId, context);
              } else {
                productController.removeFromWishlist(docId, context);
              }
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (ratingController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
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
                        : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Text(productName, style: const TextStyle(fontFamily: bold, fontSize: 24, color: darkFontGrey)),
                const SizedBox(height: 10),
                Obx(() => Row(
                      children: [
                        RatingBar.builder(
                          initialRating: ratingController.avgRating.value,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          ignoreGestures: true, // Read-only
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(width: 10),
                        Text("(${ratingController.ratingCount.value} Ratings)", style: const TextStyle(fontFamily: semibold, color: fontGrey)),
                      ],
                    )),
                const SizedBox(height: 10),
                Obx(() {
                  int originalPrice = productController.getOriginalPrice();
                  int finalPrice = productController.totalPrice.value;
                  bool onSale = productController.salePercentage.value > 0;
                  if (!onSale) {
                    return Text('${finalPrice}đ', style: const TextStyle(fontFamily: bold, fontSize: 24, color: redColor));
                  }
                  return Row(
                    children: [
                      Text('${originalPrice}đ', style: const TextStyle(fontSize: 20, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 8),
                      Text('${finalPrice}đ', style: const TextStyle(fontFamily: bold, fontSize: 24, color: redColor)),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                _buildUserRatingSection(),
                const SizedBox(height: 20),
                const Text('Sizes', style: TextStyle(fontFamily: bold, fontSize: 18, color: darkFontGrey)),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(sizes.length, (index) {
                        return ChoiceChip(
                          label: Text(sizes[index].toString(), style: TextStyle(color: productController.sizeIndex.value == index ? Colors.white : Colors.black)),
                          selected: productController.sizeIndex.value == index,
                          onSelected: (selected) {
                            if (selected) productController.changeSizeIndex(index);
                          },
                          selectedColor: Colors.deepPurple,
                          backgroundColor: Colors.grey[200],
                        );
                      }),
                    )),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Quantity', style: TextStyle(fontFamily: bold, fontSize: 18, color: darkFontGrey)),
                    const Spacer(),
                    IconButton(onPressed: productController.decreaseQuantity, icon: const Icon(Icons.remove_circle_outline)),
                    Obx(() => Text('${productController.quantity.value}', style: const TextStyle(fontSize: 18, fontFamily: bold))),
                    IconButton(onPressed: () => productController.increaseQuantity(availableStock), icon: const Icon(Icons.add_circle_outline)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Description', style: TextStyle(fontFamily: bold, fontSize: 18, color: darkFontGrey)),
                const SizedBox(height: 10),
                Text(description, style: const TextStyle(fontFamily: regular, fontSize: 16, color: fontGrey, height: 1.5)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text('${productController.totalPrice.value} VND', style: const TextStyle(fontFamily: bold, fontSize: 24, color: redColor))),
            availableStock > 0
                ? SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (auth.currentUser == null) {
                          Get.snackbar("Login Required", "You must be logged in to add items to the cart.");
                          return;
                        }
                        final String selectedSize = sizes.isNotEmpty ? sizes[productController.sizeIndex.value].toString() : 'Default Size';
                        productController.addToCart(
                          title: productName,
                          img: detailImageUrl,
                          size: selectedSize,
                          qty: productController.quantity.value,
                          tprice: productController.totalPrice.value,
                          context: context,
                          productId: docId,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: golden, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Add to Cart', style: TextStyle(fontFamily: bold, fontSize: 18, color: Colors.white)),
                    ),
                  )
                : Container(
                    width: 180,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontFamily: bold,
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRatingSection() {
    return Obx(() {
      if (auth.currentUser == null) {
        return const SizedBox.shrink();
      }

      _currentRating = ratingController.yourRating.value;

      if (!ratingController.hasPurchased.value) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber, width: 1),
          ),
          child: const Center(
            child: Text(
              "You must purchase this product to rate it.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: semibold, color: Colors.black87),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Rating', style: TextStyle(fontFamily: bold, fontSize: 18, color: darkFontGrey)),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: _currentRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              _currentRating = rating;
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() => ElevatedButton(
                  onPressed: ratingController.isSubmitting.value
                      ? null
                      : () {
                          ratingController.submitRating(_currentRating);
                        },
                  child: ratingController.isSubmitting.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Rating'),
                )),
          ),
        ],
      );
    });
  }
}
