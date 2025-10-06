import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/controllers/messages_controller.dart';
import 'package:myapp/controllers/notification_controller.dart';
import 'package:myapp/controllers/profile_controller.dart';
import 'package:myapp/views/admin_screen/home_screen/home.dart';
import 'package:myapp/views/auth_screen/signup_screen.dart';
import 'package:myapp/views/home_screen/home.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    Get.defaultDialog(
      title: "Forgot Password",
      titleStyle: const TextStyle(color: Color(0xFF6f4e37), fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter your email to get a password reset link."),
          const SizedBox(height: 20),
          TextFormField(
            controller: resetEmailController,
            decoration: InputDecoration(
              hintText: 'your.email@example.com',
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6f4e37)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF6f4e37)),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email cannot be empty";
              }
              if (!GetUtils.isEmail(value)) {
                return "Please enter a valid email";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel", style: TextStyle(color: Color(0xFF6f4e37))),
        ),
        ElevatedButton(
          onPressed: () {
            if (resetEmailController.text.isNotEmpty && GetUtils.isEmail(resetEmailController.text)) {
              _authController.resetPassword(resetEmailController.text.trim());
              Get.back(); // Close dialog
            } else {
              Get.snackbar("Error", "Please enter a valid email address.");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6f4e37),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text("Send", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6f4e37), Color(0xFFa1887f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/icons/appIcon.png', height: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Log in to Coffee Shop',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildLoginForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              'Email',
              _emailController,
              Icons.email_outlined,
              false,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              'Password',
              _passwordController,
              Icons.lock_outline,
              true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(context),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFF6f4e37)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final userCredential = await _authController.loginMethod(
                    context: context,
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  if (userCredential != null) {
                    Get.put(ProfileController(), permanent: true);
                    Get.put(CartController(), permanent: true);
                    Get.put(MessagesController(), permanent: true);
                    Get.put(NotificationController(), permanent: true);

                    VxToast.show(context, msg: "Logged in successfully");

                    if (_emailController.text == "admin@gmail.com") {
                      Get.offAll(() => const AdminHome());
                    } else {
                      Get.offAll(() => const Home());
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6f4e37),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Obx(
                () => _authController.isloading.value
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text(
                        'Log in',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("or, create a new account"),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color(0xFF6f4e37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isObscure,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6f4e37),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: isObscure ? 'Enter your password' : 'Enter your email',
            prefixIcon: Icon(icon, color: const Color(0xFF6f4e37)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF6f4e37)),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label cannot be empty";
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
