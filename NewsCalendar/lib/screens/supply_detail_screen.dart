import 'package:flutter/material.dart';
import '../utils/imports.dart';
import '../models/supply.dart';
import '../services/supply_service.dart';
import '../widgets/vendor_card.dart';
import 'supply_cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplyDetailScreen extends StatefulWidget {
  final String supplyId;

  const SupplyDetailScreen({Key? key, required this.supplyId})
    : super(key: key);

  @override
  State<SupplyDetailScreen> createState() => _SupplyDetailScreenState();
}

class _SupplyDetailScreenState extends State<SupplyDetailScreen> {
  Supply? _supply;
  bool _isLoading = true;
  String? _errorMessage;
  double _quantity = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSupply();
  }

  Future<void> _loadSupply() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supply = await SupplyService.getSupplyById(widget.supplyId);
      setState(() {
        _supply = supply;
        _quantity = supply.minOrderQuantity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load supply details';
        _isLoading = false;
      });
      print('Error loading supply: $e');
    }
  }

  Future<void> _addToCart() async {
    if (_supply == null || !_supply!.isAvailable) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartKey = 'supply_cart';
      final cartJson = prefs.getStringList(cartKey) ?? [];

      final cartItem = {'supplyId': _supply!.id, 'quantity': _quantity};
      cartJson.add(jsonEncode(cartItem));

      await prefs.setStringList(cartKey, cartJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${_supply!.name} to cart'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SupplyCartScreen()),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supply Details')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSupply,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _supply == null
              ? const Center(child: Text('Supply not found'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    _supply!.imageUrl.isNotEmpty
                        ? Image.network(
                          _supply!.imageUrl,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                        )
                        : _buildPlaceholderImage(),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                _supply!.category,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _supply!.category.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(_supply!.category),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            _supply!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_supply!.brand.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Brand: ${_supply!.brand}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Price
                          Row(
                            children: [
                              Text(
                                '₹${_supply!.pricePerUnit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '/ ${_supply!.unit}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (_supply!.stockQuantity > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'In Stock: ${_supply!.stockQuantity.toStringAsFixed(0)} ${_supply!.unit}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Description
                          if (_supply!.description.isNotEmpty) ...[
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _supply!.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Quantity selector
                          if (_supply!.isAvailable) ...[
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed:
                                      _quantity > _supply!.minOrderQuantity
                                          ? () {
                                            setState(() {
                                              _quantity -= 1;
                                            });
                                          }
                                          : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_quantity.toStringAsFixed(0)} ${_supply!.unit}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _quantity += 1;
                                    });
                                  },
                                ),
                                const Spacer(),
                                Text(
                                  'Total: ₹${(_supply!.pricePerUnit * _quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Add to cart button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _addToCart,
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text(
                                  'Add to Cart',
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Currently out of stock',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Vendor info
                          if (_supply!.vendor != null) ...[
                            const SizedBox(height: 32),
                            const Text(
                              'Vendor Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            VendorCard(vendor: _supply!.vendor!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
    );
  }

  Color _getCategoryColor(SupplyCategory category) {
    switch (category) {
      case SupplyCategory.pesticide:
        return Colors.orange;
      case SupplyCategory.fertilizer:
        return Colors.blue;
      case SupplyCategory.seed:
        return Colors.green;
      case SupplyCategory.equipment:
        return Colors.brown;
      case SupplyCategory.other:
        return Colors.grey;
    }
  }
}
