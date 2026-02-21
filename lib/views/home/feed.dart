import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../widgets/main_scaffold.dart';
import '../../widgets/post_card.dart';
import '../notifications/notifications.dart';
import '../search/search.dart';
import 'create_post.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<Post> _posts = [];
  String _selectedFilter = 'Tout';

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
    // Simulation de pagination
    setState(() => _isLoading = false);
  }

  Future<void> _refreshFeed() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadPosts();
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            _buildCreatePostInput(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildFilterChips(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildPostsList(),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 0),
    );
  }

  // ==================== APP BAR ====================

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.3),
      title: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 12),
          _buildAppTitle(),
        ],
      ),
      actions: [
        _buildIconButton(
          icon: Icons.search,
          onTap: () => _navigateTo(const Search()),
        ),
        const SizedBox(width: 8),
        _buildNotificationButton(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
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
    );
  }

  Widget _buildAppTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ConnectWork',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: IconButton(
        icon: Icon(icon, size: 24, color: AppColors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 24,
              color: AppColors.white,
            ),
            onPressed: () => _navigateTo(const Notifications()),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 143, 108, 193),
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
    );
  }

  // ==================== CREATE POST INPUT ====================

  Widget _buildCreatePostInput() {
    final currentUser = User.getCurrentUser();
    
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildUserAvatar(currentUser),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateTo(const CreatePost()),
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
    );
  }

  Widget _buildUserAvatar(User user) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
      child: user.avatarUrl == null
          ? Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  // ==================== FILTER CHIPS ====================

  Widget _buildFilterChips() {
    final filters = ['Tout', 'Mes groupes', 'Populaires', 'Mentions'];
    
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              return _buildFilterChip(
                label: filter,
                isSelected: _selectedFilter == filter,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: onSelected,
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

  // ==================== POSTS LIST ====================

  Widget _buildPostsList() {
    if (_posts.isEmpty && !_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: Text('Aucune publication')),
      );
    }

    return SliverList(
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
            onComment: () => _showPostDetail(_posts[index]),
          );
        },
        childCount: _posts.length + 1,
      ),
    );
  }

  // ==================== NAVIGATION ====================

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showPostDetail(Post post) {
    // TODO: Navigation vers le détail du post
    debugPrint('Voir détail du post: ${post.id}');
  }

  // ==================== LIFECYCLE ====================

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}