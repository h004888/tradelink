import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui_state.dart' as ui;
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../viewmodels/create_listing_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';

class CreateListingView extends StatelessWidget {
  final Listing? draft;
  const CreateListingView({super.key, this.draft});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateListingViewModel(draft: draft),
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
            onPressed: () async {
              final success = await vm.saveDraft();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lưu nháp thành công!'),
                    backgroundColor: TradeLinkColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.pushReplacement(AppPaths.draftListings);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: TradeLinkColors.actionBlue,
            ),
            child: const Text('Lưu nháp'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: TradeLinkSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sticky-like Progress Header
            Container(
              color: TradeLinkColors.surface,
              padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
              child: Column(
                children: [
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
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Hình ảnh
                  TradeLinkCard(
                    padding: const EdgeInsets.all(TradeLinkSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 20, color: TradeLinkColors.actionBlue),
                            const SizedBox(width: TradeLinkSpacing.sm),
                            Text(
                              'Hình ảnh',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thêm tối đa 8 hình ảnh rõ nét để tăng cơ hội bán/đổi',
                          style: theme.textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: TradeLinkSpacing.md),
                        if (vm.imageError != null) ...[
                          Text(
                            vm.imageError!,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                          ),
                          const SizedBox(height: TradeLinkSpacing.xs),
                        ],
                        _ImagePickerGrid(vm: vm),
                      ],
                    ),
                  ),
                  const SizedBox(height: TradeLinkSpacing.lg),

                  // Section 2: Thông tin cơ bản
                  TradeLinkCard(
                    padding: const EdgeInsets.all(TradeLinkSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20, color: TradeLinkColors.tradeTeal),
                            const SizedBox(width: TradeLinkSpacing.sm),
                            Text(
                              'Thông tin cơ bản',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TradeLinkSpacing.lg),
                        Text(
                          'Hình thức giao dịch',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: TradeLinkColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: TradeLinkSpacing.xs),
                        Row(
                          children: ListingType.values.map((t) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(t == ListingType.sale
                                      ? 'Bán'
                                      : t == ListingType.trade
                                          ? 'Trao đổi'
                                          : 'Cả hai'),
                                ),
                                selected: vm.type == t,
                                onSelected: (_) => vm.setType(t),
                                showCheckmark: false,
                                selectedColor: t == ListingType.sale
                                    ? TradeLinkColors.saleBlue.withValues(alpha: 0.15)
                                    : TradeLinkColors.tradeTeal.withValues(alpha: 0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                                  side: BorderSide(
                                    color: vm.type == t
                                        ? (t == ListingType.sale ? TradeLinkColors.saleBlue : TradeLinkColors.tradeTeal)
                                        : TradeLinkColors.outlineVariant,
                                  ),
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: TradeLinkSpacing.lg),
                        TextField(
                          controller: TextEditingController(text: vm.title),
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Tiêu đề tin đăng',
                            hintText: 'VD: iPhone 15 Pro Max 256GB',
                            errorText: vm.titleError,
                            filled: true,
                            fillColor: TradeLinkColors.surfaceContainerLowest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                              borderSide: const BorderSide(color: TradeLinkColors.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                              borderSide: const BorderSide(color: TradeLinkColors.outlineVariant),
                            ),
                          ),
                          onChanged: vm.setTitle,
                        ),
                        const SizedBox(height: TradeLinkSpacing.md),
                        if (vm.type != ListingType.trade) ...[
                          TextField(
                            controller: TextEditingController(text: vm.price?.toString() ?? ''),
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Giá bán (VNĐ)',
                              hintText: 'VD: 45000000',
                              prefixIcon: const Icon(Icons.monetization_on_outlined),
                              errorText: vm.priceError,
                              filled: true,
                              fillColor: TradeLinkColors.surfaceContainerLowest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                                borderSide: const BorderSide(color: TradeLinkColors.outlineVariant),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: vm.setPrice,
                          ),
                          const SizedBox(height: TradeLinkSpacing.md),
                        ],
                        if (vm.type != ListingType.sale) ...[
                          TextField(
                            controller: TextEditingController(text: vm.exchangeFor),
                            decoration: InputDecoration(
                              labelText: 'Mô tả món đồ muốn đổi lấy',
                              hintText: 'VD: Đổi lấy Samsung S24 Ultra',
                              errorText: vm.exchangeForError,
                              filled: true,
                              fillColor: TradeLinkColors.surfaceContainerLowest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                                borderSide: const BorderSide(color: TradeLinkColors.outlineVariant),
                              ),
                            ),
                            maxLines: 2,
                            onChanged: vm.setExchangeFor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: TradeLinkSpacing.lg),

                  // Section 3: Chi tiết món hàng
                  TradeLinkCard(
                    padding: const EdgeInsets.all(TradeLinkSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, size: 20, color: TradeLinkColors.primaryContainer),
                            const SizedBox(width: TradeLinkSpacing.sm),
                            Text(
                              'Chi tiết món hàng',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TradeLinkSpacing.lg),
                        TextField(
                          controller: TextEditingController(text: vm.description),
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Mô tả chi tiết',
                            hintText: 'Mô tả tình trạng, phụ kiện đi kèm, bảo hành...',
                            errorText: vm.descriptionError,
                            filled: true,
                            fillColor: TradeLinkColors.surfaceContainerLowest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                              borderSide: const BorderSide(color: TradeLinkColors.outlineVariant),
                            ),
                          ),
                          maxLines: 4,
                          onChanged: vm.setDescription,
                        ),
                        const SizedBox(height: TradeLinkSpacing.md),
                        DropdownButtonFormField<String>(
                          value: vm.category,
                          decoration: InputDecoration(
                            labelText: 'Danh mục',
                            filled: true,
                            fillColor: TradeLinkColors.surfaceContainerLowest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                              borderSide: const BorderSide(color: TradeLinkColors.outlineVariant),
                            ),
                          ),
                          items: CreateListingViewModel.categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => vm.setCategory(v!),
                        ),
                        const SizedBox(height: TradeLinkSpacing.md),
                        Text(
                          'Tình trạng',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: TradeLinkColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: TradeLinkSpacing.xs),
                        Wrap(
                          spacing: TradeLinkSpacing.sm,
                          runSpacing: TradeLinkSpacing.xs,
                          children: ItemCondition.values.map((c) => ChoiceChip(
                            label: Text(c == ItemCondition.new_
                                ? 'Mới'
                                : c == ItemCondition.likeNew
                                    ? 'Như mới'
                                    : 'Đã qua sử dụng'),
                            selected: vm.condition == c,
                            onSelected: (_) => vm.setCondition(c),
                            showCheckmark: false,
                            selectedColor: TradeLinkColors.primaryContainer.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TradeLinkRadii.full),
                              side: BorderSide(
                                color: vm.condition == c
                                    ? TradeLinkColors.primaryContainer
                                    : TradeLinkColors.outlineVariant,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TradeLinkSpacing.xl),
                  
                  // Action Button
                  TradeLinkButton.cta(
                    label: 'Đăng tin ngay',
                    icon: Icons.rocket_launch_outlined,
                    isLoading: vm.state is ui.Loading,
                    onPressed: vm.state is ui.Loading ? null : () async {
                      final success = await vm.publish();
                      if (success != null && context.mounted) {
                        vm.reset();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: TradeLinkColors.successGreen, size: 28),
                                const SizedBox(width: 8),
                                const Text('Đăng tin thành công!'),
                              ],
                            ),
                            content: const Text('Món hàng của bạn đã được đưa lên sàn TradeLink. Chúc bạn giao dịch thành công nhé! 🎉'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  if (vm.state is ui.Error) ...[
                    const SizedBox(height: TradeLinkSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(TradeLinkSpacing.sm),
                      decoration: BoxDecoration(
                        color: TradeLinkColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: TradeLinkColors.error, size: 16),
                          const SizedBox(width: TradeLinkSpacing.xs),
                          Expanded(
                            child: Text(
                              (vm.state as ui.Error).message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: TradeLinkColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
  final XFile? file;
  final String? url;
  final VoidCallback onDelete;
  const _ImageThumb({this.file, this.url, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (file != null) {
      if (kIsWeb) {
        img = Image.network(file!.path, fit: BoxFit.cover, width: 100, height: 100);
      } else {
        img = Image.file(File(file!.path), fit: BoxFit.cover, width: 100, height: 100);
      }
    } else if (url != null) {
      img = Image.network(
        url!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (_, _, _) => Container(
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