import 'package:go_router/go_router.dart';

import 'utils/constants.dart';
import 'views/splash/splash_view.dart';
import 'views/onboarding/onboarding_view.dart';
import 'views/login/login_view.dart';
import 'views/otp_verification/otp_verification_view.dart';
import 'views/profile/profile_view.dart';
import 'views/edit_profile/edit_profile_view.dart';
import 'views/create_listing/create_listing_view.dart';
import 'views/my_listings/my_listings_view.dart';
import 'views/edit_listing/edit_listing_view.dart';
import 'views/listing_detail/listing_detail_view.dart';
import 'views/boost_listing/boost_listing_view.dart';
import 'views/draft_listings/draft_listings_view.dart';
import 'views/home/home_view.dart';
import 'views/search_results/search_results_view.dart';
import 'views/item_detail/item_detail_view.dart';
import 'views/chat/chat_view.dart';
import 'views/watchlist/watchlist_view.dart';
import 'views/send_offer/send_offer_view.dart';
import 'views/transaction_sale/transaction_sale_view.dart';
import 'views/transaction_trade/transaction_trade_view.dart';
import 'views/create_order/create_order_view.dart';
import 'views/notifications/notifications_view.dart';
import 'views/dispute/dispute_view.dart';
import 'views/review/review_view.dart';
import 'views/admin_dashboard/admin_dashboard_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.splash,
    routes: [
      // ── TV1: Auth & Profile ──
      GoRoute(path: AppPaths.splash, builder: (_, state) => const SplashView()),
      GoRoute(path: AppPaths.onboarding, builder: (_, state) => const OnboardingView()),
      GoRoute(path: AppPaths.login, builder: (_, state) => const LoginView()),
      GoRoute(path: AppPaths.otpVerification, builder: (_, state) => const OtpVerificationView()),
      GoRoute(path: AppPaths.profile, builder: (_, state) => const ProfileView()),
      GoRoute(path: AppPaths.editProfile, builder: (_, state) => const EditProfileView()),

      // ── TV2: Post Management ──
      GoRoute(path: AppPaths.createListing, builder: (_, state) => const CreateListingView()),
      GoRoute(path: AppPaths.myListings, builder: (_, state) => const MyListingsView()),
      GoRoute(path: '${AppPaths.editListing}/:id', builder: (_, state) => EditListingView(listingId: state.pathParameters['id']!)),
      GoRoute(path: '${AppPaths.listingDetail}/:id', builder: (_, state) => ListingDetailView(listingId: state.pathParameters['id']!)),
      GoRoute(path: '${AppPaths.boostListing}/:id', builder: (_, state) => BoostListingView(listingId: state.pathParameters['id']!)),
      GoRoute(path: AppPaths.draftListings, builder: (_, state) => const DraftListingsView()),

      // ── TV3: Search & Negotiation ──
      GoRoute(path: AppPaths.home, builder: (_, state) => const HomeView()),
      GoRoute(path: AppPaths.search, builder: (_, state) => const SearchResultsView()),
      GoRoute(path: '${AppPaths.itemDetail}/:id', builder: (_, state) => ItemDetailView(itemId: state.pathParameters['id']!)),
      GoRoute(path: '${AppPaths.chat}/:conversationId', builder: (_, state) => ChatView(conversationId: state.pathParameters['conversationId']!)),
      GoRoute(path: AppPaths.watchlist, builder: (_, state) => const WatchlistView()),
      GoRoute(path: '${AppPaths.sendOffer}/:listingId', builder: (_, state) => SendOfferView(listingId: state.pathParameters['listingId']!)),

      // ── TV4: Transactions & Admin ──
      GoRoute(path: '${AppPaths.transactionSale}/:id', builder: (_, state) => TransactionSaleView(transactionId: state.pathParameters['id']!)),
      GoRoute(path: '${AppPaths.transactionTrade}/:id', builder: (_, state) => TransactionTradeView(transactionId: state.pathParameters['id']!)),
      GoRoute(path: '${AppPaths.createOrder}/:listingId', builder: (_, state) => CreateOrderView(listingId: state.pathParameters['listingId']!)),
      GoRoute(path: AppPaths.notifications, builder: (_, state) => const NotificationsView()),
      GoRoute(path: '${AppPaths.dispute}/:transactionId', builder: (_, state) => DisputeView(transactionId: state.pathParameters['transactionId']!)),
      GoRoute(path: '${AppPaths.review}/:transactionId', builder: (_, state) => ReviewView(transactionId: state.pathParameters['transactionId']!)),
      GoRoute(path: AppPaths.admin, builder: (_, state) => const AdminDashboardView()),
    ],
  );
}
