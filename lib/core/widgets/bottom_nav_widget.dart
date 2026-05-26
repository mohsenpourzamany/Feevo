import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';

class FeevoBottomNav extends StatelessWidget {
  final int currentIndex;

  const FeevoBottomNav({
    super.key,
    required this.currentIndex,
  });

  static const List<Map<String, dynamic>> _items = [
    {'icon': Icons.home_rounded,           'label': 'Home',    'route': AppRoutes.home},
    {'icon': Icons.search_rounded,         'label': 'Search',  'route': AppRoutes.search},
    {'icon': Icons.water_drop_outlined,    'label': 'Mood',    'route': AppRoutes.moodFlow},
    {'icon': Icons.map_outlined,           'label': 'Memory',  'route': AppRoutes.memoryMap},
    {'icon': Icons.person_outline_rounded, 'label': 'Profile', 'route': AppRoutes.profile},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:  AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item   = _items[i];
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () {
                  if (i != currentIndex) {
                    context.go(item['route'] as String);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: active
                        ? LinearGradient(colors: [
                            AppColors.purple.withOpacity(0.15),
                            AppColors.cyan.withOpacity(0.08),
                          ])
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // mood tab — special gradient icon
                      i == 2 && active
                          ? ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.primaryGradient.createShader(bounds),
                              child: Icon(
                                item['icon'] as IconData,
                                size:  22,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              item['icon'] as IconData,
                              size:  22,
                              color: active
                                  ? AppColors.purple3
                                  : AppColors.textThird,
                            ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize:   9,
                          fontWeight: FontWeight.w500,
                          color: active
                              ? AppColors.purple3
                              : AppColors.textThird,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
