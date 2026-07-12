import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/map_picker_screen.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(),
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatelessWidget {
  const _EditProfileBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditProfileViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Chỉnh sửa hồ sơ'),
      body: switch (vm.loadState) {
        Loading() => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Error(message: final msg) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được hồ sơ',
            message: msg,
            actionLabel: 'Thử lại',
            onAction: vm.load,
          ),
        Success(data: final profile) => _buildForm(context, vm, profile.avatarUrl),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildForm(BuildContext context, EditProfileViewModel vm, String? avatarUrl) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile completion card
          TradeLinkCard(
            padding: const EdgeInsets.all(TradeLinkSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hồ sơ',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '85% hoàn thành',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: TradeLinkColors.successGreen,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TradeLinkSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                  child: LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 6,
                    backgroundColor: TradeLinkColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      TradeLinkColors.successGreen,
                    ),
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.xs),
                Text(
                  'Hoàn thiện hồ sơ giúp tăng độ tin cậy giao dịch',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: TradeLinkColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Avatar (with upload action)
          Center(
            child: GestureDetector(
              onTap: () => _showAvatarPicker(context, vm),
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TradeLinkColors.surfaceContainerHigh,
                      border: Border.all(
                        color: TradeLinkColors.cardBorder,
                        width: 2,
                      ),
                    ),
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_outline,
                              size: 48,
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          )
                        : const Icon(
                            Icons.person_outline,
                            size: 48,
                            color: TradeLinkColors.onSurfaceVariant,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TradeLinkColors.primaryContainer,
                        border: Border.all(color: TradeLinkColors.surface, width: 2),
                      ),
                      child: vm.avatarState is Loading
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Form fields
          TextField(
            controller: TextEditingController(text: vm.name),
            style: theme.textTheme.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: vm.onNameChanged,
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          // Địa chỉ với nút chọn bản đồ
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: vm.address),
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  onChanged: vm.onAddressChanged,
                ),
              ),
              const SizedBox(width: TradeLinkSpacing.xs),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: const Icon(Icons.map_outlined, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: TradeLinkColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<LocationResult>(
                      MaterialPageRoute(
                        builder: (_) => MapPickerScreen(
                          initialLatitude: vm.latitude,
                          initialLongitude: vm.longitude,
                          initialAddress: vm.address,
                        ),
                      ),
                    );
                    if (result != null) {
                      vm.setLocation(result.latitude, result.longitude, result.address);
                    }
                  },
                ),
              ),
            ],
          ),
          if (vm.avatarState is Error) ...[
            const SizedBox(height: TradeLinkSpacing.xs),
            Text(
              (vm.avatarState as Error).message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: TradeLinkColors.error,
              ),
            ),
          ],
          const SizedBox(height: TradeLinkSpacing.xl),
          TradeLinkButton.cta(
            label: 'Lưu thay đổi',
            isLoading: vm.saveState is Loading,
            onPressed: vm.saveState is Loading
                ? null
                : () async {
                    final success = await vm.save();
                    if (success && context.mounted) context.pop();
                  },
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, EditProfileViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TradeLinkColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TradeLinkRadii.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TradeLinkColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: TradeLinkSpacing.md),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await vm.pickAndUploadAvatar(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Chụp ảnh'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await vm.pickAndUploadAvatar(source: ImageSource.camera);
                },
              ),
              const SizedBox(height: TradeLinkSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}