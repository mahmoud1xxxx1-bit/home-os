enum AuthProviderType { email, google, apple }

class LocalUser {
  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final AuthProviderType provider;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'provider': provider.name,
        'createdAt': createdAt.toIso8601String(),
      };

  static LocalUser fromJson(Map<String, Object?> json) {
    return LocalUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      provider: AuthProviderType.values.byName(json['provider'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.hasCompletedOnboarding,
    this.user,
  });

  final bool isLoading;
  final bool hasCompletedOnboarding;
  final LocalUser? user;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    bool? hasCompletedOnboarding,
    LocalUser? user,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      user: clearUser ? null : user ?? this.user,
    );
  }
}
