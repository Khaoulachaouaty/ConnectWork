import 'package:flutter/material.dart';
import '../../constants.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _contentController = TextEditingController();
  bool _isLoading = false;
  String? _selectedGroup;

  final List<String> _groups = [
    'Tous',
    'Direction Technique',
    'Développement',
    'Innovation',
  ];

  void _publish() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle publication'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publish,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Publier',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: AppColors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alexandre Moreau',
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedGroup ?? _groups[0],
                                  isDense: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  items: _groups.map((group) {
                                    return DropdownMenuItem(
                                      value: group,
                                      child: Text(
                                        group,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedGroup = value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Que voulez-vous partager ?',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.image,
                    label: 'Photo',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.attach_file,
                    label: 'Fichier',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.poll,
                    label: 'Sondage',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}