import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/ui_state.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../viewmodels/home_category_viewmodel.dart';

/// Danh mục sản phẩm dạng horizontal scroll.
/// Tải từ API, fallback về danh sách hard-code khi lỗi.
class CategoryHorizontalList extends StatelessWidget {
  const CategoryHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeCategoryViewModel(),
      child: const _CategoryListBody(),
    );
  }
}

class _CategoryListBody extends StatefulWidget {
  const _CategoryListBody();

  @override
  State<_CategoryListBody> createState() => _CategoryListBodyState();
}

class _CategoryListBodyState extends State<_CategoryListBody> {
  // ── Layout constants ──
  static const _textStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: TradeLinkColors.onSurfaceVariant,
  );
  static const _gap = 4.0;
  static const _iconSize = 44.0;
  static const _padding = 5.0;

  double _measuredHeight = 80.0; // fallback an toàn trước khi đo

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measuredHeight = _measureItemHeight(context);
  }

  /// Đo chiều cao cần thiết cho một category item dựa trên text style
  /// và font scale hiện tại. Dùng text 2 dòng ("A\nA") làm worst-case.
  double _measureItemHeight(BuildContext context) {
    final textPainter = TextPainter(
      text: const TextSpan(text: 'A\nA', style: _textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return (_padding * 2) + _iconSize + _gap + textPainter.height.ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeCategoryViewModel>();

    return switch (vm.state) {
      Loading() => _buildSkeleton(),
      Success(data: final items) => _buildList(items, context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSkeleton() {
    return SizedBox(
      height: _measuredHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: 5,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.only(right: 12),
          child: _CategorySkeleton(),
        ),
      ),
    );
  }

  Widget _buildList(List<CategoryItem> items, BuildContext context) {
    return SizedBox(
      height: _measuredHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _CategoryItemWidget(
          item: items[i],
          onTap: () => context.push(
            '${AppPaths.category}/${Uri.encodeComponent(items[i].name)}',
          ),
        ),
      ),
    );
  }
}

class _CategoryItemWidget extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onTap;

  const _CategoryItemWidget({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        padding: const EdgeInsets.all(_CategoryListBodyState._padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _CategoryListBodyState._iconSize,
              height: _CategoryListBodyState._iconSize,
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                _iconForCategory(item.name),
                size: 20,
                color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: _CategoryListBodyState._gap),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _CategoryListBodyState._textStyle,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String name) {
    const icons = <String, IconData>{
      'Điện thoại': Icons.phone_android_outlined,
      'Laptop': Icons.laptop_outlined,
      'Xe cộ': Icons.directions_car_outlined,
      'Thời trang': Icons.checkroom_outlined,
      'Máy ảnh': Icons.camera_alt_outlined,
      'Điện tử': Icons.headphones_outlined,
      'Phụ kiện': Icons.watch_outlined,
      'Đồ gia dụng': Icons.kitchen_outlined,
      'Nhà cửa': Icons.home_outlined,
      'Thể thao': Icons.fitness_center_outlined,
      'Sách': Icons.menu_book_outlined,
      'Khác': Icons.grid_view_rounded,
    };
    return icons[name] ?? Icons.grid_view_rounded;
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 68,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _CategoryListBodyState._iconSize,
            height: _CategoryListBodyState._iconSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerHigh,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          SizedBox(height: _CategoryListBodyState._gap),
          SizedBox(
            width: 40,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerHigh,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
