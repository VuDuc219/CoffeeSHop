const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * A Cloud Function that triggers whenever a user's rating for a product is
 * created, updated, or deleted. It recalculates the average rating and the
 * total rating count for the product and updates the main product document.
 */
exports.updateProductRating = functions.firestore
    .document("products/{productId}/ratings/{ratingId}")
    .onWrite(async (change, context) => {
      // Get the product ID from the context parameters.
      const productId = context.params.productId;
      functions.logger.log(`Rating changed for product: ${productId}. Recalculating...`);

      // Reference to the main product document.
      const productRef = admin.firestore().collection("products").doc(productId);

      // Reference to the subcollection of ratings for the product.
      const ratingsRef = productRef.collection("ratings");

      try {
        // Get all ratings for the product.
        const ratingsSnapshot = await ratingsRef.get();

        let totalRating = 0;
        const ratingCount = ratingsSnapshot.size;

        // If there are no ratings left, reset the product's rating fields.
        if (ratingCount === 0) {
          functions.logger.log("No ratings found. Resetting product rating.");
          return productRef.update({
            p_rating: 0,
            rating_count: 0,
          });
        }

        // Calculate the new total and average rating.
        ratingsSnapshot.forEach((doc) => {
          totalRating += doc.data().rating;
        });

        const newAverageRating = totalRating / ratingCount;

        functions.logger.log(`New average: ${newAverageRating.toFixed(2)}, Count: ${ratingCount}`);

        // Update the main product document with the new average and count.
        return productRef.update({
          p_rating: newAverageRating,
          rating_count: ratingCount,
        });

      } catch (error) {
        functions.logger.error(
            "Error updating product rating:",
            error,
        );
        return null; // Exit the function on error.
      }
    });
