import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_clone/screens/login_screen.dart';
import 'package:insta_clone/utils/colors.dart';
import 'package:insta_clone/utils/global_variables.dart';
import 'package:insta_clone/utils/utils.dart';

import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FeedScreen({super.key});

  Future<void> deleteUserAccount() async {
    await _auth.currentUser!.delete();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      backgroundColor: Colors.transparent,
      color: primaryColor,
      onRefresh: _refresh,
      child: Scaffold(
        appBar: width > webScreenSize
            ? null
            : AppBar(
                backgroundColor: mobileBackgroundColor,
                title: SvgPicture.asset(
                  'assets/images/Instagram_logo.svg',
                  // ignore: deprecated_member_use
                  color: primaryColor,
                  height: 44,
                ),
                actions: [
                  IconButton(
                    tooltip: 'Delete Account',
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Alert'),
                          content: const Text(
                              'Do you really want to DELETE your account permannently?'),
                          actions: [
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('Yes'),
                              onPressed: () async {
                                await deleteUserAccount();
                                showSnackBar(
                                    'Account deleted successfully!', context);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('No'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.powerOff,
                      color: secondaryColor,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chats',
                    onPressed: () {
                      showSnackBar('Feature coming soon!', context);
                    },
                    icon: Image.asset(
                      'assets/images/chat.png',
                      color: Colors.white,
                      fit: BoxFit.fill,
                      height: 27,
                      width: 25,
                    ),
                  ),
                ],
              ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('datePublished', descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 25,
                ),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width / 3.5 : 0,
                  vertical: width > webScreenSize ? 15 : 0,
                ),
                child: PostCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
