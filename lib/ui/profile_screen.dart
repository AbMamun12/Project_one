import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc/widget/app_bar.dart';
import 'package:mvc/widget/centered_circular_progress_indicator.dart';
import 'package:mvc/widget/snack_bar_message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _firstNameTEController = TextEditingController();
  final TextEditingController _lastNameTEController = TextEditingController();
  final TextEditingController _phoneTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? _selectedImage;
  bool _updateProfileInProgress = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _setUserData();
    super.initState();
  }

  void _setUserData() {
    _emailTEController.text = user?.email ?? '';
    _firstNameTEController.text = user?.displayName?.split(" ").first ?? '';
    _lastNameTEController.text =
        user?.displayName?.split(" ").skip(1).join(" ") ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TMAppBar(isProfileScreenOpen: true, showBackButton: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Update Profile',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPhotoPicker(),
                const SizedBox(height: 8),
                TextFormField(
                  enabled: false,
                  controller: _emailTEController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameTEController,
                  decoration: const InputDecoration(hintText: 'First Name'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Enter your First Name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameTEController,
                  decoration: const InputDecoration(hintText: 'Last Name'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Enter your Last Name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneTEController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Mobile'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordTEController,
                  decoration: const InputDecoration(hintText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: !_updateProfileInProgress,
                  replacement: const CenteredCircularProgressIndicator(),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateProfile();
                      }
                    },
                    child: const Icon(Icons.arrow_circle_right_outlined),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    _updateProfileInProgress = true;
    setState(() {});

    try {
      String fullName =
          "${_firstNameTEController.text.trim()} ${_lastNameTEController.text.trim()}";
      String? photoUrl = user?.photoURL;

      // যদি নতুন ছবি নির্বাচন করে থাকে
      if (_selectedImage != null) {
        File file = File(_selectedImage!.path);
        final storageRef = FirebaseStorage.instance.ref().child(
          "profile_photos/${user!.uid}.jpg",
        );

        await storageRef.putFile(file);
        photoUrl = await storageRef.getDownloadURL();
      }

      // FirebaseAuth User update
      await user?.updateDisplayName(fullName);
      if (photoUrl != null) {
        await user?.updatePhotoURL(photoUrl);
      }
      if (_passwordTEController.text.isNotEmpty) {
        await user?.updatePassword(_passwordTEController.text.trim());
      }

      await user?.reload();

      // Firestore এ ডাটা সংরক্ষণ
      await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
        "uid": user?.uid,
        "email": user?.email,
        "fullName": fullName,
        "phone": _phoneTEController.text.trim(),
        "photoUrl": photoUrl,
      }, SetOptions(merge: true));

      showSnackBarMessege(context, 'Profile has been updated!');
    } catch (e) {
      showSnackBarMessege(context, 'Error: $e');
    }

    _updateProfileInProgress = false;
    setState(() {});
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(_getSelectedPhotoTitle()),
          ],
        ),
      ),
    );
  }

  String _getSelectedPhotoTitle() {
    if (_selectedImage != null) {
      return _selectedImage!.name;
    }
    return 'Select Photo';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedImage != null) {
      _selectedImage = pickedImage;
      setState(() {});
    }
  }
}
