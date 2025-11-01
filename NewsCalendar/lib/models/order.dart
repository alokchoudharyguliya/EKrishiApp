import 'vendor.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  collected,
  cancelled;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.collected:
        return 'Collected';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem {
  final String supplyId;
  final String supplyName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String unit;

  OrderItem({
    required this.supplyId,
    required this.supplyName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'supplyId': supplyId,
      'supplyName': supplyName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'unit': unit,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      supplyId: json['supplyId']?.toString() ?? '',
      supplyName: json['supplyName']?.toString() ?? '',
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toDouble()
          : double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unitPrice: (json['unitPrice'] is num)
          ? (json['unitPrice'] as num).toDouble()
          : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      totalPrice: (json['totalPrice'] is num)
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      unit: json['unit']?.toString() ?? '',
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String vendorId;
  final Vendor? vendor; // Populated vendor
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? expectedPickupDate;
  final String notes;
  final bool whatsappMessageSent;
  final String whatsappMessageId;
  final DateTime? collectedAt;
  final String? whatsappUrl; // Generated URL for WhatsApp
  final String? whatsappMessage; // Generated message

  Order({
    required this.id,
    required this.orderNumber,
    required this.farmerId,
    required this.vendorId,
    this.vendor,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.expectedPickupDate,
    this.notes = '',
    this.whatsappMessageSent = false,
    this.whatsappMessageId = '',
    this.collectedAt,
    this.whatsappUrl,
    this.whatsappMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'orderNumber': orderNumber,
      'farmerId': farmerId,
      'vendorId': vendorId,
      'vendor': vendor?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'orderDate': orderDate.toIso8601String(),
      'expectedPickupDate': expectedPickupDate?.toIso8601String(),
      'notes': notes,
      'whatsappMessageSent': whatsappMessageSent,
      'whatsappMessageId': whatsappMessageId,
      'collectedAt': collectedAt?.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
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

      // Handle items
      List<OrderItem> orderItems = [];
      if (json['items'] != null && json['items'] is List) {
        orderItems = (json['items'] as List)
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Handle dates
      DateTime orderDate;
      try {
        orderDate = DateTime.parse(json['orderDate']?.toString() ?? DateTime.now().toIso8601String());
      } catch (e) {
        orderDate = DateTime.now();
      }

      DateTime? expectedPickupDate;
      if (json['expectedPickupDate'] != null) {
        try {
          expectedPickupDate = DateTime.parse(json['expectedPickupDate'].toString());
        } catch (e) {
          expectedPickupDate = null;
        }
      }

      DateTime? collectedAt;
      if (json['collectedAt'] != null) {
        try {
          collectedAt = DateTime.parse(json['collectedAt'].toString());
        } catch (e) {
          collectedAt = null;
        }
      }

      // Handle status
      final statusStr = json['status']?.toString().toLowerCase() ?? 'pending';
      final status = OrderStatus.fromString(statusStr);

      return Order(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        orderNumber: json['orderNumber']?.toString() ?? '',
        farmerId: json['farmerId']?.toString() ?? '',
        vendorId: vendorIdStr,
        vendor: vendorObj,
        items: orderItems,
        totalAmount: (json['totalAmount'] is num)
            ? (json['totalAmount'] as num).toDouble()
            : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
        status: status,
        orderDate: orderDate,
        expectedPickupDate: expectedPickupDate,
        notes: json['notes']?.toString() ?? '',
        whatsappMessageSent: json['whatsappMessageSent'] ?? false,
        whatsappMessageId: json['whatsappMessageId']?.toString() ?? '',
        collectedAt: collectedAt,
        whatsappUrl: json['whatsappUrl']?.toString(),
        whatsappMessage: json['whatsappMessage']?.toString(),
      );
    } catch (e) {
      throw FormatException('Failed to parse Order: $e\nJSON: $json');
    }
  }

  Order copyWith({
    String? id,
    String? orderNumber,
    String? farmerId,
    String? vendorId,
    Vendor? vendor,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? expectedPickupDate,
    String? notes,
    bool? whatsappMessageSent,
    String? whatsappMessageId,
    DateTime? collectedAt,
    String? whatsappUrl,
    String? whatsappMessage,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      farmerId: farmerId ?? this.farmerId,
      vendorId: vendorId ?? this.vendorId,
      vendor: vendor ?? this.vendor,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedPickupDate: expectedPickupDate ?? this.expectedPickupDate,
      notes: notes ?? this.notes,
      whatsappMessageSent: whatsappMessageSent ?? this.whatsappMessageSent,
      whatsappMessageId: whatsappMessageId ?? this.whatsappMessageId,
      collectedAt: collectedAt ?? this.collectedAt,
      whatsappUrl: whatsappUrl ?? this.whatsappUrl,
      whatsappMessage: whatsappMessage ?? this.whatsappMessage,
    );
  }

  bool get canCancel {
    return status != OrderStatus.collected && status != OrderStatus.cancelled;
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, status: ${status.name}, totalAmount: ₹$totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

