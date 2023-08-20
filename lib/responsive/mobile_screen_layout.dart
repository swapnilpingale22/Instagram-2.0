// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:insta_clone/models/user.dart' as model;
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';

class MobileScreenLayout extends StatefulWidget {
  final String uid;
  const MobileScreenLayout({super.key, required this.uid});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var userData = {};

  int _page = 0;

  late PageController pageController;

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  Future<void> getData() async {
    setState(() {});
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
    setState(() {
      _page = page;
    });
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
    model.User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: BouncingScrollPhysics(),
        children: homeScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        border: Border(
          top: BorderSide(
            width: 0.2,
            color: secondaryColor,
          ),
        ),
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.house,
              size: 24,
              color: _page == 0 ? primaryColor : secondaryColor,
            ),
            backgroundColor: primaryColor,
            tooltip: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 24,
              color: _page == 1 ? primaryColor : secondaryColor,
            ),
            backgroundColor: primaryColor,
            tooltip: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.squarePlus,
              size: 24,
              color: _page == 2 ? primaryColor : secondaryColor,
            ),
            backgroundColor: primaryColor,
            tooltip: 'Add post',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.solidHeart,
              size: 24,
              color: _page == 3 ? primaryColor : secondaryColor,
            ),
            backgroundColor: primaryColor,
            tooltip: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: userData['photoUrl'] != null
                ? CircleAvatar(
                    radius: 17.5,
                    backgroundColor: primaryColor,
                    child: CircleAvatar(
                      radius: 16,
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
            backgroundColor: primaryColor,
            tooltip: 'Account',
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
