import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui_state.dart';
import '../../models/transaction_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/active_transaction_card.dart';
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

    // Lấy transaction active đầu tiên (nếu có)
    Transaction? activeTx;
    if (vm.activeTransactions is Success<List<Transaction>>) {
      final txs = (vm.activeTransactions as Success<List<Transaction>>).data;
      activeTx = txs.cast<Transaction?>().firstWhere(
        (t) => t!.escrowStep != null && t.escrowStep != EscrowStep.released,
        orElse: () => null,
      );
    }

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
              // Header: logo + location + actions
              SliverToBoxAdapter(child: _buildHeader()),
              // Search bar
              const SliverToBoxAdapter(child: HomeSearchBar()),
              // Active transaction card
              SliverToBoxAdapter(child: ActiveTransactionCard(
                transaction: activeTx,
                isLoading: vm.activeTransactions is Loading,
                onTap: activeTx != null
                    ? () => vm.goToTransactionDetail(context, activeTx!)
                    : null,
              )),
              // Categories
              const SliverToBoxAdapter(child: CategoryHorizontalList()),
              // Safety banner
              const SliverToBoxAdapter(child: SafeTransactionBanner()),
              // Home content sections
              ...switch (vm.homeData) {
                Loading() => [_buildHomeSkeleton()],
                Idle() => [_buildHomeSkeleton()],
                Error(message: final m) => [_buildHomeError(m)],
                Success(data: final d) => [
                  // Featured (thay "Gần bạn")
                  SliverToBoxAdapter(child: ProductSection(
                    title: 'Nổi bật',
                    state: Success(d.featured),
                    onViewAll: () => context.push(AppPaths.search),
                    onProductTap: (id) => vm.goToItemDetail(context, id),
                  )),
                  // Newest
                  SliverToBoxAdapter(child: ProductSection(
                    title: 'Mới đăng',
                    state: Success(d.newest),
                    onViewAll: () => context.push(AppPaths.search),
                    onProductTap: (id) => vm.goToItemDetail(context, id),
                  )),
                  // Popular
                  SliverToBoxAdapter(child: ProductSection(
                    title: 'Phổ biến',
                    state: Success(d.popular),
                    onViewAll: () => context.push(AppPaths.search),
                    onProductTap: (id) => vm.goToItemDetail(context, id),
                  )),
                ],
              },
              // Bottom spacer
              const SliverToBoxAdapter(child: SizedBox(height: 170)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
    );
  }

  Widget _buildHomeSkeleton() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }

  Widget _buildHomeError(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.cloud_off_outlined, size: 40, color: TradeLinkColors.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
