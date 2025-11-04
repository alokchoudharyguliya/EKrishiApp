class Vendor {
  final String id;
  final String vendorName;
  final String ownerName;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final bool isActive;
  final List<String> supplyCategories;
  final Map<String, String> shopHours;
  final double rating;

  Vendor({
    required this.id,
    required this.vendorName,
    this.ownerName = '',
    required this.phone,
    this.email = '',
    required this.address,
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.isActive = true,
    this.supplyCategories = const [],
    this.shopHours = const {'open': '09:00', 'close': '18:00'},
    this.rating = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'vendorName': vendorName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isActive': isActive,
      'supplyCategories': supplyCategories,
      'shopHours': shopHours,
      'rating': rating,
    };
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    try {
      // Handle shopHours
      Map<String, String> hours = {'open': '09:00', 'close': '18:00'};
      if (json['shopHours'] != null) {
        if (json['shopHours'] is Map) {
          final hoursMap = json['shopHours'] as Map;
          hours = {
            'open': hoursMap['open']?.toString() ?? '09:00',
            'close': hoursMap['close']?.toString() ?? '18:00',
          };
        }
      }

      // Handle supplyCategories
      List<String> categories = [];
      if (json['supplyCategories'] != null) {
        if (json['supplyCategories'] is List) {
          categories = (json['supplyCategories'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }

      return Vendor(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        vendorName: json['vendorName']?.toString() ?? '',
        ownerName: json['ownerName']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        pincode: json['pincode']?.toString() ?? '',
        isActive: json['isActive'] ?? true,
        supplyCategories: categories,
        shopHours: hours,
        rating: (json['rating'] is num)
            ? (json['rating'] as num).toDouble()
            : double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      );
    } catch (e) {
      throw FormatException('Failed to parse Vendor: $e\nJSON: $json');
    }
  }

  Vendor copyWith({
    String? id,
    String? vendorName,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    bool? isActive,
    List<String>? supplyCategories,
    Map<String, String>? shopHours,
    double? rating,
  }) {
    return Vendor(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isActive: isActive ?? this.isActive,
      supplyCategories: supplyCategories ?? this.supplyCategories,
      shopHours: shopHours ?? this.shopHours,
      rating: rating ?? this.rating,
    );
  }

  String get fullAddress {
    final parts = [address, city, state, pincode].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  @override
  String toString() {
    return 'Vendor(id: $id, vendorName: $vendorName, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vendor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}




