import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/group.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/modal_handle.dart';
import '../../widgets/post_card.dart';

class GroupDetail extends StatefulWidget {
  final Group group;

  const GroupDetail({super.key, required this.group});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Post> _posts = [];
  List<User> _members = [];
  late bool _isMember;
  late bool _isAdmin;
  String _selectedFilter = 'recent';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isMember = widget.group.isMember;
    _isAdmin = widget.group.isAdmin;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _posts = Post.getMockPosts()
          .where((p) => p.groupName == widget.group.name)
          .toList();
      _members = User.getMockUsers();
      _isLoading = false;
    });
  }

  void _joinGroup() {
    setState(() => _isMember = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous avez rejoint ${widget.group.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _leaveGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quitter le groupe ?'),
        content: Text('Vous ne pourrez plus voir les publications de ${widget.group.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _isMember = false);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
          _buildGroupHeader(),
          _buildTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(),
            _buildMembersTab(),
            _buildAboutTab(),
          ],
        ),
      ),
      floatingActionButton: _isMember ? _buildFab() : null,
    );
  }

  // ==================== APP BAR ====================

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: innerBoxIsScrolled ? 4 : 0,
      backgroundColor: Colors.blue,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: _buildAppBarButton(Icons.arrow_back, () => Navigator.pop(context)),
      actions: [
        if (_isAdmin)
          _buildAppBarButton(Icons.edit, () => _showEditGroup()),
        _buildAppBarButton(Icons.more_vert, _showGroupOptions, marginRight: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue,
                Colors.blue.shade700,
                Colors.blue.shade900,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGroupAvatar(),
                const SizedBox(height: 12),
                if (widget.group.isPrivate)
                  _buildPrivateBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onPressed, {double marginRight = 0}) {
    return Container(
      margin: EdgeInsets.all(8).copyWith(right: marginRight > 0 ? marginRight : 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildGroupAvatar() {
    return Hero(
      tag: 'group_avatar_${widget.group.id}',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: 5,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          backgroundImage: widget.group.imageUrl != null
              ? NetworkImage(widget.group.imageUrl!)
              : null,
          child: widget.group.imageUrl == null
              ? Text(
                  widget.group.name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPrivateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'Privé',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildGroupHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(),
            const SizedBox(height: 16),
            Text(
              widget.group.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.group.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              '${widget.group.membersCount} membres',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 16),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Créé ${DateFormatter.getTimeAgo(widget.group.createdAt)}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (!_isMember) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _joinGroup,
          icon: const Icon(Icons.person_add),
          label: const Text('Rejoindre le groupe', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _ActionButton(
            icon: Icons.post_add,
            label: 'Nouvelle publication',
            isPrimary: true,
            onPressed: _showCreatePost,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.person_add,
            label: 'Inviter',
            isPrimary: false,
            onPressed: _showInviteMembers,
          ),
        ),
      ],
    );
  }

  // ==================== TAB BAR ====================

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.article_outlined), text: 'Publications'),
            Tab(icon: Icon(Icons.people_outline), text: 'Membres'),
            Tab(icon: Icon(Icons.info_outline), text: 'À propos'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  // ==================== ONGLET PUBLICATIONS ====================

  Widget _buildPostsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return EmptyState(
        icon: Icons.article_outlined,
        title: 'Aucune publication',
        subtitle: 'Soyez le premier à partager quelque chose avec le groupe !',
        actionLabel: 'Créer une publication',
        onAction: _showCreatePost,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_posts.length} publication${_posts.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildFilterDropdown(),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: PostCard(
                  post: _posts[index],
                  onComment: () {},
                ),
              ),
              childCount: _posts.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade700),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            DropdownMenuItem(value: 'recent', child: Text('Plus récent')),
            DropdownMenuItem(value: 'popular', child: Text('Plus populaire')),
          ],
          onChanged: (value) => setState(() => _selectedFilter = value!),
        ),
      ),
    );
  }

  // ==================== ONGLET MEMBRES ====================

  Widget _buildMembersTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Membres (${_members.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un membre...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final member = _members[index];
              final isGroupAdmin = index == 0; // Premier = admin pour l'exemple
              
              return _MemberTile(
                member: member,
                isAdmin: isGroupAdmin,
                showAdminOptions: _isAdmin && !isGroupAdmin,
              );
            },
            childCount: _members.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ==================== ONGLET À PROPOS ====================

  Widget _buildAboutTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(
                  title: 'Description',
                  content: widget.group.description,
                  icon: Icons.description_outlined,
                ),
                const Divider(height: 40),
                _InfoSection(
                  title: 'Règles du groupe',
                  content: '1. Respectez tous les membres\n2. Pas de spam\n3. Restez sur le sujet professionnel',
                  icon: Icons.gavel_outlined,
                ),
                const Divider(height: 40),
                _InfoSection(
                  title: 'Informations',
                  content: 'Type: ${widget.group.isPrivate ? "Privé" : "Public"}\n'
                      'Créé le: ${DateFormatter.formatDate(widget.group.createdAt)}\n'
                      'Créé par: ${widget.group.createdBy ?? "Admin"}',
                  icon: Icons.info_outlined,
                ),
                if (_isMember) ...[
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _leaveGroup,
                      icon: Icon(Icons.exit_to_app, color: Colors.red.shade400),
                      label: Text(
                        'Quitter le groupe',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== MODALS ====================

  void _showCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreatePostModal(
        groupName: widget.group.name,
        onSubmit: (content) {
          // TODO: Envoyer à l'API
          Navigator.pop(context);
          _loadData();
        },
      ),
    );
  }

  void _showInviteMembers() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _InviteMembersModal(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showGroupOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroupOptionsModal(
        isMember: _isMember,
        onLeave: _leaveGroup,
      ),
    );
  }

  void _showEditGroup() {
    // TODO: Édition du groupe
  }

  // ==================== FAB ====================

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _showCreatePost,
      backgroundColor: Colors.blue,
      icon: const Icon(Icons.post_add, size: 20),
      label: const Text('Publier', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ==================== WIDGETS PRIVÉS ====================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: Colors.blue, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isPrimary ? Colors.white : Colors.blue),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final User member;
  final bool isAdmin;
  final bool showAdminOptions;

  const _MemberTile({
    required this.member,
    required this.isAdmin,
    required this.showAdminOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.withOpacity(0.1),
              backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
              child: member.avatarUrl == null
                  ? Text(
                      member.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            if (isAdmin)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.star, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          isAdmin ? 'Administrateur' : (member.role ?? 'Membre'),
          style: TextStyle(
            color: isAdmin ? Colors.amber.shade700 : Colors.grey.shade600,
            fontWeight: isAdmin ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: showAdminOptions
            ? PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'admin', child: Text('Nommer admin')),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Retirer', style: TextStyle(color: Colors.red.shade400)),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoSection({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6),
        ),
      ],
    );
  }
}

