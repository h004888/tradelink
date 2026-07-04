import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../viewmodels/admin_dashboard_viewmodel.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => AdminDashboardViewModel(), child: const _Body());
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
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Stack(children: [
            const Icon(Icons.notifications_outlined),
            Positioned(
              right: 0,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: TradeLinkColors.error),
                child: const Center(child: Text('3', style: TextStyle(fontSize: 10, color: Colors.white))),
              ),
            ),
          ]),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(children: [
        // Stats
        Padding(
          padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
          child: Row(children: [
            _StatCard(label: 'Đang chờ', value: '${vm.pendingDisputes}', color: TradeLinkColors.escrowAmber),
            const SizedBox(width: 8),
            _StatCard(label: 'Đã xử lý', value: '${vm.pendingReviews}', color: TradeLinkColors.successGreen),
            const SizedBox(width: 8),
            _StatCard(label: 'Hôm nay', value: '${vm.resolvedToday}', color: TradeLinkColors.actionBlue),
          ]),
        ),
        // Tabs
        TabBar(controller: _tabController, labelColor: TradeLinkColors.primaryContainer, unselectedLabelColor: TradeLinkColors.onSurfaceVariant, tabs: const [Tab(text: 'Khiếu nại'), Tab(text: 'Duyệt tin')]),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            // Disputes tab
            ListView.builder(
              padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
              itemCount: vm.disputes.length,
              itemBuilder: (_, i) {
                final d = vm.disputes[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: d.type == 'BÁN' ? TradeLinkColors.saleBlue.withValues(alpha: 0.10) : TradeLinkColors.tradeTeal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(TradeLinkRadii.full)), child: Text('#${d.id} ${d.type}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: d.type == 'BÁN' ? TradeLinkColors.saleBlue : TradeLinkColors.tradeTeal))),
                      const Spacer(),
                      if (d.priority) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: TradeLinkColors.error.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(TradeLinkRadii.full)), child: const Text('Cao', style: TextStyle(fontSize: 11, color: TradeLinkColors.error, fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 4),
                    Text('${d.complainant} vs ${d.respondent}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${d.reason} • ${d.time}', style: const TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Chi tiết vụ việc'))),
                  ]),
                );
              },
            ),
            // Moderation tab
            ListView.builder(
              padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
              itemCount: vm.pendingListings.length,
              itemBuilder: (_, i) {
                final l = vm.pendingListings[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.base)), child: const Icon(Icons.image)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${l.seller} • ${l.flags} báo cáo', style: const TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
                      ])),
                    ]),
                    const SizedBox(height: 8),
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: TradeLinkColors.escrowAmber.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(TradeLinkRadii.base)), child: const Text('VI PHẠM TIỀM ẨN: Từ khóa nhạy cảm', style: TextStyle(fontSize: 12, color: TradeLinkColors.escrowAmber))),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.successGreen, foregroundColor: Colors.white), child: const Text('Duyệt tin'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: TradeLinkColors.error, side: const BorderSide(color: TradeLinkColors.error)), child: const Text('Từ chối'))),
                    ]),
                  ]),
                );
              },
            ),
          ]),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(TradeLinkRadii.lg)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ]),
    ),
  );
}
