class AppConstants {
  AppConstants._();

  static const String appName = 'TradeLink';
  static const String appVersion = '1.0.0';
}

/// Route paths for all 25 screens
class AppPaths {
  AppPaths._();

  // TV1 — Auth & Profile
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // TV2 — Post Management
  static const String createListing = '/listings/create';
  static const String myListings = '/listings/my';
  static const String editListing = '/listings/edit';       // + :id
  static const String listingDetail = '/listings/detail';    // + :id
  static const String boostListing = '/listings/boost';      // + :id
  static const String draftListings = '/listings/drafts';

  // TV3 — Search & Negotiation
  static const String home = '/home';
  static const String search = '/search';
  static const String itemDetail = '/items/detail';          // + :id
  static const String chat = '/chat';                        // + :conversationId
  static const String watchlist = '/watchlist';
  static const String sendOffer = '/offers/send';            // + :listingId

  // TV4 — Transactions & Admin
  static const String transactionSale = '/transactions/sale';    // + :id
  static const String transactionTrade = '/transactions/trade';  // + :id
  static const String createOrder = '/orders/create';            // + :listingId
  static const String notifications = '/notifications';
  static const String dispute = '/disputes';                     // + :transactionId
  static const String review = '/review';                        // + :transactionId
  static const String admin = '/admin';
}

class AppDurations {
  AppDurations._();

  static const Duration splashDelay = Duration(seconds: 2);
  static const Duration otpCountdown = Duration(seconds: 60);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration snackBarDisplay = Duration(seconds: 3);
}
