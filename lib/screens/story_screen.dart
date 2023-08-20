// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:insta_clone/utils/colors.dart';
// import 'package:video_player/video_player.dart';
// import '../models/story.dart';
// import '../models/user.dart';

// class StoryScreen extends StatefulWidget {
//   final String uid;
//   final List<Story> stories;
//   const StoryScreen({
//     // super.key,
//  Key? key,
//     required this.stories,
//     required this.uid,
//   // });
//     }) : super(key: key);

//   @override
//   State<StoryScreen> createState() => _StoryScreenState();
// }

// class _StoryScreenState extends State<StoryScreen>
//     with SingleTickerProviderStateMixin {
//   late PageController _pageController;
//   late VideoPlayerController _videoController;
//   late AnimationController _animController;
//   int _currentIndex = 0;
//   var userData = {};

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _animController = AnimationController(vsync: this);

//     // _videoController = VideoPlayerController.network(widget.stories[2].url)
//     //   ..initialize().then((value) => setState(() {}));
//     // _videoController.play();

//     final Story firstStory = widget.stories.first;
//     _loadStory(story: firstStory, animateToPage: false);

//     _animController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _animController.stop();
//         _animController.reset();
//         setState(() {
//           if (_currentIndex + 1 < widget.stories.length) {
//             _currentIndex += 1;
//             _loadStory(story: widget.stories[_currentIndex]);
//           } else {
//             _currentIndex = 0;
//             _loadStory(story: widget.stories[_currentIndex]);
//           }
//         });
//       }
//     });
//     getData();
//   }

//   getData() async {
//     try {
//       var userSnap = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.uid)
//           .get();
//       userData = userSnap.data()!;
//       // DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animController.dispose();
//     _videoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: mobileBackgroundColor,
//       body: GestureDetector(
//         onTapDown: (details) =>
//             _onTapDown(details, story),
//         child: Stack(
//           children: <Widget>[
//             PageView.builder(
//               controller: _pageController,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: widget.stories.length,
//               itemBuilder: (context, i) {
//                 final Story story = widget.stories[i];
//                 switch (story.media) {
//                   case MediaType.image:
//                     return CachedNetworkImage(
//                       imageUrl: story.url,
//                       fit: BoxFit.cover,
//                     );
//                   case MediaType.video:
//                     // ignore: unnecessary_null_comparison
//                     if (_videoController != null &&
//                         _videoController.value.isInitialized) {
//                       return FittedBox(
//                         fit: BoxFit.cover,
//                         child: SizedBox(
//                           width: _videoController.value.size.width,
//                           height: _videoController.value.size.height,
//                           child: VideoPlayer(_videoController),
//                         ),
//                       );
//                     }
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//             Positioned(
//               top: 40.0,
//               left: 10.0,
//               right: 10.0,
//               child: Column(
//                 children: [
//                   Row(
//                     children: widget.stories
//                         .asMap()
//                         .map((i, e) {
//                           return MapEntry(
//                             i,
//                             AnimatedBar(
//                               animConttroller: _animController,
//                               position: i,
//                               currentIndex: _currentIndex,
//                             ),
//                           );
//                         })
//                         .values
//                         .toList(),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 1.5,
//                       vertical: 10.0,
//                     ),
//                     child: UserInfo(user: story.user),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onTapDown(TapDownDetails details, Story story) {
//     final double screenwidth = MediaQuery.of(context).size.width;
//     final double dx = details.globalPosition.dx;
//     if (dx < screenwidth / 3) {
//       setState(() {
//         if (_currentIndex - 1 >= 0) {
//           _currentIndex -= 1;
//           _loadStory(story: widget.stories[_currentIndex]);
//         }
//       });
//     } else if (dx > 2 * screenwidth / 3) {
//       setState(() {
//         if (_currentIndex + 1 < widget.stories.length) {
//           _currentIndex += 1;
//           _loadStory(story: widget.stories[_currentIndex]);
//         } else {
//           //out of bounds - loop story
//           //tou can also use Navigator.of(context).pop() here
//           _currentIndex = 0;
//           _loadStory(story: widget.stories[_currentIndex]);
//         }
//       });
//     } else {
//       if (story.media == MediaType.video) {
//         if (_videoController.value.isPlaying) {
//           _videoController.pause();
//           _animController.stop();
//         } else {
//           _videoController.play();
//           _animController.forward();
//         }
//       }
//     }
//   }

//   void _loadStory({Story? story, bool animateToPage = true}) {
//     _animController.stop();
//     _animController.reset();
//     switch (story!.media) {
//       case MediaType.image:
//         _animController.duration = story.duration;
//         _animController.forward();
//         break;
//       case MediaType.video:
//         _videoController = null;
//         _videoController?.dispose();
//         _videoController = VideoPlayerController.network(story.url)
//           ..initialize().then((_) {
//             setState(() {});
//             if (_videoController.value.isInitialized) {
//               _animController.duration = _videoController.value.duration;
//               _videoController.play();
//               _animController.forward();
//             }
//           });
//         break;
//     }
//     if (animateToPage) {
//       _pageController.animateToPage(
//         _currentIndex,
//         duration: const Duration(milliseconds: 1),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
// }

// class AnimatedBar extends StatelessWidget {
//   final AnimationController animConttroller;
//   final int position;
//   final int currentIndex;

//   const AnimatedBar({
//     Key? key,
//     required this.animConttroller,
//     required this.position,
//     required this.currentIndex,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Flexible(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 1.5),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return Stack(
//               children: <Widget>[
//                 _buildContainer(
//                   double.infinity,
//                   position < currentIndex
//                       ? Colors.white
//                       : Colors.white.withOpacity(0.5),
//                 ),
//                 position == currentIndex
//                     ? AnimatedBuilder(
//                         animation: animConttroller,
//                         builder: (context, child) {
//                           return _buildContainer(
//                             constraints.maxWidth * animConttroller.value,
//                             Colors.white,
//                           );
//                         },
//                       )
//                     : const SizedBox.shrink(),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Container _buildContainer(double width, Color color) {
//     return Container(
//       height: 5.0,
//       width: width,
//       decoration: BoxDecoration(
//         color: color,
//         border: Border.all(
//           color: Colors.black26,
//           width: 0.8,
//         ),
//         borderRadius: BorderRadius.circular(3.0),
//       ),
//     );
//   }
// }

// class UserInfo extends StatelessWidget {
//   final User user;
//   const UserInfo({
//     Key? key,
//     required this.user,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         CircleAvatar(
//           radius: 20.0,
//           backgroundColor: secondaryColor,
//           backgroundImage: CachedNetworkImageProvider(
//             user.photoUrl,
//           ),
//         ),
//         const SizedBox(width: 10.0),
//         Expanded(
//           child: Text(
//             user.username,
//             style: const TextStyle(
//               color: primaryColor,
//               fontSize: 18.0,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: const Icon(
//             Icons.close,
//             size: 30.0,
//             color: primaryColor,
//           ),
//         ),
//       ],
//     );
//   }
// }
