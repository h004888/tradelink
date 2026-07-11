import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/ui_state.dart' as ui;
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/create_listing_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';

class CreateListingView extends StatelessWidget {
  const CreateListingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateListingViewModel(),
      child: const _CreateListingBody(),
    );
  }
}

class _CreateListingBody extends StatelessWidget {
  const _CreateListingBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateListingViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Đăng tin mới',
        actions: [
          TextButton(
            onPressed: vm.saveDraft,
            style: TextButton.styleFrom(
              foregroundColor: TradeLinkColors.actionBlue,
            ),
            child: const Text('Lưu nháp'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiến độ đăng tin',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: TradeLinkColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${vm.completionPercent}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: TradeLinkColors.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(TradeLinkRadii.full),
              child: LinearProgressIndicator(
                value: vm.completionPercent / 100,
                minHeight: 6,
                backgroundColor: TradeLinkColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  TradeLinkColors.successGreen,
                ),
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),

            Text(
              'Hình ảnh (tối đa 8 ảnh)',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            _ImagePickerGrid(vm: vm),

            const SizedBox(height: TradeLinkSpacing.lg),
            Text(
              'Hình thức giao dịch',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Row(
              children: ListingType.values.map((t) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(t == ListingType.sale
                        ? 'Bán'
                        : t == ListingType.trade
                            ? 'Trao đổi'
                            : 'Cả hai'),
                    selected: vm.type == t,
                    onSelected: (_) => vm.setType(t),
                    selectedColor: t == ListingType.sale
                        ? TradeLinkColors.saleBlue.withValues(alpha: 0.15)
                        : TradeLinkColors.tradeTeal.withValues(alpha: 0.15),
                  ),
                ),
              )).toList(),
            ),

            const SizedBox(height: TradeLinkSpacing.lg),
            TextField(
              style: theme.textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                hintText: 'VD: iPhone 15 Pro Max 256GB',
              ),
              onChanged: vm.setTitle,
            ),
            const SizedBox(height: TradeLinkSpacing.md),
            if (vm.type != ListingType.trade) ...[
              TextField(
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Giá bán (VNĐ)',
                  hintText: 'VD: 45000000',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
                onChanged: vm.setPrice,
              ),
              const SizedBox(height: TradeLinkSpacing.md),
            ],
            if (vm.type != ListingType.sale) ...[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Mô tả món đồ muốn đổi lấy',
                  hintText: 'VD: Đổi lấy Samsung S24 Ultra',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: TradeLinkSpacing.md),
            ],
            TextField(
              style: theme.textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Mô tả chi tiết',
                hintText: 'Mô tả tình trạng, phụ kiện đi kèm...',
              ),
              maxLines: 4,
              onChanged: vm.setDescription,
            ),
            const SizedBox(height: TradeLinkSpacing.md),
            DropdownButtonFormField<String>(
              value: vm.category,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items: CreateListingViewModel.categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => vm.setCategory(v!),
            ),
            const SizedBox(height: TradeLinkSpacing.md),
            Text(
              'Tình trạng',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Wrap(
              spacing: TradeLinkSpacing.xs,
              children: ItemCondition.values.map((c) => ChoiceChip(
                label: Text(c == ItemCondition.new_
                    ? 'Mới'
                    : c == ItemCondition.likeNew
                        ? 'Như mới'
                        : 'Đã qua sử dụng'),
                selected: vm.condition == c,
                onSelected: (_) => vm.setCondition(c),
              )).toList(),
            ),
            const SizedBox(height: TradeLinkSpacing.xl),
            TradeLinkButton.cta(
              label: 'Đăng tin',
              icon: Icons.send_outlined,
              isLoading: vm.state is ui.Loading,
              onPressed: vm.state is ui.Loading ? null : () async => await vm.publish(),
            ),
            if (vm.state is ui.Error) ...[
              const SizedBox(height: TradeLinkSpacing.sm),
              Text(
                (vm.state as ui.Error).message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: TradeLinkColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImagePickerGrid extends StatelessWidget {
  final CreateListingViewModel vm;
  const _ImagePickerGrid({required this.vm});

  @override
  Widget build(BuildContext context) {
    final urls = vm.imageUrls;
    return SizedBox(
      height: 110,
      child: vm.isUploading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length + 1,
              itemBuilder: (_, i) {
                if (i == urls.length) {
                  return GestureDetector(
                    onTap: () => _showPicker(context),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: TradeLinkSpacing.xs),
                      decoration: BoxDecoration(
                        color: TradeLinkColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                        border: Border.all(
                          color: TradeLinkColors.outlineVariant,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: TradeLinkColors.actionBlue, size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Thêm ảnh',
                            style: TextStyle(
                              fontSize: 12,
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _ImageThumb(
                  file: i < vm.localImages.length ? vm.localImages[i] : null,
                  url: urls[i],
                  onDelete: () => vm.removeImage(i),
                );
              },
            ),
    );
  }

  void _showPicker(BuildContext context) {
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
                onTap: () {
                  Navigator.pop(ctx);
                  vm.pickAndUploadImage(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(ctx);
                  vm.pickAndUploadImage(source: ImageSource.camera);
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

class _ImageThumb extends StatelessWidget {
  final File? file;
  final String? url;
  final VoidCallback onDelete;
  const _ImageThumb({this.file, this.url, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (file != null) {
      img = Image.file(file!, fit: BoxFit.cover, width: 100, height: 100);
    } else if (url != null) {
      img = Image.network(
        url!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (_, __, ___) => Container(
          width: 100,
          height: 100,
          color: TradeLinkColors.surfaceContainer,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      );
    } else {
      img = Container(width: 100, height: 100, color: TradeLinkColors.surfaceContainer);
    }
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: TradeLinkSpacing.xs),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(TradeLinkRadii.md)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          img,
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}