import 'package:flutter/material.dart';
import '../utils/imports.dart';
import '../models/supply.dart';
import '../models/vendor.dart';
import '../services/supply_service.dart';
import '../widgets/supply_card.dart';
import 'supply_detail_screen.dart';
import 'supply_cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuppliesMarketplaceScreen extends StatefulWidget {
  const SuppliesMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<SuppliesMarketplaceScreen> createState() => _SuppliesMarketplaceScreenState();
}

class _SuppliesMarketplaceScreenState extends State<SuppliesMarketplaceScreen> {
  List<Supply> _supplies = [];
  List<Supply> _filteredSupplies = [];
  List<Vendor> _vendors = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedVendorId;

  final List<String> _categories = ['All', 'pesticide', 'fertilizer', 'seed', 'equipment', 'other'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        SupplyService.getSupplies(isAvailable: true),
        SupplyService.getVendors(),
      ]);
      final supplies = results[0] as List<Supply>;
      final vendors = results[1] as List<Vendor>;

      setState(() {
        _supplies = supplies;
        _vendors = vendors;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load supplies. Please try again.';
        _isLoading = false;
      });
      print('Error loading supplies: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredSupplies = _supplies.where((supply) {
        // Category filter
        if (_selectedCategory != null && _selectedCategory != 'All') {
          if (supply.category.name != _selectedCategory) return false;
        }

        // Vendor filter
        if (_selectedVendorId != null && _selectedVendorId!.isNotEmpty) {
          if (supply.vendorId != _selectedVendorId) return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!supply.name.toLowerCase().contains(query) &&
              !supply.description.toLowerCase().contains(query) &&
              (supply.brand.isEmpty || !supply.brand.toLowerCase().contains(query))) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _addToCart(Supply supply) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartKey = 'supply_cart';
      final cartJson = prefs.getStringList(cartKey) ?? [];
      
      // Add item to cart
      final cartItem = {
        'supplyId': supply.id,
        'quantity': supply.minOrderQuantity,
      };
      cartJson.add(jsonEncode(cartItem));
      
      await prefs.setStringList(cartKey, cartJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${supply.name} added to cart'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
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
      appBar: AppBar(
        title: const Text('Supplies Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupplyCartScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search supplies...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    // Category filter chips
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category ||
                              (_selectedCategory == null && category == 'All');
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected && category != 'All' ? category : null;
                                });
                                _applyFilters();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Vendor filter dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Vendor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        value: _selectedVendorId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Vendors'),
                          ),
                          ..._vendors.map((vendor) => DropdownMenuItem<String>(
                                value: vendor.id,
                                child: Text(vendor.vendorName),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedVendorId = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Supplies list
                    Expanded(
                      child: _filteredSupplies.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No supplies found',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filteredSupplies.length,
                              itemBuilder: (context, index) {
                                final supply = _filteredSupplies[index];
                                return SupplyCard(
                                  supply: supply,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SupplyDetailScreen(supplyId: supply.id),
                                      ),
                                    );
                                  },
                                  onAddToCart: () => _addToCart(supply),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupplyCartScreen()),
          );
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Cart'),
      ),
    );
  }
}

