import 'package:flutter/material.dart';
import 'package:multi_vendor_user/Pages/category_page.dart';
import 'package:multi_vendor_user/Pages/checkout.dart';
import 'package:multi_vendor_user/Pages/connectivity.dart';
import 'package:multi_vendor_user/Pages/delivery_addresses.dart';
import 'package:multi_vendor_user/Pages/forgot_password.dart';
import 'package:multi_vendor_user/Pages/language_settings.dart';
import 'package:multi_vendor_user/Widgets/wrapper.dart';
import 'Pages/cart_page.dart';
import 'Pages/coupon_page.dart';
import 'Pages/courier.dart';
import 'Pages/faq.dart';
import 'Pages/favorites.dart';
import 'Pages/home_page.dart';
import 'Pages/login_page.dart';
import 'Pages/markets_page.dart';
import 'Pages/notifications.dart';
import 'Pages/onboarding_page.dart';
import 'Pages/orders.dart';
import 'Pages/profile.dart';
import 'Pages/referral_page.dart';
import 'Pages/signup_page.dart';
import 'Pages/wallet_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    // final args = settings.arguments;
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnBoardingPage());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case '/network-error':
        return MaterialPageRoute(builder: (_) => const NetworkError());
      case '/wrapper':
        return MaterialPageRoute(builder: (_) => const Wrapper());
      case '/categories':
        return MaterialPageRoute(builder: (_) => const CategoriesPage());
      case '/markets':
        return MaterialPageRoute(builder: (_) => const MarketsPage());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartPage());
      case '/delivery-address':
        return MaterialPageRoute(builder: (_) => const DeliveryAddressesPage());
      case '/checkout':
        return MaterialPageRoute(builder: (_) => const CheckoutPage());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/favorites':
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case '/referral-page':
        return MaterialPageRoute(builder: (_) => const ReferralPage());
      case '/wallet':
        return MaterialPageRoute(builder: (_) => const WalletPage());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case '/faq':
        return MaterialPageRoute(builder: (_) => const FaqPage());
      case '/language':
        return MaterialPageRoute(builder: (_) => const LanguageSettingsPage());
      case '/coupon':
        return MaterialPageRoute(builder: (_) => const CouponPage());
      case '/courier':
        return MaterialPageRoute(builder: (_) => const CourierPage());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: SizedBox(height: 0)));
    }
  }
}
