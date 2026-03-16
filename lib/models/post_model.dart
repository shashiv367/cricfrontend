enum MediaType { image, video }

class PostModel {
  final String user;
  final String caption;
  final MediaType mediaType;
  final String mediaUrl;
  int likes;
  int comments;
  int saves;
  bool liked;
  bool saved;

  PostModel({
    required this.user,
    required this.caption,
    required this.mediaType,
    required this.mediaUrl,
    required this.likes,
    required this.comments,
    required this.saves,
    this.liked = false,
    this.saved = false,
  });
}









