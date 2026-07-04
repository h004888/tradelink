import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/draft_listings_viewmodel.dart';

class DraftListingsView extends StatelessWidget {
  const DraftListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => DraftListingsViewModel(), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DraftListingsViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Nháp tin đăng')),
      body: vm.isEmpty
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.note_add_outlined, size: 64, color: TradeLinkColors.outlineVariant),
              SizedBox(height: 16),
              Text('Bạn chưa có tin nháp nào', style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
              Text('Tin nháp được lưu trên thiết bị của bạn', style: TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
              itemCount: vm.drafts.length,
              itemBuilder: (_, i) {
                final d = vm.drafts[i];
                return Dismissible(
                  key: Key(d.id),
                  direction: DismissDirection.endToStart,
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: TradeLinkColors.error, child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) => vm.deleteDraft(i),
                  child: Card(
                    child: ListTile(
                      leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.base)), child: const Icon(Icons.image, color: TradeLinkColors.onSurfaceVariant)),
                      title: Text(d.title.isEmpty ? 'Chưa có tiêu đề' : d.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Đã lưu lúc ${d.createdAt.hour}:${d.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: d.completionPercent / 100, backgroundColor: TradeLinkColors.surfaceContainerHigh),
                        Text('${d.completionPercent}% hoàn thành', style: const TextStyle(fontSize: 10, color: TradeLinkColors.onSurfaceVariant)),
                      ]),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppPaths.createListing),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppPaths.createListing),
        icon: const Icon(Icons.add), label: const Text('Tạo tin mới'),
      ),
    );
  }
}
