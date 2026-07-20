import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/wallet_model.dart';
import '../../repositories/admin_repository.dart';
import '../../utils/format.dart';
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

  UiState<List<WithdrawalRequestItem>> _withdrawalsState = const Loading();
  UiState<List<WithdrawalRequestItem>> get withdrawalsState => _withdrawalsState;

  UiState<WalletOverview> _overviewState = const Loading();
  UiState<WalletOverview> get overviewState => _overviewState;

  final Set<String> _processing = {};
  bool isProcessing(String id) => _processing.contains(id);

  _AdminTxVM() {
    load();
    loadWithdrawals();
    loadOverview();
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

  Future<void> loadWithdrawals() async {
    _withdrawalsState = const Loading();
    notifyListeners();
    final res = await _repository.getWithdrawals(status: 'pending');
    switch (res) {
      case ResultSuccess<List<WithdrawalRequestItem>>(:final data):
        _withdrawalsState = Success(data);
      case FailureResult<List<WithdrawalRequestItem>>(:final failure):
        _withdrawalsState = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<void> loadOverview() async {
    _overviewState = const Loading();
    notifyListeners();
    final res = await _repository.getWalletOverview();
    switch (res) {
      case ResultSuccess<WalletOverview>(:final data):
        _overviewState = Success(data);
      case FailureResult<WalletOverview>(:final failure):
        _overviewState = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<bool> approve(String withdrawalId) async {
    _processing.add(withdrawalId);
    notifyListeners();
    final res = await _repository.approveWithdrawal(withdrawalId);
    _processing.remove(withdrawalId);
    if (res is ResultSuccess<bool>) {
      await Future.wait([loadWithdrawals(), loadOverview()]);
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> reject(String withdrawalId, {String? note}) async {
    _processing.add(withdrawalId);
    notifyListeners();
    final res = await _repository.rejectWithdrawal(withdrawalId, note: note);
    _processing.remove(withdrawalId);
    if (res is ResultSuccess<bool>) {
      await Future.wait([loadWithdrawals(), loadOverview()]);
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

    final pendingCount = switch (vm.withdrawalsState) {
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
            Tab(text: pendingCount > 0 ? 'Yêu cầu rút tiền ($pendingCount)' : 'Yêu cầu rút tiền'),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: AdminBottomNav.tabTransactions),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllTransactionsTab(vm: vm),
          _WithdrawalRequestsTab(vm: vm),
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

class _WithdrawalRequestsTab extends StatelessWidget {
  final _AdminTxVM vm;
  const _WithdrawalRequestsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OverviewRow(vm: vm),
        Expanded(
          child: switch (vm.withdrawalsState) {
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
                onAction: vm.loadWithdrawals,
              ),
            Success(:final data) when data.isEmpty => const EmptyState(
                icon: Icons.check_circle_outline,
                title: 'Không có yêu cầu nào',
                message: 'Các yêu cầu rút tiền của người bán sẽ hiển thị ở đây.',
              ),
            Success(:final data) => RefreshIndicator(
                onRefresh: vm.loadWithdrawals,
                child: ListView.separated(
                  padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                  itemCount: data.length,
                  separatorBuilder: (_, _) => const SizedBox(height: TradeLinkSpacing.sm),
                  itemBuilder: (_, i) => _WithdrawalCard(item: data[i], vm: vm),
                ),
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final _AdminTxVM vm;
  const _OverviewRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    final overview = switch (vm.overviewState) {
      Success(data: final d) => d,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TradeLinkSpacing.marginMobile,
        TradeLinkSpacing.md,
        TradeLinkSpacing.marginMobile,
        0,
      ),
      child: Row(
        children: [
          Expanded(child: _OverviewStat(label: 'Tổng số dư ví', value: overview?.totalBalance)),
          const SizedBox(width: TradeLinkSpacing.sm),
          Expanded(child: _OverviewStat(label: 'Đang chờ rút', value: overview?.totalPending)),
          const SizedBox(width: TradeLinkSpacing.sm),
          Expanded(child: _OverviewStat(label: 'Đã rút', value: overview?.totalPaidOut)),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final double? value;
  const _OverviewStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TradeLinkCard(
      padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.sm, vertical: TradeLinkSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: TradeLinkColors.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            value != null ? formatVnd(value) : '—',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  final WithdrawalRequestItem item;
  final _AdminTxVM vm;
  const _WithdrawalCard({required this.item, required this.vm});

  bool get _hasBankInfo => item.bankAccountNumber.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = vm.isProcessing(item.id);

    return TradeLinkCard(
      padding: const EdgeInsets.all(TradeLinkSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.userName ?? 'Không rõ',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TradeLinkText.money(formatVnd(item.amount), size: 'compact'),
            ],
          ),
          if (item.userPhone != null) ...[
            const SizedBox(height: TradeLinkSpacing.xs),
            Text(
              item.userPhone!,
              style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
            ),
          ],
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
                      Text(item.bankName, style: theme.textTheme.bodySmall),
                      Text(
                        'STK: ${item.bankAccountNumber} — ${item.bankAccountHolder}',
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
                          'Thiếu thông tin ngân hàng — liên hệ trực tiếp để xin STK.',
                          style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.error),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          Row(
            children: [
              Expanded(
                child: TradeLinkButton.secondary(
                  label: 'Từ chối',
                  onPressed: isLoading ? null : () => _confirmAndReject(context),
                ),
              ),
              const SizedBox(width: TradeLinkSpacing.sm),
              Expanded(
                flex: 2,
                child: TradeLinkButton.primary(
                  label: isLoading ? 'Đang xử lý...' : 'Duyệt & đã chuyển khoản',
                  fullWidth: true,
                  onPressed: isLoading ? null : () => _confirmAndApprove(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndApprove(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đã chuyển khoản'),
        content: Text(
          'Bạn xác nhận đã tự chuyển ${formatVnd(item.amount)} cho ${item.userName ?? 'người dùng'} '
          '(STK ${item.bankAccountNumber.isNotEmpty ? item.bankAccountNumber : '(chưa có)'}) chưa? '
          'Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final ok = await vm.approve(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Đã duyệt yêu cầu rút tiền' : 'Có lỗi xảy ra, thử lại')),
      );
    }
  }

  Future<void> _confirmAndReject(BuildContext context) async {
    final noteController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối yêu cầu rút tiền'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Số dư sẽ được hoàn lại vào ví người dùng. Vui lòng nhập lý do (tuỳ chọn):'),
            const SizedBox(height: TradeLinkSpacing.sm),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(hintText: 'Lý do từ chối'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Từ chối')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final note = noteController.text.trim();
    final ok = await vm.reject(item.id, note: note.isEmpty ? null : note);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Đã từ chối yêu cầu' : 'Có lỗi xảy ra, thử lại')),
      );
    }
  }
}
