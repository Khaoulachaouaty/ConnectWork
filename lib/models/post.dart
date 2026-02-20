class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String>? images;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String? groupName;
  final List<String>? attachments;
  final bool isEdited;


  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.images,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.groupName,
    this.attachments,
    this.isEdited = false,
  });

  static List<Post> getMockPosts() {
    return [
      Post(
        id: '1',
        userId: 'user1',
        userName: 'Marie Dupont',
        content: 'Super nouvelle ! Notre équipe vient de terminer le projet Alpha en avance. Félicitations à tous ! 🎉',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        likesCount: 24,
        commentsCount: 8,
        isLiked: true,
        groupName: 'Direction Technique',
      ),
      Post(
        id: '2',
        userId: 'user2',
        userName: 'Jean Martin',
        content: 'Quelqu\'un aurait-il la documentation API pour le nouveau service ?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 5,
        commentsCount: 12,
        groupName: 'Développement',
      ),
      Post(
        id: '3',
        userId: 'user3',
        userName: 'Sophie Bernard',
        content: 'Photos de l\'événement team building d\'hier !',
        images: ['https://picsum.photos/400/300?random=1', 'https://picsum.photos/400/300?random=2'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likesCount: 45,
        commentsCount: 15,
        groupName: 'Ressources Humaines',
      ),
      Post(
        id: '4',
        userId: 'user4',
        userName: 'Lucas Petit',
        content: 'Rappel : La réunion mensuelle est déplacée à 14h demain.',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likesCount: 12,
        commentsCount: 3,
      ),
      Post(
        id: '5',
        userId: 'user5',
        userName: 'Emma Richard',
        content: 'Je cherche un développeur Flutter pour m\'aider sur un projet interne.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 18,
        commentsCount: 7,
        groupName: 'Innovation',
      ),
    ];
  }

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return 'Il y a ${diff.inDays}j';
    }
  }
}