// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/login_screen.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../utils/utils.dart';
// import 'package:insta_clone/models/user.dart' as model;
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';

class WebScreenLayout extends StatefulWidget {
  final String uid;
  const WebScreenLayout({Key? key, required this.uid}) : super(key: key);

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var userData = {};

  int _page = 0;

  late PageController pageController;

  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    // pageController = PageController();
    pageController = PageController(initialPage: _page);

    getData();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  Future<void> getData() async {
    // setState(() {});
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      userData = userSnap.data()!;
    } catch (e) {
      //error catch
    }
  }

  void onPageChanged(int page) {
    // setState(() {
    //   _page = page;
    // });
  }

  Future<void> deleteUserAccount() async {
    await _auth.currentUser!.delete();
  }

  static final customCacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 15),
      maxNrOfCacheObjects: 100,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset(
          'assets/images/Instagram_logo.svg',
          // ignore: deprecated_member_use
          color: primaryColor,
          height: 44,
        ),
        actions: [
          IconButton(
            tooltip: 'Feed',
            onPressed: () => navigationTapped(0),
            icon: FaIcon(
              FontAwesomeIcons.house,
              size: 24,
              color: _page == 0 ? primaryColor : secondaryColor,
            ),
          ),
          IconButton(
            tooltip: 'Explore',
            onPressed: () => navigationTapped(1),
            icon: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 24,
              color: _page == 1 ? primaryColor : secondaryColor,
            ),
          ),
          IconButton(
            tooltip: 'Add post',
            onPressed: () => navigationTapped(2),
            icon: FaIcon(
              FontAwesomeIcons.squarePlus,
              size: 24,
              color: _page == 2 ? primaryColor : secondaryColor,
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => navigationTapped(3),
            icon: FaIcon(
              FontAwesomeIcons.solidHeart,
              size: 24,
              color: _page == 3 ? primaryColor : secondaryColor,
            ),
          ),
          IconButton(
            tooltip: 'Account',
            onPressed: () {
              navigationTapped(4);
            },
            icon: userData['photoUrl'] != null
                ? CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: CachedNetworkImageProvider(
                        userData['photoUrl'],
                        cacheManager: customCacheManager,
                        cacheKey: userData['uid'],
                        errorListener: () {
                          const Icon(Icons.error);
                        },
                      ),
                    ),
                  )
                : FaIcon(
                    FontAwesomeIcons.solidCircleUser,
                    size: 24,
                    color: _page == 4 ? primaryColor : secondaryColor,
                  ),
          ),
          IconButton(
            tooltip: 'Chats',
            onPressed: () {
              showSnackBar('Feature coming soon.', context);
            },
            icon: Image.asset(
              'assets/images/chat.png',
              color: Colors.white,
              fit: BoxFit.fill,
              height: 27,
              width: 25,
            ),
          ),
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
                        showSnackBar('Account deleted successfully!', context);
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
        ],
      ),
      body: FutureBuilder<void>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoActivityIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: homeScreenItems,
            );
          }
        },
      ),
    );
  }
}
