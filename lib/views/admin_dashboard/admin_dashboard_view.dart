import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/admin_dashboard_viewmodel.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(
        title: 'Admin Dashboard',
        subtitle: 'Quản lý hệ thống',
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: AdminBottomNav.tabDashboard),
      body: switch (state) {
        Loading() => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Error(:final message) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được dashboard',
            message: message,
            actionLabel: 'Thử lại',
            onAction: vm.load,
          ),
        Success() => _buildBody(context, vm),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminDashboardViewModel vm) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Đang chờ',
                      value: '${vm.pendingDisputes}',
                      color: TradeLinkColors.escrowAmber,
                    ),
                  ),
                  const SizedBox(width: TradeLinkSpacing.xs),
                  Expanded(
                    child: _StatCard(
                      label: 'Đã xử lý',
                      value: '${vm.data.resolvedToday}',
                      color: TradeLinkColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: TradeLinkSpacing.xs),
                  Expanded(
                    child: _StatCard(
                      label: 'Người dùng',
                      value: '${vm.data.totalUsers}',
                      color: TradeLinkColors.actionBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TradeLinkSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Tin đăng',
                      value: '${vm.data.totalListings}',
                      color: TradeLinkColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: TradeLinkSpacing.xs),
                  Expanded(
                    child: _StatCard(
                      label: 'Giao dịch',
                      value: '${vm.data.totalTransactions}',
                      color: TradeLinkColors.tradeTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: TradeLinkColors.surfaceContainerLowest,
            border: Border(bottom: BorderSide(color: TradeLinkColors.cardDivider)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: TradeLinkColors.primaryContainer,
            unselectedLabelColor: TradeLinkColors.onSurfaceVariant,
            indicatorColor: TradeLinkColors.primaryContainer,
            indicatorWeight: 3,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'Khiếu nại'),
              Tab(text: 'Duyệt tin'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DisputesTab(vm: vm),
              _ModerationTab(vm: vm),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisputesTab extends StatelessWidget {
  final AdminDashboardViewModel vm;
  const _DisputesTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.disputes.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'Không có khiếu nại',
        message: 'Tất cả các khiếu nại đã được xử lý.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      itemCount: vm.disputes.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
        child: _DisputeCard(dispute: vm.disputes[i], vm: vm),
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final dynamic dispute;
  final AdminDashboardViewModel vm;
  const _DisputeCard({required this.dispute, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TradeLinkCard(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TradeLinkSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: TradeLinkColors.saleBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                ),
                child: Text(
                  '#${dispute.id.substring(dispute.id.length - 6)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TradeLinkColors.saleBlue,
                  ),
                ),
              ),
              const Spacer(),
              if (dispute.priority == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TradeLinkSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: TradeLinkColors.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                  ),
                  child: Text(
                    'Cao',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: TradeLinkColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TradeLinkSpacing.xs),
          Text(
            dispute.reason,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (dispute.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dispute.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: TradeLinkColors.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (dispute.attachments.isNotEmpty) ...[
            const SizedBox(height: TradeLinkSpacing.xs),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: dispute.attachments.map((url) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(url, width: 48, height: 48, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 48, height: 48, color: TradeLinkColors.surfaceContainerHigh,
                        child: const Icon(Icons.broken_image_outlined, size: 16),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
          if (dispute.raisedByName != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Từ: ${dispute.raisedByName} • ${dispute.status}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: TradeLinkColors.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: TradeLinkSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: TradeLinkColors.successGreen,
              borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
              child: InkWell(
                onTap: vm.isBusy(dispute.id) ? null : () => _openResolveDialog(context),
                borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.sm),
                  child: Center(
                    child: vm.isBusy(dispute.id)
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Giải quyết',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openResolveDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    String decision = 'release';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Giải quyết khiếu nại'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quyết định', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              RadioListTile<String>(
                value: 'release',
                groupValue: decision,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Giải ngân cho người bán', style: TextStyle(fontSize: 13)),
                onChanged: (v) => setState(() => decision = v!),
              ),
              RadioListTile<String>(
                value: 'refund',
                groupValue: decision,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Hoàn tiền cho người mua', style: TextStyle(fontSize: 13)),
                onChanged: (v) => setState(() => decision = v!),
              ),
              RadioListTile<String>(
                value: 'reject',
                groupValue: decision,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Từ chối khiếu nại (giữ nguyên)', style: TextStyle(fontSize: 13)),
                onChanged: (v) => setState(() => decision = v!),
              ),
              const SizedBox(height: TradeLinkSpacing.sm),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Nội dung giải quyết'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && ctrl.text.isNotEmpty) {
      final success = await vm.resolveDispute(dispute.id, ctrl.text, decision: decision);
      if (!success && context.mounted && vm.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.actionError!)));
      }
    }
  }
}

class _ModerationTab extends StatelessWidget {
  final AdminDashboardViewModel vm;
  const _ModerationTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (vm.data.flaggedListings.isEmpty) {
      return const EmptyState(
        icon: Icons.shield_outlined,
        title: 'Không có tin bị báo cáo',
        message: 'Tất cả tin đăng đều tuân thủ quy định.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      itemCount: vm.data.flaggedListings.length,
      itemBuilder: (_, i) {
        final l = vm.data.flaggedListings[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
          child: TradeLinkCard(
            padding: const EdgeInsets.all(TradeLinkSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: TradeLinkColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: TradeLinkColors.outlineVariant,
                  ),
                ),
                const SizedBox(width: TradeLinkSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l.sellerName ?? "?"} • ${l.flags} báo cáo',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: TradeLinkColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TradeLinkSpacing.xs),
                if (vm.isBusy(l.id))
                  const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: TradeLinkColors.successGreen),
                    tooltip: 'Duyệt — tin hợp lệ',
                    onPressed: () => _moderate(context, vm, l.id, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: TradeLinkColors.error),
                    tooltip: 'Gỡ tin vi phạm',
                    onPressed: () => _moderate(context, vm, l.id, false),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _moderate(BuildContext context, AdminDashboardViewModel vm, String listingId, bool approve) async {
    final ok = await vm.moderateListing(listingId, approve: approve);
    if (!context.mounted) return;
    if (!ok && vm.actionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.actionError!)));
    } else if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Đã duyệt tin đăng' : 'Đã gỡ tin vi phạm')),
      );
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(TradeLinkRadii.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}