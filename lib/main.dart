// SmartCart – Flutter E-commerce Application

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // ✅ ADD THIS

import 'utils/theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/wishlist_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

import 'viewmodels/theme_viewmodel.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartCartApp());
}

class SmartCartApp extends StatelessWidget {
  const SmartCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp(
            title: 'SmartCart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVM.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

/// Auth-based routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    // Show loading while auth state is being determined
    if (!authVM.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return authVM.user != null ? const HomeScreen() : const LoginScreen();
  }
}