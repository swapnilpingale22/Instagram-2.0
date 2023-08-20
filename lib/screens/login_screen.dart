// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_clone/resources/auth_methods.dart';
import 'package:insta_clone/screens/sign_up_screen.dart';
import 'package:insta_clone/utils/colors.dart';
import 'package:insta_clone/utils/global_variables.dart';
import 'package:insta_clone/utils/utils.dart';
import 'package:insta_clone/widgets/text_input_field.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
  }

  void logInUSer() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().logInUSer(
      email: _emailController.text,
      password: _passwordController.text,
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
      showSnackBar('Welcome', context);
      // showSnackBar(res, context);
    }
  }

  void navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          // color: Colors.green,
          height: MediaQuery.of(context).size.height,
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  // Flexible(flex: 2, child: Container()),
                  SvgPicture.asset(
                    'assets/images/Instagram_logo.svg',
                    height: 100,
                    // ignore: deprecated_member_use
                    color: Colors.white,
                  ),
                  const SizedBox(height: 65),
                  TextFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Enter your email',
                    labelText: 'Email',
                    textInputType: TextInputType.emailAddress,
                    suficon: null,
                  ),
                  const SizedBox(height: 25),
                  TextFieldInput(
                    textEditingController: _passwordController,
                    hintText: 'Enter your password',
                    labelText: 'Password',
                    textInputType: TextInputType.visiblePassword,
                    isPass: _isObscure ? true : false,
                    suficon: IconButton(
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
                    onTap: logInUSer,
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
                        color: Colors.blue,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CupertinoActivityIndicator(
                                color: primaryColor,
                              ),
                            )
                          : const Text('Log In'),
                    ),
                  ),
                  // Flexible(flex: 2, child: Container()),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text("Don't have an account?   "),
                      ),
                      InkWell(
                        onTap: navigateToSignUp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
