import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants.dart';
import '../models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Function()? onComment; 

  const PostCard({
    super.key,
    required this.post,
    this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String? _userReaction;
  bool _showReactions = false;
  int _likesCount = 0;

  final Map<String, Map<String, dynamic>> _reactions = {
    'like': {'emoji': '👍', 'label': 'J\'aime', 'color': Colors.blue},
    'love': {'emoji': '❤️', 'label': 'J\'adore', 'color': Colors.red},
    'haha': {'emoji': '😂', 'label': 'Haha', 'color': Colors.orange},
    'wow': {'emoji': '😮', 'label': 'Wouah', 'color': Colors.amber},
    'sad': {'emoji': '😢', 'label': 'Triste', 'color': Colors.indigo},
    'angry': {'emoji': '😡', 'label': 'Grrr', 'color': Colors.deepOrange},
  };

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    if (widget.post.isLiked) _userReaction = 'like';
  }

  void _onReactionSelected(String reaction) {
    setState(() {
      if (_userReaction == reaction) {
        // Annuler la réaction
        _userReaction = null;
        _likesCount--;
      } else {
        // Nouvelle réaction ou changement
        if (_userReaction == null) _likesCount++;
        _userReaction = reaction;
      }
      _showReactions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildMetaInfo(),
                    ],
                  ),
                ),
                _buildPopupMenu(context),
              ],
            ),
          ),

          // Badge Groupe
          if (widget.post.groupName != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.post.groupName!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Contenu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // Images
          if (widget.post.images != null && widget.post.images!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildImagesSection(context),
          ],

          // Pièces jointes
          if (widget.post.attachments != null && widget.post.attachments!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAttachmentsSection(context),
          ],

          const SizedBox(height: 12),

          // Stats réactions
          if (_likesCount > 0 || widget.post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (_likesCount > 0) ...[
                    _buildReactionsSummary(),
                    const SizedBox(width: 6),
                    Text(
                      '$_likesCount',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (widget.post.commentsCount > 0)
                    Text(
                      '${widget.post.commentsCount} commentaires',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

          if (_likesCount > 0 || widget.post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),

          // Actions avec réactions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                // Bouton J'aime avec réactions
                Expanded(
                  child: _buildReactionButton(),
                ),
                Expanded(
                  child: InkWell(
                    onTap: widget.onComment,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Commenter',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barre de réactions flottante
          if (_showReactions)
            _buildReactionsBar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      backgroundImage: widget.post.userAvatar != null
          ? NetworkImage(widget.post.userAvatar!)
          : null,
      child: widget.post.userAvatar == null
          ? Text(
              widget.post.userName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          : null,
    );
  }

  Widget _buildMetaInfo() {
    return Row(
      children: [
        Text(
          widget.post.formattedTime,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        if (widget.post.groupName == null) ...[
          const SizedBox(width: 4),
          Text(
            '•',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.public,
            size: 12,
            color: Colors.grey.shade500,
          ),
        ],
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    if (widget.post.userId != 'current_user') return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        size: 20,
        color: Colors.grey.shade500,
      ),
      offset: const Offset(0, 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'delete') {
          _showDeleteConfirm(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 10),
              const Text('Modifier'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
              const SizedBox(width: 10),
              Text('Supprimer', style: TextStyle(color: Colors.red.shade400)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionsSummary() {
    // Montrer les 3 premières réactions différentes
    final shownReactions = ['like', 'love', 'haha'];
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: shownReactions.asMap().entries.map((entry) {
        final index = entry.key;
        final reaction = entry.value;
        return Transform.translate(
          offset: Offset(index * -8.0, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              _reactions[reaction]!['emoji'],
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReactionButton() {
    final reaction = _userReaction != null ? _reactions[_userReaction] : null;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _showReactions = true),
      onExit: (_) => Future.delayed(
        const Duration(milliseconds: 200),
        () {
          if (mounted && !_isHoveringReactions) {
            setState(() => _showReactions = false);
          }
        },
      ),
      child: GestureDetector(
        onLongPress: () => setState(() => _showReactions = true),
        onTap: () {
          if (_userReaction != null) {
            _onReactionSelected(_userReaction!); // Annuler
          } else {
            _onReactionSelected('like'); // Like par défaut
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: reaction != null ? reaction['color'].withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (reaction != null)
                Text(
                  reaction['emoji'],
                  style: const TextStyle(fontSize: 18),
                )
              else
                Icon(
                  Icons.thumb_up_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              const SizedBox(width: 6),
              Text(
                reaction != null ? reaction['label'] : 'J\'aime',
                style: TextStyle(
                  color: reaction != null ? reaction['color'] : Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isHoveringReactions = false;

  Widget _buildReactionsBar() {
    return MouseRegion(
      onEnter: (_) => _isHoveringReactions = true,
      onExit: (_) {
        _isHoveringReactions = false;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_isHoveringReactions) {
            setState(() => _showReactions = false);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 12, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _reactions.entries.map((entry) {
            return GestureDetector(
              onTap: () => _onReactionSelected(entry.key),
              child: MouseRegion(
                onEnter: (_) => setState(() {}),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1, end: 1.3),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, scale, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        entry.value['emoji'],
                        style: TextStyle(fontSize: 28 * scale),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    final images = widget.post.images!;
    
    if (images.length == 1) {
      return GestureDetector(
        onTap: () => _openImage(context, images[0]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              images[0],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openImage(context, images[index]),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.network(
                      images[index],
                      width: 280,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildIconButton(
                        icon: Icons.download,
                        onTap: () => _downloadFile(
                          context,
                          images[index],
                          'image_${index + 1}.jpg',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: widget.post.attachments!.map((attachment) {
          final ext = attachment.split('.').last.toLowerCase();
          return GestureDetector(
            onTap: () => _openFile(context, attachment, ext),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  _getFileIcon(ext),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'PDF • 2.4 MB',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildIconButton(
                    icon: Icons.download,
                    onTap: () => _downloadFile(context, attachment, attachment),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _getFileIcon(String ext) {
    IconData icon;
    Color color;
    
    switch (ext) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _openImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(url),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 40,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadFile(context, url, 'image.jpg'),
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFile(BuildContext context, String url, String ext) {
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      _openImage(context, url);
    } else {
      // Pour PDF et autres, montrer un aperçu
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(ext.toUpperCase()),
          content: const Text('Ouvrir ce fichier ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _downloadFile(context, url, 'fichier.$ext');
              },
              icon: const Icon(Icons.download),
              label: const Text('Télécharger'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _downloadFile(BuildContext context, String url, String fileName) async {
    try {
      // Permissions
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = deviceInfo.version.sdkInt;

        PermissionStatus status;
        if (sdkInt >= 33) {
          status = PermissionStatus.granted;
        } else {
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          _showError(context, 'Permission refusée');
          return;
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final dio = Dio();
      Directory dir;

      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download/ConnectWork');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (!await dir.exists()) await dir.create(recursive: true);

      final path = '${dir.path}/$fileName';
      await dio.download(url, path);

      Navigator.pop(context);
      _showSuccess(context, 'Téléchargé dans Téléchargements/ConnectWork');
    } catch (e) {
      Navigator.pop(context);
      _showError(context, 'Erreur: $e');
    }
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}