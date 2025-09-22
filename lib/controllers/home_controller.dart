import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    getUsername();
    super.onInit();
  }

  var currentNavIndex = 0.obs;
  var username = ''.obs;

  getUsername() async {
    try {
      var querySnapshot = await firestore
          .collection(usersCollection)
          .where('id', isEqualTo: auth.currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        username.value = querySnapshot.docs.single['name'];
      } else {
        print("User document not found for UID: ${auth.currentUser!.uid}");
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
  }
}
