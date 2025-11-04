import 'package:flutter/material.dart';
import '../utils/imports.dart';
import '../models/supply.dart';
import '../models/order.dart';
import '../services/supply_service.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/vendor_card.dart';
import '../utils/whatsapp_launcher.dart';
import 'package:intl/intl.dart';

class CreateOrderScreen extends StatefulWidget {
  final List<dynamic> cartItems; // List<CartItem>

  const CreateOrderScreen({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  DateTime? _pickupDate;
  final TextEditingController _notesController = TextEditingController();
  bool _isCreating = false;
  String? _errorMessage;

  // Group cart items by vendor (one order per vendor)
  Map<String, List<dynamic>> get _groupedByVendor {
    final Map<String, List<dynamic>> grouped = {};
    for (final item in widget.cartItems) {
      final supply = item.supply as Supply;
      final vendorId = supply.vendorId;
      if (!grouped.containsKey(vendorId)) {
        grouped[vendorId] = [];
      }
      grouped[vendorId]!.add(item);
    }
    return grouped;
  }

  double _calculateTotalForItems(List<dynamic> items) {
    return items.fold(
      0.0,
      (sum, item) {
        final supply = item.supply as Supply;
        return sum + (supply.pricePerUnit * item.quantity);
      },
    );
  }

  Future<void> _selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }

  Future<void> _createOrderForVendor(String vendorId, List<dynamic> items) async {
    try {
      setState(() {
        _isCreating = true;
        _errorMessage = null;
      });

      final orderItems = items.map((item) {
        final supply = item.supply as Supply;
        return {
          'supplyId': supply.id,
          'quantity': item.quantity,
        };
      }).toList();

      final order = await SupplyService.createOrder(
        items: orderItems,
        vendorId: vendorId,
        expectedPickupDate: _pickupDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Launch WhatsApp with order message
      if (order.whatsappUrl != null && order.vendor != null) {
        await launchWhatsAppOrder(order.vendor!.phone, order.whatsappMessage ?? '');
      }

      if (mounted) {
        // Clear cart for this vendor's items
        final prefs = await SharedPreferences.getInstance();
        final cartJson = prefs.getStringList('supply_cart') ?? [];
        final remainingItems = cartJson.where((itemJson) {
          final item = jsonDecode(itemJson) as Map<String, dynamic>;
          final supplyId = item['supplyId'] as String;
          return !items.any((cartItem) => (cartItem.supply as Supply).id == supplyId);
        }).toList();
        await prefs.setStringList('supply_cart', remainingItems);

        Navigator.pop(context); // Close create order screen
        Navigator.pop(context); // Close cart screen
        Navigator.pop(context); // Close marketplace screen

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! WhatsApp message opened.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create order: ${e.toString()}';
        _isCreating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupedByVendor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order items by vendor
            ...groupedItems.entries.map((entry) {
              final vendorId = entry.key;
              final items = entry.value;
              final total = _calculateTotalForItems(items);
              final firstItem = items.first;
              final supply = firstItem.supply as Supply;
              final vendor = supply.vendor;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor info
                  if (vendor != null) ...[
                    VendorCard(vendor: vendor),
                    const SizedBox(height: 16),
                  ],
                  // Items
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) {
                    final supply = item.supply as Supply;
                    final orderItem = OrderItem(
                      supplyId: supply.id,
                      supplyName: supply.name,
                      quantity: item.quantity,
                      unitPrice: supply.pricePerUnit,
                      totalPrice: supply.pricePerUnit * item.quantity,
                      unit: supply.unit,
                    );
                    return OrderItemTile(item: orderItem);
                  }).toList(),
                  // Total for this vendor
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),

            // Pickup date
            const Text(
              'Expected Pickup Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectPickupDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _pickupDate != null
                          ? DateFormat('MMMM dd, yyyy').format(_pickupDate!)
                          : 'Select pickup date',
                      style: TextStyle(
                        fontSize: 16,
                        color: _pickupDate != null ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any special instructions or notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Create order button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating || groupedItems.isEmpty
                    ? null
                    : () async {
                        // Create order for each vendor
                        for (final entry in groupedItems.entries) {
                          await _createOrderForVendor(entry.key, entry.value);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Place Order & Send WhatsApp',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}




