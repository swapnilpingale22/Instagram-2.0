// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:insta_clone/resources/auth_methods.dart';
import 'package:insta_clone/resources/firestore_methods.dart';
import 'package:insta_clone/screens/login_screen.dart';
import 'package:insta_clone/utils/colors.dart';
import 'package:insta_clone/utils/utils.dart';
import '../utils/global_variables.dart';
import '../widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      //getting posts length

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          // .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('uid', isEqualTo: widget.uid)
          .get();
      userData = userSnap.data()!;
      postLength = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
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
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Center(
            child: CupertinoActivityIndicator(
            radius: 25,
          ))
        : Scaffold(
            appBar: AppBar(
              centerTitle: width > webScreenSize ? true : false,
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            body: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width / 3.5 : 0,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0).copyWith(right: 0),
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: CachedNetworkImageProvider(
                                userData['photoUrl'],
                                cacheManager: customCacheManager,
                                cacheKey: userData['uid'],
                                errorListener: () {
                                  const Icon(Icons.error);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      buildStatColumn(postLength, 'Posts'),
                                      InkWell(
                                        onTap: () {},
                                        child: buildStatColumn(
                                            followers, 'Followers'),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: buildStatColumn(
                                            following, 'Following'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FirebaseAuth.instance.currentUser!.uid ==
                                              widget.uid
                                          ? FollowButton(
                                              text: 'Sign Out',
                                              baclgroundColor:
                                                  mobileBackgroundColor,
                                              textColor: primaryColor,
                                              borderColor: secondaryColor,
                                              function: () async {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      CupertinoAlertDialog(
                                                    title: const Text('Alert'),
                                                    content: const Text(
                                                        'Do you really want to Sign Out?'),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                        isDestructiveAction:
                                                            true,
                                                        child:
                                                            const Text('Yes'),
                                                        onPressed: () async {
                                                          await AuthMethods()
                                                              .signOut();
                                                          showSnackBar(
                                                              'Signed out successfully',
                                                              context);
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const LoginScreen(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: const Text('No'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                          : isFollowing
                                              ? FollowButton(
                                                  text: 'Unfollow',
                                                  baclgroundColor: primaryColor,
                                                  textColor: Colors.black,
                                                  borderColor: secondaryColor,
                                                  function: () async {
                                                    await FirestoreMethods()
                                                        .floowUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );
                                                    setState(() {
                                                      isFollowing = false;
                                                      followers--;
                                                    });
                                                  },
                                                )
                                              : FollowButton(
                                                  text: 'Follow',
                                                  baclgroundColor: blueColor,
                                                  textColor: primaryColor,
                                                  borderColor: blueColor,
                                                  function: () async {
                                                    await FirestoreMethods()
                                                        .floowUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );
                                                    setState(() {
                                                      isFollowing = true;
                                                      followers++;
                                                    });
                                                  },
                                                ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            userData['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            userData['bio'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // const Divider(
                //   color: secondaryColor,
                //   thickness: 0.1,
                // ),
                // TabBar(
                //   tabs: [
                //     Container(
                //       color: Colors.blue,
                //       height: 100,
                //       width: 100,
                //     ),
                //     Container(
                //       color: Colors.orange,
                //       height: 100,
                //       width: 100,
                //     ),
                //     Container(
                //       color: Colors.purple,
                //       height: 100,
                //       width: 100,
                //     ),
                //   ],
                // ),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];
                        return Container(
                          child: CachedNetworkImage(
                            key: UniqueKey(),
                            fit: BoxFit.cover,
                            cacheManager: customCacheManager,
                            imageUrl: snap['postUrl'],
                            placeholder: (context, url) => const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
