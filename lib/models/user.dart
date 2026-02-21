class User {
  final String id;
  final String name;
  final String? email;
  final String? role;
  final String? avatarUrl;
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    this.email,
    this.role,
    this.avatarUrl,
    this.isAdmin = false,
  });

  // Utilisateur connecté (singleton pour l'exemple)
  static User? _currentUser;

  static User getCurrentUser() {
    _currentUser ??= User(
      id: 'current_user',
      name: 'Jean Dupont',
      email: 'jean.dupont@company.com',
      role: 'Développeur',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      isAdmin: false,
    );
    return _currentUser!;
  }

  // Pour changer l'utilisateur connecté (utile pour les tests)
  static void setCurrentUser(User user) {
    _currentUser = user;
  }

  // Mock data pour test
  static List<User> getMockUsers() {
    return [
      User(id: '1', name: 'Jean Martin', email: 'jean@company.com', role: 'Développeur', isAdmin: true, avatarUrl: 'https://i.pravatar.cc/150?img=11'),
      User(id: '2', name: 'Marie Dubois', email: 'marie@company.com', role: 'Designer', avatarUrl: 'https://i.pravatar.cc/150?img=5'),
      User(id: '3', name: 'Pierre Bernard', email: 'pierre@company.com', role: 'Product Owner'),
      User(id: '4', name: 'Sophie Laurent', email: 'sophie@company.com', role: 'Marketing', avatarUrl: 'https://i.pravatar.cc/150?img=9'),
      User(id: '5', name: 'Thomas Petit', email: 'thomas@company.com', role: 'Développeur'),
      User(id: '6', name: 'Emma Roux', email: 'emma@company.com', role: 'RH', avatarUrl: 'https://i.pravatar.cc/150?img=10'),
    ];
  }
}