import 'package:flutter/material.dart';

class FoodItemRow extends StatelessWidget {
  final String name;
  final double calories;
  final IconData icon;

  const FoodItemRow({
    super.key,
    required this.name,
    required this.calories,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Text(
            "$calories KCal",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
