// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_clone/utils/colors.dart';
import 'package:insta_clone/utils/utils.dart';
import 'package:insta_clone/widgets/text_input_field.dart';
import '../resources/auth_methods.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/global_variables.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;

  bool _isLoading = false;
  bool _isSeen = true;
  bool _isObscure = true;
  var eyeFill = const Icon(CupertinoIcons.eye_fill, color: Colors.grey);
  var eyeSlashFill = const Icon(CupertinoIcons.eye_slash_fill);

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    if (_image == null) {
      showSnackBar("Please select an image", context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image!,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != 'Success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ),
            webScreenLayout: WebScreenLayout(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
        ),
      );
      showSnackBar('Account Created Successfully! Welcome', context);
    }
  }

  void navigateToLogIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                SvgPicture.asset(
                  'assets/images/Instagram_logo.svg',
                  height: 100,
                  // ignore: deprecated_member_use
                  color: Colors.white,
                ),
                const SizedBox(height: 65),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 67,
                            backgroundColor: primaryColor,
                            child: CircleAvatar(
                              radius: 65,
                              backgroundImage: MemoryImage(_image!),
                            ),
                          )
                        : const CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/user.png',
                            ),
                            radius: 65,
                          ),
                    Positioned(
                      bottom: -10,
                      left: 75,
                      child: IconButton(
                        tooltip: 'Choose photo',
                        onPressed: () {
                          selectImage();
                        },
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 25),
                TextFieldInput(
                  textEditingController: _usernameController,
                  hintText: 'Enter your username',
                  labelText: 'Username',
                  textInputType: TextInputType.text,
                  suficon: null,
                ),
                const SizedBox(height: 25),
                TextFieldInput(
                  textEditingController: _emailController,
                  hintText: 'Enter your email',
                  labelText: 'Email',
                  textInputType: TextInputType.emailAddress,
                  suficon: null,
                ),
                const SizedBox(height: 25),
                TextFieldInput(
                  textEditingController: _bioController,
                  hintText: 'Write a bio',
                  labelText: 'Bio',
                  textInputType: TextInputType.text,
                  suficon: null,
                ),
                const SizedBox(height: 25),
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: 'Enter new password',
                  labelText: "Password",
                  textInputType: TextInputType.visiblePassword,
                  isPass: _isObscure ? true : false,
                  suficon: IconButton(
                    tooltip: 'Show password',
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                        _isSeen = !_isSeen;
                      });
                    },
                    icon: _isSeen ? eyeFill : eyeSlashFill,
                  ),
                ),
                const SizedBox(height: 25),
                InkWell(
                  onTap: signUpUser,
                  child: Container(
                    height: 60.0,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      color: blueColor,
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CupertinoActivityIndicator(
                              color: primaryColor,
                            ),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text('Already have an account?    '),
                    ),
                    InkWell(
                      onTap: navigateToLogIn,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
