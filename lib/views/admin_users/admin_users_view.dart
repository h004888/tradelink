import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/admin_repository.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => _AdminUsersVM(), child: const _Body());
  }
}

class _AdminUsersVM extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();
  UiState<List<AdminUserItem>> _state = const Loading();
  UiState<List<AdminUserItem>> get state => _state;

  _AdminUsersVM() {
    load();
  }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final res = await _repository.getUsers();
    switch (res) {
      case ResultSuccess<List<AdminUserItem>>(:final data):
        _state = Success(data);
      case FailureResult<List<AdminUserItem>>(:final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }

  Future<bool> create({
    required String email,
    required String name,
    required String password,
    required String role,
  }) async {
    final res = await _repository.createUser(
      email: email,
      name: name,
      password: password,
      role: role,
    );
    if (res is ResultSuccess<AdminUserItem>) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> delete(String userId) async {
    final res = await _repository.deleteUser(userId);
    if (res is ResultSuccess<bool>) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> changeRole(String userId, String role) async {
    final res = await _repository.updateRole(userId, role);
    if (res is ResultSuccess<AdminUserItem>) {
      await load();
      return true;
    }
    return false;
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<_AdminUsersVM>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Quản lý người dùng',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Tạo người dùng',
            onPressed: () => _showCreateDialog(context, vm),
          ),
        ],
      ),
      body: switch (vm.state) {
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
            onAction: vm.load,
          ),
        Success(:final data) when data.isEmpty => const EmptyState(
            icon: Icons.people_outline,
            title: 'Chưa có người dùng',
            message: 'Tạo người dùng đầu tiên để bắt đầu.',
          ),
        Success(:final data) => ListView.separated(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            itemCount: data.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: TradeLinkSpacing.sm),
            itemBuilder: (_, i) {
              final u = data[i];
              return TradeLinkCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: TradeLinkSpacing.md,
                  vertical: TradeLinkSpacing.sm,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          TradeLinkColors.primaryContainer.withValues(alpha: 0.1),
                      child: Text(
                        u.name.isNotEmpty
                            ? u.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: TradeLinkColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: TradeLinkSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${u.email} • ${u.role} • ${u.totalTransactions} GD',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (action) async {
                        if (action == 'delete') {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xóa người dùng?'),
                              content: Text(
                                'Xóa ${u.name}? Hành động này không thể hoàn tác.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Huỷ'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TradeLinkColors.error,
                                  ),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) await vm.delete(u.id);
                        } else if (action == 'promote-buyer') {
                          await vm.changeRole(u.id, 'buyer');
                        } else if (action == 'promote-seller') {
                          await vm.changeRole(u.id, 'seller');
                        } else if (action == 'promote-admin') {
                          await vm.changeRole(u.id, 'admin');
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'promote-buyer',
                          child: Text('Đặt vai trò: Buyer'),
                        ),
                        PopupMenuItem(
                          value: 'promote-seller',
                          child: Text('Đặt vai trò: Seller'),
                        ),
                        PopupMenuItem(
                          value: 'promote-admin',
                          child: Text('Đặt vai trò: Admin'),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Xóa người dùng',
                            style: TextStyle(color: TradeLinkColors.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  void _showCreateDialog(BuildContext context, _AdminUsersVM vm) {
    final emailCtl = TextEditingController();
    final nameCtl = TextEditingController();
    final pwdCtl = TextEditingController();
    String role = 'buyer';
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Tạo người dùng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: nameCtl,
                decoration: const InputDecoration(labelText: 'Họ tên'),
              ),
              TextField(
                controller: pwdCtl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
              ),
              const SizedBox(height: TradeLinkSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                  DropdownMenuItem(value: 'seller', child: Text('Seller')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => role = v ?? 'buyer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final ok = await vm.create(
                  email: emailCtl.text.trim(),
                  name: nameCtl.text.trim(),
                  password: pwdCtl.text,
                  role: role,
                );
                if (ok && context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }
}