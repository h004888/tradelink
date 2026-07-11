import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '../utils/theme.dart';

/// Search bar trên Home — tap → navigate SearchScreen
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: () => context.push(AppPaths.search),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: TradeLinkColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TradeLinkColors.inputBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 20,
                color: TradeLinkColors.textMuted,
              ),
              const SizedBox(width: 10),
              Text(
                'Tìm kiếm sản phẩm, thương hiệu...',
                style: TextStyle(
                  fontSize: 14,
                  color: TradeLinkColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
