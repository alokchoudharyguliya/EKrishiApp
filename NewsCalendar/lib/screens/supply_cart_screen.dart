import 'package:flutter/material.dart';
import '../utils/imports.dart';
import '../models/supply.dart';
import '../models/vendor.dart';
import '../services/supply_service.dart';
import '../widgets/order_item_tile.dart';
import '../models/order.dart';
import 'create_order_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplyCartScreen extends StatefulWidget {
  const SupplyCartScreen({Key? key}) : super(key: key);

  @override
  State<SupplyCartScreen> createState() => _SupplyCartScreenState();
}

class _SupplyCartScreenState extends State<SupplyCartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, Supply> _suppliesMap = {};
  Map<String, Vendor> _vendorsMap = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getStringList('supply_cart') ?? [];

      if (cartJson.isEmpty) {
        setState(() {
          _cartItems = [];
          _isLoading = false;
        });
        return;
      }

      // Parse cart items
      final List<Map<String, dynamic>> cartItemsData = cartJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      // Get unique supply IDs
      final supplyIds = cartItemsData.map((e) => e['supplyId'] as String).toSet().toList();

      // Fetch all supplies
      final supplies = await Future.wait(
        supplyIds.map((id) => SupplyService.getSupplyById(id)),
      );

      // Create supplies map
      for (final supply in supplies) {
        _suppliesMap[supply.id] = supply;
        if (supply.vendor != null) {
          _vendorsMap[supply.vendorId] = supply.vendor!;
        }
      }

      // Create cart items
      final List<CartItem> items = [];
      final Map<String, double> quantityMap = {};

      // Group by supply ID and sum quantities
      for (final itemData in cartItemsData) {
        final supplyId = itemData['supplyId'] as String;
        final quantity = (itemData['quantity'] as num).toDouble();
        quantityMap[supplyId] = (quantityMap[supplyId] ?? 0) + quantity;
      }

      // Create cart items
      for (final entry in quantityMap.entries) {
        final supply = _suppliesMap[entry.key];
        if (supply != null) {
          items.add(CartItem(
            supply: supply,
            quantity: entry.value,
          ));
        }
      }

      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cart';
        _isLoading = false;
      });
      print('Error loading cart: $e');
    }
  }

  Future<void> _updateCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = _cartItems.map((item) {
        return jsonEncode({
          'supplyId': item.supply.id,
          'quantity': item.quantity,
        });
      }).toList();

      await prefs.setStringList('supply_cart', cartJson);
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  void _updateQuantity(int index, double delta) {
    setState(() {
      final item = _cartItems[index];
      final newQuantity = item.quantity + delta;
      if (newQuantity >= item.supply.minOrderQuantity) {
        _cartItems[index] = CartItem(
          supply: item.supply,
          quantity: newQuantity,
        );
        _updateCart();
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _updateCart();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _updateCart();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cart cleared'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  double _calculateTotal() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.supply.pricePerUnit * item.quantity),
    );
  }

  Map<String, List<CartItem>> _groupByVendor() {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _cartItems) {
      final vendorId = item.supply.vendorId;
      if (!grouped.containsKey(vendorId)) {
        grouped[vendorId] = [];
      }
      grouped[vendorId]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCart,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shopping Cart')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final groupedItems = _groupByVendor();
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to clear all items?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearCart();
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupedItems.length,
              itemBuilder: (context, vendorIndex) {
                final vendorId = groupedItems.keys.elementAt(vendorIndex);
                final items = groupedItems[vendorId]!;
                final vendor = _vendorsMap[vendorId];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vendor != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.store, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              vendor.vendorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    ...items.asMap().entries.map((entry) {
                      final index = _cartItems.indexOf(entry.value);
                      final item = entry.value;
                      final orderItem = OrderItem(
                        supplyId: item.supply.id,
                        supplyName: item.supply.name,
                        quantity: item.quantity,
                        unitPrice: item.supply.pricePerUnit,
                        totalPrice: item.supply.pricePerUnit * item.quantity,
                        unit: item.supply.unit,
                      );

                      return Dismissible(
                        key: Key('${item.supply.id}_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _removeItem(index),
                        child: OrderItemTile(
                          item: orderItem,
                          showQuantityControls: true,
                          onIncrease: () => _updateQuantity(index, 1),
                          onDecrease: () => _updateQuantity(index, -1),
                        ),
                      );
                    }).toList(),
                    if (vendorIndex < groupedItems.length - 1)
                      const Divider(height: 32),
                  ],
                );
              },
            ),
          ),
          // Total and checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to create order screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateOrderScreen(cartItems: _cartItems),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final Supply supply;
  double quantity;

  CartItem({
    required this.supply,
    required this.quantity,
  });
}


