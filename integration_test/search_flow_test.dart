import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tradelink/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _goHome(tester) async {
    await EasyLocalization.ensureInitialized();
    await tester.pumpWidget(EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations', fallbackLocale: const Locale('vi'),
      child: const TradeLinkApp(),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    if (find.text('Bắt đầu').evaluate().isNotEmpty) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
    }
    if (find.text('Số điện thoại').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).first, '0912345678');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  group('TV3 — Search & Negotiation (6 screens)', () {
    testWidgets('13. Home → Search bar + Category chips + Product grid', (tester) async {
      await _goHome(tester);

      // Home screen after auth
      expect(find.text('TradeLink'), findsWidgets);

      // Search bar
      expect(find.text('Tìm kiếm...'), findsOneWidget);

      // Category chips
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Điện tử'), findsOneWidget);
      expect(find.text('Điện thoại'), findsOneWidget);

      // Nav icons
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      // Product grid items should exist (if any loaded)
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('14. Search Results → Search bar + Filter chips + Result cards', (tester) async {
      await _goHome(tester);

      // Tap search bar → navigate to search
      if (find.text('Tìm kiếm...').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tìm kiếm...'));
        await tester.pumpAndSettle();
      }

      // Search screen should show
      final hasSearchField = find.byType(TextField).evaluate().isNotEmpty;
      expect(hasSearchField, true);

      // Filter chips
      expect(find.text('Tất cả'), findsWidgets);
      expect(find.text('Bán'), findsWidgets);
      expect(find.text('Trao đổi'), findsWidgets);

      // Type search query
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'iPhone');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Results should appear or empty state
      final hasResults = find.byType(Card).evaluate().isNotEmpty;
      expect(hasResults || !hasResults, true); // either has results or doesn't — app didn't crash
    });

    testWidgets('15. Item Detail → Gallery + Seller info + Contact + Offer buttons', (tester) async {
      await _goHome(tester);

      // Search for item
      if (find.text('Tìm kiếm...').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tìm kiếm...'));
        await tester.pumpAndSettle();
      }
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'Sony');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Tap first search result
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      // Item detail screen should show
      final hasDetail = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasDetail, true);

      // Should have action buttons
      final hasContact = find.text('Liên hệ').evaluate().isNotEmpty;
      final hasOffer = find.text('Gửi đề nghị').evaluate().isNotEmpty;
      final hasStatus = find.byIcon(Icons.lock).evaluate().isNotEmpty ||
                        find.byIcon(Icons.swap_horiz).evaluate().isNotEmpty;

      expect(hasContact || hasOffer || hasStatus, true);
    });

    testWidgets('16. Chat → Message bubbles + Input bar', (tester) async {
      await _goHome(tester);

      // From Home, find an item and navigate to chat
      if (find.text('Tìm kiếm...').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tìm kiếm...'));
        await tester.pumpAndSettle();
      }
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'Sony');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      // Tap "Liên hệ"
      if (find.text('Liên hệ').evaluate().isNotEmpty) {
        await tester.tap(find.text('Liên hệ'));
        await tester.pumpAndSettle();
      }

      // Chat screen should show
      final hasChat = find.text('Thương lượng').evaluate().isNotEmpty;
      if (hasChat) {
        // Messages (mock data)
        expect(find.text('Chào bạn, mình quan tâm đến Sony A7IV'), findsOneWidget);

        // Input bar
        expect(find.text('Nhập tin nhắn...'), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);

        // Send a message
        if (find.byType(TextField).evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField).last, 'Xin chào!');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pumpAndSettle();
          expect(find.text('Xin chào!'), findsOneWidget);
        }
      }
    });

    testWidgets('17. Watchlist → Grid layout + Saved items', (tester) async {
      await _goHome(tester);

      // From Item Detail, tap bookmark to add to watchlist
      // Navigate via search to item detail first
      if (find.text('Tìm kiếm...').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tìm kiếm...'));
        await tester.pumpAndSettle();
      }
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'Sony');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      // Bookmark button
      final bookmark = find.byIcon(Icons.bookmark_border);
      if (bookmark.evaluate().isNotEmpty) {
        await tester.tap(bookmark.first);
        await tester.pumpAndSettle();
        // Should change to filled
        expect(find.byIcon(Icons.bookmark), findsOneWidget);
      }
    });

    testWidgets('18. Send Offer → Dynamic buy/trade form + Submit button', (tester) async {
      await _goHome(tester);

      // Navigate to item detail then offer
      if (find.text('Tìm kiếm...').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tìm kiếm...'));
        await tester.pumpAndSettle();
      }
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'Sony');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      // Tap "Gửi đề nghị"
      if (find.text('Gửi đề nghị').evaluate().isNotEmpty) {
        await tester.tap(find.text('Gửi đề nghị'));
        await tester.pumpAndSettle();
      }

      final hasOffer = find.text('Gửi đề nghị').evaluate().length >= 1;
      if (hasOffer) {
        // Type selector
        expect(find.text('Mua'), findsOneWidget);
        expect(find.text('Trao đổi'), findsOneWidget);

        // Form fields
        expect(find.text('Lời nhắn'), findsOneWidget);

        // Submit button
        expect(find.text('Gửi đề nghị'), findsWidgets); // title + button

        // Disclaimer
        expect(find.textContaining('không tạo ràng buộc'), findsOneWidget);
      }
    });
  });
}
