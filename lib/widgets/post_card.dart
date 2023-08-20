// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/providers/user_provider.dart';
import 'package:insta_clone/resources/firestore_methods.dart';
import 'package:insta_clone/utils/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_clone/utils/utils.dart';
import 'package:insta_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../screens/comments_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/profile_screen.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLength = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();

      commentLength = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  void deletePost() async {
    try {
      await FirestoreMethods().deletePost(widget.snap['postId']);
      Navigator.of(context).pop();
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  static final customCacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
//DP & username row

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          uid: widget.snap['uid'],
                        ),
                      ),
                    );
                  },
                  onLongPress: () {},
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.snap['profileImage'],
                      cacheManager: customCacheManager,
                      cacheKey: widget.snap['uid'],
                      errorListener: () {
                        const Icon(Icons.error);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  uid: widget.snap['uid'],
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '${widget.snap['username']}  ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

//Blue Tick widget

                        const Stack(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.certificate,
                              color: blueColor,
                              size: 18,
                            ),
                            Positioned(
                              left: 2,
                              top: 3,
                              child: FaIcon(
                                FontAwesomeIcons.check,
                                color: mobileBackgroundColor,
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

//delete account button

                IconButton(
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Alert'),
                        content: const Text(
                            'Do you really want to delete this post?'),
                        actions: [
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: const Text('Yes'),
                            onPressed: () {
                              deletePost();
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
                    FontAwesomeIcons.ellipsisVertical,
                    size: 20,
                  ),
                )
              ],
            ),
          ),

//Images Section

          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap['postId'],
                user!.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  child: InteractiveViewer(
                    maxScale: 2.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        cacheManager: customCacheManager,
                        key: UniqueKey(),
                        fit: BoxFit.cover,
                        imageUrl: widget.snap['postUrl'],
                        placeholder: (context, url) => const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    duration: const Duration(milliseconds: 400),
                    child: const FaIcon(
                      FontAwesomeIcons.solidHeart,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //like comment row

          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user!.uid),
                smallLike: true,
                child: IconButton(
                    onPressed: () async {
                      await FirestoreMethods().likePost(
                        widget.snap['postId'],
                        user.uid,
                        widget.snap['likes'],
                      );
                    },
                    icon: widget.snap['likes'].contains(user.uid)
                        ? const FaIcon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red,
                          )
                        : const FaIcon(
                            FontAwesomeIcons.heart,
                          )),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        snap: widget.snap,
                      ),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/images/comments.png',
                  color: Colors.white,
                ),
                // FaIcon(FontAwesomeIcons.comment),
              ),
              IconButton(
                onPressed: () {
                  showSnackBar('Feature coming soon.', context);
                },
                icon: Image.asset(
                  'assets/images/send.png',
                  color: Colors.white,
                  fit: BoxFit.fill,
                  width: 25,
                  height: 24,
                ),
                // const FaIcon(
                //   FontAwesomeIcons.paperPlane,
                //   size: 22,
                // ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {
                      showSnackBar('Feature coming soon.', context);
                    },
                    icon: Image.asset(
                      'assets/images/save.png',
                      color: Colors.white,
                      height: 22,
                      width: 20,
                      fit: BoxFit.fill,
                    ),
                    //  const FaIcon(
                    //   Icons.bookmark_outline,
                    //   size: 28,
                    // ),
                  ),
                ),
              )
            ],
          ),

          //like count, username & caption panel

          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.snap['likes'].length} likes',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextSpan(
                          text: '  ${widget.snap['description']}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //Comments & date section

                //chatgpt code

                Visibility(
                  visible: commentLength > 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            snap: widget.snap,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'View all $commentLength comments',
                        style: const TextStyle(
                          fontSize: 14,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.d().add_MMM().add_jm().format(
                          widget.snap['datePublished'].toDate(),
                        ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
