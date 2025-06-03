// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../../ui/pages/main/main_page.dart';
import '../../ui/pages/home/home_screen.dart';
import '../../ui/pages/chat/chat_screen.dart';
import '../../ui/pages/reservations/reservations_screen.dart';
import '../../ui/pages/community/community_screen.dart';
import '../../ui/pages/profile/profile_screen.dart';
import '../../ui/pages/authentication/login_screen.dart';
import '../../ui/pages/authentication/register_screen.dart';

class AppRoutes {
  // Rutas de autenticación
  static const String login = '/login';
  static const String register = '/register';

  static const String main = '/main';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String reservations = '/reservations';
  static const String community = '/community';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    // Rutas de autenticación
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),

    // Rutas de la aplicación principal
    main: (_) => const MainPage(),
    home: (_) => const HomeScreen(),
    chat: (_) => const ChatScreen(),
    reservations: (_) => const ReservationsScreen(),
    community: (_) => const CommunityScreen(),
    profile: (_) => const ProfileScreen(),
  };
}