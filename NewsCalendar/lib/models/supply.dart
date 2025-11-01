import 'vendor.dart';

enum SupplyCategory {
  pesticide,
  fertilizer,
  seed,
  equipment,
  other;

  static SupplyCategory fromString(String value) {
    return SupplyCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SupplyCategory.other,
    );
  }

  String get displayName {
    switch (this) {
      case SupplyCategory.pesticide:
        return 'Pesticide';
      case SupplyCategory.fertilizer:
        return 'Fertilizer';
      case SupplyCategory.seed:
        return 'Seed';
      case SupplyCategory.equipment:
        return 'Equipment';
      case SupplyCategory.other:
        return 'Other';
    }
  }
}

class Supply {
  final String id;
  final String name;
  final String description;
  final SupplyCategory category;
  final String unit;
  final double pricePerUnit;
  final String vendorId;
  final Vendor? vendor; // Populated vendor
  final bool isAvailable;
  final double stockQuantity;
  final String imageUrl;
  final String brand;
  final Map<String, dynamic> specifications;
  final double minOrderQuantity;

  Supply({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.unit,
    required this.pricePerUnit,
    required this.vendorId,
    this.vendor,
    this.isAvailable = true,
    this.stockQuantity = 0.0,
    this.imageUrl = '',
    this.brand = '',
    this.specifications = const {},
    this.minOrderQuantity = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'vendorId': vendorId,
      'vendor': vendor?.toJson(),
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
      'imageUrl': imageUrl,
      'brand': brand,
      'specifications': specifications,
      'minOrderQuantity': minOrderQuantity,
    };
  }

  factory Supply.fromJson(Map<String, dynamic> json) {
    try {
      // Handle vendor (can be ObjectId string or populated object)
      String vendorIdStr = '';
      Vendor? vendorObj;

      if (json['vendorId'] != null) {
        if (json['vendorId'] is Map) {
          // Populated vendor
          vendorObj = Vendor.fromJson(json['vendorId'] as Map<String, dynamic>);
          vendorIdStr = vendorObj.id;
        } else {
          vendorIdStr = json['vendorId'].toString();
        }
      }

      // Handle category
      final categoryStr = json['category']?.toString().toLowerCase() ?? 'other';
      final category = SupplyCategory.fromString(categoryStr);

      // Handle specifications
      Map<String, dynamic> specs = {};
      if (json['specifications'] != null && json['specifications'] is Map) {
        specs = Map<String, dynamic>.from(json['specifications'] as Map);
      }

      return Supply(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: category,
        unit: json['unit']?.toString() ?? '',
        pricePerUnit: (json['pricePerUnit'] is num)
            ? (json['pricePerUnit'] as num).toDouble()
            : double.tryParse(json['pricePerUnit']?.toString() ?? '0') ?? 0.0,
        vendorId: vendorIdStr,
        vendor: vendorObj,
        isAvailable: json['isAvailable'] ?? true,
        stockQuantity: (json['stockQuantity'] is num)
            ? (json['stockQuantity'] as num).toDouble()
            : double.tryParse(json['stockQuantity']?.toString() ?? '0') ?? 0.0,
        imageUrl: json['imageUrl']?.toString() ?? '',
        brand: json['brand']?.toString() ?? '',
        specifications: specs,
        minOrderQuantity: (json['minOrderQuantity'] is num)
            ? (json['minOrderQuantity'] as num).toDouble()
            : double.tryParse(json['minOrderQuantity']?.toString() ?? '1') ?? 1.0,
      );
    } catch (e) {
      throw FormatException('Failed to parse Supply: $e\nJSON: $json');
    }
  }

  Supply copyWith({
    String? id,
    String? name,
    String? description,
    SupplyCategory? category,
    String? unit,
    double? pricePerUnit,
    String? vendorId,
    Vendor? vendor,
    bool? isAvailable,
    double? stockQuantity,
    String? imageUrl,
    String? brand,
    Map<String, dynamic>? specifications,
    double? minOrderQuantity,
  }) {
    return Supply(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      vendorId: vendorId ?? this.vendorId,
      vendor: vendor ?? this.vendor,
      isAvailable: isAvailable ?? this.isAvailable,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand ?? this.brand,
      specifications: specifications ?? this.specifications,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
    );
  }

  double calculateTotal(double quantity) {
    return pricePerUnit * quantity;
  }

  @override
  String toString() {
    return 'Supply(id: $id, name: $name, category: ${category.name}, price: ₹$pricePerUnit/$unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supply && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

