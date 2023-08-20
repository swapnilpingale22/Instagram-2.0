import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_clone/screens/profile_screen.dart';
import 'package:insta_clone/utils/colors.dart';

import '../utils/global_variables.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
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
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 16,
            ),
            hintText: 'Search',
          ),
          onFieldSubmitted: (String _) {
            if (searchController.text.isNotEmpty) {
              setState(() {
                isShowUsers = true;
              });
            }
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final docs = snapshot.data?.docs;
                    if (docs == null || index >= docs.length) {
                      return const SizedBox();
                    }
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: docs[index]['uid'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: width > webScreenSize ? width / 3.5 : 0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              docs[index]['photoUrl'],
                              cacheManager: customCacheManager,
                              cacheKey: docs[index]['uid'],
                              errorListener: () {
                                const Icon(Icons.error);
                              },
                            ),
                          ),
                          title: Text(
                            docs[index]['username'],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.data?.docs.length ?? 0,
                );
              },
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
            )
          : isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('datePublished', descending: true)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CupertinoActivityIndicator(
                          radius: 25,
                        ),
                      );
                    }
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width > webScreenSize ? width / 3.5 : 0,
                      ),
                      child: MasonryGridView.builder(
                        controller: ScrollController(),
                        physics: const BouncingScrollPhysics(),
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        gridDelegate:
                            const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (context, index) {
                          final document = snapshot.data!.docs[index];

                          final postUrl = document['postUrl'] as String?;

                          if (postUrl == null) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                cacheManager: customCacheManager,
                                key: UniqueKey(),
                                fit: BoxFit.cover,
                                imageUrl: postUrl,
                                placeholder: (context, url) => const Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                height: 200,
                                width: 200,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
