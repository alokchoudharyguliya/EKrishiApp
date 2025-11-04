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
  State<SuppliesMarketplaceScreen> createState() =>
      _SuppliesMarketplaceScreenState();
}

class _SuppliesMarketplaceScreenState extends State<SuppliesMarketplaceScreen>
    with TickerProviderStateMixin {
  List<Supply> _supplies = [];
  List<Supply> _filteredSupplies = [];
  List<Vendor> _vendors = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedVendorId;

  final List<String> _categories = [
    'All',
    'pesticide',
    'fertilizer',
    'seed',
    'equipment',
    'other',
  ];

  // Animation controller for card entrance animations
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
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
      // Animate cards in after data loads
      _listAnimationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load supplies. Please try again.';
        _isLoading = false;
      });
      print('Error loading supplies: $e');
    }
  }

  void _applyFilters() {
    // Reset animation when filtering
    _listAnimationController.reset();
    setState(() {
      _filteredSupplies =
          _supplies.where((supply) {
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
                  (supply.brand.isEmpty ||
                      !supply.brand.toLowerCase().contains(query))) {
                return false;
              }
            }

            return true;
          }).toList();
    });
    // Animate filtered results
    _listAnimationController.forward();
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
      body:
          _isLoading
              ? _buildLoadingSkeleton()
              : _errorMessage != null
              ? _buildErrorState()
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
                        final isSelected =
                            _selectedCategory == category ||
                            (_selectedCategory == null && category == 'All');
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory =
                                    selected && category != 'All'
                                        ? category
                                        : null;
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                        ..._vendors.map(
                          (vendor) => DropdownMenuItem<String>(
                            value: vendor.id,
                            child: Text(vendor.vendorName),
                          ),
                        ),
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
                    child:
                        _filteredSupplies.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No supplies found',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                            : _buildSuppliesGrid(),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 45, 13, 13),
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

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        // Search bar skeleton
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Category chips skeleton
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Grid skeleton
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildSkeletonCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),
          // Content skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliesGrid() {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredSupplies.length,
          itemBuilder: (context, index) {
            final supply = _filteredSupplies[index];
            // Stagger animation for each card (50ms delay per card, max 500ms)
            final animationDelay = (index * 0.05).clamp(0.0, 0.5);
            final controllerValue = _listAnimationController.value;
            final animationValue =
                controllerValue > animationDelay
                    ? ((controllerValue - animationDelay) /
                            (1.0 - animationDelay))
                        .clamp(0.0, 1.0)
                    : 0.0;

            return Transform.translate(
              offset: Offset(0, 20 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: SupplyCard(
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}
