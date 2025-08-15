import 'package:flutter/material.dart';
import '../../utils/app_routes.dart'; // Adjust the path as needed

class CategorySection extends StatelessWidget {
  const CategorySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'All', 'image': 'assets/images/all.png', 'color': Colors.purple.shade400},
      {'name': 'Banana', 'image': 'assets/images/banana.png', 'color': Colors.yellow.shade400},
      {'name': 'Apple', 'image': 'assets/images/apple.png', 'color': Colors.red.shade400},
      {'name': 'Orange', 'image': 'assets/images/orange.png', 'color': Colors.orange.shade400},
      {'name': 'Grapes', 'image': 'assets/images/grapes.png', 'color': Colors.purple.shade300},
      {'name': 'Strawberry', 'image': 'assets/images/strawberry.png', 'color': Colors.pink.shade400},
      {'name': 'Mango', 'image': 'assets/images/mango.png', 'color': Colors.orange.shade300},
      {'name': 'Pineapple', 'image': 'assets/images/pineapple.png', 'color': Colors.yellow.shade600},
      {'name': 'Vegetables', 'image': 'assets/images/vegetables.png', 'color': Colors.green.shade400},
      {'name': 'Dairy', 'image': 'assets/images/dairy.png', 'color': Colors.blue.shade400},
      {'name': 'Grains', 'image': 'assets/images/grains.png', 'color': Colors.amber.shade400},
      {'name': 'Pulses', 'image': 'assets/images/pulses.png', 'color': Colors.brown.shade400},
      {'name': 'Spices', 'image': 'assets/images/spices.png', 'color': Colors.green.shade600},
      {'name': 'Beverages', 'image': 'assets/images/beverages.png', 'color': Colors.orange.shade400},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0), // Added top margin of 20
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 4),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.search,
                        arguments: {'category': category['name']},
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: (category['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: (category['color'] as Color).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                category['image'] as String,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to icon if image fails to load
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 30,
                                    color: category['color'] as Color,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Container(
                            width: 80,
                            child: Text(
                              category['name'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}