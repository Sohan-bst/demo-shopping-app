import 'dart:convert';

/// A signed-in demo user.
///
/// This is fake, locally-stored data — there is no real authentication or
/// backend. The model is immutable; use [copyWith] to derive updated copies.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarSeed,
    this.memberSince,
  });

  final String id;
  final String name;
  final String email;

  /// Seed used to pick a deterministic avatar color/initials in the UI.
  final String? avatarSeed;

  /// When the (fake) account was created; used on the profile screen.
  final DateTime? memberSince;

  /// Uppercase initials derived from [name], e.g. "Ada Lovelace" -> "AL".
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarSeed,
    DateTime? memberSince,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarSeed': avatarSeed,
        'memberSince': memberSince?.toIso8601String(),
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        avatarSeed: map['avatarSeed'] as String?,
        memberSince: map['memberSince'] == null
            ? null
            : DateTime.tryParse(map['memberSince'] as String),
      );

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email;

  @override
  int get hashCode => Object.hash(id, name, email);

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
