import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart' as ui;
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/create_listing_viewmodel.dart';

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

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        title: const Text('Đăng tin mới'),
        actions: [
          TextButton(onPressed: vm.saveDraft, child: const Text('Lưu nháp', style: TextStyle(color: TradeLinkColors.actionBlue))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Progress
          LinearProgressIndicator(value: vm.completionPercent / 100, backgroundColor: TradeLinkColors.surfaceContainerHigh, color: TradeLinkColors.successGreen),
          const SizedBox(height: TradeLinkSpacing.xs),
          Text('${vm.completionPercent}% hoàn thành', style: const TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Type selector
          const Text('Hình thức giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: TradeLinkSpacing.xs),
          Row(children: ListingType.values.map((t) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(t == ListingType.sale ? 'Bán' : t == ListingType.trade ? 'Trao đổi' : 'Cả hai'),
              selected: vm.type == t,
              onSelected: (_) => vm.setType(t),
              selectedColor: t == ListingType.sale ? TradeLinkColors.saleBlue.withValues(alpha: 0.15) : TradeLinkColors.tradeTeal.withValues(alpha: 0.15),
            ),
          ))).toList()),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Title
          TextField(
            decoration: const InputDecoration(labelText: 'Tiêu đề', hintText: 'VD: iPhone 15 Pro Max 256GB'),
            onChanged: vm.setTitle,
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          // Price (if sale)
          if (vm.type != ListingType.trade) ...[
            TextField(
              decoration: const InputDecoration(labelText: 'Giá bán (VNĐ)', hintText: 'VD: 45000000', prefixIcon: Icon(Icons.monetization_on_outlined)),
              keyboardType: TextInputType.number,
              onChanged: vm.setPrice,
            ),
            const SizedBox(height: TradeLinkSpacing.md),
          ],
          // Trade description
          if (vm.type != ListingType.sale) ...[
            TextField(
              decoration: const InputDecoration(labelText: 'Mô tả món đồ muốn đổi lấy', hintText: 'VD: Đổi lấy Samsung S24 Ultra'),
              maxLines: 2,
            ),
            const SizedBox(height: TradeLinkSpacing.md),
          ],
          // Description
          TextField(
            decoration: const InputDecoration(labelText: 'Mô tả chi tiết', hintText: 'Mô tả tình trạng, phụ kiện đi kèm...'),
            maxLines: 4, onChanged: vm.setDescription,
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          // Category
          DropdownButtonFormField<String>(
            value: vm.category,
            decoration: const InputDecoration(labelText: 'Danh mục'),
            items: CreateListingViewModel.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => vm.setCategory(v!),
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          // Condition
          Row(children: [
            const Text('Tình trạng: ', style: TextStyle(fontSize: 14)),
            ...ItemCondition.values.map((c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(c == ItemCondition.new_ ? 'Mới' : c == ItemCondition.likeNew ? 'Như mới' : 'Đã qua sử dụng'),
                selected: vm.condition == c,
                onSelected: (_) => vm.setCondition(c),
              ),
            )),
          ]),
          const SizedBox(height: TradeLinkSpacing.xl),
          // Publish button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.state is ui.Loading ? null : () async => await vm.publish(),
              style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.primaryContainer, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.md)),
              child: vm.state is ui.Loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Đăng tin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (vm.state is ui.Error) ...[
            const SizedBox(height: TradeLinkSpacing.xs),
            Text((vm.state as ui.Error).message, style: const TextStyle(color: TradeLinkColors.error, fontSize: 14), textAlign: TextAlign.center),
          ],
        ]),
      ),
    );
  }
}
