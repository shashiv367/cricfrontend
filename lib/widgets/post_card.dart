import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          _mediaPreview(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              post.caption,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          _actionsRow(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.backgroundCardAlt,
            child: Icon(Icons.person, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              post.user,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _mediaPreview() {
    final isVideo = post.mediaType == MediaType.video;
    return Container(
      height: 190,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isVideo ? Icons.play_circle_fill : Icons.image,
            color: AppColors.primaryBlue.withOpacity(0.85),
            size: 58,
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isVideo ? 'Video' : 'Image',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _iconButton(
            icon: post.liked ? Icons.favorite : Icons.favorite_border,
            color: post.liked ? Colors.redAccent : AppColors.textSecondary,
            label: post.likes.toString(),
            onTap: onLike,
          ),
          _iconButton(
            icon: Icons.mode_comment_outlined,
            color: AppColors.textSecondary,
            label: post.comments.toString(),
            onTap: onComment,
          ),
          _iconButton(
            icon: post.saved ? Icons.bookmark : Icons.bookmark_border,
            color: post.saved ? AppColors.primaryBlue : AppColors.textSecondary,
            label: post.saves.toString(),
            onTap: onSave,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onTap,
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}


