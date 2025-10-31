class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime? dob; // Changed from String to Date
  final String? phone;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.dob,
    this.phone,
    this.role = 'student',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id, // Backend compatibility
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'dob': dob?.toIso8601String(), // Convert Date to ISO string
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] ?? json['_id'] ?? '',
        email: json['email'] ?? '',
        name: json['name'],
        photoUrl: json['photoUrl'],
        dob: _parseDateTime(json['dob']), // Parse String or Date to DateTime
        phone: json['phone'],
        role: json['role'] ?? 'student',
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse User: $e\nJSON: $json');
    }
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date == null) return null;

    try {
      if (date is String) {
        return DateTime.parse(date);
      }
      return null;
    } catch (e) {
      print('Failed to parse date: $date');
      return null;
    }
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? dob,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to calculate age from DOB
  int? get age {
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
