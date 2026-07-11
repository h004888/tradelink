import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/category_horizontal_list.dart';
import '../../widgets/home_search_bar.dart';
import '../../widgets/product_section.dart';
import '../../widgets/safe_transaction_banner.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();
  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: vm.load,
          color: TradeLinkColors.primaryContainer,
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Unified header: logo + location + actions
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Image.asset('assets/images/logo.png', width: 32, height: 32),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 18, color: TradeLinkColors.primary),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text('Hà Nội', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: TradeLinkColors.onSurfaceVariant),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded),
                        onPressed: () {},
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              )),
              // Search bar
              SliverToBoxAdapter(child: const HomeSearchBar()),
              // Categories
              SliverToBoxAdapter(child: const CategoryHorizontalList()),
              // Safety banner
              SliverToBoxAdapter(child: const SafeTransactionBanner()),
              // Nearby section
              SliverToBoxAdapter(child: ProductSection(
                title: 'Gần bạn',
                state: vm.nearby,
                onViewAll: () => context.push(AppPaths.search),
                onProductTap: (id) => vm.goToItemDetail(context, id),
              )),
              // Newest section
              SliverToBoxAdapter(child: ProductSection(
                title: 'Mới đăng',
                state: vm.newest,
                onViewAll: () => context.push(AppPaths.search),
                onProductTap: (id) => vm.goToItemDetail(context, id),
              )),
              // Bottom spacer để content không bị nav che
              const SliverToBoxAdapter(child: SizedBox(height: 170)),
            ],
          ),
        ),
      ),
    );
  }
}
