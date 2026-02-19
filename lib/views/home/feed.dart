import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../widgets/post_card.dart';
import 'create_post.dart';
import '../../widgets/bottom_nav_bar.dart';


class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  void _loadPosts() {
    setState(() => _posts = Post.getMockPosts());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _refreshFeed() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildFeedPage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _showCreateOptions();
          } else {
            final adjustedIndex = index > 2 ? index - 1 : index;
            setState(() => _currentIndex = adjustedIndex);
          }
        },
      ),
    );
  }

  Widget _buildFeedPage() {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar simple et propre
          SliverAppBar(
  floating: true,
  pinned: true,
  backgroundColor: AppColors.primary,
  elevation: 4,
  shadowColor: AppColors.primary.withOpacity(0.3),
  title: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.connect_without_contact,
          color: AppColors.white,
          size: 24,
        ),
      ),
      const SizedBox(width: 12),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ConnectWork',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              fontSize: 20,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            'Réseau d\'entreprise',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ],
  ),
  actions: [
    Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.search, size: 24, color: AppColors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Scaffold()),
        ),
      ),
    ),
    const SizedBox(width: 8),
    Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 24, color: AppColors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Scaffold(),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 135, 193, 108),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '3',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 16),
  ],
),          // Champ "Créer une publication"
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      User.getMockCurrentUser().name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePost(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Text(
                          'Partager une actualité...',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tout', true),
                    _buildFilterChip('Mes groupes', false),
                    _buildFilterChip('Populaires', false),
                    _buildFilterChip('Mentions', false),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == _posts.length) {
                  return _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                return PostCard(
                  post: _posts[index],
                  onLike: () {},
                  onComment: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(),
                    ),
                  ),
                );
              },
              childCount: _posts.length + 1,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {},
        selectedColor: AppColors.primary.withOpacity(0.1),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Créer', style: AppTextStyles.heading2),
                const SizedBox(height: 24),
                _buildCreateOption(
                  icon: Icons.edit_note,
                  color: AppColors.primary,
                  title: 'Nouvelle publication',
                  subtitle: 'Partager avec vos collègues',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePost(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildCreateOption(
                  icon: Icons.group_add,
                  color: AppColors.accent,
                  title: 'Nouveau groupe',
                  subtitle: 'Créer un groupe de travail',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: AppTextStyles.heading3),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}