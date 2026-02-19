import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: post.userAvatar != null
                      ? NetworkImage(post.userAvatar!)
                      : null,
                  child: post.userAvatar == null
                      ? Text(
                          post.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName, style: AppTextStyles.heading3),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (post.groupName != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                post.groupName!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(post.formattedTime, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                // Menu simplifié - uniquement pour l'auteur (modifier/supprimer)
                if (post.userId == 'current_user')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Modifier
                      } else if (value == 'delete') {
                        _showDeleteConfirm(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: AppColors.primary),
                            SizedBox(width: 12),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppColors.error),
                            SizedBox(width: 12),
                            Text('Supprimer', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: AppTextStyles.body.copyWith(height: 1.4),
            ),
          ),
          if (post.images != null && post.images!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: post.images!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        post.images![index],
                        width: 280,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 280,
                            color: AppColors.grey300,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: post.isLiked ? AppColors.error : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount}',
                  style: AppTextStyles.caption.copyWith(
                    color: post.isLiked ? AppColors.error : AppColors.textSecondary,
                    fontWeight: post.isLiked ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.commentsCount}', style: AppTextStyles.caption),
              ],
            ),
          ),
          const Divider(height: 24),
          // Actions simplifiées : Like et Commenter uniquement
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: 'J\'aime',
                    color: post.isLiked ? AppColors.error : AppColors.textSecondary,
                    onTap: onLike,
                  ),
                ),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Commenter',
                    onTap: onComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la publication'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette publication ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Supprimer le post
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}