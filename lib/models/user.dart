class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String password;
  final String phone;
  final String location;
  final String avatarUrl;
  final List<String> favoriteCarIds;
  final List<String> listedCarIds;
  final DateTime createdAt;
  final bool isVerified;
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.phone,
    required this.location,
    required this.avatarUrl,
    required this.favoriteCarIds,
    required this.listedCarIds,
    required this.createdAt,
    required this.isVerified,
    this.isAdmin = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? password,
    String? phone,
    String? location,
    String? avatarUrl,
    List<String>? favoriteCarIds,
    List<String>? listedCarIds,
    DateTime? createdAt,
    bool? isVerified,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteCarIds: favoriteCarIds ?? this.favoriteCarIds,
      listedCarIds: listedCarIds ?? this.listedCarIds,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'phone': phone,
      'location': location,
      'avatarUrl': avatarUrl,
      'favoriteCarIds': favoriteCarIds.join(','), // Convert list to comma-separated string
      'listedCarIds': listedCarIds.join(','), // Convert list to comma-separated string
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified ? 1 : 0, // Convert boolean to integer
      'isAdmin': isAdmin ? 1 : 0, // Convert boolean to integer
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      phone: json['phone'],
      location: json['location'],
      avatarUrl: json['avatarUrl'],
      favoriteCarIds: json['favoriteCarIds'] is String 
          ? json['favoriteCarIds'].split(',').map((e) => e.trim()).toList()
          : List<String>.from(json['favoriteCarIds'] ?? []),
      listedCarIds: json['listedCarIds'] is String 
          ? json['listedCarIds'].split(',').map((e) => e.trim()).toList()
          : List<String>.from(json['listedCarIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      isVerified: json['isVerified'] == 1, // Convert integer to boolean
      isAdmin: json['isAdmin'] == 1, // Convert integer to boolean
    );
  }
}
