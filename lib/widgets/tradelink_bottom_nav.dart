import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/theme.dart';
import '../utils/constants.dart';

/// Bottom navigation bar của TradeLink — card nền trắng bo góc, 5 tab.
///
/// - 4 tab chính: Khám phá, Tin nhắn, Giao dịch, Hồ sơ
/// - 1 FAB center: Đăng tin (mở CreateListingView)
///
/// ## Layout
///
/// Container (surface, radius: xl, shadow: medium, margin: 12x8)
///   └── SafeArea
///         └── Row (5 items)
///               ├── Expanded + _NavItem × 4
///               └── _FabItem × 1
///
/// Không dùng SizedBox height fixed — Row tự do co giãn theo nội dung
/// để tránh RenderFlex overflow khi textScaleFactor thay đổi.
class TradeLinkBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TradeLinkBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const int tabHome = 0;
  static const int tabChat = 1;
  static const int tabTransactions = 2;
  static const int tabProfile = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TradeLinkColors.surface,
        borderRadius: BorderRadius.circular(TradeLinkRadii.xl),
        boxShadow: TradeLinkShadow.medium,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          // Chiều cao đủ để chứa FAB circle (56px) + text + gaps
          // = 56 + 4 + ~15 (text 11px) + 6 + 3 = 84px → 85px
          height: 85,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab 0: Khám phá
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                  label: 'Khám phá',
                  selected: currentIndex == tabHome,
                  onTap: () => onTap(tabHome),
                ),
              ),
              // Tab 1: Tin nhắn
              Expanded(
                child: _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Tin nhắn',
                  selected: currentIndex == tabChat,
                  onTap: () => onTap(tabChat),
                ),
              ),
              // FAB: Đăng tin
              _FabItem(onTap: () => context.push(AppPaths.createListing)),
              // Tab 2: Giao dịch
              Expanded(
                child: _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Giao dịch',
                  selected: currentIndex == tabTransactions,
                  onTap: () => onTap(tabTransactions),
                ),
              ),
              // Tab 3: Hồ sơ
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Hồ sơ',
                  selected: currentIndex == tabProfile,
                  onTap: () => onTap(tabProfile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Một tab item thường — icon + label + underline active
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? TradeLinkColors.primary
        : TradeLinkColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          Icon(
            selected ? activeIcon : icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textScaleFactor: 1.0,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          // Active indicator
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: selected ? TradeLinkColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// FAB center — nút tròn xanh, dấu cộng trắng.
/// Có Spacer để chiều cao co giãn đồng nhất với _NavItem,
/// tránh RenderFlex overflow.
class _FabItem extends StatelessWidget {
  final VoidCallback onTap;

  const _FabItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: TradeLinkColors.primary,
              shape: BoxShape.circle,
              boxShadow: TradeLinkShadow.medium,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Đăng tin',
            textScaleFactor: 1.0,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TradeLinkColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          // Spacer để khớp chiều cao underline của _NavItem
          const SizedBox(height: 3),
        ],
      ),
    );
  }
}
