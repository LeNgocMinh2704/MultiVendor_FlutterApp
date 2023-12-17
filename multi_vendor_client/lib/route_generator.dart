import 'package:flutter/material.dart';
import 'package:vendor/Pages/delivery_boys.dart';
import 'package:vendor/Widget/welcome.dart';
import 'Pages/about.dart';
import 'Pages/delivery_addresses.dart';
import 'Pages/faq.dart';
import 'Pages/home.dart';
import 'Pages/inbox.dart';
import 'Pages/language_settings.dart';
import 'Pages/login.dart';
import 'Pages/profile.dart';
import 'Pages/bottomnav.dart';
import 'Pages/forgot_password.dart';
import 'Pages/orders.dart';
import 'Pages/signup.dart';
import 'Pages/my_dashboard.dart';
import 'Widget/add_market.dart';
import 'Widget/network.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    // final args = settings.arguments;
    switch (settings.name) {
      case '/bottomNav':
        return MaterialPageRoute(builder: (_) => const BottomNav());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const OnBoardingPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersPage());
      case '/inbox':
        return MaterialPageRoute(builder: (_) => const InboxPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/delivery-addresses':
        return MaterialPageRoute(builder: (_) => const DeliveryAddressesPage());
      case '/wallet':
        return MaterialPageRoute(builder: (_) => const WalletPage());
      case '/about':
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case '/faq':
        return MaterialPageRoute(builder: (_) => const FaqPage());
      case '/language-settings':
        return MaterialPageRoute(builder: (_) => const LanguageSettingsPage());
      case '/network':
        return MaterialPageRoute(builder: (_) => const Network());
      case '/add-market':
        return MaterialPageRoute(builder: (_) => const AddMarket());
      //  case '/market-detail':
      // return MaterialPageRoute(builder: (_) => MarketDetail());
      case '/delivery-boys':
        return MaterialPageRoute(builder: (_) => const DeliveryBoys());
      case '/screenOnboarding':
        return MaterialPageRoute(builder: (_) => const OnBoardingPage());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: SizedBox(height: 0)));
    }
  }
}
