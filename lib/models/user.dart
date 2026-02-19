class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? function;
  final String? bio;
  final String role;
  final List<String> groups;
  final DateTime joinedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.function,
    this.bio,
    this.role = 'employee',
    this.groups = const [],
    required this.joinedAt,
  });

  static User getMockCurrentUser() {
    return User(
      id: 'current_user',
      name: 'Alexandre Moreau',
      email: 'alexandre.moreau@connectwork.com',
      function: 'Développeur Mobile',
      bio: 'Passionné par Flutter et le développement mobile.',
      role: 'employee',
      groups: ['Direction Technique', 'Développement', 'Innovation'],
      joinedAt: DateTime(2023, 6, 15),
    );
  }
}