class _CreatePostModal extends StatelessWidget {
  final String groupName;
  final Function(String) onSubmit;

  const _CreatePostModal({
    required this.groupName,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModalHandle(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.post_add, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nouvelle publication',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Dans $groupName',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Que voulez-vous partager ?',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.blue.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Chip(
                          avatar: Icon(Icons.image_outlined, size: 18, color: Colors.grey.shade700),
                          label: const Text('Photo'),
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide.none,
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          avatar: Icon(Icons.attach_file_outlined, size: 18, color: Colors.grey.shade700),
                          label: const Text('Fichier'),
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide.none,
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => onSubmit(controller.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Publier'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteMembersModal extends StatelessWidget {
  final ScrollController scrollController;

  const _InviteMembersModal({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const ModalHandle(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inviter des membres',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom ou email...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(String.fromCharCode(65 + index)),
                  ),
                  title: Text('Utilisateur ${index + 1}'),
                  subtitle: Text('utilisateur${index + 1}@email.com'),
                  trailing: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Inviter'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupOptionsModal extends StatelessWidget {
  final bool isMember;
  final VoidCallback onLeave;

  const _GroupOptionsModal({
    required this.isMember,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ModalHandle(),
            ListTile(
              leading: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
              title: const Text('Notifications'),
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: Colors.blue),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.share_outlined, color: Colors.grey.shade700),
              title: const Text('Partager le groupe'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.link, color: Colors.grey.shade700),
              title: const Text('Copier le lien'),
              onTap: () => Navigator.pop(context),
            ),
            if (isMember) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red.shade400),
                title: Text('Quitter le groupe', style: TextStyle(color: Colors.red.shade400)),
                onTap: () {
                  Navigator.pop(context);
                  onLeave();
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}