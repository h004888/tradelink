import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';

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
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: switch (vm.loadState) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final msg) => Center(child: Text(msg)),
        Success() => _buildForm(context, vm),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildForm(BuildContext context, EditProfileViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        children: [
          // Profile completion
          Container(
            padding: const EdgeInsets.all(TradeLinkSpacing.md),
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              border: Border.all(color: TradeLinkColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hồ sơ: 85%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: TradeLinkSpacing.xs),
                LinearProgressIndicator(value: 0.85, backgroundColor: TradeLinkColors.surfaceContainerHigh, color: TradeLinkColors.successGreen),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Avatar
          Center(
            child: Stack(
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: TradeLinkColors.surfaceContainerHigh),
                  child: const Icon(Icons.person, size: 48, color: TradeLinkColors.onSurfaceVariant),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: TradeLinkColors.primaryContainer),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Form fields
          TextField(
            controller: TextEditingController(text: vm.name),
            decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline)),
            onChanged: vm.onNameChanged,
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          TextField(
            controller: TextEditingController(text: vm.phone),
            decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined)),
            keyboardType: TextInputType.phone,
            onChanged: vm.onPhoneChanged,
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          TextField(
            controller: TextEditingController(text: vm.address),
            decoration: const InputDecoration(labelText: 'Địa chỉ', prefixIcon: Icon(Icons.location_on_outlined)),
            onChanged: vm.onAddressChanged,
          ),
          const SizedBox(height: TradeLinkSpacing.xl),
          // Settings toggles
          Container(
            padding: const EdgeInsets.all(TradeLinkSpacing.md),
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              border: Border.all(color: TradeLinkColors.cardBorder),
            ),
            child: const Column(
              children: [
                _SettingToggle(icon: Icons.swap_horiz, title: 'Thông báo giao dịch'),
                Divider(),
                _SettingToggle(icon: Icons.chat_outlined, title: 'Thông báo tin nhắn'),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.saveState is Loading ? null : () async {
                final success = await vm.save();
                if (success && context.mounted) context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TradeLinkColors.primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.md),
              ),
              child: vm.saveState is Loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatefulWidget {
  final IconData icon;
  final String title;
  const _SettingToggle({required this.icon, required this.title});

  @override
  State<_SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<_SettingToggle> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(widget.icon, color: TradeLinkColors.onSurfaceVariant, size: 20),
      title: Text(widget.title, style: const TextStyle(fontSize: 16, color: TradeLinkColors.onSurface)),
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      contentPadding: EdgeInsets.zero,
    );
  }
}
