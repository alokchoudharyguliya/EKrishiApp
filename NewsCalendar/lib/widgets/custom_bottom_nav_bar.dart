import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 0, 'Home'),
          _buildNavItem(context, Icons.camera, 1, 'Farm CCTV'),
          _buildNavItem(context, Icons.newspaper, 2, 'News'),
          _buildNavItem(context, Icons.person, 3, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    int index,
    String label,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
            size: 28,
            semanticLabel: label,
          ),
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
