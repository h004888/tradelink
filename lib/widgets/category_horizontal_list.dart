import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/ui_state.dart';
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

  double _measuredHeight = 84.0; // fallback an toàn trước khi đo

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measuredHeight = _measureItemHeight(context);
  }

  /// Đo chiều cao cần thiết cho một category item dựa trên text style
  /// và font scale hiện tại. Dùng text 2 dòng ("A\nA") làm worst-case
  /// + buffer 4px cho font metrics差异 (ASCII vs Vietnamese diacritics).
  double _measureItemHeight(BuildContext context) {
    final textPainter = TextPainter(
      text: const TextSpan(text: 'A\nA', style: _textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return (_padding * 2) + _iconSize + _gap + textPainter.height.ceilToDouble() + 4;
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
            '/home/category/${Uri.encodeComponent(items[i].id)}',
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
                _iconForName(item.name, item.icon),
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

  /// Map icon name string từ API → IconData (Material Design icons)
  ///
  /// Bao gồm cả variant `_rounded` được seed data trên server sử dụng.
  static final Map<String, IconData> _iconMap = {
    // ── Devices ──
    'phone_android': Icons.phone_android,
    'phone_android_outlined': Icons.phone_android_outlined,
    'phone_android_rounded': Icons.phone_android_rounded,
    'phone': Icons.phone,
    'phone_outlined': Icons.phone_outlined,
    'phone_rounded': Icons.phone_rounded,
    'smartphone': Icons.smartphone,
    'smartphone_rounded': Icons.smartphone_rounded,
    'laptop': Icons.laptop,
    'laptop_outlined': Icons.laptop_outlined,
    'laptop_rounded': Icons.laptop_rounded,
    'laptop_mac': Icons.laptop_mac,
    'laptop_mac_rounded': Icons.laptop_mac_rounded,
    'computer': Icons.computer,
    'computer_outlined': Icons.computer_outlined,
    'computer_rounded': Icons.computer_rounded,
    'tablet': Icons.tablet,
    'tablet_outlined': Icons.tablet_outlined,
    'tablet_rounded': Icons.tablet_rounded,
    'tablet_mac': Icons.tablet_mac,
    'tablet_mac_rounded': Icons.tablet_mac_rounded,
    'desktop_windows': Icons.desktop_windows,
    'watch': Icons.watch,
    'watch_outlined': Icons.watch_outlined,
    'watch_rounded': Icons.watch_rounded,
    'headphones': Icons.headphones,
    'headphones_outlined': Icons.headphones_outlined,
    'headphones_rounded': Icons.headphones_rounded,
    'headset': Icons.headset,
    'headset_rounded': Icons.headset_rounded,
    'speaker': Icons.speaker,
    'speaker_outlined': Icons.speaker_outlined,
    'speaker_rounded': Icons.speaker_rounded,
    'tv': Icons.tv,
    'tv_outlined': Icons.tv_outlined,
    'tv_rounded': Icons.tv_rounded,
    'camera_alt': Icons.camera_alt,
    'camera_alt_outlined': Icons.camera_alt_outlined,
    'camera_alt_rounded': Icons.camera_alt_rounded,
    'camera': Icons.camera,
    'camera_outlined': Icons.camera_outlined,
    'camera_rounded': Icons.camera_rounded,
    'videocam': Icons.videocam,
    'videocam_outlined': Icons.videocam_outlined,
    'videocam_rounded': Icons.videocam_rounded,
    'memory': Icons.memory,
    'memory_rounded': Icons.memory_rounded,
    'devices': Icons.devices,
    'devices_outlined': Icons.devices_outlined,
    'devices_rounded': Icons.devices_rounded,
    'router': Icons.router,
    'router_rounded': Icons.router_rounded,
    'keyboard': Icons.keyboard,
    'keyboard_outlined': Icons.keyboard_outlined,
    'keyboard_rounded': Icons.keyboard_rounded,
    'mouse': Icons.mouse,
    'mouse_rounded': Icons.mouse_rounded,
    'print': Icons.print,
    'print_rounded': Icons.print_rounded,
    'scanner': Icons.scanner,
    'battery_charging_full': Icons.battery_charging_full,
    'power': Icons.power,

    // ── Transportation ──
    'directions_car': Icons.directions_car,
    'directions_car_outlined': Icons.directions_car_outlined,
    'directions_car_rounded': Icons.directions_car_rounded,
    'directions_bike': Icons.directions_bike,
    'directions_bike_outlined': Icons.directions_bike_outlined,
    'directions_bike_rounded': Icons.directions_bike_rounded,
    'motorcycle': Icons.motorcycle,
    'motorcycle_outlined': Icons.motorcycle_outlined,
    'motorcycle_rounded': Icons.motorcycle_rounded,
    'two_wheeler': Icons.two_wheeler,
    'two_wheeler_rounded': Icons.two_wheeler_rounded,
    'directions_bus': Icons.directions_bus,
    'directions_bus_rounded': Icons.directions_bus_rounded,
    'train': Icons.train,
    'train_rounded': Icons.train_rounded,
    'flight': Icons.flight,
    'flight_outlined': Icons.flight_outlined,
    'flight_rounded': Icons.flight_rounded,
    'directions_boat': Icons.directions_boat,
    'directions_boat_rounded': Icons.directions_boat_rounded,
    'local_shipping': Icons.local_shipping,
    'local_shipping_outlined': Icons.local_shipping_outlined,
    'local_shipping_rounded': Icons.local_shipping_rounded,
    'pedal_bike': Icons.pedal_bike,
    'pedal_bike_rounded': Icons.pedal_bike_rounded,
    'directions_walk': Icons.directions_walk,
    'directions_walk_rounded': Icons.directions_walk_rounded,

    // ── Fashion / Clothing ──
    'checkroom': Icons.checkroom,
    'checkroom_outlined': Icons.checkroom_outlined,
    'checkroom_rounded': Icons.checkroom_rounded,
    'dry_cleaning': Icons.dry_cleaning,
    'dry_cleaning_rounded': Icons.dry_cleaning_rounded,
    'local_laundry_service': Icons.local_laundry_service,
    'local_laundry_service_rounded': Icons.local_laundry_service_rounded,
    'style': Icons.style,
    'style_outlined': Icons.style_outlined,
    'style_rounded': Icons.style_rounded,

    // ── Shopping ──
    'shopping_bag': Icons.shopping_bag,
    'shopping_bag_outlined': Icons.shopping_bag_outlined,
    'shopping_bag_rounded': Icons.shopping_bag_rounded,
    'shopping_basket': Icons.shopping_basket,
    'shopping_basket_rounded': Icons.shopping_basket_rounded,
    'shopping_cart': Icons.shopping_cart,
    'shopping_cart_outlined': Icons.shopping_cart_outlined,
    'shopping_cart_rounded': Icons.shopping_cart_rounded,
    'store': Icons.store,
    'store_outlined': Icons.store_outlined,
    'store_rounded': Icons.store_rounded,
    'storefront': Icons.storefront,
    'storefront_outlined': Icons.storefront_outlined,
    'storefront_rounded': Icons.storefront_rounded,
    'local_mall': Icons.local_mall,
    'local_mall_outlined': Icons.local_mall_outlined,
    'local_mall_rounded': Icons.local_mall_rounded,
    'receipt_long': Icons.receipt_long,
    'receipt_long_rounded': Icons.receipt_long_rounded,
    'sell': Icons.sell,
    'sell_outlined': Icons.sell_outlined,
    'sell_rounded': Icons.sell_rounded,
    'local_offer': Icons.local_offer,
    'local_offer_outlined': Icons.local_offer_outlined,
    'local_offer_rounded': Icons.local_offer_rounded,
    'loyalty': Icons.loyalty,
    'loyalty_rounded': Icons.loyalty_rounded,

    // ── Home / Furniture ──
    'home': Icons.home,
    'home_outlined': Icons.home_outlined,
    'home_rounded': Icons.home_rounded,
    'kitchen': Icons.kitchen,
    'kitchen_outlined': Icons.kitchen_outlined,
    'kitchen_rounded': Icons.kitchen_rounded,
    'bed': Icons.bed,
    'bed_outlined': Icons.bed_outlined,
    'bed_rounded': Icons.bed_rounded,
    'chair': Icons.chair,
    'chair_outlined': Icons.chair_outlined,
    'chair_rounded': Icons.chair_rounded,
    'weekend': Icons.weekend,
    'weekend_outlined': Icons.weekend_outlined,
    'weekend_rounded': Icons.weekend_rounded,
    'dining': Icons.dining,
    'dining_outlined': Icons.dining_outlined,
    'dining_rounded': Icons.dining_rounded,
    'shower': Icons.shower,
    'shower_rounded': Icons.shower_rounded,
    'garage': Icons.garage,
    'light': Icons.light,
    'light_outlined': Icons.light_outlined,
    'light_rounded': Icons.light_rounded,
    'lightbulb': Icons.lightbulb,
    'lightbulb_outlined': Icons.lightbulb_outlined,
    'lightbulb_rounded': Icons.lightbulb_rounded,
    'cleaning_services': Icons.cleaning_services,
    'cleaning_services_rounded': Icons.cleaning_services_rounded,
    'local_laundry_service_outlined': Icons.local_laundry_service_outlined,
    'hardware': Icons.hardware,
    'hardware_outlined': Icons.hardware_outlined,
    'hardware_rounded': Icons.hardware_rounded,
    'grass': Icons.grass,
    'grass_rounded': Icons.grass_rounded,
    'yard': Icons.yard,
    'yard_rounded': Icons.yard_rounded,
    'door_front': Icons.door_front_door,
    'door_front_door': Icons.door_front_door,
    'door_front_door_rounded': Icons.door_front_door_rounded,
    'window': Icons.window,
    'window_rounded': Icons.window_rounded,
    'decorative_services': Icons.palette, // fallback: API dùng icon này cho "Trang trí nhà"
    'decorative_services_rounded': Icons.palette_rounded,

    // ── Sports / Fitness ──
    'fitness_center': Icons.fitness_center,
    'fitness_center_outlined': Icons.fitness_center_outlined,
    'fitness_center_rounded': Icons.fitness_center_rounded,
    'sports': Icons.sports,
    'sports_outlined': Icons.sports_outlined,
    'sports_rounded': Icons.sports_rounded,
    'sports_basketball': Icons.sports_basketball,
    'sports_basketball_rounded': Icons.sports_basketball_rounded,
    'sports_soccer': Icons.sports_soccer,
    'sports_soccer_rounded': Icons.sports_soccer_rounded,
    'sports_tennis': Icons.sports_tennis,
    'sports_tennis_rounded': Icons.sports_tennis_rounded,
    'sports_esports': Icons.sports_esports,
    'sports_esports_outlined': Icons.sports_esports_outlined,
    'sports_esports_rounded': Icons.sports_esports_rounded,
    'pool': Icons.pool,
    'pool_rounded': Icons.pool_rounded,
    'hiking': Icons.hiking,
    'hiking_rounded': Icons.hiking_rounded,
    'surfing': Icons.surfing,
    'self_improvement': Icons.self_improvement,
    'emoji_events': Icons.emoji_events,
    'emoji_events_outlined': Icons.emoji_events_outlined,
    'emoji_events_rounded': Icons.emoji_events_rounded,

    // ── Books / Education ──
    'menu_book': Icons.menu_book,
    'menu_book_outlined': Icons.menu_book_outlined,
    'menu_book_rounded': Icons.menu_book_rounded,
    'auto_stories': Icons.auto_stories,
    'auto_stories_outlined': Icons.auto_stories_outlined,
    'auto_stories_rounded': Icons.auto_stories_rounded,
    'library_books': Icons.library_books,
    'library_books_outlined': Icons.library_books_outlined,
    'library_books_rounded': Icons.library_books_rounded,
    'school': Icons.school,
    'school_outlined': Icons.school_outlined,
    'school_rounded': Icons.school_rounded,
    'science': Icons.science,
    'science_outlined': Icons.science_outlined,
    'science_rounded': Icons.science_rounded,
    'calculate': Icons.calculate,
    'calculate_rounded': Icons.calculate_rounded,
    'history_edu': Icons.history_edu,
    'history_edu_rounded': Icons.history_edu_rounded,
    'edit_note': Icons.edit_note,
    'edit_note_rounded': Icons.edit_note_rounded,

    // ── Music / Entertainment ──
    'music_note': Icons.music_note,
    'music_note_outlined': Icons.music_note_outlined,
    'music_note_rounded': Icons.music_note_rounded,
    'library_music': Icons.library_music,
    'library_music_rounded': Icons.library_music_rounded,
    'piano': Icons.piano,
    'piano_rounded': Icons.piano_rounded,
    'album': Icons.album,
    'album_rounded': Icons.album_rounded,
    'movie': Icons.movie,
    'movie_outlined': Icons.movie_outlined,
    'movie_rounded': Icons.movie_rounded,
    'theaters': Icons.theaters,
    'theaters_outlined': Icons.theaters_outlined,
    'theaters_rounded': Icons.theaters_rounded,
    'gamepad': Icons.gamepad,
    'gamepad_outlined': Icons.gamepad_outlined,
    'gamepad_rounded': Icons.gamepad_rounded,
    'toys': Icons.toys,
    'toys_outlined': Icons.toys_outlined,
    'toys_rounded': Icons.toys_rounded,

    // ── Accessories / Jewelry ──
    'diamond': Icons.diamond,
    'diamond_outlined': Icons.diamond_outlined,
    'diamond_rounded': Icons.diamond_rounded,
    'ring_volume': Icons.ring_volume,
    'ring_volume_rounded': Icons.ring_volume_rounded,
    'backpack': Icons.backpack,
    'backpack_outlined': Icons.backpack_outlined,
    'backpack_rounded': Icons.backpack_rounded,

    // ── Beauty / Health ──
    'spa': Icons.spa,
    'spa_outlined': Icons.spa_outlined,
    'spa_rounded': Icons.spa_rounded,
    'face': Icons.face,
    'face_outlined': Icons.face_outlined,
    'face_rounded': Icons.face_rounded,
    'face_retouching_natural': Icons.face_retouching_natural,
    'face_retouching_natural_rounded': Icons.face_retouching_natural_rounded,
    'brush': Icons.brush,
    'brush_outlined': Icons.brush_outlined,
    'brush_rounded': Icons.brush_rounded,
    'colorize': Icons.colorize,
    'colorize_rounded': Icons.colorize_rounded,
    'healing': Icons.healing,
    'healing_outlined': Icons.healing_outlined,
    'healing_rounded': Icons.healing_rounded,
    'favorite': Icons.favorite,
    'favorite_outlined': Icons.favorite_outlined,
    'favorite_rounded': Icons.favorite_rounded,
    'local_hospital': Icons.local_hospital,
    'local_hospital_rounded': Icons.local_hospital_rounded,
    'medication': Icons.medication,
    'medication_rounded': Icons.medication_rounded,

    // ── Pets ──
    'pets': Icons.pets,
    'pets_outlined': Icons.pets_outlined,
    'pets_rounded': Icons.pets_rounded,

    // ── Food / Grocery ──
    'restaurant': Icons.restaurant,
    'restaurant_outlined': Icons.restaurant_outlined,
    'restaurant_rounded': Icons.restaurant_rounded,
    'local_cafe': Icons.local_cafe,
    'local_cafe_outlined': Icons.local_cafe_outlined,
    'local_cafe_rounded': Icons.local_cafe_rounded,
    'local_grocery_store': Icons.local_grocery_store,
    'local_grocery_store_outlined': Icons.local_grocery_store_outlined,
    'local_grocery_store_rounded': Icons.local_grocery_store_rounded,
    'local_pizza': Icons.local_pizza,
    'local_pizza_rounded': Icons.local_pizza_rounded,
    'fastfood': Icons.fastfood,
    'fastfood_rounded': Icons.fastfood_rounded,
    'cake': Icons.cake,
    'cake_rounded': Icons.cake_rounded,
    'egg': Icons.egg,
    'egg_outlined': Icons.egg_outlined,
    'egg_rounded': Icons.egg_rounded,

    // ── Tools / Misc ──
    'build': Icons.build,
    'build_outlined': Icons.build_outlined,
    'build_rounded': Icons.build_rounded,
    'construction': Icons.construction,
    'construction_outlined': Icons.construction_outlined,
    'construction_rounded': Icons.construction_rounded,
    'handyman': Icons.handyman,
    'handyman_outlined': Icons.handyman_outlined,
    'handyman_rounded': Icons.handyman_rounded,
    'palette': Icons.palette,
    'palette_outlined': Icons.palette_outlined,
    'palette_rounded': Icons.palette_rounded,
    'extension': Icons.extension,
    'extension_outlined': Icons.extension_outlined,
    'extension_rounded': Icons.extension_rounded,
    'category': Icons.category,
    'category_outlined': Icons.category_outlined,
    'category_rounded': Icons.category_rounded,

    // ── Grid / Default ──
    'grid_view': Icons.grid_view,
    'grid_view_rounded': Icons.grid_view_rounded,
    'grid_view_outlined': Icons.grid_view_outlined,
    'apps': Icons.apps,
    'apps_outlined': Icons.apps_outlined,
    'apps_rounded': Icons.apps_rounded,
    'dashboard': Icons.dashboard,
    'dashboard_outlined': Icons.dashboard_outlined,
    'dashboard_rounded': Icons.dashboard_rounded,
    'view_module': Icons.view_module,
    'view_module_outlined': Icons.view_module_outlined,
    'view_module_rounded': Icons.view_module_rounded,
    'widgets': Icons.widgets,
    'widgets_outlined': Icons.widgets_outlined,
    'widgets_rounded': Icons.widgets_rounded,

    // ── Nature / Outdoor ──
    'park': Icons.park,
    'park_outlined': Icons.park_outlined,
    'park_rounded': Icons.park_rounded,
    'local_florist': Icons.local_florist,
    'local_florist_outlined': Icons.local_florist_outlined,
    'local_florist_rounded': Icons.local_florist_rounded,
    'eco': Icons.eco,
    'eco_outlined': Icons.eco_outlined,
    'eco_rounded': Icons.eco_rounded,
    'wb_sunny': Icons.wb_sunny,
    'wb_sunny_rounded': Icons.wb_sunny_rounded,
    'terrain': Icons.terrain,
    'terrain_rounded': Icons.terrain_rounded,
    'landscape': Icons.landscape,
    'landscape_outlined': Icons.landscape_outlined,
    'landscape_rounded': Icons.landscape_rounded,

    // ── Work / Office ──
    'work': Icons.work,
    'work_outlined': Icons.work_outlined,
    'work_rounded': Icons.work_rounded,
    'business': Icons.business,
    'business_outlined': Icons.business_outlined,
    'business_rounded': Icons.business_rounded,
    'badge': Icons.badge,
    'badge_outlined': Icons.badge_outlined,
    'badge_rounded': Icons.badge_rounded,
    'folder': Icons.folder,
    'folder_outlined': Icons.folder_outlined,
    'folder_rounded': Icons.folder_rounded,
    'description': Icons.description,
    'description_outlined': Icons.description_outlined,
    'description_rounded': Icons.description_rounded,

    // ── Visibility ──
    'visibility': Icons.visibility,
    'visibility_rounded': Icons.visibility_rounded,
    'visibility_outlined': Icons.visibility_outlined,

    // ── Baby / Kids ──
    'child_care': Icons.child_care,
    'child_care_outlined': Icons.child_care_outlined,
    'child_care_rounded': Icons.child_care_rounded,
    'child_friendly': Icons.child_friendly,
    'child_friendly_rounded': Icons.child_friendly_rounded,
  };

  static IconData? _iconFromString(String name) {
    if (name.isEmpty) return null;
    return _iconMap[name];
  }

  IconData _iconForName(String name, String iconName) {
    // Ưu tiên icon từ API
    final apiIcon = _iconFromString(iconName);
    if (apiIcon != null) return apiIcon;

    // Fallback: map từ tên category
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
