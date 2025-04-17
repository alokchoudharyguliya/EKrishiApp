import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String? password; // Should be handled carefully
  final String profilePicURL;
  final String? phone;
  final DateTime? dateOfBirth;
  final String role;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? passwordChangedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.profilePicURL = 'default.jpg',
    this.phone,
    this.dateOfBirth,
    this.role = 'user',
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
    this.passwordChangedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: null, // Never store password in the model after retrieval
      profilePicURL: data['profilePicURL'] ?? 'default.jpg',
      phone: data['phone'],
      dateOfBirth:
          data['dateOfBirth'] != null
              ? (data['dateOfBirth'] as Timestamp).toDate()
              : null,
      role: data['role'] ?? 'user',
      active: data['active'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      passwordChangedAt:
          data['passwordChangedAt'] != null
              ? (data['passwordChangedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore({bool includePassword = false}) {
    final map = {
      'name': name,
      'email': email,
      'profilePicURL': profilePicURL,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      'role': role,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (passwordChangedAt != null)
        'passwordChangedAt': Timestamp.fromDate(passwordChangedAt!),
    };

    if (includePassword && password != null) {
      map['password'] = _hashPassword(password!);
    }

    return map;
  }

  String _hashPassword(String plainPassword) {
    // In a real app, use proper hashing like on backend (this is simplified)
    final bytes = utf8.encode(plainPassword);
    return sha256.convert(bytes).toString();
  }

  // Calculated age property
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Formatted date of birth
  String? get formattedDateOfBirth {
    return dateOfBirth != null
        ? DateFormat('MMM dd, yyyy').format(dateOfBirth!)
        : null;
  }

  // Formatted phone number
  String? get formattedPhone {
    if (phone == null) return null;
    // Simple formatting - adjust based on your needs
    if (phone!.length == 10) {
      return '(${phone!.substring(0, 3)}) ${phone!.substring(3, 6)}-${phone!.substring(6)}';
    }
    return phone;
  }

  // Copy with method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? profilePicURL,
    String? phone,
    DateTime? dateOfBirth,
    String? role,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? passwordChangedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePicURL: profilePicURL ?? this.profilePicURL,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
    );
  }
}
