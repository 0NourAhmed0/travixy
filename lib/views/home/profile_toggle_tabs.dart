import 'package:flutter/material.dart';

class ProfileToggleTabs extends StatefulWidget {
  const ProfileToggleTabs({super.key});

  @override
  State<ProfileToggleTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileToggleTabs> {
  int _selected = 0; // 0 = Trips, 1 = Recently Viewed

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle buttons
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab('Trips', 0),
              _buildTab('Recently Viewed', 1, icon: Icons.lock, iconSize: 14),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content
        if (_selected == 0)
          const Text('Trips content here')
        else
          const Text('Recently Viewed content here'),
      ],
    );
  }

  Widget _buildTab(String label, int index, {IconData? icon, double iconSize = 14}) {
    final isSelected = _selected == index;
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: iconSize, color: Colors.black),
            ],
          ],
        ),
      ),
    );
  }
}