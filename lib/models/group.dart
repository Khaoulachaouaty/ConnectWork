class Group {
  final String id;
  final String name;
  final String description;
  final bool isPrivate;
  final int membersCount;
  final DateTime createdAt;
  final String? imageUrl;
  final bool isMember;
  final bool isAdmin;
  final String? createdBy;

  Group({
    required this.id,
    required this.name,
    required this.description,
    this.isPrivate = false,
    required this.membersCount,
    required this.createdAt,
    this.imageUrl,
    this.isMember = false,
    this.isAdmin = false,
    this.createdBy,
  });

  static List<Group> getMockGroups() {
    return [
      Group(
        id: '1',
        name: 'Développement Mobile',
        description: 'Groupe dédié aux discussions sur le développement d\'applications mobiles Flutter et React Native. Partagez vos expériences et posez vos questions.',
        isPrivate: false,
        membersCount: 24,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        isMember: true,
        isAdmin: true,
        createdBy: 'Jean Martin',
        imageUrl: 'https://picsum.photos/seed/mobile/200',
      ),
      Group(
        id: '2',
        name: 'Design UX/UI',
        description: 'Partagez vos créations et discutez des meilleures pratiques en design d\'interface utilisateur.',
        isPrivate: true,
        membersCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        isMember: true,
        imageUrl: 'https://picsum.photos/seed/design/200',
      ),
      Group(
        id: '3',
        name: 'Marketing Digital',
        description: 'Stratégies marketing, SEO, et campagnes publicitaires.',
        isPrivate: false,
        membersCount: 56,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        isMember: false,
      ),
      Group(
        id: '4',
        name: 'Ressources Humaines',
        description: 'Informations internes, recrutement et événements d\'entreprise.',
        isPrivate: true,
        membersCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        isMember: true,
        isAdmin: false,
      ),
    ];
  }
}