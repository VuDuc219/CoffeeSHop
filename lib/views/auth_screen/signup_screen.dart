import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/views/auth_screen/login_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  bool _agreeToTerms = false;
  final controller = Get.put(AuthController());

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
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/icons/appIcon.png', height: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Join the Coffee Shop',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSignupForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
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
            _buildTextField('Name', _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(
              'Email',
              _emailController,
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildPasswordField('Password', _passwordController, Icons.lock_outline),
            const SizedBox(height: 20),
            _buildRetypePasswordField('Retype Password', _retypePasswordController, Icons.lock_outline),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (val) => setState(() => _agreeToTerms = val!),
                  activeColor: const Color(0xFF6f4e37),
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Terms and Conditions & Privacy Policy',
                    style: TextStyle(color: Color(0xFF6f4e37)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSignupButton(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text(
                    'Log in',
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
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
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
              return '$label cannot be empty';
            }
            if (label == 'Email') {
              final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegExp.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller, IconData icon) {
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
          obscureText: true,
          decoration: InputDecoration(
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
              return 'Password cannot be empty';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters long.';
            }
            if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain both letters and numbers.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRetypePasswordField(
      String label, TextEditingController controller, IconData icon) {
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
          obscureText: true,
          decoration: InputDecoration(
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
              return 'Please retype your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _agreeToTerms
          ? () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final userCredential = await controller.signupMethod(
                    context: context,
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  if (userCredential != null) {
                    await controller.storeUserData(
                      email: _emailController.text,
                      password: _passwordController.text,
                      name: _nameController.text,
                    );

                    VxToast.show(context, msg: "Account created successfully!");
                    Get.offAll(() => const LoginScreen());
                  }
                } catch (e) {
                  auth.signOut();
                  VxToast.show(context, msg: e.toString());
                }
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _agreeToTerms ? const Color(0xFF6f4e37) : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: const Text(
        'Sign up',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }
}
