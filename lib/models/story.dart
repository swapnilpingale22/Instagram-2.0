// ignore_for_file: unused_import

import 'package:insta_clone/models/user.dart';
import 'package:meta/meta.dart';

enum MediaType {
  image,
  video,
}

class Story {
  final String url;
  final MediaType media;
  final Duration duration;
  final User user;

  const Story({
    required this.url,
    required this.media,
    required this.duration,
    required this.user,
  });
}
