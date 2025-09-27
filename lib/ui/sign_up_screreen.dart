import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc/ui/sign_in_screen.dart';
import 'package:mvc/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 82),
              Text('Create Account', style: textTheme.titleLarge),
              const SizedBox(height: 24),
              _buildSignUpForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        TextFormField(controller: _firstNameController, decoration: const InputDecoration(hintText: "First Name")),
        const SizedBox(height: 12),
        TextFormField(controller: _lastNameController, decoration: const InputDecoration(hintText: "Last Name")),
        const SizedBox(height: 12),
        TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: "Phone")),
        const SizedBox(height: 12),
        TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: "Email")),
        const SizedBox(height: 12),
        TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(hintText: "Password")),
        const SizedBox(height: 12),
        TextFormField(controller: _confirmPasswordController, obscureText: true, decoration: const InputDecoration(hintText: "Confirm Password")),
        const SizedBox(height: 24),
        _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _onTapSignUpButton,
          child: const Text("Sign Up"),
        ),
        const SizedBox(height: 24),
        _buildSignUpSection(),
      ],
    );
  }

  Widget _buildSignUpSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
      },
      child: const Text("Have an account? Sign In", style: TextStyle(color: AppColors.themeColor)),
    );
  }

  Future<void> _onTapSignUpButton() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _loading = true);

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        // Save user data in Firestore
        await _firestore.collection("users").doc(user.uid).set({
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "email": _emailController.text.trim(),
          "createdAt": DateTime.now(),
        });

        // Send email verification
        await user.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent! Please check your inbox.")),
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Sign up failed")));
    } finally {
      setState(() => _loading = false);
    }
  }
}
