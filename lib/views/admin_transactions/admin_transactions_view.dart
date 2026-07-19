import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/admin_repository.dart';
import '../../utils/theme.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';

class AdminTransactionsView extends StatelessWidget {
  const AdminTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _AdminTxVM(),
      child: const _Body(),
    );
  }
}

class _AdminTxVM extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  UiState<List<AdminTransactionItem>> _state = const Loading();
  UiState<List<AdminTransactionItem>> get state => _state;

  UiState<List<PendingPayoutItem>> _payoutsState = const Loading();
  UiState<List<PendingPayoutItem>> get payoutsState => _payoutsState;

  final Set<String> _markingPaid = {};
  bool isMarkingPaid(String id) => _markingPaid.contains(id);

  _AdminTxVM() {
    load();
    loadPayouts();
  }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final res = await _repository.getTransactions();
    switch (res) {
      case ResultSuccess<List<AdminTransactionItem>>(:final data):
        _state = Success(data);
      case FailureResult<List<AdminTransactionItem>>(:final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> loadPayouts() async {
    _payoutsState = const Loading();
    notifyListeners();
    final res = await _repository.getPendingPayouts();
    switch (res) {
      case ResultSuccess<List<PendingPayoutItem>>(:final data):
        _payoutsState = Success(data);
      case FailureResult<List<PendingPayoutItem>>(:final failure):
        _payoutsState = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<bool> markPaid(String transactionId) async {
    _markingPaid.add(transactionId);
    notifyListeners();
    final res = await _repository.markPayoutPaid(transactionId);
    _markingPaid.remove(transactionId);
    if (res is ResultSuccess<bool>) {
      await loadPayouts();
      return true;
    }
    notifyListeners();
    return false;
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<_AdminTxVM>();

    final pendingCount = switch (vm.payoutsState) {
      Success(data: final d) => d.length,
      _ => 0,
    };

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        backgroundColor: TradeLinkColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: TradeLinkSpacing.md,
        title: Text(
          'Quản lý giao dịch',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TradeLinkColors.primary,
          unselectedLabelColor: TradeLinkColors.onSurfaceVariant,
          indicatorColor: TradeLinkColors.primary,
          tabs: [
            const Tab(text: 'Tất cả'),
            Tab(text: pendingCount > 0 ? 'Cần thanh toán ($pendingCount)' : 'Cần thanh toán'),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: AdminBottomNav.tabTransactions),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllTransactionsTab(vm: vm),
          _PendingPayoutsTab(vm: vm),
        ],
      ),
    );
  }
}

class _AllTransactionsTab extends StatelessWidget {
  final _AdminTxVM vm;
  const _AllTransactionsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (vm.state) {
      Loading() => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      Error(:final message) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không tải được giao dịch',
          message: message,
          actionLabel: 'Thử lại',
          onAction: vm.load,
        ),
      Success(:final data) when data.isEmpty => const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Chưa có giao dịch',
          message: 'Các giao dịch trên hệ thống sẽ hiển thị ở đây.',
        ),
      Success(:final data) => ListView.separated(
          padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
          itemCount: data.length,
          separatorBuilder: (_, _) => const SizedBox(height: TradeLinkSpacing.sm),
          itemBuilder: (_, i) {
            final t = data[i];
            return TradeLinkCard(
              padding: const EdgeInsets.symmetric(
                horizontal: TradeLinkSpacing.md,
                vertical: TradeLinkSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.listingTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${t.type} • ${t.status} • ${_fmtDate(t.createdAt)}',
                          style: theme.textTheme.labelSmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TradeLinkSpacing.sm),
                  if (t.amount > 0) TradeLinkText.money(_fmtAmount(t.amount), size: 'compact'),
                ],
              ),
            );
          },
        ),
      _ => const SizedBox.shrink(),
    };
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtAmount(double a) {
    if (a <= 0) return '-';
    if (a >= 1e9) return '${(a / 1e9).toStringAsFixed(1)} tỷ';
    if (a >= 1e6) return '${(a / 1e6).toStringAsFixed(1)} tr';
    return a.toStringAsFixed(0);
  }
}

class _PendingPayoutsTab extends StatelessWidget {
  final _AdminTxVM vm;
  const _PendingPayoutsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return switch (vm.payoutsState) {
      Loading() => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      Error(:final message) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không tải được danh sách',
          message: message,
          actionLabel: 'Thử lại',
          onAction: vm.loadPayouts,
        ),
      Success(:final data) when data.isEmpty => const EmptyState(
          icon: Icons.check_circle_outline,
          title: 'Không có gì cần thanh toán',
          message: 'Các giao dịch bán hàng đã hoàn tất, chờ chuyển khoản cho người bán sẽ hiển thị ở đây.',
        ),
      Success(:final data) => RefreshIndicator(
          onRefresh: vm.loadPayouts,
          child: ListView.separated(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: TradeLinkSpacing.sm),
            itemBuilder: (_, i) => _PayoutCard(item: data[i], vm: vm),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PayoutCard extends StatelessWidget {
  final PendingPayoutItem item;
  final _AdminTxVM vm;
  const _PayoutCard({required this.item, required this.vm});

  bool get _hasBankInfo => (item.bankAccountNumber ?? '').isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = vm.isMarkingPaid(item.id);

    return TradeLinkCard(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.listingTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TradeLinkText.money(_fmtAmount(item.amount), size: 'compact'),
            ],
          ),
          const SizedBox(height: TradeLinkSpacing.xs),
          Text(
            'Người bán: ${item.sellerName}${item.sellerPhone != null ? ' • ${item.sellerPhone}' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
          ),
          const SizedBox(height: TradeLinkSpacing.sm),
          Container(
            padding: const EdgeInsets.all(TradeLinkSpacing.sm),
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
            ),
            child: _hasBankInfo
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.bankName ?? 'Ngân hàng', style: theme.textTheme.bodySmall),
                      Text(
                        'STK: ${item.bankAccountNumber} — ${item.bankAccountHolder ?? ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: TradeLinkColors.error),
                      const SizedBox(width: TradeLinkSpacing.xs),
                      Expanded(
                        child: Text(
                          'Người bán chưa nhập thông tin ngân hàng — liên hệ trực tiếp để xin STK.',
                          style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.error),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          TradeLinkButton.primary(
            label: isLoading ? 'Đang xử lý...' : 'Đánh dấu đã chuyển khoản',
            fullWidth: true,
            onPressed: isLoading ? null : () => _confirmAndMarkPaid(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndMarkPaid(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đã chuyển khoản'),
        content: Text(
          'Bạn xác nhận đã tự chuyển ${_fmtAmount(item.amount)}đ cho ${item.sellerName} '
          '(STK ${item.bankAccountNumber ?? '(chưa có)'}) chưa? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final ok = await vm.markPaid(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Đã đánh dấu thanh toán thành công' : 'Có lỗi xảy ra, thử lại')),
      );
    }
  }

  String _fmtAmount(double a) {
    if (a <= 0) return '0';
    return a.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
