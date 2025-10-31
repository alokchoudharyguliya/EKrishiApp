class Equipment {
  final String id;
  final String name;
  final String description;
  final double price; // Number, not String
  final String contact;
  final String location;
  final bool isAvailable;
  final String imageUrl; // Standardized name from backend
  final String ownerId; // Standardized name (ObjectId as String)

  Equipment({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.contact,
    this.location = '',
    this.isAvailable = true,
    this.imageUrl = '',
    required this.ownerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id, // Backend compatibility
      'name': name,
      'description': description,
      'price': price,
      'contact': contact,
      'location': location,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'owner': ownerId, // Backend uses 'owner'
      'ownerId': ownerId, // Frontend compatibility
    };
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    try {
      // Handle both backend format (owner as ObjectId) and frontend format (ownerId)
      final ownerId =
          json['ownerId']?.toString() ?? json['owner']?.toString() ?? '';

      return Equipment(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price:
            (json['price'] is num)
                ? (json['price'] as num).toDouble()
                : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
        contact: json['contact'] ?? '',
        location: json['location'] ?? '',
        isAvailable: json['isAvailable'] ?? true,
        imageUrl: json['imageUrl'] ?? json['image'] ?? '', // Handle both names
        ownerId: ownerId,
      );
    } catch (e) {
      throw FormatException('Failed to parse Equipment: $e\nJSON: $json');
    }
  }

  Equipment copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? contact,
    String? location,
    bool? isAvailable,
    String? imageUrl,
    String? ownerId,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      contact: contact ?? this.contact,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  String toString() {
    return 'Equipment(id: $id, name: $name, price: $price, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
